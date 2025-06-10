package zw.co.kenac.takeu.backend.model.enumeration;

public enum TransactionStatus {
    PENDING, COMPLETED, FAILED, REVERSED, CANCELED,
    // Payment successful statuses,
    PAID,
    AWAITING_DELIVERY,
    DELIVERED,

    // Transaction lifecycle statuses
    CREATED,
    SENT,
    CANCELLED,
    DISPUTED,
    REFUNDED;
    public boolean isSuccessful() {
        return this == PAID || this == AWAITING_DELIVERY || this == DELIVERED;
    }

    public static TransactionStatus fromString(String status) {
        for (TransactionStatus s : TransactionStatus.values()) {
            if (s.name().equalsIgnoreCase(status.replace(" ", "_"))) {
                return s;
            }
        }
        throw new IllegalArgumentException("Unknown Paynow status: " + status);
    }
}
