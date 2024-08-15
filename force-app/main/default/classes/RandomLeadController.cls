public without sharing class RandomLeadController {
    public List<Lead> randomLeads { get; set; }
    public String pageTitle { get; set; }
    public String nameHeader { get; set; }
    public String companyHeader { get; set; }
    public String emailHeader { get; set; }
    public String industryHeader { get; set; }
    public String createdDateHeader { get; set; }
    public String reloadButtonLabel { get; set; }

    public RandomLeadController() {
        pageTitle = 'Random Leads';
        nameHeader = 'Name';
        companyHeader = 'Company';
        emailHeader = 'Email';
        industryHeader = 'Industry';
        createdDateHeader = 'Created Date';
        reloadButtonLabel = 'Reload Page';
        loadRandomLeads();
    }

    public void loadRandomLeads() {
        List<Lead> allLeads = fetchAllLeads();
        allLeads = getShuffledList(allLeads);
        randomLeads = new List<Lead>();
        Integer numberOfLeadsToShow = Math.min(5, allLeads.size());
        for (Integer i = 0; i < numberOfLeadsToShow; i++) {
            randomLeads.add(allLeads.get(i));
        }
    }

    public List<Lead> getShuffledList(List<Lead> leads) {
        List<Lead> shuffledList = new List<Lead>();
        while (!leads.isEmpty()) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), leads.size());
            shuffledList.add(leads.remove(randomIndex));
        }
        return shuffledList;
    }

    private List<Lead> fetchAllLeads() {
        return [
                SELECT Name, Company, Email, Industry, CreatedDate
                FROM Lead
        ];
    }

    public PageReference refreshPage() {
        loadRandomLeads();
        return null;
    }
}
