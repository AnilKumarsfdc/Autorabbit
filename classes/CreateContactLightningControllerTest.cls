/* --------------------------------------------------------------------------------------------------
Name:            CreateContactLightningControllerTest.cls 
Description:     Test Class for Aura controller CreateContactLightningController
------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class CreateContactLightningControllerTest {
    
    private static final String PROFILE_NAME = 'System Administrator';
    
    /**
	* @description Test for creating contact from BDP contact. 
	* 
	**/
    @isTest private static void runPositiveTests() {
        Boolean isChecked = True;
        String dummyEmail = 'test@test.com'; 
        
        System.runAs(PrepareTestData.getRunningUser()) {
            Account acct = new Account(Name='Test') ;
            Database.insert(acct);
            
            Account acct1 = new Account(Name='Test1') ;
            Database.insert(acct1);
            
            Account acct2 = new Account(Name='Test2') ;
            Database.insert(acct2);
            
            Contact cont = new Contact(LastName='Test Contact', Email='test1@test.com');
            Database.insert(cont);
            
            BDP_Company__c bdpCompany = new BDP_Company__c(Company__c = acct.Id, Name='12345678', BDP_Customer_Number__c = '12345678');
            Database.insert(bdpCompany);
            
            BDP_Company__c bdpCompany1 = new BDP_Company__c(Company__c = acct1.Id, Name='1234569', BDP_Customer_Number__c = '1234569');
            Database.insert(bdpCompany1);
            
            BDP_Company__c bdpCompany2 = new BDP_Company__c(Company__c = acct2.Id, Name='1234560', BDP_Customer_Number__c = '1234560');
            Database.insert(bdpCompany2);
            
            BDP_Contact__c bdpContact = new BDP_Contact__c(Name = 'Test Contact', First_Name__c = 'Test', Last_Name__c ='Contact', 
                                                           F_Number__c='2342322');
            Database.insert(bdpContact);
            
            BDP_Contact_Relationship__c bdpConRel = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id, BDP_Contact__c = bdpContact.Id);
            Database.insert(bdpConRel);
            
            BDP_Contact_Relationship__c bdpConRel1 = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany1.Id, BDP_Contact__c = bdpContact.Id);
            Database.insert(bdpConRel1);
            
            BDP_Contact_Relationship__c bdpConRel2 = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany2.Id, BDP_Contact__c = bdpContact.Id);
            Database.insert(bdpConRel2);
            
            test.startTest();
            
            List<BDP_Contact_Relationship__c> bdpConRelList = CreateContactLightningController.getCompanyList(bdpContact.Id);
            
            
            List<BDP_Contact__c> bdpContactList = [SELECT Id, Salesforce_Contact__c, BDP_Phone__c,
                                                   BDP_Email__c,First_Name__c, Last_Name__c 
                                                   FROM BDP_Contact__c WHERE id =: bdpContact.Id LIMIT 10000]; 
            
            CreateContactLightningController.ContactWrapper conWrapper = new CreateContactLightningController.ContactWrapper(cont, 'test');
            
            conWrapper = CreateContactLightningController.createSfdcContact(bdpContact.Id, acct.Id, isChecked, dummyEmail);
            //Contact con = CreateContactLightningController.createSfdcContact(bdpContact.Id, acct.Id, isChecked);
            
            BDP_Contact__c  bdpCon = [SELECT Id, Salesforce_Contact__c FROM BDP_Contact__c WHERE Id =: bdpContact.Id LIMIT 1000];
            List<AccountContactRelation> accConRelList = [SELECT Id, ContactId FROM AccountContactRelation WHERE ContactId =: conWrapper.conObj.Id LIMIT 1000];
            
            
            test.stopTest();
            System.assertEquals(conWrapper.conObj.Id, bdpCon.Salesforce_Contact__c);
            System.assertEquals(3, accConRelList.size());
            System.assertEquals(1, bdpContactList.size());
            System.assertEquals(3, bdpConRelList.size());
        }
    }
}