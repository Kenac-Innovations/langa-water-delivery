package zw.co.kenac.takeu.backend.mailer.templates;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 5/14/2025
 */
@Getter
@Component
public class MailTemplates {
    @Value("${app.logo-url}")
    private String logoUrl;

    public static String generateOtpVerificationTemplate(String name, String otp) {
        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                "    <title>OTP Verification</title>\n" +
                "    <style>\n" +
                "        body {\n" +
                "            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "            background-color: #f4f4f4;\n" +
                "        }\n" +
                "        .container {\n" +
                "            max-width: 600px;\n" +
                "            margin: 0 auto;\n" +
                "            padding: 20px;\n" +
                "        }\n" +
                "        .header {\n" +
                "            background-color: #ebedf0;\n" +
                "            padding: 20px;\n" +
                "            text-align: center;\n" +
                "            border-top-left-radius: 5px;\n" +
                "            border-top-right-radius: 5px;\n" +
                "        }\n" +
                "        .header img {\n" +
                "            max-width: 150px;\n" +
                "        }\n" +
                "        .content {\n" +
                "            background-color: #ffffff;\n" +
                "            padding: 30px;\n" +
                "            border-bottom-left-radius: 5px;\n" +
                "            border-bottom-right-radius: 5px;\n" +
                "            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n" +
                "        }\n" +
                "        .otp-container {\n" +
                "            margin: 30px 0;\n" +
                "            text-align: center;\n" +
                "        }\n" +
                "        .otp-code {\n" +
                "            font-size: 32px;\n" +
                "            letter-spacing: 5px;\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "            padding: 10px 20px;\n" +
                "            background-color: #f8f8f8;\n" +
                "            border-radius: 5px;\n" +
                "            border: 1px dashed #ccc;\n" +
                "            display: inline-block;\n" +
                "        }\n" +
                "        .expiry-note {\n" +
                "            background-color: #f8f8f8;\n" +
                "            padding: 10px 15px;\n" +
                "            border-radius: 5px;\n" +
                "            margin: 20px 0;\n" +
                "            font-size: 14px;\n" +
                "            color: #555;\n" +
                "        }\n" +
                "        .footer {\n" +
                "            margin-top: 20px;\n" +
                "            color: #666;\n" +
                "            font-size: 14px;\n" +
                "        }\n" +
                "        .company-name {\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <div class=\"container\">\n" +
                "        <div class=\"header\">\n" +
                "            <img src=\"${logoUrl}\" alt=\"Take U Logo\">\n" +
                "        </div>\n" +
                "        <div class=\"content\">\n" +
                "            <p>Dear <strong>" + name + "</strong>,</p>\n" +
                "            <p>Thank you for choosing Take U Service. To complete your account verification, please use the following One-Time Password (OTP):</p>\n" +
                "            \n" +
                "            <div class=\"otp-container\">\n" +
                "                <p>Your verification code is:</p>\n" +
                "                <div class=\"otp-code\">" + otp + "</div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"expiry-note\">\n" +
                "                <strong>Note:</strong> This OTP will expire in 15 minutes after arrival for security purposes.\n" +
                "            </div>\n" +
                "            \n" +
                "            <p>If you did not request this verification, please ignore this email or contact our support team if you have concerns.</p>\n" +
                "            \n" +
                "            <div class=\"footer\">\n" +
                "                <p>Best regards,<br>\n" +
                "                <span class=\"company-name\">Take U Service</span><br>\n" +
                "             </p>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "    </div>\n" +
                "</body>\n" +
                "</html>";
    }

