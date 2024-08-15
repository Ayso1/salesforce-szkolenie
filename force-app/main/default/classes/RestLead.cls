@RestResource(urlMapping='/Leads/*')
global with sharing class RestLead {

    @HttpGet
    global static String receiveLeads() {
        try {
            String names = RestContext.request.params.get('nameQuery');
            String emails = RestContext.request.params.get('emailQuery');
            if (names == null) names = '';
            if (emails == null) emails = '';
            String nameQuery = '%'+names+'%';
            String emailQuery = '%'+emails+'%';
            List<Lead> leads = [
                    SELECT Name, FirstName, LastName, Email, Company
                    FROM Lead
                    WHERE Name LIKE :nameQuery
                    AND Email LIKE :emailQuery
            ];
            return JSON.serialize(leads);
        } catch (JSONException e) {
            return JSON.serialize('"error": "Failed To Prepare Data"');
        }
    }

    @HttpPatch
    global static String updateLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Lead updatedLead = (Lead) JSON.deserialize(req.requestBody.toString(), Lead.class);
        if (updatedLead.Id == null) {
            res.statusCode = 400;
            return 'Lead ID is required';
        }
        try {
            Lead existingLead = [
                    SELECT Name, Email, Company
                    FROM Lead
                    WHERE Id = :updatedLead.Id
                    LIMIT 1
            ];
            if (updatedLead.FirstName != null)
                existingLead.FirstName = updatedLead.FirstName;
            if (updatedLead.LastName != null)
                existingLead.LastName = updatedLead.LastName;
            if (updatedLead.Email != null)
                existingLead.Email = updatedLead.Email;
            if (updatedLead.Company != null)
                existingLead.Company = updatedLead.Company;
            update existingLead;
            res.statusCode = 200;
            return JSON.serialize(existingLead);
        } catch (QueryException e) {
            res.statusCode = 404;
            return 'Lead not found';
        } catch (DmlException e) {
            res.statusCode = 500;
            return 'Failed to update lead: ' + e.getMessage();
        }
    }

    @HttpDelete
    global static String deleteLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String leadId = RestContext.request.params.get('id');
        if (leadId == null) {
            res.statusCode = 400;
            return 'Lead ID is required';
        }
        try {
            Lead leadToDelete = [
                    SELECT Name
                    FROM Lead
                    WHERE Id = :leadId
            ];
            res.statusCode = 200;
            delete leadToDelete;
            return JSON.serialize(leadId);
        } catch (QueryException e) {
            res.statusCode = 404;
            return 'Lead not found';
        } catch (DmlException e) {
            res.statusCode = 500;
            return 'Failed to delete lead';
        }
    }
}