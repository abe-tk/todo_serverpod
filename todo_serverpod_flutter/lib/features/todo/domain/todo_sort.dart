enum TodoSortField {
  createdAt('createdAt', '作成日'),
  updatedAt('updatedAt', '更新日'),
  dueDate('dueDate', '期限日');

  const TodoSortField(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum TodoSortOrder {
  asc('asc', '昇順'),
  desc('desc', '降順');

  const TodoSortOrder(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
