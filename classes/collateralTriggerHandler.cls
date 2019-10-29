/***********************************
Name: collateralTriggerHandler
Created Date: 19-09-2019
Version: 1.0
Description: This class is used to handle all the operations performed on the Collateral trigger.

************************************/
public with sharing class collateralTriggerHandler {
    
   public static Boolean runOnce = true;

    
    
/***********************************
Method Name: OnAfterInsert
Created Date: 10-08-2019
Version: 1.0
Input parameters: List of newRecords
Output Parameters: None
Description: This method is used to perform all the action when collateral after insert trigger will be invoked.
************************************/ 
    
   // public void OnAfterInsert(List<LLC_BI__Collateral__c> newcollaterals){
      
       // system.debug('test method on after insert');
        //ltvCollateralcalulation(newcollaterals);
        
//    }
/***********************************
Method Name: OnAfterUpdate
Created Date: 10-08-2019
Version: 1.0
Input parameters: List of newRecords, List of Old Records
Output Parameters: None
Description: This method is used to perform all the action when collateral after update trigger will be invoked.
************************************/            
    
// public void OnAfterUpdate(List<LLC_BI__Collateral__c> newCollaterals,Map<Id,LLC_BI__Collateral__c>oldCollaterals){
        
     
        
  //  }
    
/***********************************
Method Name: OnBeforeDelete
Created Date: 10-08-2019
Version: 1.0
Input parameters: List of newRecords
Output Parameters: None
Description: This method is used to perform all the action when collateral before delete trigger will be invoked.
************************************/             
    
  //  public void OnBeforeDelete(Map<Id,LLC_BI__Collateral__c>oldCollaterals){
        
        
        
    //}
    
   
    
/***********************************
Method Name: ltvCollateralcalulation
Created Date: 19-09-2019
Version: 1.0
Input parameters: List of newCollaterals, oldCollaterals, isInsert,isUpdate
Output Parameters: None
Description: This method is used to call the LTV calcualtion class when Collateral is inserted or updated

************************************/  
    
    public Boolean ltvCollateralcalulation(List<LLC_BI__Collateral__c> newCollaterals,Map<Id,LLC_BI__Collateral__c>oldCollaterals,Boolean isInsert,Boolean isUpdate, Boolean isDelete)
    {    
        List<Id> productpackageIds=new List<Id>();
        List<Id> collateralList = new List<Id>();
        
        try{
            system.debug('Inside New Collaterals boolean value' + isInsert);
            if(isInsert==true){
               
                for (LLC_BI__Collateral__c col:newCollaterals){
                    
                    collateralList.add(col.Id);
                 }
                
                system.debug('Inside New Collaterals');
                system.debug(' New Collaterals list ids-->'+ collateralList);
              }
            
            if(isUpdate==true){
                
                for (LLC_BI__Collateral__c co:newCollaterals){
                    LLC_BI__Collateral__c oldCollateral=oldCollaterals.get(co.Id);
                    if((co.Santander_Value__c !=oldCollateral.Santander_Value__c)||(co.Collateral_Valuation_Value__c !=oldCollateral.Collateral_Valuation_Value__c) ||(co.Collateral_Type_Formula__c !=oldCollateral.Collateral_Type_Formula__c)||(co.Lendable_Value_WDV__c !=oldCollateral.Lendable_Value_WDV__c)|| (co.Collateral_Valuation_Value__c!=oldCollateral.Collateral_Valuation_Value__c)||(co.Active_Collateral_LTV__c!=oldCollateral.Active_Collateral_LTV__c)||(co.Ranking__c !=oldCollateral.Ranking__c)||(co.Direct_Third_Party_Charge__c !=oldCollateral.Direct_Third_Party_Charge__c)||(co.Further_Advance_with_no_DoP__c!=oldCollateral.Further_Advance_with_no_DoP__c)){
                        collateralList.add(co.Id);     
                    }
                }
                
               system.debug('Inside update Collaterals');
               system.debug(' updated Collaterals list ids-->'+ collateralList); 
              }
              if(isDelete==true){
                  
                  for (LLC_BI__Collateral__c col:oldCollaterals.values()){
                    
                    collateralList.add(col.Id);
                 }
                
                system.debug('Inside delete Collaterals');
               system.debug('deleted Collaterals list ids-->'+ collateralList);   
              }
            
                if(!collateralList.isEmpty()){
                    
                    system.debug('UpdatedCollateralslist' + collateralList);
                    
                    List<LLC_BI__Loan_Collateral2__c> colpledgeList=SOQLUtility.getcollateralpledgeforCollaterals(collateralList);
                    
                    if(!colpledgeList.isEmpty()){
                        for(LLC_BI__Loan_Collateral2__c collateral :colpledgeList){
                            
                            if(string.isNotBlank(collateral.LLC_BI__Loan__r.LLC_BI__Product_Package__c)) {
                                productpackageIds.add(collateral.LLC_BI__Loan__r.LLC_BI__Product_Package__c) ;
                            }
                        }
                        
                        
                    } 
                    
                    if(!productpackageIds.isEmpty()){
                        // calling the calcualtion method 
                        
                         LTVPPCalculation.calculateLTVForPP(productpackageIds, false); 
                    }
                }
                
           
          
            return true;
        }catch(Exception e){
            
            
            return false;
            
            
        }
        
    }
    
  
}