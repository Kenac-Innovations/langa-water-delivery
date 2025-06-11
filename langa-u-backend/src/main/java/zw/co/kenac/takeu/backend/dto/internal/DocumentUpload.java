package zw.co.kenac.takeu.backend.dto.internal;

import org.springframework.web.multipart.MultipartFile;

 record DocumentUpload(String bucketType, MultipartFile file, String fieldName,
                              java.util.function.Consumer<String> entitySetter) {}