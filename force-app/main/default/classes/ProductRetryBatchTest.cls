@IsTest
public class ProductRetryBatchTest {

    @TestSetup
    static void setupTestData() {
        ProductTestDataCreator dataCreator = new ProductTestDataCreator();

        Product2 prod1 = dataCreator.createProduct();
        Product2 prod2 = dataCreator.createProduct();

        dataCreator.createAdditionalLogs(prod1, prod2);
    }

    @IsTest
    static void testBatchExecutionWithSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();

        ProductRetryBatch batch = new ProductRetryBatch();
        Database.executeBatch(batch);

        Test.stopTest();

        List<Integration_Logger__c> logs = [
                SELECT Id, Status__c, Retry_Count__c
                FROM Integration_Logger__c
                WHERE Status__c = 'Retry Success'
                AND Retry_Count__c = 1
        ];

        Assert.areEqual(2, logs.size(), 'Expected 2 logs to be updated to Retry Success.');

        for (Integration_Logger__c log : logs) {
            Assert.areEqual(1, log.Retry_Count__c, 'Retry count should remain the same after successful retry.');
        }
    }

    private class ProductTestDataCreator extends TestDataCreator {

        public void createAdditionalLogs(Product2 prod1, Product2 prod2) {
            List<Integration_Logger__c> logs = new List<Integration_Logger__c>{
                    new Integration_Logger__c(Product__c = prod1.Id, Status__c = 'Error', Retry_Count__c = 1),
                    new Integration_Logger__c(Product__c = prod2.Id, Status__c = 'Error', Retry_Count__c = 1),
                    new Integration_Logger__c(Product__c = null, Status__c = 'Error', Retry_Count__c = 0),
                    new Integration_Logger__c(Product__c = prod1.Id, Status__c = 'Success', Retry_Count__c = 1)
            };
            insert logs;
        }
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }

}
