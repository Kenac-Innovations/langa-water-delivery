class PaginationDto {
  final int total;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  PaginationDto({
    required this.total,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? json['pages'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? json['limit'] as int? ?? 0,
    );
  }
}
