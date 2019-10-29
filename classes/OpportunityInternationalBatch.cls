/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityInternationalBatch.cls 
   Description:     Batch runs through existing Trading Setting records and creates Opportunity_International__c 
					junction object records if any opportunites exists on related company.
   Test class:      OpportunityInternationalTest.cls 
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   20-Feb-2018          0.1        Vijay Sonawane        Intial
  ------------------------------------------------------------------------------------------------ */  
global class OpportunityInternationalBatch implements Database.Batchable<sObject> {
	  
       public final static String QUERY = 'select Id,Company__c from Trading_Settings__c order by Company__c'; 
       
       /*
        * @description Interface start method, which returns all Trading Setting records
        */
        global Database.QueryLocator start(Database.BatchableContext BC){        
            return Database.getQueryLocator(QUERY);
        }
       /*
        * @description Main batch execute method, which create map<CompanyId,Set<Trading Settings Ids>> 
        * for calling future method from OpportunityInternation Helper method 
        * and then create Opportunity_Interanational__c junction object records       
        */
        global void execute(Database.BatchableContext BC, List<Trading_Settings__c> scope){ 
            
            List<Opportunity_International__c> opportunityInternationalList = new List<Opportunity_International__c>();	
            Map<Id, Set<Id>> tradingSettingAccountMap = new Map<Id,Set<id>>(); 
            
            for(Trading_Settings__c tradingSetting : scope){            
                if(tradingSettingAccountMap.keySet().contains(tradingSetting.Company__c)){                
                    tradingSettingAccountMap.get(tradingSetting.Company__c).add(tradingSetting.Id);
                }else{                
                    Set<Id> newTradingSettingSet = new Set<id>();
                    newTradingSettingSet.add(tradingSetting.Id);
                    tradingSettingAccountMap.put(tradingSetting.Company__c,newTradingSettingSet);
                }
            }  
            
            for(Opportunity opp : [select id,AccountId from Opportunity where accountId IN : tradingSettingAccountMap.keySet() LIMIT 50000]){
                for(Id traddingSettingId : tradingSettingAccountMap.get(opp.AccountId)){
                    opportunityInternationalList.add(new Opportunity_International__c(Opportunity__c=opp.Id,Trading_Settings__c=traddingSettingId));
                }            
            }
            if(opportunityInternationalList.size()>0){
                Database.insert(opportunityInternationalList);
            }
       }
    
      /*
       * @description No final actions are required, so function is empty
       */
       global void finish(Database.BatchableContext BC){ 
       }
}