/* -------------------------------------------------------------------------------------------------- 
   Description:     Test Class which checks functionality of ProductHoldingsTrigger trigger.
   Test Class:      ProductHoldingsTriggerHandlerTest.cls
   Date                 Version     Author              Summary of Changes 
   -----------          -------     ------------------- -------------------------------------------
   11-May-2018          0.1       Vijay R. Sonawane   Initial
  ------------------------------------------------------------------------------------------------  */
@isTest(SeeAllData = false)
private with sharing class ProductHoldingsTriggerHandlerTest {
	
   /*
	* @describe Create Product Holding and Company lookup will be populated
	*/
    @isTest private static void testCompanyLookupIsPopulated() {
        
        List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
        List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);
    	
        List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(1,false,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,null);
    	  		
        Test.startTest();
    	Database.insert(hldgList); 
        Test.stopTest();
        
        Holding__c updatedHldg = [SELECT Id, Company__c 
                                  FROM Holding__c 
                                  WHERE BDPRecord__c =: bdpCompanyList[0].Id
                                  LIMIT 1];
        System.assertEquals(accountsList[0].Id,updatedHldg.Company__c);    	
    }    
    
    /*
	* @describe tests Product family update as per Product_Holding_Family__c custom setting config
	*/
    @isTest private static void testCompanyProductFamilyIsPopulated() {
        
        List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
        
        Product_Holding_Family__c pfObj = new Product_Holding_Family__c();
        pfObj.Name = GlobalConstants.TEST_CUSTOM_SETTING_NAME;
        pfObj.Sub_Type__c = GlobalConstants.TEST_SUB_TYPE;
        pfObj.Type__c = GlobalConstants.TEST_TYPE;
        pfObj.Product_Family__c = GlobalConstants.TEST_PRODUCT_FAMILY1;
        pfObj.Product_Name__c = GlobalConstants.TEST_PRODUCT_NAME;
        Database.insert(pfObj);
        
        List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);		       
    	
        List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(1,false,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,null);
    	
        Test.startTest();                
        Database.insert(hldgList);   
        Test.stopTest();
        Holding__c updatedHldg = [SELECT Id, Name,Product_Family__c
                                  FROM Holding__c 
                                  WHERE Id =: hldgList[0].Id
                                  LIMIT 1];
        System.assertEquals(GlobalConstants.TEST_PRODUCT_FAMILY1,updatedHldg.Product_Family__c);
        System.assertEquals(GlobalConstants.TEST_PRODUCT_NAME,updatedHldg.Name);
        
    }  
    
    /*
	* @describe tests Account status when new Santender Holding is created with Open Status
	*/
    @isTest private static void TestOpenHoldingToUpdateStatus(){
    	List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
        accountsList[0].status__c = GlobalConstants.COMPANY_STATUS_INACTIVECUSTOMER;
        update accountsList;
    	List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);
        Test.startTest(); 
    	PrepareTestData.PrepareProductHoldings(1,true,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                       null,GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS);
        Test.stopTest();
        Account accObj = [SELECT Id, Name,Status__c
                                  FROM Account 
                                  WHERE Id =: accountsList[0].Id
                                  LIMIT 1];
        System.assertEquals(accObj.Status__c,GlobalConstants.COMPANY_STATUS_ACTIVECUSTOMER);
       
    }
    
    /*
	* @describe tests Account status when only Santender Holding is updated with Closed Status 
	*/   
   /* @isTest private static void TestAllHoldingClosed(){
    	List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
    	List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);
    	List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(1,true,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                        GlobalConstants.TEST_PRODUCT_FAMILY1,GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS); 
        Test.startTest(); 
        hldgList[0].status__c = GlobalConstants.PRODUCT_HOLDINGS_CLOSED_STATUS;
        update hldgList;
        Test.stopTest();
        Account accObj = [SELECT Id, Name,Status__c
                                  FROM Account 
                                  WHERE Id =: accountsList[0].Id
                                  LIMIT 1];
        System.assertEquals(accObj.Status__c,GlobalConstants.COMPANY_STATUS_FORMERCUSTOMER);
    }*/
    
    /*
	* @describe tests Account status when Santender Holding is updated with Closed Status and Open Satus Both 
	*/   
   /* @isTest private static void TestHoldingHavingClosedandOpenStatus(){
    	List<Account> accountsList = PrepareTestData.PrepareAccounts(2, true, GlobalConstants.ACCOUNT_CUSTOMER);
    	List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);
    	PrepareTestData.PrepareProductHoldings(1,true,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS); 
        Test.startTest(); 
        List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(1,true,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS);  
        hldgList[0].status__c = GlobalConstants.PRODUCT_HOLDINGS_CLOSED_STATUS;
        update hldgList;
        Test.stopTest();
        Account accObj = [SELECT Id, Name,Status__c
                                  FROM Account 
                                  WHERE Id =: accountsList[0].Id
                                  LIMIT 1];
        System.assertEquals(accObj.Status__c,GlobalConstants.COMPANY_STATUS_ACTIVECUSTOMER);
    }*/
}