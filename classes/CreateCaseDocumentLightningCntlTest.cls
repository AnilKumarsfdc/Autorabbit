/* --------------------------------------------------------------------------------------------------
   Name:            CreateCaseDocumentLightningCntlTest.cls 
   Description:     Test Class for Aura controller CreateCaseDocumentLightningController
  ------------------------------------------------------------------------------------------------ */

@isTest (SeeAllData = false)
public class CreateCaseDocumentLightningCntlTest {

	private static final String PROFILE_NAME = 'System Administrator';
	private static final String TEST_RECORD_TYPE = 'Customer Risk Assessment';
	private static final String DOC_TYPE = 'KYC';
	private static final String DOC_DATA_TYPE = 'Date of Birth';
    
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

            List<Missing_Information__c> caseDocList = new List<Missing_Information__c>();
            Account acct = new Account(Name = 'Test');
            Database.insert(acct);
            
            Contact con = new Contact( AccountId = acct.Id, LastName = 'TestName');
            Database.insert(con);
            
            BDP_Company__c bdpCompany = new BDP_Company__c(Name = '1246786', Company__c = acct.Id, BDP_Customer_Number__c = '1246786');
            Database.insert(bdpCompany);
            
            BDP_Contact__c bdpContact = new BDP_Contact__c(Name='1231231', Last_Name__c = 'TestName', F_Number__c = '1231231', Salesforce_Contact__c = con.Id);
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
            
            
            Case_Contact__c caseContact = new Case_Contact__c(BDP_Contact__c = bdpContact.Id, Contact__c = con.Id, Case__c = case1.Id);
            Database.insert(caseContact);

			Missing_Information__c caseDocument1 = new Missing_Information__c();
			caseDocument1.Case__c = case1.Id;
			caseDocument1.Type__c = DOC_TYPE;
			caseDocument1.Data_Type__c = DOC_DATA_TYPE;
			caseDocList.add(caseDocument1);

			Missing_Information__c caseDocument2 = new Missing_Information__c();
			caseDocument2.Case_Contact__c = caseContact.Id;
			caseDocument2.Case__c = case1.Id;
			caseDocument2.Type__c = DOC_TYPE;
			caseDocument2.Data_Type__c = DOC_DATA_TYPE;
			caseDocList.add(caseDocument2);

            
            string caseDocumentToInsert = JSON.serialize(caseDocList);
            
            test.startTest();
			List<Case_Contact__c> caseConList = CreateCaseDocumentLightningController.getCaseContactList(case1.Id);
			Map<String, List<String>> docMap = CreateCaseDocumentLightningController.getDocumentTypes();
			CreateCaseDocumentLightningController.saveCaseDocuments(caseDocumentToInsert);
			test.stopTest();
			
			System.assertEquals(1,caseConList.size());
			System.assertNotEquals(0,docMap.size());
			List<Missing_Information__c> docsInserted = [SELECT Id
														 FROM Missing_Information__c
														 WHERE Case__c =: case1.Id];
			System.assertEquals(2,docsInserted.size());
        }       
    }      
}