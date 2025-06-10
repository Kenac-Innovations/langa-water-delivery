class Pagination {
  final int total;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  Pagination({
    required this.total,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      totalPages: json['totalPages'] ?? json['pages'],
      pageNumber: json['pageNumber'] ?? json['page'],
      pageSize: json['pageSize'] ?? json['limit'],
    );
  }
}