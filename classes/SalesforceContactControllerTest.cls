/* --------------------------------------------------------------------------------------------------
Name:            SalesforceContactControllerTest.cls 
Description:     Test Class for Aura controller SalesforceContactController
------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class SalesforceContactControllerTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    
    /**
	* Ensures that Primary Contact is not added on creation
	**/ 
    private static testMethod void assignRapportContactTest() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        
        system.runAs(user) {
            RecordType customerRecordType = [SELECT Id FROM RecordType WHERE Name=:GlobalConstants.CUSTOMER_RECORD_TYPE LIMIT 1];
            Account testAccount = PrepareTestData.getDefaultAccount();
            testAccount.RecordTypeId = customerRecordType.Id;
            Database.insert(testAccount);
            
            Contact testContact = new Contact(LastName='TestCont1', AccountId= testAccount.Id);
            Database.insert(testContact);
            
            BDP_Company__c bdpCompany = new BDP_Company__c(Company__c = testAccount.Id, BDP_Customer_Number__c = '1246786');
            Database.insert(bdpCompany);
            
            BDP_Contact__c bdpContact = new BDP_Contact__c(Name = 'Test Contact', First_Name__c = 'Test', Last_Name__c ='Contact', 
                                                           F_Number__c='2342322');
            Database.insert(bdpContact);
            
            BDP_Contact_Relationship__c bdpConRel = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id, BDP_Contact__c = bdpContact.Id);
            Database.insert(bdpConRel);
            
            Test.startTest();		
            List<AccountContactRelation> accConRel= SalesforceContactController.getContactList(bdpContact.Id);
            Contact fetchedContact = SalesforceContactController.getSalesforceContact(bdpContact.Id);
            
            bdpContact.Salesforce_Contact__c = testContact.Id; 
            List<BDP_Contact__c> bdpConList = new List<BDP_Contact__c> { bdpContact };
            String conToUpsertString = JSON.serialize(bdpConList);
            SalesforceContactController.updateSalesforceContact(conToUpsertString);
            Test.stopTest();
            
            BDP_Contact__c resultBdpContact = [SELECT Id, Salesforce_Contact__c FROM BDP_Contact__c WHERE Id = :bdpContact.Id LIMIT 1];
            System.assertEquals(1, accConRel.size());
            System.assertEquals(testContact.Id,resultBdpContact.Salesforce_Contact__c);
        }
    }
}