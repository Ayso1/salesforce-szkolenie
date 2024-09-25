@IsTest
public class ProductTriggerHandlerTest {

    @IsTest
    static void testAfterInsert() {
        ProductTestDataCreator dataCreator = new ProductTestDataCreator();

        Test.startTest();

        dataCreator.createData();

        List<Product2> products = [SELECT Id, External_Product__c FROM Product2];
        Assert.areEqual(1, products.size(), 'One product should have been created');
        Assert.isFalse(products[0].External_Product__c, 'Product should have External_Product__c = false');

        Test.stopTest();
    }

    @IsTest
    static void testAfterUpdate() {
        ProductTestDataCreator dataCreator = new ProductTestDataCreator();
        Product2 prod = dataCreator.createProduct();

        Test.startTest();

        prod.ProductCode = 'P-002';
        update prod;

        List<Product2> updatedProducts = [SELECT Id, ProductCode FROM Product2 WHERE Id = :prod.Id];
        Assert.areEqual('P-002', updatedProducts[0].ProductCode, 'ProductCode should be updated to P-002');

        Test.stopTest();
    }

    @IsTest
    static void testSendProducts() {
        ProductTestDataCreator dataCreator = new ProductTestDataCreator();

        Test.startTest();

        Product2 prodToSend = dataCreator.createProduct();
        Product2 prodNotToSend = dataCreator.createProduct();

        List<Product2> products = [SELECT Id, External_Product__c FROM Product2];
        Assert.areEqual(2, products.size(), 'Two products should have been created');

        Test.stopTest();
    }

    private class ProductTestDataCreator extends TestDataCreator {
    }
}
