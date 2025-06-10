import 'package:langas_user/dto/delivery_dto.dart';

class PaginatedResponse<T> {
  final List<T> content;
  final PaginationDto pagination;

  PaginatedResponse({required this.content, required this.pagination});
}
