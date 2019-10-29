/* -------------------------------------------------------------------------------------------------- 
   Description:     Test Class which checks functionality of ProductHoldingDataFixerBatch Batch.
   Test Class:      ProductHoldingDataFixerBatchTest.cls
   Date                 Version     Author              Summary of Changes 
   -----------          -------     ------------------- -------------------------------------------
   17-July-2018          0.1         Anjali Nigam         Initial
  ------------------------------------------------------------------------------------------------  */
@isTest(SeeAllData = false)
private with sharing class ProductHoldingDataFixerBatchTest{
    
    /*
	* @describe tests Product family update as per Product_Holding_Family__c custom setting config
	*/
    @isTest
    private static void testCompanyProductFamilyIsPopulated(){
        List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
        
        Product_Holding_Family__c pfObj = new Product_Holding_Family__c();
        pfObj.Name = GlobalConstants.TEST_CUSTOM_SETTING_NAME;
        pfObj.Sub_Type__c = GlobalConstants.TEST_SUB_TYPE;
        pfObj.Type__c = GlobalConstants.TEST_TYPE;
        pfObj.Product_Family__c = GlobalConstants.TEST_PRODUCT_FAMILY1;
        pfObj.Product_Name__c = GlobalConstants.TEST_PRODUCT_NAME;
        Database.insert(pfObj);
        
        List<BDP_Company__c> bdpCompanyList = PrepareTestData.PrepareBDPcompanies(1,true,accountsList[0].Id);	
        
        List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(10,false,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           bdpCompanyList[0].Id,null,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,null);
        Test.startTest();     
        Database.insert(hldgList);   
        Database.executeBatch(new ProductHoldingDataFixerBatch(),200);
        Test.stopTest();
        Holding__c updatedHldg = [SELECT Id, Name,Product_Family__c
                                  FROM Holding__c 
                                  WHERE Id =: hldgList[0].Id
                                  LIMIT 1];
        System.assertEquals(GlobalConstants.TEST_PRODUCT_FAMILY1,updatedHldg.Product_Family__c);
    }

}