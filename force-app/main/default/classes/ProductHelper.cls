public with sharing class ProductHelper {

    public class ProductOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public ProductOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class DiscountTypeOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public DiscountTypeOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<ProductOption> getProductOptions() {
        List<ProductOption> options = new List<ProductOption>();
        for (Project_Product__c product : [SELECT Id, Name FROM Project_Product__c ORDER BY Name ASC]) {
            options.add(new ProductOption(product.Name, product.Id));
        }
        return options;
    }

    @AuraEnabled(Cacheable=true)
    public static List<DiscountTypeOption> getDiscountTypeOptions() {
        List<DiscountTypeOption> options = new List<DiscountTypeOption>();
        for (Discount_Type__c discountType : [SELECT Id, Name FROM Discount_Type__c ORDER BY Name ASC]) {
            options.add(new DiscountTypeOption(discountType.Name, discountType.Id));
        }
        return options;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getPicklistOptions(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();

        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = objDescribeSobject.fields.getMap();

        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry pickListVal : picklistEntries) {
            picklistValues.add(pickListVal.getValue());
        }
        return picklistValues;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Discount_Type__c> getDiscountTypes() {
        return [SELECT Id, Name, Start_Date__c, End_Date__c, Recurring_Discount__c, Discount_Period__c FROM Discount_Type__c ORDER BY Name ASC];
    }

    @AuraEnabled
    public static void applyDiscountToProduct(String productId, String discountType, Decimal discountValue, String discountUnit) {
        Project_Product__c product = new Project_Product__c(
                Id = productId,
                Discount__c = discountValue,
                Discount_Type__c = discountType,
                Discount_Unit__c = discountUnit
        );
        update product;
    }

    @AuraEnabled
    public static void createDiscountType(String name, Date startDate, Date endDate, Boolean recurringDiscount, String discountPeriod, String dayOfWeek, String month, Decimal specificDay, String specificDayMonth) {
        Discount_Type__c newDiscountType = new Discount_Type__c(
                Name = name,
                Start_Date__c = (recurringDiscount && discountPeriod == 'Specific Date Range') ? startDate : null,
                End_Date__c = (recurringDiscount && discountPeriod == 'Specific Date Range') ? endDate : null,
                Recurring_Discount__c = recurringDiscount,
                Discount_Period__c = recurringDiscount ? discountPeriod : null,
                Day_of_Week__c = discountPeriod == 'Day of Week' ? dayOfWeek : null,
                Month__c = discountPeriod == 'Month' ? month : null,
                Specific_Day__c = discountPeriod == 'Specific DD' ? specificDay : null,
                Specific_Day_Month__c = discountPeriod == 'Specific DD.MM' ? specificDayMonth : null
        );
        insert newDiscountType;
    }
}
