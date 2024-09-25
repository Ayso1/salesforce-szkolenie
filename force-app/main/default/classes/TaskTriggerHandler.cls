public with sharing class TaskTriggerHandler extends TriggerHandler {

    override protected void beforeInsert() {
        validateTasks((List<Task>) Trigger.new);
    }

    private static void validateTasks(List<Task> tasks) {
        for (Task task : tasks) {
            if (task.Subject != null && task.Subject.contains('Follow up on Opportunity')) {
                if (task.ActivityDate == null) {
                    task.addError(Label.Due_Date_Required_Label);
                }
                if (task.Start_Date__c == null) {
                    task.addError(Label.Start_Date_Required_Label);
                }
                if (task.Status != Util.PENDING) {
                    task.addError(Label.Status_Pending_Required_Label);
                }

                String availabilityMessage = getUserAvailabilityMessage(task.OwnerId, task.Start_Date__c, task.ActivityDate);
                if (availabilityMessage != null) {
                    task.addError(Label.User_Not_Avalaible_Label + ' ' + availabilityMessage);
                }
            }
        }
    }

    private static String getUserAvailabilityMessage(Id userId, Date startDate, Date endDate) {
        List<Task> userTasks = [
                SELECT Id, ActivityDate
                FROM Task
                WHERE OwnerId = :userId
                AND (ActivityDate <= :endDate AND ActivityDate >= :startDate)
        ];

        if (!userTasks.isEmpty()) {
            Task conflictingTask = userTasks[0];
            return Label.Conflicting_Due_Label + ' ' + conflictingTask.ActivityDate.format();
        }

        return null;
    }
}
