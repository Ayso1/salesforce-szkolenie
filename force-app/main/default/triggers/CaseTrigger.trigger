trigger CaseTrigger on Case (before insert) {
    for (Case caseRecord : Trigger.new) {
//        CasePlatformEventPublisher.publishCaseEvent(caseRecord);
    }
}
