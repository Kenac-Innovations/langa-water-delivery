package zw.co.kenac.takeu.backend.dto;

public record CustomPagination(
        Long total,
        int totalPages,
        int pageNumber,
        int pageSize
) { }
