public with sharing class AddProjectsController {

    @AuraEnabled
    public static List<Product2> getAllProducts() {
        return [
                SELECT Id, Name, Family
                FROM Product2
                WHERE Family IN :new List<String>{
                        'Design Services',
                        'Renovation Services',
                        'Furniture & Fittings',
                        'Furnishing & Fittings Installation',
                        'Materials'
                }
        ];
    }

    @AuraEnabled
    public static void saveSelectedProductsAndTime(List<Id> selectedProductIds, Date realizationTime, Id oppId) {

        List<Product2> selectedProducts = [SELECT Family, Name FROM Product2 WHERE Id IN :selectedProductIds];

        Map<String, String> familyRoleMap = new Map<String, String>{
                'Design Services' => 'Interior Designer',
                'Renovation Services' => 'Renovation Specialist',
                'Furniture & Fittings' => 'Furniture Maker',
                'Furnishing & Fittings Installation' => 'Furnishing & Installation Expert',
                'Materials' => 'Renovation Specialist'
        };

        Map<String, List<String>> familyProductMap = new Map<String, List<String>>();
        for (Product2 product : selectedProducts) {
            if (!familyProductMap.containsKey(product.Family)) {
                familyProductMap.put(product.Family, new List<String>());
            }
            familyProductMap.get(product.Family).add(product.Name);
        }

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
                        Status = 'Pending',
                        WhatId = oppId,
                        Description = taskDescription
                );
                insert newTask;
            }
        }
    }
}
