package java.lang;

public class ExceptionInInitializerError extends RuntimeException {

    public ExceptionInInitializerError(String message) {
        super(message);
    }

    public ExceptionInInitializerError(Object cause) {
      super(null, (RuntimeException)cause);
    }
}
