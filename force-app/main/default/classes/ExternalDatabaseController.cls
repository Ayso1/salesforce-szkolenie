public class ExternalDatabaseController {
    public List<Lead> leads { get; set; }
    public String searchKeyword { get; set; }

    public ExternalDatabaseController() {
        leads = new List<Lead>();
    }

    public void search() {
        leads = ExternalDatabase.fetchLeads(searchKeyword);
    }

    public void clear() {
        searchKeyword = '';
        leads = new List<Lead>();
    }

    @RemoteAction
    public static boolean updateLead(String jsonLead) {
        boolean leadUpdated = ExternalDatabase.updateLead((Lead) JSON.deserialize(jsonLead, Lead.class));
        return leadUpdated;
    }

    @RemoteAction
    public static void deleteLead(String id) {
        ExternalDatabase.deleteLead(id);
    }

}
