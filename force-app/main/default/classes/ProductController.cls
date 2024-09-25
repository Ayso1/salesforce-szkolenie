public with sharing class ProductController {

    @AuraEnabled(Cacheable=true)
    public static List<ProductHelper.ProductOption> getProductOptions() {
        return ProductHelper.getProductOptions();
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProductHelper.DiscountTypeOption> getDiscountTypeOptions() {
        return ProductHelper.getDiscountTypeOptions();
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getPicklistOptions(String objectName, String fieldName) {
        return ProductHelper.getPicklistOptions(objectName, fieldName);
    }

    @AuraEnabled(Cacheable=true)
    public static List<Discount_Type__c> getDiscountTypes() {
        return ProductHelper.getDiscountTypes();
    }

    @AuraEnabled
    public static void applyDiscountToProduct(String productId, String discountType, Decimal discountValue, String discountUnit) {
        ProductHelper.applyDiscountToProduct(productId, discountType, discountValue, discountUnit);
    }

    @AuraEnabled
    public static void createDiscountType(String name, Date startDate, Date endDate, Boolean recurringDiscount, String discountPeriod, String dayOfWeek, String month, Decimal specificDay, String specificDayMonth) {
        ProductHelper.createDiscountType(name, startDate, endDate, recurringDiscount, discountPeriod, dayOfWeek, month, specificDay, specificDayMonth);
    }
}

