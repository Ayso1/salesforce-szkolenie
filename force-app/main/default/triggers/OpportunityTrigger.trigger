trigger OpportunityTrigger on Opportunity (after update) {
    OppToOrderConvert.convertOrder(Trigger.new, Trigger.oldMap);
}

