public with sharing class NewCaseHelper {
    @AuraEnabled(Cacheable=true)
    public static Boolean hasExternalProduct(Id orderId) {
        if (orderId == null) {
            throw new AuraHandledException('Invalid Order Id.');
        }

        List<OrderItem> orderItems = [SELECT Id, Product2.External_Product__c
        FROM OrderItem
        WHERE OrderId = :orderId
        AND Product2.External_Product__c = TRUE];

        return orderItems.size() > 0;
    }
}
