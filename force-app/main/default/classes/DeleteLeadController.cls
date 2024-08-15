public without sharing class DeleteLeadController {
    public String leadId { get; set; }
    public Lead lead { get; set; }
    public User adminUser { get; set; }

    public DeleteLeadController() {
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        if (leadId != null) {
            fetchLead();
        }
    }

    public void fetchLead() {
        lead = [
                SELECT Id, FirstName, LastName, Email, Company
                FROM Lead
                WHERE Hashed_ID__c = :leadId
                LIMIT 1
        ];
    }

    public void fetchSystemAdminEmail() {
        adminUser = [
                SELECT Email
                FROM User
                WHERE Profile.Name = 'System Administrator'
                LIMIT 1
        ];
    }

    public OrgWideEmailAddress fetchOrgWideEmailAddress() {
        return [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = 'Urban Cube'
                LIMIT 1
        ];
    }

    public PageReference sendEmailToDeleteLead() {
        if (lead != null) {
            fetchSystemAdminEmail();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress orgEmail = fetchOrgWideEmailAddress();
            mail.setOrgWideEmailAddressId(orgEmail.Id);
            mail.setToAddresses(new String[]{
                    lead.Email
            });
            mail.setSubject('Lead Information To Delete');
            mail.setPlainTextBody(
                    'Lead Name: ' + lead.FirstName + ' ' + lead.LastName + '\n' +
                            'Lead Email: ' + lead.Email + '\n' +
                            'Lead Company: ' + lead.Company + '\n'
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
            PageReference pageRef = new PageReference('https://britenet-2e-dev-ed.develop.my.salesforce-sites.com/LeadDeleted');
            pageRef.setRedirect(true);
            return pageRef;
        }
        return new PageReference('https://britenet-2e-dev-ed.develop.my.salesforce-sites.com/LeadDeleted');
    }

    public PageReference cancel() {
        return new PageReference('https://britenet-2e-dev-ed.develop.my.salesforce-sites.com');
    }
}