/// Dev-project schema: tables, columns, indexes, buckets.
///
/// SDK-free on purpose so it can be unit-tested and printed by `--dry-run`.
/// Source of truth for meaning: docs/database_schema.md and
/// docs/security_rules.md. Everything here is PROPOSED (dev project only).
library;

const adminLabel = 'label:admin';

String _perm(String action, String role) => '$action("$role")';
String _readAny() => _perm('read', 'any');
String _readUsers() => _perm('read', 'users');
String _createUsers() => _perm('create', 'users');
List<String> _adminWrite() => [
      _perm('create', adminLabel),
      _perm('update', adminLabel),
      _perm('delete', adminLabel),
    ];

enum ColType { string, text, integer, float, boolean, datetime, enumeration }

class Col {
  final String key;
  final ColType type;
  final bool required;
  final int? size;
  final num? min;
  final num? max;
  final Object? def;
  final List<String>? elements;
  final bool array;

  const Col._(this.key, this.type,
      {this.required = false,
      this.size,
      this.min,
      this.max,
      this.def,
      this.elements,
      this.array = false});

  const Col.string(String key, int size, {bool required = false, String? def})
      : this._(key, ColType.string, required: required, size: size, def: def);
  const Col.text(String key, {bool required = false})
      : this._(key, ColType.text, required: required);
  const Col.integer(String key,
      {bool required = false, int? min, int? max, int? def})
      : this._(key, ColType.integer,
            required: required, min: min, max: max, def: def);
  const Col.float(String key,
      {bool required = false, double? min, double? max, double? def})
      : this._(key, ColType.float,
            required: required, min: min, max: max, def: def);
  const Col.boolean(String key, {bool required = false, bool? def})
      : this._(key, ColType.boolean, required: required, def: def);
  const Col.datetime(String key, {bool required = false})
      : this._(key, ColType.datetime, required: required);
  const Col.enumeration(String key, List<String> elements,
      {bool required = false, String? def, bool array = false})
      : this._(key, ColType.enumeration,
            required: required, elements: elements, def: def, array: array);
}

class Idx {
  final String key;
  final bool unique;
  final List<String> columns;
  const Idx(this.key, this.columns, {this.unique = false});
}

class TableDef {
  final String id;
  final String name;
  final List<String> permissions;
  final List<Col> columns;
  final List<Idx> indexes;
  const TableDef(this.id, this.name,
      {this.permissions = const [],
      required this.columns,
      this.indexes = const []});
}

class BucketDef {
  final String id;
  final String name;
  final List<String> permissions;
  final bool fileSecurity;
  final int maxBytes;
  final List<String> extensions;
  const BucketDef(this.id, this.name,
      {required this.permissions,
      required this.fileSecurity,
      required this.maxBytes,
      required this.extensions});
}

// Shared value sets (keep in sync with docs/booking_workflow.md).
const vehicleTypes = ['cng', 'car'];
const bookingStatuses = [
  'pending',
  'receiving_offers',
  'confirmed',
  'driver_arriving',
  'ongoing',
  'completed',
  'cancelled',
  'expired',
];
const verificationStatuses = ['pending', 'approved', 'rejected'];

// All ids are Appwrite ids (<= 36 chars).
const _id = 36;

final List<BucketDef> buckets = [
  BucketDef('images', 'Images',
      permissions: [_createUsers()],
      // The ONLY bucket (product decision). Access is decided per file at
      // upload time: avatars get read(any); driver verification photos (D-11)
      // MUST be uploaded with owner-only permissions, never read(any).
      fileSecurity: true,
      maxBytes: 5 * 1024 * 1024,
      extensions: const ['jpg', 'jpeg', 'png', 'webp']),
];

