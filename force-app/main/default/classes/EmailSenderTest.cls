@isTest
public class EmailSenderTest {

   @isTest
    static void testSendEmailToAllUsers() {
        Test.startTest();
        // Call the sendEmailToAllUsers method
        EmailSender.sendEmailToAllUsers('Test Subject', 'Test Body');
        Test.stopTest();

        // Add assertions here, e.g., check for email sending success or other specific outcomes
        // You can use System.assert methods to make assertions
    }

    @isTest
    static void testSendEmailToContacts() {
        // Create a test account and related contact records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                AccountId = testAccount.Id,
                FirstName = 'TestContact' + i,
                LastName = 'Last' + i,
                Email = 'testcontact' + i + '@example.com'
            ));
        }
        insert testContacts;

        Test.startTest();
        // Call the sendEmailToContacts method
        EmailSender.sendEmailToContacts(testAccount.Id, 'Test Subject', 'Test Body');
        Test.stopTest();

        // Add assertions here, e.g., check for email sending success or other specific outcomes
        // You can use System.assert methods to make assertions
    }
}