    public static String generateAccountCreationTemplate(String name, String email, String mobile, String password) {
        return String.format(
                "Dear %s,\n\n" +
                        "Please find your Account Details below:\n\n" +
                        "Login ID :: %s or %s.\n\n" +
                        "Password :: %s.\n\n" +
                        "Please change your password after signing in to your account.\n\n" +
                        "Best regards,\n" +
                        "Take U Service",
                name,
                email,
                mobile,
                password
        );
    }
    public static String generateDeliveryCompletionOtpTemplate(String name, String otp, DeliveryEntity delivery) {
        String pickupAddress = delivery.getPickupLocation().getPickupLocation();
        String dropOffAddress = delivery.getDropOffLocation().getDropOffLocation();
        String dropOffContactName = delivery.getDropOffLocation().getDropOffContactName();

        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                "    <title>Delivery Completion OTP</title>\n" +
                "    <style>\n" +
                "        body {\n" +
                "            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "            background-color: #f4f4f4;\n" +
                "        }\n" +
                "        .container {\n" +
                "            max-width: 600px;\n" +
                "            margin: 0 auto;\n" +
                "            padding: 20px;\n" +
                "        }\n" +
                "        .header {\n" +
                "            background-color: #ebedf0;\n" +
                "            padding: 20px;\n" +
                "            text-align: center;\n" +
                "            border-top-left-radius: 5px;\n" +
                "            border-top-right-radius: 5px;\n" +
                "        }\n" +
                "        .header img {\n" +
                "            max-width: 150px;\n" +
                "        }\n" +
                "        .content {\n" +
                "            background-color: #ffffff;\n" +
                "            padding: 30px;\n" +
                "            border-bottom-left-radius: 5px;\n" +
                "            border-bottom-right-radius: 5px;\n" +
                "            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n" +
                "        }\n" +
                "        .otp-container {\n" +
                "            margin: 30px 0;\n" +
                "            text-align: center;\n" +
                "        }\n" +
                "        .otp-code {\n" +
                "            font-size: 32px;\n" +
                "            letter-spacing: 5px;\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "            padding: 10px 20px;\n" +
                "            background-color: #f8f8f8;\n" +
                "            border-radius: 5px;\n" +
                "            border: 1px dashed #ccc;\n" +
                "            display: inline-block;\n" +
                "        }\n" +
                "        .delivery-details {\n" +
                "            background-color: #f8f8f8;\n" +
                "            padding: 15px;\n" +
                "            border-radius: 5px;\n" +
                "            margin: 20px 0;\n" +
                "        }\n" +
                "        .detail-row {\n" +
                "            margin-bottom: 10px;\n" +
                "        }\n" +
                "        .detail-label {\n" +
                "            font-weight: bold;\n" +
                "            color: #555;\n" +
                "        }\n" +
                "        .expiry-note {\n" +
                "            background-color: #f8f8f8;\n" +
                "            padding: 10px 15px;\n" +
                "            border-radius: 5px;\n" +
                "            margin: 20px 0;\n" +
                "            font-size: 14px;\n" +
                "            color: #555;\n" +
                "        }\n" +
                "        .footer {\n" +
                "            margin-top: 20px;\n" +
                "            color: #666;\n" +
                "            font-size: 14px;\n" +
                "        }\n" +
                "        .company-name {\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <div class=\"container\">\n" +
                "        <div class=\"header\">\n" +
                "            <img src=\"${logoUrl}\" alt=\"Take U Logo\">\n" +
                "        </div>\n" +
                "        <div class=\"content\">\n" +
                "            <p>Dear <strong>" + name + "</strong>,</p>\n" +
                "            <p>Your delivery is ready for completion. Please provide the following One-Time Password (OTP) to the delivery personnel to confirm receipt:</p>\n" +
                "            \n" +
                "            <div class=\"otp-container\">\n" +
                "                <p>Delivery Completion OTP:</p>\n" +
                "                <div class=\"otp-code\">" + otp + "</div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"delivery-details\">\n" +
                "                <p><strong>Delivery Details</strong></p>\n" +
                "                <div class=\"detail-row\">\n" +
                "                    <span class=\"detail-label\">From:</span> " + pickupAddress + "\n" +
                "                </div>\n" +
                "                <div class=\"detail-row\">\n" +
                "                    <span class=\"detail-label\">To:</span> " + dropOffAddress + "\n" +
                "                </div>\n" +
                "                <div class=\"detail-row\">\n" +
                "                    <span class=\"detail-label\">Recipient:</span> " + dropOffContactName + "\n" +
                "                </div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <p>For security purposes, please do not share this OTP with anyone other than the authorized delivery personnel.</p>\n" +
                "            \n" +
                "            <div class=\"footer\">\n" +
                "                <p>Thank you for choosing our service,<br>\n" +
                "                <span class=\"company-name\">Take U Service</span><br>\n" +
                "             </p>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "    </div>\n" +
                "</body>\n" +
                "</html>";
    }
    public static String generateDeliveryCompletionTemplate(String name, DeliveryEntity delivery) {
        String pickupAddress = delivery.getPickupLocation().getPickupLocation();
        String dropOffAddress = delivery.getDropOffLocation().getDropOffLocation();
        String dropOffContactName = delivery.getDropOffLocation().getDropOffContactName();
        String deliveryDate = delivery.getDeliveryDate().toString();
        String priceAmount = delivery.getPriceAmount().toString();
        String currency = delivery.getPayment().getCurrency();
        String deliveryId = delivery.getEntityId().toString();

        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                "    <title>Delivery Completion Receipt</title>\n" +
                "    <style>\n" +
                "        body {\n" +
                "            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "            background-color: #f4f4f4;\n" +
                "        }\n" +
                "        .container {\n" +
                "            max-width: 600px;\n" +
                "            margin: 0 auto;\n" +
                "            padding: 20px;\n" +
                "        }\n" +
                "        .header {\n" +
                "            background-color: #ebedf0;\n" +
                "            padding: 20px;\n" +
                "            text-align: center;\n" +
                "            border-top-left-radius: 5px;\n" +
                "            border-top-right-radius: 5px;\n" +
                "        }\n" +
                "        .header img {\n" +
                "            max-width: 150px;\n" +
                "        }\n" +
                "        .content {\n" +
                "            background-color: #ffffff;\n" +
                "            padding: 30px;\n" +
                "            border-bottom-left-radius: 5px;\n" +
                "            border-bottom-right-radius: 5px;\n" +
                "            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n" +
                "        }\n" +
                "        .thank-you {\n" +
                "            text-align: center;\n" +
                "            margin: 30px 0;\n" +
                "            color: #2c3e50;\n" +
                "        }\n" +
                "        .receipt {\n" +
                "            background-color: #f8f8f8;\n" +
                "            padding: 20px;\n" +
                "            border-radius: 5px;\n" +
                "            margin: 20px 0;\n" +
                "        }\n" +
                "        .receipt-header {\n" +
                "            text-align: center;\n" +
                "            border-bottom: 2px solid #ddd;\n" +
                "            padding-bottom: 10px;\n" +
                "            margin-bottom: 20px;\n" +
                "        }\n" +
                "        .receipt-details {\n" +
                "            margin: 20px 0;\n" +
                "        }\n" +
                "        .detail-row {\n" +
                "            display: flex;\n" +
                "            justify-content: space-between;\n" +
                "            margin-bottom: 10px;\n" +
                "            padding: 5px 0;\n" +
                "            border-bottom: 1px solid #eee;\n" +
                "        }\n" +
                "        .detail-label {\n" +
                "            font-weight: bold;\n" +
                "            color: #555;\n" +
                "        }\n" +
                "        .detail-value {\n" +
                "            color: #333;\n" +
                "        }\n" +
                "        .total {\n" +
                "            margin-top: 20px;\n" +
                "            padding-top: 10px;\n" +
                "            border-top: 2px solid #ddd;\n" +
                "            text-align: right;\n" +
                "            font-weight: bold;\n" +
                "        }\n" +
                "        .print-button {\n" +
                "            display: block;\n" +
                "            width: 200px;\n" +
                "            margin: 20px auto;\n" +
                "            padding: 10px 20px;\n" +
                "            background-color: #2c3e50;\n" +
                "            color: white;\n" +
                "            text-align: center;\n" +
                "            text-decoration: none;\n" +
                "            border-radius: 5px;\n" +
                "            cursor: pointer;\n" +
                "        }\n" +
                "        .print-button:hover {\n" +
                "            background-color: #34495e;\n" +
                "        }\n" +
                "        .footer {\n" +
                "            margin-top: 20px;\n" +
                "            text-align: center;\n" +
                "            color: #666;\n" +
                "            font-size: 14px;\n" +
                "        }\n" +
                "        .company-name {\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "        }\n" +
                "        @media print {\n" +
                "            .print-button {\n" +
                "                display: none;\n" +
                "            }\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <div class=\"container\">\n" +
                "        <div class=\"header\">\n" +
                "            <img src=\"${logoUrl}\" alt=\"Take U Logo\">\n" +
                "        </div>\n" +
                "        <div class=\"content\">\n" +
                "            <div class=\"thank-you\">\n" +
                "                <h2>Thank You for Using Take U!</h2>\n" +
                "                <p>Dear <strong>" + name + "</strong>,</p>\n" +
                "                <p>Your delivery has been successfully completed. We appreciate your business!</p>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"receipt\">\n" +
                "                <div class=\"receipt-header\">\n" +
                "                    <h3>Delivery Receipt</h3>\n" +
                "                    <p>Delivery ID: " + deliveryId + "</p>\n" +
                "                    <p>Date: " + deliveryDate + "</p>\n" +
                "                </div>\n" +
                "                \n" +
                "                <div class=\"receipt-details\">\n" +
                "                    <div class=\"detail-row\">\n" +
                "                        <span class=\"detail-label\">From:</span>\n" +
                "                        <span class=\"detail-value\">" + pickupAddress + "</span>\n" +
                "                    </div>\n" +
                "                    <div class=\"detail-row\">\n" +
                "                        <span class=\"detail-label\">To:</span>\n" +
                "                        <span class=\"detail-value\">" + dropOffAddress + "</span>\n" +
                "                    </div>\n" +
                "                    <div class=\"detail-row\">\n" +
                "                        <span class=\"detail-label\">Recipient:</span>\n" +
                "                        <span class=\"detail-value\">" + dropOffContactName + "</span>\n" +
                "                    </div>\n" +
                "                    <div class=\"detail-row\">\n" +
                "                        <span class=\"detail-label\">Amount:</span>\n" +
                "                        <span class=\"detail-value\">" + priceAmount + " " + currency + "</span>\n" +
                "                    </div>\n" +
                "                </div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <button class=\"print-button\" onclick=\"window.print()\">Print Receipt</button>\n" +
                "            \n" +
                "            <div class=\"footer\">\n" +
                "                <p>Thank you for choosing our service,<br>\n" +
                "                <span class=\"company-name\">Take U Service</span><br>\n" +
                "                We look forward to serving you again!</p>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "    </div>\n" +
                "</body>\n" +
                "</html>";
    }
    public static String generateGenericHtmlTemplate(String subject, String content, boolean showFooter) {
        StringBuilder template = new StringBuilder();
        template.append("<!DOCTYPE html>\n")
                .append("<html>\n")
                .append("<head>\n")
                .append("    <meta charset=\"UTF-8\">\n")
                .append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n")
                .append("    <title>").append(subject).append("</title>\n")
                .append("    <style>\n")
                .append("        body {\n")
                .append("            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n")
                .append("            margin: 0;\n")
                .append("            padding: 0;\n")
                .append("            background-color: #f4f4f4;\n")
                .append("        }\n")
                .append("        .container {\n")
                .append("            max-width: 600px;\n")
                .append("            margin: 0 auto;\n")
                .append("            padding: 20px;\n")
                .append("        }\n")
                .append("        .header {\n")
                .append("            background-color: #ebedf0;\n")
                .append("            padding: 20px;\n")
                .append("            text-align: center;\n")
                .append("            border-top-left-radius: 5px;\n")
                .append("            border-top-right-radius: 5px;\n")
                .append("        }\n")
                .append("        .header img {\n")
                .append("            max-width: 150px;\n")
                .append("        }\n")
                .append("        .content {\n")
                .append("            background-color: #ffffff;\n")
                .append("            padding: 30px;\n")
                .append("            border-bottom-left-radius: 5px;\n")
                .append("            border-bottom-right-radius: 5px;\n")
                .append("            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n")
                .append("        }\n")
                .append("        .footer {\n")
                .append("            margin-top: 20px;\n")
                .append("            color: #666;\n")
                .append("            font-size: 14px;\n")
                .append("        }\n")
                .append("        .company-name {\n")
                .append("            font-weight: bold;\n")
                .append("            color: #000000;\n")
                .append("        }\n")
                .append("    </style>\n")
                .append("</head>\n")
                .append("<body>\n")
                .append("    <div class=\"container\">\n")
                .append("        <div class=\"header\">\n")
                .append("            <img src=\"${logoUrl}\" alt=\"Take U Logo\">\n")
                .append("        </div>\n")
                .append("        <div class=\"content\">\n")
                .append(content).append("\n");

        if (showFooter) {
            template.append("            <div class=\"footer\">\n")
                    .append("                <p>Best regards,<br>\n")
                    .append("                <span class=\"company-name\">Take U Service</span><br>\n")
                    .append("             </p>\n")
                    .append("            </div>\n");
        }

        template.append("        </div>\n")
                .append("    </div>\n")
                .append("</body>\n")
                .append("</html>");

        return template.toString();
    }


    public static String generateDriverProfileReviewTemplate(String driverName, String status, String reason) {
        boolean isApproved = "APPROVED".equalsIgnoreCase(status);

        StringBuilder content = new StringBuilder();
        content.append("<p>Dear <strong>").append(driverName).append("</strong>,</p>\n");

        if (isApproved) {
            content.append("<p>Congratulations! Your driver profile has been <strong style=\"color: #28a745;\">APPROVED</strong>.</p>\n")
                    .append("<p>You can now start accepting and completing deliveries through the Take U platform.</p>\n")
                    .append("<div style=\"background-color: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n")
                    .append("  <p><strong>Next Steps:</strong></p>\n")
                    .append("  <ul>\n")
                    .append("    <li>Log in to your Take U driver account</li>\n")
                    .append("    <li>Update your availability status</li>\n")
                    .append("    <li>Start accepting delivery requests</li>\n")
                    .append("  </ul>\n")
                    .append("</div>\n");
        } else {
            content.append("<p>We regret to inform you that your driver profile has been <strong style=\"color: #dc3545;\">REJECTED</strong>.</p>\n")
                    .append("<div style=\"background-color: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n")
                    .append("  <p><strong>Reason for Rejection:</strong></p>\n")
                    .append("  <p>").append(reason != null ? reason : "No specific reason provided").append("</p>\n")
                    .append("</div>\n")
                    .append("<p>Please address the issues mentioned above and resubmit your profile for approval.</p>\n")
                    .append("<div style=\"background-color: #e8f4ff; padding: 15px; border-radius: 5px; margin: 20px 0;\">\n")
                    .append("  <p><strong>Next Steps:</strong></p>\n")
                    .append("  <ul>\n")
                    .append("    <li>Log in to your Take U driver account</li>\n")
                    .append("    <li>Update the required information or documentation</li>\n")
                    .append("    <li>Resubmit your profile for review</li>\n")
                    .append("  </ul>\n")
                    .append("</div>\n");
        }

        content.append("<p>If you have any questions or need assistance, please contact our support team.</p>\n");

        return generateGenericHtmlTemplate(
                isApproved ? "Driver Profile Approved" : "Driver Profile Requires Updates",
                content.toString(),
                true
        );
    }

    /**
     * Generate a password reset email template with a reset link
     * @param name User's name
     * @param resetToken Password reset token
     * @param resetLink Full URL with the reset token for resetting password
     * @return HTML template for password reset email
     */
    public static String generatePasswordResetTemplate(String name, String resetToken, String resetLink) {
        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                "    <title>Password Reset</title>\n" +
                "    <style>\n" +
                "        body {\n" +
                "            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "            background-color: #f4f4f4;\n" +
                "        }\n" +
                "        .container {\n" +
                "            max-width: 600px;\n" +
                "            margin: 0 auto;\n" +
                "            padding: 20px;\n" +
                "        }\n" +
                "        .header {\n" +
                "            background-color: #ebedf0;\n" +
                "            padding: 20px;\n" +
                "            text-align: center;\n" +
                "            border-top-left-radius: 5px;\n" +
                "            border-top-right-radius: 5px;\n" +
                "        }\n" +
                "        .header img {\n" +
                "            max-width: 150px;\n" +
                "        }\n" +
                "        .content {\n" +
                "            background-color: #ffffff;\n" +
                "            padding: 30px;\n" +
                "            border-bottom-left-radius: 5px;\n" +
                "            border-bottom-right-radius: 5px;\n" +
                "            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n" +
                "        }\n" +
                "        .reset-button {\n" +
                "            display: inline-block;\n" +
                "            background-color: #0066cc;\n" +
                "            color: white;\n" +
                "            padding: 12px 24px;\n" +
                "            text-decoration: none;\n" +
                "            border-radius: 4px;\n" +
                "            font-weight: bold;\n" +
                "            margin: 20px 0;\n" +
                "        }\n" +
                "        .reset-token {\n" +
                "            font-size: 18px;\n" +
                "            letter-spacing: 2px;\n" +
                "            font-weight: bold;\n" +
                "            color: #333333;\n" +
                "            padding: 10px 15px;\n" +
                "            background-color: #f8f8f8;\n" +
                "            border-radius: 5px;\n" +
                "            border: 1px dashed #ccc;\n" +
                "            display: inline-block;\n" +
                "            margin: 10px 0;\n" +
                "        }\n" +
                "        .expiry-note {\n" +
                "            background-color: #f8f8f8;\n" +
                "            padding: 10px 15px;\n" +
                "            border-radius: 5px;\n" +
                "            margin: 20px 0;\n" +
                "            font-size: 14px;\n" +
                "            color: #555;\n" +
                "        }\n" +
                "        .footer {\n" +
                "            margin-top: 20px;\n" +
                "            color: #666;\n" +
                "            font-size: 14px;\n" +
                "        }\n" +
                "        .company-name {\n" +
                "            font-weight: bold;\n" +
                "            color: #000000;\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <div class=\"container\">\n" +
                "        <div class=\"header\">\n" +
                "            <img src=\"${logoUrl}\" alt=\"Take U Logo\">\n" +
                "        </div>\n" +
                "        <div class=\"content\">\n" +
                "            <p>Dear <strong>" + name + "</strong>,</p>\n" +
                "            <p>We received a request to reset your password for your Take U driver account. If you didn't make this request, you can ignore this email.</p>\n" +

                "            \n" +
                "            <p>Alternatively, you can use the following reset code on the password reset page:</p>\n" +
                "            <div style=\"text-align: center;\">\n" +
                "                <div class=\"reset-token\">" + resetToken + "</div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"expiry-note\">\n" +
                "                <strong>Note:</strong> This password reset code will expire in 1 hour for security purposes.\n" +
                "            </div>\n" +
                "            \n" +
                "            <p>If you did not request a password reset, please contact our support team immediately.</p>\n" +
                "            \n" +
                "            <div class=\"footer\">\n" +
                "                <p>Best regards,<br>\n" +
                "                <span class=\"company-name\">Take U Service</span><br>\n" +
                "             </p>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "    </div>\n" +
                "</body>\n" +
                "</html>";
    }
} 