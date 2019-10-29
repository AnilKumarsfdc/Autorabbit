/* --------------------------------------------------------------------------------------------------
   Name:            AssignBDPContactsControllerTest.cls 
   Description:     Test Class for Aura controller AssignBDPContactsController

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   20-Feb-2018          0.1       Vijay Sonawane    Initial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
 private class AssignBDPContactsControllerTest {
     
    private static final String PROFILE_NAME = 'System Administrator';
     
    /**
	 * @description This test class verifies bpd contacts are fetched for selected contact 
	 * 
	 **/
   @isTest  private static  void runPositiveTests() {
		
       System.runAs(PrepareTestData.getRunningUser()) {
			
            List<sObject> contactList = new List<sObject>();
            AssignBDPContactsController.OuterWrapper wrapperObj = new AssignBDPContactsController.OuterWrapper();            
            List<Account> accountList = PrepareTestData.PrepareAccounts(1, true, 'Customer');
	        
            Contact contact1= new Contact( FirstName='Test1',
                                          LastName='contact1',
                                          email='test@test.com',
                                          accountId=accountList[0].id);
            Database.insert(contact1);
            
	        BDP_Company__c bdpCompany = new BDP_Company__c(Name = '1234',
                                                           Company__c = accountList[0].Id,
                                                           BDP_Customer_Number__c= '1234');
	        Database.insert(bdpCompany);
            
	        BDP_Contact__c bdpContact1 = new BDP_Contact__c(Name = 'Test Contact1',
                                                            First_Name__c = 'Test1',
                                                            Last_Name__c ='Contact1', 
                                                            F_Number__c='1324',
                                                            Active__c = true,
                                                            Salesforce_contact__c=NULL);
            Database.insert(bdpContact1);
            BDP_Contact__c bdpContact2 = new BDP_Contact__c(Name = 'Test Contact2', 
                                                            First_Name__c = 'Test2',
                                                            Last_Name__c ='Contact2', 
 	        											    F_Number__c='5432',
                                                            Active__c = true);
	        Database.insert(bdpContact2);
	        
	        BDP_Contact_Relationship__c bdpRelationship = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id,
                                                                                          BDP_Contact__c = bdpContact1.Id);
	        Database.insert(bdpRelationship);
	        
            Test.startTest();        	
	        	wrapperObj = AssignBDPContactsController.getContactList(contact1.Id,1);
	        Test.stopTest();
            
	        System.assertEquals(1, wrapperObj.wrapperList.size());            
		}		
    }
     
    /**
	 * @description This test class verfies when no bdp contacts are fetched for selected contact .
	 * 
	 **/
   @isTest  private static  void runNegativeTests() {
		
       System.runAs(PrepareTestData.getRunningUser()) {
			
            List<sObject> contactList = new List<sObject>();
            AssignBDPContactsController.OuterWrapper wrapperObj = new AssignBDPContactsController.OuterWrapper();            
            List<Account> accountList = PrepareTestData.PrepareAccounts(1, true, 'Customer');
	        
            Contact contact1= new Contact( FirstName='Test1',
                                          LastName='contact1',
                                          email='test@test.com',
                                          accountId=accountList[0].id);
            Database.insert(contact1);
            
	        BDP_Company__c bdpCompany = new BDP_Company__c(Name = '1234',
                                                           Company__c = accountList[0].Id,
                                                           BDP_Customer_Number__c= '1234');
	        Database.insert(bdpCompany);
            
	        BDP_Contact__c bdpContact1 = new BDP_Contact__c(Name = 'Test Contact1',
                                                            Salesforce_contact__c=contact1.Id,
                                                            First_Name__c = 'Test1',
                                                            Last_Name__c ='Contact1', 
	        											    F_Number__c='1324',
                                                            Active__c = true);
            Database.insert(bdpContact1);
	        
	        BDP_Contact_Relationship__c bdpRelationship = new BDP_Contact_Relationship__c(BDP_Company__c = bdpCompany.Id,
                                                                                          BDP_Contact__c = bdpContact1.Id);
	        Database.insert(bdpRelationship);
	        
            Test.startTest();        	
	        	wrapperObj = AssignBDPContactsController.getContactList(contact1.Id,1);               
            Test.stopTest();
	        
	        System.assertEquals(0, wrapperObj.wrapperList.size());
		}
   }
     
     /**
	 * @description This test saveBDPContacts method .
	 * 
	 **/
   @isTest  private static  void testsaveBDPContacts() {
		
       System.runAs(PrepareTestData.getRunningUser()) {
            List<Account> accountList = PrepareTestData.PrepareAccounts(1, true, 'Customer');
            Contact contact1= new Contact( FirstName='Test1',
                                          LastName='contact1',
                                          email='test@test.com',
                                          accountId=accountList[0].id);
            Database.insert(contact1);
            Contact contact2= new Contact( FirstName='Test2',
                                          LastName='contact2',
                                          email='test2@test2.com',
                                          accountId=accountList[0].id);
            Database.insert(contact2);
	        BDP_Contact__c bdpContact = new BDP_Contact__c(Salesforce_contact__c=contact1.Id,  
	        											   F_Number__c='1324',
                                                           Active__c = true);
            Database.insert(bdpContact);
            bdpContact.Salesforce_contact__c=contact2.Id;
            List<Bdp_Contact__c> l_bdpContact=new List<Bdp_Contact__c>();
            l_bdpContact.add(bdpContact);
            String jsonString = Json.serialize(l_bdpContact);
            Test.startTest();
	        	AssignBDPContactsController.saveBDPContacts(jsonString);
            Test.stopTest();	
            BDP_Contact__c updatedBdpContact=[SELECT Salesforce_contact__c,id,Active__c 
                                              FROM BDP_Contact__c 
                                              WHERE Id=:bdpContact.id LIMIT 1];
	        System.assertEquals(contact2.Id, updatedBdpContact.Salesforce_contact__c);
		}
   } 
}