/* --------------------------------------------------------------------------------------------------
     Name:            AttachFileLightningControllerTest.cls 
     Description:     Test Class for Aura controller AttachFileLightningController
  <EOF>
     Date                 Version     Author              Summary of Changes 
     -----------          -------     -----------------   -------------------------------------------
     21-April-2017          0.1       Sheshant Kashyap    Ability to upload bigger files
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class AttachFileLightningControllerTest {

    /**
     * @description Test for adding attachment for company folder
     * 
     **/
    @isTest private static void runPositiveTests() {

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User user = new User(LastName = 'Test',
                             FirstName = 'User',
                             Alias = 'utest',
                             Email = 'santander@test.com',
                             Username = 'santander@test.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US'
        );

        System.RunAs(user) {

            String name = 'Test Attachment';
            string base64Data = EncodingUtil.urlEncode(name, 'UTF-8');
            string content = 'text/plain';
            string description = 'Passport';
            Id attachId = null;
            Boolean lastChunk = true;

            Account acct = new Account(Name = 'Test');
            Database.insert(acct);

            List<Company_Folder__c> comFolderList = [SELECT Id, Name from Company_Folder__c where Company__c = :acct.Id LIMIT 10000];

            test.startTest();

            Company_Folder__c[] comFol = AttachFileLightningController.getfolderName(acct.Id);


            Map<String, List<String>> tags = AttachFileLightningController.getDocumentTypes();

            Company_Folder__c companyFolder = [SELECT Id, Name from Company_Folder__c where Company__c = :acct.Id LIMIT 1];

            Id contentId = AttachFileLightningController.saveTheChunk(companyFolder.Id, name, base64Data, content, description, false, attachId);

            Attachment attachment = [SELECT Id, ParentId, Description, Name FROM Attachment WHERE Name = :name LIMIT 10000];

            Id attId = AttachFileLightningController.saveTheChunk(companyFolder.Id, name, base64Data, content, description, lastChunk, contentId);
            test.stopTest();
            System.assertEquals(comFolderList.size(), comFol.size());
            System.assertEquals(contentId, attachment.Id);
            System.assertEquals(companyFolder.Id, attachment.ParentId);
            System.assertEquals(contentId, attId);
        }
    }
}