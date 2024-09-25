public abstract class TestDataCreator implements DataCreator {

    public virtual Product2 createProduct() {
        Product2 prod = ProductBuilder.getBuilder()
            .setName('Default Product Name')
            .save();
        return prod;
    }

    public virtual Integration_Logger__c createLogger(Product2 prod) {
        Integration_Logger__c log = IntegrationLoggerBuilder.getBuilder()
            .setName('Product Creation Log')
            .setStatus('Success')
            .setRequestData('Product Created: ' + prod.Name)
            .setResponseData('Product ID: ' + prod.Id)
            .setTimestamp(System.now())
            .setProductId(prod.Id)
            .save();
        return log;
    }

    public void createData() {
        createProduct();
    }
}
