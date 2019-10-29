/* --------------------------------------------------------------------------------------------------
   Name:            BDPContactListControllerTest.cls 
   Description:     Test Class for Aura controller BDPContactListController

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   21-April-2017          0.1       Sheshant Kashyap    
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
 private class BDPContactListControllerTest {
    private static final String PROFILE_NAME = 'System Administrator';
  
    /**
	 * @description This test class with check the list of BDP companies associated with the BDP Contact  .
	 * 
	 **/
   @isTest  private static  void runPositiveTests() {
		System.runAs(PrepareTestData.getRunningUser()) {
			List<sObject> contactList = new List<sObject>();
            BDPContactListController.BdpContactWrapper wrapperObj = new BDPContactListController.BdpContactWrapper();
            
	        Account acct = new Account(Name='Test Account');
	        Database.insert(acct);
	        
	        BDP_Company__c bdpCompany = new BDP_Company__c(Name = '12312312', Company__c = acct.Id, BDP_Customer_Number__c= '12312312');
	        Database.insert(bdpCompany);
	        
	        BDP_Contact__c bdpContact = new BDP_Contact__c(Name = 'Test Contact', First_Name__c = 'Test', Last_Name__c ='Contact', 
	        											   F_Number__c='2342322', Active__c = true);
	        Database.insert(bdpContact);
	        
	        BDP_Contact_Relationship__c bdpRelationship = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id, BDP_Contact__c = bdpContact.Id);
	        Database.insert(bdpRelationship);
	        
	        Test.startTest();
	        wrapperObj = BDPContactListController.getContactList(acct.Id,1,10);
	        Test.stopTest();
	        
	        System.assertEquals(1, wrapperObj.bdpConRelList.size());
		}		
    }
}