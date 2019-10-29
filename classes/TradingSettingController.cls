/* --------------------------------------------------------------------------------------------------
     Name:            TradingSettingController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  of setting up trade
	 Test class:      TradingSettingControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class TradingSettingController { 
	/**
	 * @description Get the list of Company , exporter , Importer and trading allowed .
	 * @return Trading_Settings__c List 
	 **/
	@AuraEnabled
	public static List<TradingSettingWrapper> tradingSettings(String accountId) {

		try {           
            List<TradingSettingWrapper> tradingSettingWrapperList = new List<TradingSettingWrapper>();
			List<String> countryOption = new List<String> ();
			Trading_Settings__c tradingSetting = new Trading_Settings__c();
			
			Schema.DescribeFieldResult fieldResult = Trading_Settings__c.Country__c.getDescribe();
			Schema.DescribeFieldResult corridorDescribe = Trading_Settings__c.Corridor_Country__c.getDescribe();
			Map<String, String> corridorPicklistMap = new Map<String, String>();

			for (Schema.PicklistEntry corridorData : corridorDescribe.getPicklistValues()){                          
    				corridorPicklistMap.put(corridorData.getValue(), corridorData.getLabel());
    		}	

			Map<String, Trading_Settings__c> existingSettingsMap = new Map<String, Trading_Settings__c> ();

			for (Trading_Settings__c tsObj :[SELECT Id, Name, Company__c, Country__c,International_Corridor__c,  
                                          Exporter__c, Importer__c, Actual_Importer__c, Actual_Exporter__c,
                                          Customer__c, Parent__c, Subsidiary__c,Exporter_Formula__c,Importer_Formula__c
										  FROM Trading_Settings__c 
                                          WHERE Company__c = :accountId 
                                          LIMIT 10000]) {
                                              
				existingSettingsMap.put(tsObj.Country__c, tsObj);
			}

            
			List<Schema.PicklistEntry> picklistEnt = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry ple : picklistEnt) {                
                if (existingSettingsMap.containsKey(ple.getValue())) {
                    tradingSetting = existingSettingsMap.get(ple.getValue());
                    tradingSettingWrapperList.add(new TradingSettingWrapper(tradingSetting));
                } else if(ple.getValue()!='OT') {     
                    countryOption.add(ple.getValue());
                    tradingSetting = new Trading_Settings__c();
                    tradingSetting.Name = ple.getLabel();
                    tradingSetting.Country__c = ple.getValue();
                    tradingSetting.Parent__c = false;
                    tradingSetting.Subsidiary__c = false;
                    tradingSetting.Importer__c = false;
                    tradingSetting.Exporter__c = false;
                    tradingSetting.Actual_Exporter__c = false;
                    tradingSetting.Actual_Importer__c = false; 
                    tradingSetting.Customer__c = false;  
                    tradingSetting.International_Corridor__c = corridorPicklistMap.containsKey(ple.getValue());					
                    tradingSettingWrapperList.add(new TradingSettingWrapper(tradingSetting));
                }                                                
			}
          
			return tradingSettingWrapperList;
		}
		catch(Exception e) {
			throw e;
		}
	}   
    

	/**
	 * @description Save trading settings to the object .
	 **/
	@AuraEnabled
	public static void saveSettings(string insertTradeRecords) {
		List<Trading_Settings__c> records = null;

		if (insertTradeRecords != null) {
			records = (List<Trading_Settings__c>) JSON.deserialize(insertTradeRecords,
			                                                       List<Trading_Settings__c>.class);
		}
        
		List<Trading_Settings__c> recordsToDelete = new List<Trading_Settings__c> ();
		List<Trading_Settings__c> recordsToUpsert = new List<Trading_Settings__c> ();
		for (Trading_Settings__c ts : records) {
          
			if ((!ts.Exporter__c) && (!ts.Importer__c) && (!ts.Actual_Exporter__c) && (!ts.Actual_Importer__c) 
                && (!ts.Customer__c) && (!ts.Subsidiary__c) && (!ts.Parent__c) && !String.isBlank(ts.Id)) {
				recordsToDelete.add(ts);
			} else {
				recordsToUpsert.add(ts);
			}
		}

		if (recordsToDelete != null && recordsToDelete.size() > 0) {
			Database.delete(recordsToDelete);
		} 
        
        if (recordsToUpsert != null && recordsToUpsert.size() > 0) {
			Database.upsert(recordsToUpsert);
		}
	}
    
    
    /**
    * @description:Trading Settings Wrapper class with @AuraEnabled Properties.
    *  
    **/  
    public with sharing class TradingSettingWrapper {
        
        @AuraEnabled public String selectedImporterValue {get;set;}
        @AuraEnabled public String selectedExporterValue {get;set;}
        @AuraEnabled public Trading_Settings__c tradingSetting {get;set;}
        /**
         * Description: contstructor
         * */
        public TradingSettingWrapper(Trading_Settings__c tradingSetting){
            this.tradingSetting = tradingSetting;  
            this.selectedImporterValue = tradingSetting.Importer_Formula__c;
            this.selectedExporterValue = tradingSetting.Exporter_Formula__c;           
        }
    }
}