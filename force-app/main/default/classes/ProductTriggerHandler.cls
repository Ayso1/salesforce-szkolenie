public with sharing class ProductTriggerHandler extends TriggerHandler {

    override protected void afterInsert() {
        sendProducts(Trigger.new);
    }

    override protected void afterUpdate() {
        sendProducts(Trigger.new);
    }

    private void sendProducts(List<Product2> products) {
        List<Product2> productsToSend = new List<Product2>();

        for (Product2 product : products) {
            if (product.External_Product__c == false) {
                productsToSend.add(product);
            }
        }

        if (!productsToSend.isEmpty()) {
            System.enqueueJob(new ProductCallout(productsToSend));
        }
    }
}
