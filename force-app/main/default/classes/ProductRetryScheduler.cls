public class ProductRetryScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        ProductRetryBatch retryBatch = new ProductRetryBatch();
        Database.executeBatch(retryBatch, 200);
    }
}
