/***********************************
Name: collateralPledgeTriggerHandler
Created Date: 21-09-2019
Version: 1.0
Description: This class is used to handle all the operations performed on the CollateralPledge trigger.
        
************************************/
        
public with sharing class collateralPledgeTriggerHandler { 
          
            
/***********************************
Method Name: ltvCollateralpledgecalulation
Created Date: 21-09-2019
Version: 1.0
Input parameters: List of newCollateralpledges, isInsert
Output Parameters: None
Description: This method is used to call the LTV calcualtion class when Collateralpledge is inserted
************************************/  
            
            public Boolean ltvCollateralpledgecalulation(List<LLC_BI__Loan_Collateral2__c> newCollateralpledge,Boolean isInsert,Boolean isUpdate,Boolean isDelete)
            {    
                
                	List<Id> productpackageIds=new List<Id>();
                	List<Id> newCollateralpledgeIds=new List<Id>();
                	List<LLC_BI__Loan_Collateral2__c> colpledgeList;
                    for(LLC_BI__Loan_Collateral2__c colpldge : newCollateralpledge){
                    		newCollateralpledgeIds.add(colpldge.Id);
                    }
                
				   if(!newCollateralpledgeIds.isEmpty()){
                   		colpledgeList=SOQLUtility.getnewcollateralpledge(newCollateralpledgeIds);
                   }
                  try{
                      if(!colpledgeList.isEmpty()){
                    	for(LLC_BI__Loan_Collateral2__c collateral :colpledgeList){
                            if(collateral.LLC_BI__Loan__r.LLC_BI__Product_Package__c!=null){
                           		productpackageIds.add(collateral.LLC_BI__Loan__r.LLC_BI__Product_Package__c) ;
                        	}
                        }
                      }
                    
                        if(!productpackageIds.isEmpty()){
                         		LTVPPCalculation.calculateLTVForPP(productpackageIds,false);
                          }
                      
                      		 return true;
                       }catch(Exception e){
                           
                           return false;
                }              
    }
  }