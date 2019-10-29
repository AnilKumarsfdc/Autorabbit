/* -------------------------------------------------------------------------------------------------- 
Description:     Test Class which checks functionality of ProductHoldingsController.
Test Class:      ProductHoldingsControllerTest.cls
Date             Version     Author               Summary of Changes 
-----------      -------     -------------------  -------------------------------------------
18-May-2018      0.1         Vijay R. Sonawane    Initial
------------------------------------------------------------------------------------------------  */
@isTest(SeeAllData = false)
private class ProductHoldingsControllerTest { 
    
    /*
    * @describe Create Product Holding for company and check aura enabled data for component
    */
    @isTest private static void testCompanyProductHoldingsFetched() {        

        List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);
        
        
        List<Holding__c> hldgList1 = PrepareTestData.PrepareProductHoldings(2,false,GlobalConstants.PRODUCT_HOLDINGS_COMPETITOR,
                                                                           null,accountsList[0].Id,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,null);
        List<Holding__c> hldgList2 = PrepareTestData.PrepareProductHoldings(2,false,GlobalConstants.PRODUCT_HOLDINGS_COMPETITOR,
                                                                           null,accountsList[0].Id,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY2,null);
        
        Database.insert(hldgList1);
        Database.insert(hldgList2);
        Test.startTest();
        ProductHoldingsController.ProductHoldingSummaryWrapper pswObj 
            =	ProductHoldingsController.getProductHoldingSummary(accountsList[0].Id);
        Test.stopTest();            
        System.assertEquals(2,pswObj.mapSummary.get(GlobalConstants.PRODUCT_HOLDINGS_COMPETITOR).size());
        
    }  
    
    /*
    * @describe Create Product Holding for company and check aura enabled pagination method
    */
    @isTest private static void testCompanyProductHoldingsPagination() {
        List<Account> accountsList = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER);      
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Holding__c.getRecordTypeInfosByName();
        Id santanderRecordTypeId = recordTypes.get(GlobalConstants.PRODUCT_HOLDINGS_SANTANDER).getRecordTypeId();
        
       
        List<Holding__c> hldgList = PrepareTestData.PrepareProductHoldings(1,false,GlobalConstants.PRODUCT_HOLDINGS_SANTANDER,
                                                                           null,accountsList[0].Id,
                                                                           GlobalConstants.TEST_PRODUCT_FAMILY1,null);    
        Database.insert(hldgList);
        Test.startTest();
        ProductHoldingsController.ProductDetailPagerWrapper pspwObj 
            = ProductHoldingsController.fetchProductHoldingsDetails(
                accountsList[0].Id,
                GlobalConstants.TEST_PRODUCT_FAMILY1,
                1,
                santanderRecordTypeId,
                1
            );
        Test.stopTest();            
        System.assertEquals(1,pspwObj.products.size());
        
    } 
}