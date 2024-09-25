public with sharing class AddProjectHelper {

    public static List<Project__c> getAllProjects() {
        return [
                SELECT Id, Name
                FROM Project__c
        ];
    }

    public static List<Project_Product__c> getProductsByProjectIds(List<Id> projectIds) {
        Id pricebookId = getPricebookId();
        String targetCurrency = getTargetCurrency();

        List<Project_Product__c> projectProducts = fetchProjectProducts(projectIds);
        Set<Id> productIds = extractProductIds(projectProducts);
        Map<Id, Decimal> productPrices = fetchProductPrices(productIds, pricebookId, targetCurrency);

        updateProductPrices(projectProducts, productPrices);
        return projectProducts;
    }

    private static List<Project_Product__c> fetchProjectProducts(List<Id> projectIds) {
        return [
                SELECT Id, Product__c, Product__r.Name, Product__r.Family, Quantity__c, Project__r.Name,
                        Price__c, Discount_Price__c, Discount__c, Discount_Unit__c, Discount_Type__r.Recurring_Discount__c,
                        Discount_Type__r.Start_Date__c, Discount_Type__r.End_Date__c, Discount_Type__r.Discount_Period__c,
                        Discount_Type__r.Day_of_Week__c, Discount_Type__r.Month__c, Discount_Type__r.Specific_Day__c, Discount_Type__r.Specific_Day_Month__c
                FROM Project_Product__c
                WHERE Project__c IN :projectIds
        ];
    }

    private static Set<Id> extractProductIds(List<Project_Product__c> projectProducts) {
        Set<Id> productIds = new Set<Id>();
        for (Project_Product__c projectProduct : projectProducts) {
            productIds.add(projectProduct.Product__c);
        }
        return productIds;
    }

    private static Map<Id, Decimal> fetchProductPrices(Set<Id> productIds, Id pricebookId, String targetCurrency) {
        Map<Id, Decimal> productPrices = new Map<Id, Decimal>();
        if (!productIds.isEmpty()) {
            List<PricebookEntry> pricebookEntries = [
                    SELECT Product2Id, UnitPrice
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :pricebookId
                    AND Product2Id IN :productIds
                    AND CurrencyIsoCode = :targetCurrency
            ];

            for (PricebookEntry pricebookEntry : pricebookEntries) {
                productPrices.put(pricebookEntry.Product2Id, pricebookEntry.UnitPrice);
            }
        }
        return productPrices;
    }

    private static void updateProductPrices(List<Project_Product__c> projectProducts, Map<Id, Decimal> productPrices) {
        Datetime now = Datetime.now();
        String dayOfWeek = now.format('EEEE');

        for (Project_Product__c projectProduct : projectProducts) {
            Decimal basePrice = productPrices.get(projectProduct.Product__c);
            Decimal finalPrice = calculateDiscountedPrice(projectProduct, basePrice, dayOfWeek);
            projectProduct.Discount_Price__c = finalPrice;
            projectProduct.Price__c = basePrice;
        }
    }

    private static Id getPricebookId() {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        return standardPricebook.Id;
    }

    private static String getTargetCurrency() {
        CurrencyType defaultCurrency = [
                SELECT IsoCode
                FROM CurrencyType
                WHERE IsCorporate = true
                LIMIT 1
        ];
        return defaultCurrency.IsoCode;
    }

    private static Map<String, String> getFamilyRoleMap() {
        return new Map<String, String>{
                Util.DESIGN_SERVICES => Util.INTERIOR_DESIGNER,
                Util.RENOVATION_SERVICES => Util.RENOVATION_SPECIALIST,
                Util.FURNITURE_FITTINGS => Util.FURNITURE_MAKER,
                Util.FURNISHING_FITTINGS_INSTALLATION => Util.FURNISHING_INSTALLATION_EXPERT,
                Util.MATERIALS_SERVICES => Util.RENOVATION_SPECIALIST
        };
    }

    private static Decimal calculateDiscountedPrice(Project_Product__c projectProduct, Decimal basePrice, String dayOfWeekToday) {
        Decimal discountedPrice = basePrice;

        if (projectProduct.Discount__c != null && projectProduct.Discount__c > 0) {
            discountedPrice = applyDiscount(projectProduct, discountedPrice);
            Discount_Type__c discountType = projectProduct.Discount_Type__r;
            if (discountType != null) {
                Boolean isRecurring = discountType.Recurring_Discount__c;
                Date nowDate = Datetime.now().date();
                String discountPeriod = discountType.Discount_Period__c;
                String discountPeriodLabel = getPicklistLabel('Discount_Type__c', 'Discount_Period__c', discountPeriod);
                if (isRecurring) {
                    return discountedPrice = applyRecurringDiscount(discountType,discountPeriodLabel, discountedPrice, basePrice);
                } else {
                    if (isDateWithinRange(nowDate, discountType.Start_Date__c, discountType.End_Date__c)) {
                        return discountedPrice;
                    }
                }
            }
        }

        return basePrice;
    }

    private static String getPicklistLabel(String objectName, String fieldName, String picklistValue) {
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }

        return null;
    }

    private static Decimal applyDiscount(Project_Product__c projectProduct, Decimal basePrice) {
        if (projectProduct.Discount_Unit__c == 'Percent') {
            return basePrice - basePrice * (projectProduct.Discount__c / 100);
        } else if (projectProduct.Discount_Unit__c == 'Value') {
            return basePrice - projectProduct.Discount__c;
        }
        return basePrice;
    }

    private static Decimal applyRecurringDiscount(
            Discount_Type__c discountType,
            String discountPeriodLabel,
            Decimal discountedPrice,
            Decimal basePrice
    ) {
        DiscountContext context = new DiscountContext(discountType,discountPeriodLabel);
        return context.applyDiscount(discountedPrice, basePrice);
    }

    private static Boolean isDateWithinRange(Date currentDate, Date startDate, Date endDate) {
        return startDate != null && endDate != null && currentDate >= startDate && currentDate <= endDate;
    }

    public static void createTaskAndOppProduct(List<Map<String, Object>> selectedProducts, Date realizationTime, Date startDate, Id oppId) {
        Map<String, String> familyRoleMap = getFamilyRoleMap();
        Id pricebookId = getPricebookId();
        String targetCurrency = getTargetCurrency();

        Map<String, List<String>> familyProductMap = new Map<String, List<String>>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        Map<Id, PricebookEntry> pricebookEntriesMap = getPricebookEntries(pricebookId, targetCurrency, selectedProducts);

        oppLineItems = createOpportunityLineItems(selectedProducts, pricebookEntriesMap, oppId, familyProductMap);

        insert oppLineItems;

        createTasks(familyProductMap, familyRoleMap, realizationTime, startDate, oppId);
    }

    private static Map<Id, PricebookEntry> getPricebookEntries(Id pricebookId, String targetCurrency, List<Map<String, Object>> selectedProducts) {
        Set<Id> productIds = new Set<Id>();
        for (Map<String, Object> product : selectedProducts) {
            productIds.add((Id) product.get('Id'));
        }

        List<PricebookEntry> pricebookEntries = [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :pricebookId
                AND Product2Id IN :productIds
                AND CurrencyIsoCode = :targetCurrency
        ];

        return new Map<Id, PricebookEntry>(pricebookEntries);
    }

    private static List<OpportunityLineItem> createOpportunityLineItems(List<Map<String, Object>> selectedProducts, Map<Id, PricebookEntry> pricebookEntriesMap, Id oppId, Map<String, List<String>> familyProductMap) {
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        for (Map<String, Object> product : selectedProducts) {
            String productFamily = (String) product.get('ProductFamily');
            Id productId = (Id) product.get('Id');
            Integer productQuantity = Integer.valueOf(product.get('Quantity__c'));
            Integer productPrice = Integer.valueOf(product.get('Price__c'));
            Integer discountProductPrice2 = Integer.valueOf(product.get('Discount_Price__c'));

            Id pricebookEntryId = getPricebookEntryId(pricebookEntriesMap, productId);

            Integer unitPrice = (productPrice.equals(discountProductPrice2)) ? productPrice : discountProductPrice2;

            OpportunityLineItem lineItem = new OpportunityLineItem(
                    OpportunityId = oppId,
                    Quantity = productQuantity,
                    UnitPrice = unitPrice,
                    PricebookEntryId = pricebookEntryId
            );
            oppLineItems.add(lineItem);

            if (!familyProductMap.containsKey(productFamily)) {
                familyProductMap.put(productFamily, new List<String>());
            }
            familyProductMap.get(productFamily).add((String) product.get('ProductName'));
        }

        return oppLineItems;
    }

    private static Id getPricebookEntryId(Map<Id, PricebookEntry> pricebookEntriesMap, Id productId) {
        for (PricebookEntry pricebookEntry : pricebookEntriesMap.values()) {
            if (pricebookEntry.Product2Id == productId) {
                return pricebookEntry.Id;
            }
        }
        return null;
    }

    private static void createTasks(Map<String, List<String>> familyProductMap, Map<String, String> familyRoleMap, Date realizationTime, Date startDate, Id oppId) {
        List<Task> tasksToInsert = new List<Task>();

        for (String family : familyProductMap.keySet()) {
            if (familyRoleMap.containsKey(family)) {
                String roleName = familyRoleMap.get(family);
                User assignedUser = [SELECT Id FROM User WHERE UserRole.Name = :roleName LIMIT 1];
                String productsList = String.join(familyProductMap.get(family), ', ');
                String taskDescription = 'Products selected: ' + productsList;

                Task newTask = new Task(
                        OwnerId = assignedUser.Id,
                        Subject = 'Follow up on Opportunity - ' + oppId,
                        ActivityDate = realizationTime,
                        Start_Date__c = startDate,
                        Status = Util.PENDING,
                        WhatId = oppId,
                        Description = taskDescription
                );
                tasksToInsert.add(newTask);
            }
        }
        insert tasksToInsert;
    }

}