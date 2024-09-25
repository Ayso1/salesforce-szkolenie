//public class CasePlatformEventPublisher {
//    public static void publishCaseEvent(Case caseRecord) {
//        Case_Event__e caseEvent = new Case_Event__e(
//                Subject__c = caseRecord.Subject,
//                Description__c = caseRecord.Description
//        );
//
//        System.enqueueJob(new CaseEventCallout(caseEvent));
//
//        System.debug('Case platform event prepared with subject: ' + caseRecord.Subject);
//    }
//}
public with sharing class CasePlatformEventPublisher {
//    @AuraEnabled
//    public static void publishCaseEvent(String subject, String description) {
//        Case_Event__e caseEvent = new Case_Event__e(
//                Subject__c = subject,
//                Description__c = description
//        );
//
//        System.enqueueJob(new CaseEventCallout(caseEvent));
//    }
}
