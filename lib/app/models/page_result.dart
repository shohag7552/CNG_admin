/// One page of a server-paginated list. [total] is the match count across all
/// pages (used for "showing x of y" and the load-more button).
class PageResult<T> {
  final List<T> items;
  final int total;

  const PageResult(this.items, this.total);
}
