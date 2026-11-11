// Creates the dev-project buckets, tables, columns and indexes.
//
//   APPWRITE_API_KEY=... dart run bin/setup.dart            # real run
//   dart run bin/setup.dart --dry-run                       # prints the plan, no network, no key
//
// Safe to re-run: existing buckets/tables/columns/indexes are skipped. It never
// deletes or alters anything. See README.md for the required API-key scopes.
import 'dart:io';

import 'package:appwrite_setup/schema.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart' as enums;

// Hard guard: this script only ever runs against the shared DEV project.
const _devProjectId = '6af42d370036f3d1cf4d';
const _endpoint = 'https://sgp.cloud.appwrite.io/v1';
const _databaseId = '6af42f2d0018ed2e149a';

final _failures = <String>[];

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final onlyArg = args.where((a) => a.startsWith('--only=')).toList();
  final only = onlyArg.isEmpty ? null : onlyArg.first.substring(7).split(',');
  final selected =
      tables.where((t) => only == null || only.contains(t.id)).toList();

  if (dryRun) {
    _printPlan(selected);
    return;
  }

  final key = Platform.environment['APPWRITE_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('APPWRITE_API_KEY is not set. Export it in this shell only '
        '(never commit it), then re-run. Use --dry-run to preview.');
    exit(64);
  }

  final client = Client()
      .setEndpoint(_endpoint)
      .setProject(_devProjectId) // fixed: refuses any other project
      .setKey(key);
  final db = TablesDB(client);
  final storage = Storage(client);

  try {
    final d = await db.get(databaseId: _databaseId);
    stdout.writeln('Database OK: ${d.name} (${d.$id})');
  } on AppwriteException catch (e) {
    stderr.writeln('Cannot read database $_databaseId: ${e.message} '
        '(code ${e.code}). Check the key scopes and the database id.');
    exit(65);
  }

  for (final b in buckets) {
    await _ensureBucket(storage, b);
  }
  for (final t in selected) {
    await _ensureTable(db, t);
  }

  // Indexes are built asynchronously; wait and surface failures (a failed
  // unique index is how we learn a capability is unsupported).
  for (final t in selected) {
    await _waitIndexes(db, t);
  }

  stdout.writeln('\n==== Summary ====');
  if (_failures.isEmpty) {
    stdout.writeln('All ${selected.length} tables and ${buckets.length} '
        'buckets are in place.');
  } else {
    stdout.writeln('${_failures.length} problem(s):');
    for (final f in _failures) {
      stdout.writeln('  - $f');
    }
    exit(1);
  }
}

void _printPlan(List<TableDef> selected) {
  stdout.writeln('DRY RUN — no network calls.');
  stdout.writeln('Project $_devProjectId  Database $_databaseId\n');
  for (final b in buckets) {
    stdout.writeln('bucket ${b.id}  perms=${b.permissions}  '
        'fileSecurity=${b.fileSecurity}  max=${b.maxBytes}B');
  }
  for (final t in selected) {
    stdout.writeln('\ntable ${t.id}  perms=${t.permissions}  rowSecurity=true');
    stdout.writeln('  ${t.columns.length} columns, ${t.indexes.length} indexes');
    for (final i in t.indexes) {
      stdout.writeln(
          '  ${i.unique ? 'UNIQUE' : 'index '} ${i.key}: ${i.columns.join(', ')}');
    }
  }
  final cols = selected.fold<int>(0, (s, t) => s + t.columns.length);
  final uniq = selected
      .fold<int>(0, (s, t) => s + t.indexes.where((i) => i.unique).length);
  stdout.writeln('\nTotal: ${selected.length} tables, $cols columns, '
      '$uniq unique indexes, ${buckets.length} buckets.');
}

Future<void> _ensureBucket(Storage storage, BucketDef b) async {
  try {
    await storage.getBucket(bucketId: b.id);
    stdout.writeln('bucket ${b.id}: exists, skipped');
    return;
  } on AppwriteException catch (e) {
    if (e.code != 404) return _fail('bucket ${b.id}', e);
  }
  try {
    await storage.createBucket(
      bucketId: b.id,
      name: b.name,
      permissions: b.permissions,
      fileSecurity: b.fileSecurity,
      maximumFileSize: b.maxBytes,
      allowedFileExtensions: b.extensions,
    );
    stdout.writeln('bucket ${b.id}: created');
  } on AppwriteException catch (e) {
    _fail('bucket ${b.id}', e);
  }
}

