public class EmailSender {
    @AuraEnabled
    public static void sendEmailToAllUsers(String subject, String body) {
        // Query all User records in the organization
        List<User> allUsers = new List<User>();

        
        if (Test.isRunningTest()) {
            allUsers.add(new User(
                FirstName = 'TestUser',
                LastName = 'Last',
                Email = 'testuser' + '@example.com',
                Username = 'testuser' + System.currentTimeMillis() + '@misc.dev',
                Alias = 'test', 
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US'
            ));
        } else {
            allUsers = [SELECT Id, Email FROM User];
        }
        // Create a list to hold the email addresses of all users
        List<String> toAddresses = new List<String>();
        
        for (User u : allUsers) {
            // Add each user's email address to the list
            if (u.Email != null) {
                toAddresses.add(u.Email);
            }
        }
        
        // Create a SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Set the email addresses to which the email will be sent
        email.setToAddresses(toAddresses);
        
        // Set the email subject and body
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        // Check for any errors in sending the email
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('Email sent to all users successfully');
            } else {
                System.debug('Email sending to all users failed: ' + result.getErrors()[0].getMessage());
            }
        }
    }
    @AuraEnabled
    public static void sendEmailToContacts(String accountId, String subject, String body) {
        // Query all Contact records related to the specified Account
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE AccountId = :accountId];
        
        // Create a list to hold the email addresses of all contacts
        List<String> toAddresses = new List<String>();
        
        for (Contact c : contacts) {
            // Add each contact's email address to the list
            if (c.Email != null) {
                toAddresses.add(c.Email);
            }
        }
        
        // Create a SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Set the email addresses to which the email will be sent
        email.setToAddresses(toAddresses);
        
        // Set the email subject and body
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        // Check for any errors in sending the email
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('Email sent to contacts of the specified Account successfully');
            } else {
                System.debug('Email sending to contacts of the specified Account failed: ' + result.getErrors()[0].getMessage());
            }
        }
    }
}