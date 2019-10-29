/* --------------------------------------------------------------------------------------------------
Name:            ReportingControlsIntegrationHandler.cls 
Description:     Handler class for ReportingControlsIntegrationTrigger
Test class:      ReportingControlsIntegrationFlushTest.cls 
------------------------------------------------------------------------------------------------ */
public with sharing class ReportingControlsIntegrationHandler {

    /** 
	* @description : This method is used to process Before Insert Functionalities
	**/
    public static void processBeforeInsert(List<Reporting_Controls_Integration__c> repControlsList, Map<ID, Reporting_Controls_Integration__c> repControlsMap) {
        try{
            updateBDPLastUpdatedDate(repControlsList, repControlsMap);
        }catch(Exception exc){
            throw exc;
        }
    }
    
    /** 
	* @description : This method will set the Last Updated Date of J / F records
	**/
     public static void updateBDPLastUpdatedDate(List<Reporting_Controls_Integration__c> repControlsList, Map<ID, Reporting_Controls_Integration__c> repControlsMap) {
         
         Set<String> bdpIdentifierSet = new Set<String>(); 
         Map<String,BDP_Company__c> bdpCompanyMap = new Map<String,BDP_Company__c>();
         Map<String,BDP_Contact__c> bdpContactMap = new Map<String,BDP_Contact__c>();
         List<BDP_Company__c> bdpCompanyList = new List<BDP_Company__c>();
         List<BDP_Contact__c> bdpContactList = new List<BDP_Contact__c>();
         
         for(Reporting_Controls_Integration__c rciObj : repControlsList) {
           bdpIdentifierSet.add(String.valueof(rciObj.BDP_Identifier__c));
         } 
         
         for(BDP_Company__c bComObj : [Select Id,BDP_Last_Updated_Date__c, BDP_Customer_Number__c
             						 FROM BDP_Company__c
                                     WHERE BDP_Customer_Number__c IN : bdpIdentifierSet 
                                     LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
                    bdpCompanyMap.put(bComObj.BDP_Customer_Number__c,bComObj); 
         }
         
         for(BDP_Contact__c bConObj : [Select Id,BDP_Last_Updated_Date__c, F_Number__c
                                     FROM BDP_Contact__c
                                     WHERE F_Number__c IN : bdpIdentifierSet 
                                     LIMIT :GlobalConstants.MAX_QUERY_LIMIT]){
                    bdpContactMap.put(bConObj.F_Number__c,bConObj);
         }
        
         for(Reporting_Controls_Integration__c rciObj : repControlsList) {
             If(rciObj.SFDC_Last_Updated_Date__c > rciObj.BDP_Last_Updated_Date__c){
                 String bdpIdentifier = String.valueOf(rciObj.BDP_Identifier__c);                
                 if(rciObj.BDP_Type__c == GlobalConstants.BDP_TYPE_J){                     
                     if(bdpCompanyMap.keySet().contains(bdpIdentifier)){
                         BDP_Company__c bComObj = bdpCompanyMap.get(bdpIdentifier);
                         bComObj.BDP_Last_Updated_Date__c = rciObj.BDP_Last_Updated_Date__c;
                         bdpCompanyList.add(bComObj);
                     }
                 }else if(rciObj.BDP_Type__c == GlobalConstants.BDP_TYPE_F){                    
                     if(bdpContactMap.keySet().contains(bdpIdentifier)){
                         BDP_Contact__c bConObj = bdpContactMap.get(bdpIdentifier);
                         bConObj.BDP_Last_Updated_Date__c = rciObj.BDP_Last_Updated_Date__c;
                         bdpContactList.add(bConObj);
                     }
                 }
             }
         } 
         
         if(bdpCompanyList.size()>0){             
             Database.update(bdpCompanyList);
         }
          
         if(bdpContactList.size()>0){            
             Database.update(bdpContactList);
         }    
         
     }
}