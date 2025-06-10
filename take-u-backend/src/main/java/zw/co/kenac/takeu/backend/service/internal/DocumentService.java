/*
 * Created by kudzaimacheyo
 * Date: 15/5/2025
 * Time: 07:45
 * Email: kudzaim@kenac.co.zw
 */
package zw.co.kenac.takeu.backend.service.internal;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

public interface DocumentService {

    String uploadDocument(String bucketType, MultipartFile file) throws Exception;

    InputStream getDocument(String bucketType, String filename) throws Exception;

    void deleteDocument(String bucketType, String filename) throws Exception;

    String getDocumentUrl(String bucketType, String filename, int expirySeconds) throws Exception;
}