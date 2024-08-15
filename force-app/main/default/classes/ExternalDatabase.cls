public class ExternalDatabase {
    private static final String BASE_ENDPOINT = 'callout:SecondFloor/services/apexrest/Leads';

    private static List<Lead> mockLeads;
    private static Boolean mockUpdateLead;
    private static Boolean mockDeleteLead;

    public static void setMockFetchLeads(List<Lead> leads) {
        mockLeads = leads;
    }

    public static void setMockUpdateLead(Boolean result) {
        mockUpdateLead = result;
    }

    public static void setMockDeleteLead(Boolean result) {
        mockDeleteLead = result;
    }

    public static List<Lead> fetchLeads(String search) {
        String targetEndpoint = BASE_ENDPOINT + '?nameQuery=' + search;
        HttpRequest req = new HttpRequest();
        req.setEndpoint (targetEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse res = http.send(req);
        try {
            if (res.getStatusCode() == 200) {
                return (List<Lead>) JSON.deserialize(res.getBody().replaceAll('\\\\', '').replaceAll('^\"|\"$', ''), List<Lead>.class);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static boolean updateLead(Lead leadToUpdate) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT + '/');
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        String leadJson = JSON.serialize(leadToUpdate);
        req.setBody(leadJson);
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            return true;
        } else {
            return false;
        }
    }

    public static boolean deleteLead(String id) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT + '?id=' + id);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            return true;
        }
        return false;
    }
}
