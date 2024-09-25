@IsTest
public class IntegrationLoggerTest {

    @IsTest
    static void testLogSuccess() {
        TestDataCreator dataCreator = new ProductTestDataCreator();

        Product2 testProduct = dataCreator.createProduct();

        Test.startTest();
        IntegrationLogger.logSuccess('Test Integration', 'Test Request Data', 'Test Response Data', testProduct);
        Test.stopTest();

        List<Integration_Logger__c> logs = [
                SELECT Name, Status__c, Request_Data__c, Response_Data__c, Timestamp__c, Product__c
                FROM Integration_Logger__c
                WHERE Name = 'Test Integration'
        ];
        Assert.areEqual(1, logs.size(), 'Expected one log record to be created.');
        Integration_Logger__c log = logs[0];
        Assert.areEqual(Util.SUCCESS, log.Status__c, 'Status should be SUCCESS.');
        Assert.areEqual('Test Request Data', log.Request_Data__c, 'Request Data should match.');
        Assert.areEqual('Test Response Data', log.Response_Data__c, 'Response Data should match.');
        Assert.isNotNull(log.Timestamp__c, 'Timestamp should be set.');
        Assert.areEqual(testProduct.Id, log.Product__c, 'Product should be set.');
    }

    @IsTest
    static void testLogError() {
        TestDataCreator dataCreator = new ProductTestDataCreator();

        Product2 testProduct = dataCreator.createProduct();

        Test.startTest();
        IntegrationLogger.logError('Test Integration', 'Test Request Data', 'Test Error Message', testProduct);
        Test.stopTest();

        List<Integration_Logger__c> logs = [
                SELECT Name, Status__c, Request_Data__c, Error_Message__c, Timestamp__c, Product__c, Retry_Count__c
                FROM Integration_Logger__c
                WHERE Name = 'Test Integration'
        ];
        Assert.areEqual(1, logs.size(), 'Expected one log record to be created.');
        Integration_Logger__c log = logs[0];
        Assert.areEqual(Util.ERROR, log.Status__c, 'Status should be ERROR.');
        Assert.areEqual('Test Request Data', log.Request_Data__c, 'Request Data should match.');
        Assert.areEqual('Test Error Message', log.Error_Message__c, 'Error Message should match.');
        Assert.isNotNull(log.Timestamp__c, 'Timestamp should be set.');
        Assert.areEqual(testProduct.Id, log.Product__c, 'Product should be set.');
        Assert.areEqual(0, log.Retry_Count__c, 'Retry Count should be 0.');
    }

    private class ProductTestDataCreator extends TestDataCreator {
    }
}
