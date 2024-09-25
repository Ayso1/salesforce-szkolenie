public class ProductCalloutRetry implements Queueable, Database.AllowsCallouts {
    private Integration_Logger__c errorLog;

    public ProductCalloutRetry(Integration_Logger__c log) {
        this.errorLog = log;
    }

    public void execute(QueueableContext context) {
        errorLog = [SELECT Id, Product__c, Retry_Count__c FROM Integration_Logger__c WHERE Id = :errorLog.Id LIMIT 1];

        Product2 product = [
                SELECT Id, Name, CurrencyIsoCode, Description, External_Product__c, ProductClass
                FROM Product2
                WHERE Id = :errorLog.Product__c
                LIMIT 1
        ];

        if (product != null) {
            List<Product2> productList = new List<Product2>{product};

            try {
                ProductCallout.sendProduct(productList);
                errorLog.Status__c = 'Retry Success';
                update errorLog;
            } catch (Exception e) {
                errorLog.Retry_Count__c += 1;
                update errorLog;

            }
        }
    }
}
