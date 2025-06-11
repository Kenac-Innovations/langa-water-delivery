package zw.co.kenac.takeu.backend.dto;

import org.springframework.web.multipart.MultipartFile;
import java.util.function.Consumer;

public record DocumentUpload(
    String bucketType,
    MultipartFile file,
    String fieldName,
    Consumer<String> entitySetter
) {} 