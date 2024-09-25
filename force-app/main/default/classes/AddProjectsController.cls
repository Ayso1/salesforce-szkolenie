public with sharing class AddProjectsController {

    @AuraEnabled
    public static List<Project_Product__c> getProductsByProjectIds(List<Id> projectIds) {
        try {
            return AddProjectHelper.getProductsByProjectIds(projectIds);
        } catch (Exception e) {
            throw new AuraHandledException(Label.Error_Retrieving_Products);
        }
    }

    @AuraEnabled
    public static List<Project__c> getAllProjects() {
        try {
            return AddProjectHelper.getAllProjects();
        } catch (Exception e) {
            throw new AuraHandledException(Label.Error_Retrieving_Projects);
        }
    }

    @AuraEnabled
    public static void createTaskAndOppProduct(List<Map<String, Object>> selectedProducts, Date realizationTime, Date startDate, Id oppId) {
        try {
            AddProjectHelper.createTaskAndOppProduct(selectedProducts, realizationTime, startDate, oppId);
        } catch (Exception e) {
            throw new AuraHandledException(Label.Creating_Tasks_and_Opportunity_Error);
        }
    }
}
