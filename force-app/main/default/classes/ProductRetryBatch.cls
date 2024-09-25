public class ProductRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT Id, Product__c, Retry_Count__c, Status__c
                FROM Integration_Logger__c
                WHERE Status__c = 'Error'
                AND Retry_Count__c < 3
                AND Product__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Integration_Logger__c> scope) {
        Set<Id> productIds = new Set<Id>();
        for (Integration_Logger__c log : scope) {
            if (log.Product__c != null) {
                productIds.add(log.Product__c);
            }
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>();
        if (!productIds.isEmpty()) {
            List<Product2> products = [
                    SELECT Id, Name, CurrencyIsoCode, Description, External_Product__c, ProductClass
                    FROM Product2
                    WHERE Id IN :productIds
            ];
            productMap = new Map<Id, Product2>(products);
        }

        List<Integration_Logger__c> logsToUpdate = new List<Integration_Logger__c>();

        for (Integration_Logger__c log : scope) {
            if (log.Product__c != null && productMap.containsKey(log.Product__c)) {
                Product2 product = productMap.get(log.Product__c);

                if (product != null) {
                    List<Product2> productList = new List<Product2>{product};
                    try {
                        ProductCallout.sendProduct(productList);
                        log.Status__c = Util.RETRY_SUCCESS;
                    } catch (Exception e) {
                        log.Retry_Count__c += 1;
                        log.Status__c = Util.RETRY_ERROR;
                    }

                    logsToUpdate.add(log);
                }
            }
        }

        if (!logsToUpdate.isEmpty()) {
            update logsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
