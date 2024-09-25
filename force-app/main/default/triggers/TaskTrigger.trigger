trigger TaskTrigger on Task (before insert, before update, after insert, after update, after delete ) {
    new TaskTriggerHandler().run();
}