final List<TableDef> tables = [
  // ───────────── Boilerplate tables (README "Appwrite tables") ─────────────
  TableDef('users', 'Users',
      // Table-wide read for logged-in users is the accepted C-25 gap: the apps
      // read the counterpart's phone from here. Must be fixed before release.
      permissions: [_createUsers(), _readUsers()],
      columns: const [
        Col.string('name', 128),
        Col.string('email', 255),
        Col.string('phone', 32),
        Col.string('profile_image_url', 2048),
        // Client-writable today -> privilege-escalation risk (D-21, release blocker).
        Col.string('role', 32, def: 'customer'),
        Col.boolean('is_active', def: true),
      ],
      indexes: const [Idx('idx_email', ['email'])]),
  TableDef('business_setup', 'Business setup',
      permissions: [_readAny(), ..._adminWrite()],
      columns: const [
        Col.string('business_name', 128),
        Col.string('currency_symbol', 8),
        Col.string('store_location', 255),
        Col.float('store_latitude'),
        Col.float('store_longitude'),
        Col.boolean('is_maintenance_mode_on', def: false),
        Col.boolean('is_email_otp_enabled', def: false),
        Col.boolean('is_force_update_active', def: false),
        Col.string('app_min_version', 32),
        Col.string('android_store_url', 512),
        Col.string('ios_store_url', 512),
        Col.string('copyright_text', 255),
        Col.text('cookies_text'),
        Col.string('location_iq_key', 255),
      ]),
  TableDef('store_setup', 'Store setup',
      permissions: [_readAny(), ..._adminWrite()],
      columns: const [
        Col.string('store_name', 128),
        Col.text('description'),
        Col.string('address', 255),
        Col.string('city', 64),
        Col.string('state', 64),
        Col.string('zip_code', 16),
        Col.string('phone', 32),
        Col.string('email', 255),
        Col.string('website', 255),
        Col.string('facebook', 255),
        Col.string('instagram', 255),
        Col.string('twitter', 255),
        Col.string('logo_url', 2048),
        Col.string('cover_url', 2048),
      ]),
  TableDef('privacy_policy', 'Privacy policy',
      permissions: [_readAny(), ..._adminWrite()],
      columns: const [
        Col.text('about_us_html'),
        Col.text('terms_and_conditions_html'),
        Col.text('privacy_policy_html'),
      ]),
  TableDef('addresses', 'Addresses',
      permissions: [_createUsers()], // owner-only rows via row security
      columns: const [
        Col.string('user_id', _id, required: true),
        Col.string('name', 128),
        Col.string('phone', 32),
        Col.string('address_line_1', 255),
        Col.string('address_line_2', 255),
        Col.string('city', 64),
        Col.string('postal_code', 16),
        Col.float('latitude'),
        Col.float('longitude'),
        Col.boolean('is_default', def: false),
      ],
      indexes: const [Idx('idx_user', ['user_id'])]),
  TableDef('notifications', 'Notifications',
      permissions: [_perm('create', adminLabel)], // fn/admin writes, owner reads
      columns: const [
        Col.string('user_id', _id, required: true),
        Col.string('type', 32),
        Col.string('title', 255),
        Col.text('message'),
        Col.string('image_url', 2048),
        Col.string('action_type', 16, def: 'none'),
        Col.string('action_value', 512),
        Col.boolean('is_read', def: false),
        Col.datetime('created_at'),
      ],
      indexes: const [Idx('idx_user', ['user_id'])]),

  // ───────────────────── Product tables (docs/database_schema.md) ──────────
  // Written only by the `api` / `admin` Functions (API key bypasses table
  // permissions). Clients get access through row permissions set by the
  // function at creation time.
  TableDef('driver_profiles', 'Driver profiles',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('driver_id', _id, required: true),
        Col.enumeration('vehicle_type', vehicleTypes, required: true),
        Col.string('vehicle_registration', 32),
        Col.string('license_number', 64),
        Col.enumeration('verification_status', verificationStatuses,
            def: 'pending'),
        Col.string('rejection_reason', 255),
        Col.enumeration('availability_status', ['offline', 'online', 'busy'],
            def: 'offline'),
        Col.datetime('last_location_at'),
        Col.float('rating_avg', min: 0, max: 5),
        Col.integer('rating_count', min: 0, def: 0),
        Col.integer('completed_trip_count', min: 0, def: 0),
      ],
      indexes: const [
        Idx('uniq_driver', ['driver_id'], unique: true),
        Idx('idx_availability',
            ['availability_status', 'vehicle_type', 'verification_status']),
      ]),
  TableDef('driver_documents', 'Driver documents',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('driver_id', _id, required: true),
        Col.enumeration(
            'doc_type', ['nid', 'license', 'vehicle_registration', 'other'],
            required: true),
        Col.string('file_id', _id, required: true),
        Col.enumeration('status', verificationStatuses, def: 'pending'),
        Col.string('reviewed_by', _id),
        Col.datetime('reviewed_at'),
      ],
      indexes: const [Idx('idx_driver', ['driver_id'])]),
  TableDef('driver_locations', 'Driver locations',
      permissions: [_perm('read', adminLabel)],
      // Freshness uses Appwrite's server-set $updatedAt (D-20).
      columns: const [
        Col.string('driver_id', _id, required: true),
        Col.float('latitude', required: true, min: -90, max: 90),
        Col.float('longitude', required: true, min: -180, max: 180),
        Col.float('heading'),
        Col.float('speed'),
        Col.float('accuracy'),
      ],
      indexes: const [Idx('uniq_driver', ['driver_id'], unique: true)]),
  TableDef('route_fare_templates', 'Route fare templates',
      permissions: [_readUsers()],
      columns: const [
        Col.string('route_name', 128, required: true),
        Col.string('origin_name', 128, required: true),
        Col.string('destination_name', 128, required: true),
        Col.float('origin_lat'),
        Col.float('origin_lng'),
        Col.float('destination_lat'),
        Col.float('destination_lng'),
        Col.enumeration('vehicle_type', vehicleTypes, required: true),
        Col.integer('regular_fare', required: true, min: 0),
        Col.text('description'),
        Col.boolean('is_active', def: true),
        Col.boolean('is_featured', def: false),
        Col.string('created_by', _id),
        Col.string('updated_by', _id),
      ],
      indexes: const [
        Idx('uniq_route', ['origin_name', 'destination_name', 'vehicle_type'],
            unique: true),
        Idx('idx_active', ['is_active', 'origin_name']),
      ]),
  TableDef('booking_requests', 'Booking requests',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('passenger_id', _id, required: true),
        Col.enumeration('booking_type', ['regular_route', 'custom'],
            required: true),
        Col.string('route_template_id', _id),
        Col.string('route_name_snapshot', 128),
        Col.integer('regular_fare_snapshot', min: 0),
        Col.enumeration('vehicle_type', vehicleTypes, required: true),
        Col.float('pickup_lat', required: true, min: -90, max: 90),
        Col.float('pickup_lng', required: true, min: -180, max: 180),
        Col.string('pickup_address', 255),
        Col.float('destination_lat', required: true, min: -90, max: 90),
        Col.float('destination_lng', required: true, min: -180, max: 180),
        Col.string('destination_address', 255),
        Col.integer('proposed_fare', required: true, min: 1),
        Col.string('selected_driver_id', _id),
        Col.integer('agreed_fare', min: 1),
        Col.enumeration('status', bookingStatuses, def: 'pending'),
        Col.datetime('expires_at'),
        Col.datetime('confirmed_at'),
        Col.datetime('arriving_at'),
        Col.datetime('started_at'),
        Col.datetime('completed_at'),
        Col.datetime('cancelled_at'),
        Col.string('cancel_reason', 255),
        Col.string('cancelled_by', _id),
        Col.enumeration('cancelled_by_role', ['passenger', 'driver', 'admin']),
        Col.string('idempotency_key', 64, required: true),
      ],
      indexes: const [
        Idx('idx_passenger_status', ['passenger_id', 'status']),
        Idx('idx_status_expiry', ['status', 'expires_at']),
        Idx('idx_driver_status', ['selected_driver_id', 'status']),
        Idx('uniq_idem', ['passenger_id', 'idempotency_key'], unique: true),
      ]),
  TableDef('booking_dispatches', 'Booking dispatches',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('booking_id', _id, required: true),
        Col.string('driver_id', _id, required: true),
        Col.enumeration('status', ['sent', 'responded', 'declined', 'expired'],
            def: 'sent'),
        Col.integer('distance_to_pickup_m', min: 0),
        Col.datetime('sent_at'),
        Col.datetime('responded_at'),
      ],
      indexes: const [
        Idx('uniq_booking_driver', ['booking_id', 'driver_id'], unique: true),
        Idx('idx_driver_status', ['driver_id', 'status']),
      ]),
  TableDef('booking_offers', 'Booking offers',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('booking_id', _id, required: true),
        Col.string('driver_id', _id, required: true),
        Col.integer('offered_fare', required: true, min: 1),
        Col.enumeration('response_type', ['accepted', 'counteroffer'],
            required: true),
        Col.enumeration('status',
            ['active', 'selected', 'rejected', 'expired', 'superseded'],
            def: 'active'),
        Col.datetime('responded_at'),
        Col.string('idempotency_key', 64, required: true),
      ],
      indexes: const [
        Idx('idx_booking_status', ['booking_id', 'status']),
        Idx('idx_booking_driver_status', ['booking_id', 'driver_id', 'status']),
        Idx('uniq_idem', ['driver_id', 'idempotency_key'], unique: true),
      ]),
  TableDef('device_tokens', 'Device tokens',
      permissions: [_createUsers()], // owner-only rows via row security
      columns: const [
        Col.string('user_id', _id, required: true),
        Col.enumeration('platform', ['android', 'ios', 'web'], required: true),
        Col.string('push_token', 512, required: true),
        Col.boolean('is_active', def: true),
      ],
      indexes: const [Idx('idx_user_active', ['user_id', 'is_active'])]),
  TableDef('business_settings', 'Business settings',
      permissions: [_readUsers()],
      columns: const [
        Col.string('business_name', 128),
        Col.string('support_phone', 32),
        Col.string('support_email', 255),
        Col.string('currency_code', 8, def: 'BDT'),
        Col.enumeration('enabled_vehicle_types', vehicleTypes, array: true),
        // Radii are kilometres.
        Col.float('default_search_radius', min: 0.1, def: 3),
        Col.float('max_search_radius', min: 0.1, def: 10),
        Col.integer('booking_expiry_seconds', min: 30, def: 300),
        Col.integer('driver_location_freshness_seconds', min: 5, def: 60),
        Col.integer('min_fare_cng', min: 0),
        Col.integer('max_fare_cng', min: 0),
        Col.integer('min_fare_car', min: 0),
        Col.integer('max_fare_car', min: 0),
        Col.string('updated_by', _id),
      ]),
  TableDef('conversations', 'Conversations',
      columns: const [
        Col.string('booking_id', _id, required: true),
        Col.string('passenger_id', _id, required: true),
        Col.string('driver_id', _id, required: true),
        Col.enumeration('status', ['active', 'closed'], def: 'active'),
        Col.datetime('last_message_at'),
      ],
      indexes: const [
        Idx('uniq_booking', ['booking_id'], unique: true),
        Idx('idx_passenger', ['passenger_id']),
        Idx('idx_driver', ['driver_id']),
      ]),
  TableDef('messages', 'Messages',
      columns: const [
        Col.string('conversation_id', _id, required: true),
        Col.string('sender_id', _id, required: true),
        Col.enumeration('message_type', ['text'], def: 'text'),
        Col.string('content', 2000, required: true),
        Col.datetime('read_at'),
        Col.string('idempotency_key', 64, required: true),
      ],
      indexes: const [
        Idx('idx_conversation', ['conversation_id']),
        Idx('uniq_idem', ['sender_id', 'idempotency_key'], unique: true),
      ]),
  TableDef('ratings', 'Ratings',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('booking_id', _id, required: true),
        Col.string('driver_id', _id, required: true),
        Col.string('passenger_id', _id, required: true),
        Col.integer('stars', required: true, min: 1, max: 5),
        Col.string('comment', 500),
        Col.boolean('is_hidden', def: false),
        Col.string('idempotency_key', 64, required: true),
      ],
      indexes: const [
        Idx('uniq_booking_passenger', ['booking_id', 'passenger_id'],
            unique: true),
        Idx('idx_driver', ['driver_id']),
      ]),
  TableDef('admin_audit_logs', 'Admin audit logs',
      permissions: [_perm('read', adminLabel)],
      columns: const [
        Col.string('admin_id', _id, required: true),
        Col.string('action', 64, required: true),
        Col.string('target_type', 64, required: true),
        Col.string('target_id', _id, required: true),
        Col.string('reason', 500),
        Col.text('before_json'),
        Col.text('after_json'),
      ],
      indexes: const [
        Idx('idx_admin', ['admin_id']),
        Idx('idx_target', ['target_type', 'target_id']),
      ]),
];
