package zw.co.kenac.takeu.backend.mapper;

import org.springframework.data.domain.Page;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;

public class PaginationMapper {

    public static <T> PaginatedResponse<T> toPaginatedResponse(Page<T> page) {
        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber(),
                page.getSize()
        );

        return new PaginatedResponse<>(page.getContent(), pagination);
    }

}