Future<void> _ensureTable(TablesDB db, TableDef t) async {
  var exists = true;
  try {
    await db.getTable(databaseId: _databaseId, tableId: t.id);
  } on AppwriteException catch (e) {
    if (e.code != 404) return _fail('table ${t.id}', e);
    exists = false;
  }
  if (!exists) {
    try {
      await db.createTable(
        databaseId: _databaseId,
        tableId: t.id,
        name: t.name,
        permissions: t.permissions,
        rowSecurity: true,
      );
      stdout.writeln('table ${t.id}: created');
    } on AppwriteException catch (e) {
      return _fail('table ${t.id}', e);
    }
  } else {
    stdout.writeln('table ${t.id}: exists (adding anything missing)');
  }

  final have = await _columnKeys(db, t.id);
  var added = 0;
  for (final c in t.columns) {
    if (have.contains(c.key)) continue;
    try {
      await _createColumn(db, t.id, c);
      added++;
    } on AppwriteException catch (e) {
      _fail('column ${t.id}.${c.key}', e);
    }
  }
  if (added > 0) stdout.writeln('  +$added columns');

  if (!await _waitColumns(db, t.id)) return; // indexes need available columns

  final haveIdx = (await db.listIndexes(
          databaseId: _databaseId,
          tableId: t.id,
          queries: [Query.limit(100)]))
      .indexes
      .map((i) => i.key)
      .toSet();
  var idxAdded = 0;
  for (final i in t.indexes) {
    if (haveIdx.contains(i.key)) continue;
    try {
      await db.createIndex(
        databaseId: _databaseId,
        tableId: t.id,
        key: i.key,
        type: i.unique ? enums.IndexType.unique : enums.IndexType.key,
        columns: i.columns,
      );
      idxAdded++;
    } on AppwriteException catch (e) {
      _fail('index ${t.id}.${i.key}${i.unique ? ' (UNIQUE)' : ''}', e);
    }
  }
  if (idxAdded > 0) stdout.writeln('  +$idxAdded indexes (building)');
}

Future<Set<String>> _columnKeys(TablesDB db, String tableId) async {
  final r = await db.listColumns(
      databaseId: _databaseId, tableId: tableId, queries: [Query.limit(500)]);
  return r.columns.map((c) => (c as Map)['key'] as String).toSet();
}

Future<void> _createColumn(TablesDB db, String t, Col c) {
  switch (c.type) {
    case ColType.string:
      return db.createStringColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          size: c.size!,
          xrequired: c.required,
          xdefault: c.def as String?);
    case ColType.text:
      return db.createTextColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          xrequired: c.required);
    case ColType.integer:
      return db.createIntegerColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          xrequired: c.required,
          min: c.min?.toInt(),
          max: c.max?.toInt(),
          xdefault: c.def as int?);
    case ColType.float:
      return db.createFloatColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          xrequired: c.required,
          min: c.min?.toDouble(),
          max: c.max?.toDouble(),
          xdefault: (c.def as num?)?.toDouble());
    case ColType.boolean:
      return db.createBooleanColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          xrequired: c.required,
          xdefault: c.def as bool?);
    case ColType.datetime:
      return db.createDatetimeColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          xrequired: c.required);
    case ColType.enumeration:
      return db.createEnumColumn(
          databaseId: _databaseId,
          tableId: t,
          key: c.key,
          elements: c.elements!,
          xrequired: c.required,
          xdefault: c.def as String?,
          array: c.array ? true : null);
  }
}

/// Columns are created asynchronously; returns false if any failed/stuck.
Future<bool> _waitColumns(TablesDB db, String tableId) async {
  final deadline = DateTime.now().add(const Duration(minutes: 3));
  while (DateTime.now().isBefore(deadline)) {
    final r = await db.listColumns(
        databaseId: _databaseId,
        tableId: tableId,
        queries: [Query.limit(500)]);
    final cols = r.columns.cast<Map>();
    final bad = cols.where((c) => c['status'] == 'failed' || c['status'] == 'stuck');
    if (bad.isNotEmpty) {
      for (final c in bad) {
        _failures.add('column $tableId.${c['key']} is ${c['status']}: ${c['error']}');
      }
      return false;
    }
    if (cols.every((c) => c['status'] == 'available')) return true;
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  _failures.add('table $tableId: columns still processing after 3 minutes');
  return false;
}

Future<void> _waitIndexes(TablesDB db, TableDef t) async {
  if (t.indexes.isEmpty) return;
  final deadline = DateTime.now().add(const Duration(minutes: 3));
  while (DateTime.now().isBefore(deadline)) {
    final r = await db.listIndexes(
        databaseId: _databaseId, tableId: t.id, queries: [Query.limit(100)]);
    final bad = r.indexes.where((i) => i.status == 'failed' || i.status == 'stuck');
    if (bad.isNotEmpty) {
      for (final i in bad) {
        _failures.add('index ${t.id}.${i.key} is ${i.status}: ${i.error}');
      }
      return;
    }
    if (r.indexes.every((i) => i.status == 'available')) {
      stdout.writeln('table ${t.id}: indexes available');
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  _failures.add('table ${t.id}: indexes still processing after 3 minutes');
}

void _fail(String what, AppwriteException e) {
  final msg = '$what: ${e.message} (code ${e.code}, ${e.type})';
  _failures.add(msg);
  stderr.writeln('FAILED $msg');
}
