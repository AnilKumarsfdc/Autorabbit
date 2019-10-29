/***********************************
    Name: collateralPledgeTriggerHandlerTest
    Created Date: 16-10-2019
    Version: 1.0
    Description: This class is used to handle all the operations performed on the CollateralPledge trigger.
************************************/
 @isTest
private class collateralPledgeTriggerHandlerTest {
    
            
/***********************************
    Method Name: setup
    Input parameters: None
    Output Parameters: None
    Description: This method is used to setup the data for the test class
    
************************************/ 
        
         @testSetup static void setup(){
        
         List<Account> accounts= TestDataFactoryUtility.createAccounts(2);
         Id AccountId = [ Select id from Account LIMIT 1].Id;
         List< LLC_BI__Product_Package__c> productPackage= TestDataFactoryUtility.createProductPackageswithAccount(2,AccountId);
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
         List <LLC_BI__Legal_Entities__c> legalEntities=TestDataFactoryUtility.createLegalEntities(2,AccountId,productpackageId);
         List<LLC_BI__Loan__c> loans=TestDataFactoryUtility.createLoanswithProductpackage(2,productpackageId);
        
         Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
         List<LLC_BI__Collateral__c> collaterals= TestDataFactoryUtility.createCollaterals(2);
         Id collateralId =[ Select id from LLC_BI__Collateral__c where id IN:collaterals LIMIT 1].Id;
        
        
         }
    
  /****************************************************************
* Method: validateLTVCalculation
* Description: To validate ltv calcualtion on CollateralPledge
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
       static testMethod void validateLTVCalculation() {
           
           Id loanId =[ Select id from LLC_BI__Loan__c LIMIT 1].Id;
            Id collateralId =[ Select id from LLC_BI__Collateral__c LIMIT 1].Id;
             Test.StartTest();
             List<LLC_BI__Loan_Collateral2__c> collateralPledge=TestDataFactoryUtility.createCollateralPledge(2,loanId,collateralId);
             Test.StopTest();
           
           
       }  
    
    

}