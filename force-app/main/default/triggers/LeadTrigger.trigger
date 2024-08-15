trigger LeadTrigger on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        if (lead.Id != null) {
            lead.Hashed_ID__c = EncryptionUtils.encrypt(lead.Id);
        }
    }
}

