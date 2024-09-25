@IsTest
public class TaskTriggerHandlerTest {
    @IsTest
    static void testTaskValidation() {
        Task task = new Task(
                Subject = 'Follow up on Opportunity',
                Status = 'In Progress',
                Start_Date__c = null,
                ActivityDate = null
        );
        Test.startTest();

        try {
            insert task;
            System.assert(false, 'Task insert should have failed due to validation errors.');
        } catch (DmlException e) {
            System.debug('DML Exception Message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Start Date is required.'), 'Expected error message for start date validation.');
            System.assert(e.getMessage().contains('Due Date is required.'), 'Expected error message for due date validation.');
            System.assert(e.getMessage().contains('Status must be "Pending" when the task is created'), 'Expected error message for status validation.');
        }

        Test.stopTest();
    }
}
