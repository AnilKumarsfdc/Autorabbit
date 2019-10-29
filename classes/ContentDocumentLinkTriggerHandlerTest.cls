/* --------------------------------------------------------------------------------------------------
   Name:            ContentDocumentLinkTriggerHandlerTest.cls 
   Description:     Test Class for Trigger Handler ContentDocumentLinkTriggerHandler

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   25-April-2017          0.1       Sheshant Kashyap    
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class ContentDocumentLinkTriggerHandlerTest {
    
	private static final String SHARE_TYPE = 'I';
	private static final String CONTENT_LOCATION = 'S';
	
	/**
	*@description Prepopulate Custom Settings for testing
	*/
	@testSetup
	private static void setupTestConfigSettings() {       
		Santander_Lending_Policy__c setting1 = new Santander_Lending_Policy__c();
		setting1.Name = '123456';
		setting1.SIC_Code__c = '123456';
		setting1.Brag_Status__c = 'RED';
		setting1.Sector_Policy__c = 'Test123';

		Santander_Lending_Policy__c setting2 = new Santander_Lending_Policy__c();
		setting2.Name = '654321';
		setting2.SIC_Code__c = '654321';
		setting2.Brag_Status__c = 'GREEN';
		setting2.Sector_Policy__c = 'Test321';
		Database.insert(new List<Santander_Lending_Policy__c>{setting1, setting2});
		
		ContentWorkspace documentRetentionLibrary = [SELECT Id, Name FROM ContentWorkspace LIMIT 1];
		Database.insert(new Config_Settings__c(
			Document_Retention_Library__c = documentRetentionLibrary.Id
		));
	}
	

    /**
	 * @description Test for updating checkbox on meeting record. 
	 * 
	 **/
    private static testMethod void runPositiveTests() {
       
		User usr = PrepareTestData.getRunningUser('System Administrator');

		System.RunAs(usr) {        
	        String name = 'Test Attachment';
	        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
	        string description = 'Test Description';
	        
	        Account acc = new Account(Name='Test', AnnualRevenue = 60000) ;
	        Database.insert(acc);
	       
	       	Case case1 = new Case(AccountId =acc.id, Type='Create J Number',Origin ='Phone',J_Number__c='581' );
	      	Database.insert(case1);
	       
	       	Missing_Information__c contentDoc = new Missing_Information__c(Case__c=case1.Id);
	       	Database.insert(contentDoc);
	        
	        Meeting__c meeting = new Meeting__c(Account__c= acc.Id , Attachment_Added__c = false, Incomplete__c = True);
	        Database.insert(meeting);
	        
	          
	        Company_Folder__c companyFolder = new Company_Folder__c(Company__c = acc.Id);
	        Database.insert(companyFolder);    	            
	            
	        Test.startTest();
	        
	        Id contentDocumentId = PrepareTestData.createTestContentDocumnet();
	        
	        ContentDocumentLink cdl = new ContentDocumentLink();
	        cdl.ContentDocumentId = contentDocumentId;
	        cdl.LinkedEntityId = meeting.Id;
	        cdl.ShareType = SHARE_TYPE;
	           
	       	ContentDocumentLink cdl1 = new ContentDocumentLink();
	        cdl1.ContentDocumentId = contentDocumentId;
	        cdl1.LinkedEntityId = contentDoc.Id;
	        cdl1.ShareType = SHARE_TYPE;
	        
	        Database.insert(new List<ContentDocumentLink>{cdl, cdl1}); 
	        
	        Test.stopTest();
	        
	        Meeting__c meetingRecord = [SELECT Id, Account__c, Attachment_Added__c, Incomplete__c FROM Meeting__c LIMIT 10000];	        
	        System.assert(meetingRecord.Attachment_Added__c, 'Attachment hasn\'t been added in Link properly');
	    }
	}
}