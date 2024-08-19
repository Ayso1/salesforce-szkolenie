public with sharing class ProductSelectionController {
    @AuraEnabled
    public static List<Product2> getProductsByFamily(String productFamily) {
        return [SELECT Id, Name FROM Product2 WHERE Family = :productFamily];
    }
}
