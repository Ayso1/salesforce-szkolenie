public class CaseEventDTO {
    public String Subject;
    public String Description;

    public CaseEventDTO(Case_Event__e event) {
        this.Subject = event.Subject__c;
        this.Description = event.Description__c;
    }
}
