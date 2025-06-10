package zw.co.kenac.takeu.backend.exception.custom;

public class DriverProposalLimitExceededException extends RuntimeException {
    public DriverProposalLimitExceededException(String message) {
        super(message);
    }
}
