public with sharing class CaseEventCallout {

    @AuraEnabled
    public static void sendCaseEvent(String subject, String description) {

        Case_Event__e caseEvent = new Case_Event__e(
                Subject__c = subject,
                Description__c = description
        );

        String requestBody = JSON.serialize(caseEvent);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:NamedCred/services/data/v61.0/sobjects/Case_Event__e/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);

            if (res.getStatusCode() == 201) {
                System.debug('Platform event sent successfully.');
                System.debug('Response Body: ' + res.getBody());
            } else {
                throw new CalloutException('Error: Callout failed with Status Code: ' + res.getStatusCode());
            }

        } catch (Exception e) {
            throw new CalloutException('Error: ' + e.getMessage());
        }
    }
}

