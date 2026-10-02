class NetworkResponse<T> {
  final int currentPage;
  final int resultsPerPage;
  final int totalPages;
  final int totalResults;
  final List<T> items;
  final bool empty;

  const NetworkResponse({
    required this.currentPage,
    required this.resultsPerPage,
    required this.totalPages,
    required this.totalResults,
    required this.items,
    required this.empty,
  });
}
