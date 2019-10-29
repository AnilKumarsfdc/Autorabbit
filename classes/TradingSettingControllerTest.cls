/* --------------------------------------------------------------------------------------------------
   Name:            TradingSettingControllerTest.cls 
   Description:     Test Class for Aura controller TradingSettingController  
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
 private class TradingSettingControllerTest {
     private final static String TEST_USER_PROFILE = 'SAN Relationship Director';

	 /**
	 * @description  This method tests fetching of all the trading details. 
	 * 
	 **/
     private static testMethod void runPositiveTestCases() {
         
        User usr = PrepareTestData.PrepareUser(1, true, 'System Administrator')[0];       
        System.runAs(usr){         
            Account acc = PrepareTestData.PrepareAccounts(1, true, 'Customer')[0];
            List<Trading_Settings__c> tsObj = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);
            List<TradingSettingController.TradingSettingWrapper> initRecordList = TradingSettingController.tradingSettings(acc.Id); //init
        
            tsObj[1].Exporter__c = false;
            tsObj[2].Importer__c = true; 
        
        	String jsonString = JSON.serialize(tsObj);
        	System.assert(initRecordList.size() > 200, 
                          'Number of countries is less then expected. Problem with generation');
        	TradingSettingController.saveSettings(jsonString);          
         }         
     }
    
	/**
	 * @description This method is for negative test purposes.  
	 * 
	 **/
    private static testMethod void runNegativeTestCases() {
                
       User usr = PrepareTestData.PrepareUser(1, true, TEST_USER_PROFILE)[0];
       System.runAs(usr){         
            Account acc = PrepareTestData.PrepareAccounts(1, true, 'Customer')[0];
            List<Trading_Settings__c> tsObj = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);
            List<TradingSettingController.TradingSettingWrapper> initRecordList = TradingSettingController.tradingSettings(acc.Id); //init
        
            tsObj[1].Exporter__c = false;
            tsObj[2].Importer__c = true; 
        
            String jsonString = JSON.serialize(tsObj);
            System.assert(initRecordList.size() > 200, 
                          'Number of countries is less then expected. Problem with generation');
            TradingSettingController.saveSettings(jsonString); 
         }              
    }    
}