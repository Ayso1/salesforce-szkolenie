@IsTest
public class ProductCalloutTest {

    @IsTest
    static void testProductCalloutSuccessWithDataCreator() {

        ProductTestDataCreator dataCreator = new ProductTestDataCreator();
        dataCreator.createData();

        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE External_Product__c = FALSE];
        Assert.areEqual(1, products.size(), 'One product should have been created by TestDataCreator');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        System.enqueueJob(new ProductCallout(products));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, JobItemsProcessed, Status, CreatedDate FROM AsyncApexJob WHERE JobType = 'Queueable'];

        Assert.isTrue(jobs.size() >= 1, 'At least one job should have been enqueued');

        List<Integration_Logger__c> logs = [SELECT Id, Status__c, Request_Data__c, Response_Data__c FROM Integration_Logger__c];
        Assert.isTrue(logs.size() >= 1, 'At least one log entry should be created');
        Assert.areEqual('Success', logs[0].Status__c, 'Log should indicate a successful callout');
    }

    @IsTest
    static void testProductCalloutErrorWithDataCreator() {

        ProductTestDataCreator dataCreator = new ProductTestDataCreator();
        dataCreator.createData();

        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE External_Product__c = FALSE];
        Assert.areEqual(1, products.size(), 'One product should have been created by TestDataCreator');

        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        Test.startTest();
        System.enqueueJob(new ProductCallout(products));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, JobItemsProcessed, Status, CreatedDate FROM AsyncApexJob WHERE JobType = 'Queueable'];

        Assert.isTrue(jobs.size() >= 1, 'At least one job should have been enqueued');

        List<Integration_Logger__c> logs = [SELECT Id, Status__c, Request_Data__c, Error_Message__c FROM Integration_Logger__c];
        Assert.isTrue(logs.size() >= 1, 'At least one error log entry should be created');
        Assert.areEqual('Error', logs[0].Status__c, 'Log should indicate an error occurred');
        Assert.isTrue(logs[0].Error_Message__c.contains('Internal Server Error'), 'Log should capture the error message');
    }

    private class ProductTestDataCreator extends TestDataCreator {
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }

    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }
}
