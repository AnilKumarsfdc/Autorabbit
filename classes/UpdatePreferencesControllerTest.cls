/* --------------------------------------------------------------------------------------------------
   Name:            UpdatePreferencesControllerTest.cls 
   Description:     Test Class for Aura controller UpdatePreferencesController

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   28-Feb-2018          0.1       Vijay Sonawane    Initial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private class UpdatePreferencesControllerTest {
     
    private static final String PROFILE_NAME = 'System Administrator';
     
    /**
	 * @description This test class verifies preferences are available for selected contact 
	 * and returns latest preference
	 * 
	 **/
   @isTest  private static  void runPositiveTests() {
		
       System.runAs(PrepareTestData.getRunningUser()) {
           
			Contact contact= new Contact( FirstName='Test1', LastName='contact1', email='test@test.com');
            Database.insert(contact);
           
            Preferences__c pref1 = new Preferences__c();
            pref1.Contact__c=contact.ID;
            pref1.Products_and_Services__c = 'Open Products and Services only';
            Database.insert(pref1);
            Test.setCreatedDate(pref1.Id, System.today() - 8);
            
            Preferences__c pref2 = new Preferences__c();
            pref2.Contact__c=contact.ID;
            pref2.Products_and_Services__c = 'Open Products and Services only';
            Database.insert(pref2);
           
            Test.startTest();        	
	        	Preferences__c returnedPref = UpdatePreferencesController.getPreferncesData(contact.Id);
	        Test.stopTest();
            
	        System.assertEquals(returnedPref.Id, pref2.Id);            
		}		
    }
     
    
}