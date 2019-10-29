/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityInternationalHelper.trigger 
   Description:     Helper class for creating Opportunity_International__c(Junction object) records
					( Call is originating from Opportunity and Trading_Settings__c trigger)
   Test class:      OpportunityInternationalTest.cls 

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   13-Feb-2018          0.1         Vijay Sonawane      Initial 
  ------------------------------------------------------------------------------------------------  */
public class OpportunityInternationalHelper {
    /**
 	* @Description: accepts data from Opportunity trigger[isInsert && isAfter] for creation on Opportunity International records
 	* */
    @future
    public static void createJunctionsForNewOpportunities(String json_opportunityAccountMap){        
        Map<Id, Set<Id>> opportunityAccountMap=(Map<Id,Set<Id>>) JSON.deserialize(json_opportunityAccountMap, Map<Id,Set<Id>>.class);
        List<Opportunity_International__c> opportunityInternationalList = new List<Opportunity_International__c>();
        for(Trading_Settings__c tradingSetting : [select id,Company__c from Trading_Settings__c where Company__c IN : opportunityAccountMap.keySet()]){
		   for(Id oppId : opportunityAccountMap.get(tradingSetting.Company__c)){                
                opportunityInternationalList.add(new Opportunity_International__c(Opportunity__c=oppId,Trading_Settings__c=tradingSetting.Id));
            }            
        } 
        if(opportunityInternationalList.size()>0 && !GlobalConstants.IGNORE_OPPORTUNITY_TRIGGER){
            insert opportunityInternationalList;
        }      
    }
    
   /**
    * @Description: accepts data from TTrading_Settings__c trigger[isInsert && isAfter] for creation on Opportunity International records
    * */
    @future
    public static void createJunctionsForNewTradingSettings(String json_tradingSettingAccountMap){
        Map<Id, Set<Id>> tradingSettingAccountMap=(Map<Id,Set<Id>>) JSON.deserialize(json_tradingSettingAccountMap, Map<Id,Set<Id>>.class);        
        List<Opportunity_International__c> opportunityInternationalList = new List<Opportunity_International__c>();
        for(Opportunity opp : [select id,AccountId from Opportunity where accountId IN : tradingSettingAccountMap.keySet()]){
            for(Id traddingSettingId : tradingSettingAccountMap.get(opp.AccountId)){
                opportunityInternationalList.add(new Opportunity_International__c(Opportunity__c=opp.Id,Trading_Settings__c=traddingSettingId));
            }            
        }       
        if(opportunityInternationalList.size()>0 && !GlobalConstants.IGNORE_TRADING_SETTING_TRIGGER){
            insert opportunityInternationalList;
        }   
    }
}