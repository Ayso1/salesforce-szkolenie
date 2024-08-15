public with sharing class OpportunityLineItemBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private OpportunityLineItem opportunityLineItem;

        public Builder() {
            opportunityLineItem = new OpportunityLineItem();
        }

        public Builder setOpportunityId(Id opportunityId) {
            opportunityLineItem.OpportunityId = opportunityId;
            return this;
        }

        public Builder setPricebookEntryId(Id pricebookEntryId) {
            opportunityLineItem.PricebookEntryId = pricebookEntryId;
            return this;
        }

        public Builder setQuantity(Decimal quantity) {
            opportunityLineItem.Quantity = quantity;
            return this;
        }

        public Builder setUnitPrice(Decimal unitPrice) {
            opportunityLineItem.UnitPrice = unitPrice;
            return this;
        }

        public OpportunityLineItem save() {
            insert opportunityLineItem;
            return opportunityLineItem;
        }

        public OpportunityLineItem getOpportunityLineItem() {
            return opportunityLineItem;
        }
    }
}