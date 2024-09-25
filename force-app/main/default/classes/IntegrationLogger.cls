public class IntegrationLogger {

    public static void logSuccess(String integrationName, String requestData, String responseData, Product2 product) {
        Integration_Logger__c log = new Integration_Logger__c();
        log.Name = integrationName;
        log.Status__c = Util.SUCCESS;
        log.Request_Data__c = requestData;
        log.Response_Data__c = responseData;
        log.Timestamp__c = System.now();
        log.Product__c = product != null ? product.Id : null;
        insert log;
    }

    public static void logError(String integrationName, String requestData, String errorMessage, Product2 product) {
        Integration_Logger__c log = new Integration_Logger__c();
        log.Name = integrationName;
        log.Status__c = Util.ERROR;
        log.Request_Data__c = requestData;
        log.Error_Message__c = errorMessage;
        log.Timestamp__c = System.now();
        log.Product__c = product != null ? product.Id : null;
        log.Retry_Count__c = 0;
        insert log;
    }
}
