public with sharing class OpportunityBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private Opportunity opportunity;

        public Builder() {
            opportunity = new Opportunity();
        }

        public Builder setName(String name) {
            opportunity.Name = name;
            return this;
        }

        public Builder setCloseDate(Date closeDate) {
            opportunity.CloseDate = closeDate;
            return this;
        }

        public Builder setStageName(String stageName) {
            opportunity.StageName = stageName;
            return this;
        }

        public Opportunity save() {
            insert opportunity;
            return opportunity;
        }

        public Opportunity getOpportunity() {
            return opportunity;
        }
    }
}