public with sharing class SendEmailController {
    public void sendEmail() {
        User admin = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { admin.Email });
        mail.setSubject('Test Email from Visualforce Page');
        mail.setPlainTextBody('This is a test email sent from a Visualforce page when a button is clicked.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}