@IsTest
public class ProductRetrySchedulerTest {

    @IsTest
    static void testScheduler() {
        ProductRetryScheduler scheduler = new ProductRetryScheduler();

        Test.startTest();
        String jobID = System.schedule('Test ProductRetryScheduler Job', '0 0 0 * * ?', scheduler);
        Test.stopTest();

        CronTrigger[] scheduledJobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE Id = :jobID];
        Assert.areEqual(1, scheduledJobs.size(), 'Expected one scheduled job.');
        Assert.areEqual('Test ProductRetryScheduler Job', scheduledJobs[0].CronJobDetail.Name, 'Job name should match.');
        Assert.areEqual('WAITING', scheduledJobs[0].State, 'Job should be in WAITING state.');
    }

    @IsTest
    static void testBatchExecution() {
        ProductRetryBatch retryBatch = new ProductRetryBatch();

        Test.startTest();
        Database.executeBatch(retryBatch, 200);
        Test.stopTest();

        List<AsyncApexJob> batchJobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        Assert.isTrue(batchJobs.size() > 0, 'Batch job should have been enqueued.');
    }
}
