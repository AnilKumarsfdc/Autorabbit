/* --------------------------------------------------------------------------------------------------
   Name:            CreateCaseContactLightningControllerTest.cls 
   Description:     Test Class for Aura controller CreateCaseContactLightningController
  ------------------------------------------------------------------------------------------------ */

@isTest(SeeAllData = false)
public class CreateCaseContactLightningControllerTest {
    private static final String PROFILE_NAME = 'System Administrator';
    private static final String TEST_RECORD_TYPE = 'Customer Risk Assessment';
    
    @isTest private static void runPositiveTests() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = :PROFILE_NAME LIMIT 1];
        
        
        
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
        
        system.runAs(user) {
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

            List<Case_Contact__c> caseConList = new List<Case_Contact__c>();
            Account acct = new Account(Name = 'Test');
            Database.insert(acct);
            
            Contact Contct = new Contact( AccountId = acct.Id, LastName = 'TestName');
            Database.insert(contct);
            
            BDP_Company__c bdpCompany = new BDP_Company__c(Name = '1246786', Company__c = acct.Id, BDP_Customer_Number__c = '1246786');
            Database.insert(bdpCompany);
            
            BDP_Contact__c bdpContact = new BDP_Contact__c(Name='TestName', Last_Name__c = 'TestName', F_Number__c = '1231231', Salesforce_Contact__c = Contct.Id);
            Database.insert(bdpContact);
            
            BDP_Contact_Relationship__c bdpConRel = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id, BDP_Contact__c = bdpContact.Id);
            Database.insert(bdpConRel); 
            
            Case case1 = new Case(RecordTypeId = caseRecordTypeInfo.get(TEST_RECORD_TYPE).getRecordTypeId(),
                                  Status = 'New', AccountId = acct.Id, 
                                  BDP_Company__c = bdpCompany.Id, 
                                  Priority = 'Medium', Type = 'CRA-High Risk',
                                  Reason = 'Triage Request', Subject = 'Test', 
                                  Front_Office_Contact_Identified__c = 'No'); 
            Database.insert(case1);
            
            
            Case_Contact__c caseContact = new Case_Contact__c(BDP_Contact__c = bdpContact.Id, Contact__c = contct.Id, Case__c = case1.Id);
            caseConList.add(caseContact);

            
            string caseContactToInsert = JSON.serialize(caseConList);
            
            test.startTest();
            CreateCaseContactLightningController.wrapperClass wrclass = new CreateCaseContactLightningController.wrapperClass(bdpConRel,true);
            List<CreateCaseContactLightningController.wrapperClass> wrapperList = CreateCaseContactLightningController.getContactList(case1.Id);
            
            CreateCaseContactLightningController.saveCaseContacts(caseContactToInsert);
            test.stopTest();

            System.assertEquals(1,wrapperList.size());

            Case_Contact__c caseCon = [SELECT Id, Case__c, Contact__c
                                       FROM Case_Contact__c LIMIT 1];
            System.assertEquals(case1.Id, caseCon.Case__c);
            System.assertEquals(Contct.Id, caseCon.Contact__c);
  
        }       
    }      
}