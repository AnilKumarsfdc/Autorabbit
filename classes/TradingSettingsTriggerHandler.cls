/* --------------------------------------------------------------------------------------------------
   Name:            TradingSettingsTriggerHandler.cls 
   Description:     Trigger Handler class which run through the logic of Auto-populating Trading 
                    Settings Name
   Test class:      TradingSettingControllerTest.cls    
  ------------------------------------------------------------------------------------------------ */
public with sharing class TradingSettingsTriggerHandler {
    private static String exceptionMessage; 
    /*
    * @description Populate trading settings name based on selected picklist value of the country
    */
    public static void processBeforeInsert(List<Trading_Settings__c> tradingSettingsList){
        try{
        	populateTradingSettingsNames(tradingSettingsList);
        }catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
    }   
    
    /*
    * @description Populate trading settings name based on selected picklist value of the country
    */
    public static void processBeforeUpdate(List<Trading_Settings__c> tradingSettingsList , Map<ID, Trading_Settings__c> tradingMap){
         try{
       		 populateTradingSettingsNames(tradingSettingsList);
         }catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
    }
    
    /*
    * @description populationg tradingSettingAccountMap data for creating Opportunity_International__c records 
    */
    public static void processAfterInsert(List<Trading_Settings__c> tradingSettingsList){
        try{
        	populateTradingSettingAccountMap(tradingSettingsList);
        }catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
    }
    
    /*
    * @description Checkbox check and date set for trading setting .
    */
    public static void populateTradingSettingsNames(List<Trading_Settings__c> tradingSettingsList){
        Schema.DescribeFieldResult fieldDescribe = Trading_Settings__c.Country__c.getDescribe();
        Schema.DescribeFieldResult corridorDescribe = Trading_Settings__c.Corridor_Country__c.getDescribe();
        Map<String, String> picklistMap = new Map<String, String>(); 
        Map<String, String> corridorPicklistMap = new Map<String, String>();
        
        for (Schema.PicklistEntry picklistData : fieldDescribe.getPicklistValues()){
            picklistMap.put(picklistData.getValue(), picklistData.getLabel());  
        }

        for (Schema.PicklistEntry corridorData : corridorDescribe.getPicklistValues()){
            corridorPicklistMap.put(corridorData.getValue(), corridorData.getLabel());  
        }
        
        for (Trading_Settings__c tradingSettings : tradingSettingsList){       
               if(tradingSettings.Country__c != null){
                    if (corridorPicklistMap.containsKey(tradingSettings.Country__c)){
                        tradingSettings.Name = corridorPicklistMap.get(tradingSettings.Country__c);
                        tradingSettings.International_Corridor__c = true;
                    }
                   // Code Added for user story no SR-333 . setting trading year .
                    if(tradingSettings.Importer__c != true){
                        tradingSettings.Importer_Year__c = null;
                    }
                                        
                    if(tradingSettings.Exporter__c != true){
                        tradingSettings.Exporter_Year__c = null;
                    }
                   
                    if(tradingSettings.Subsidiary__c != true){
                        tradingSettings.Subsidiary_Year__c = null;
                    }
                   
                    if(tradingSettings.Parent__c != true){
                        tradingSettings.Parent_Year__c = null;
                    }
                   // Code Ends for SR-333
                   
                    if (picklistMap.containsKey(tradingSettings.Country__c)){
                        tradingSettings.Name = picklistMap.get(tradingSettings.Country__c);
                }
            
            } 
        }
    }
    
    /*
    * @description: populationg tradingSettingAccountMap data for creating Opportunity_International__c records
    * by calling OpportunityInternationHelper Class async future method .
    */
    public static void populateTradingSettingAccountMap(List<Trading_Settings__c> tradingSettingsList){
        Map<Id, Set<Id>> tradingSettingAccountMap = new Map<Id,Set<id>>(); 
        for(Trading_Settings__c tradingSetting : tradingSettingsList){            
            if(tradingSettingAccountMap.keySet().contains(tradingSetting.Company__c)){                
                tradingSettingAccountMap.get(tradingSetting.Company__c).add(tradingSetting.Id);
            }else{                
                Set<Id> newTradingSettingSet = new Set<id>();
                newTradingSettingSet.add(tradingSetting.Id);
                tradingSettingAccountMap.put(tradingSetting.Company__c,newTradingSettingSet);
            }
        }
        if(tradingSettingAccountMap.size()>0){
            OpportunityInternationalHelper.createJunctionsForNewTradingSettings(JSON.serialize(tradingSettingAccountMap));
        }
    }    
    
}