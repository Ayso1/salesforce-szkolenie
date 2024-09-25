trigger ProductTrigger on Product2  (before insert, before update, after insert, after update, after delete) {
    new ProductTriggerHandler().run();
}