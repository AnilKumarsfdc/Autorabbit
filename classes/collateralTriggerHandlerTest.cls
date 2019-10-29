/***********************************
    Name: collateralTriggerHandler
    Created Date: 19-09-2019
    Version: 1.0
    Description: This class is used to handle all the operations performed on the Collateral trigger.
************************************/
    
    @isTest
    private class collateralTriggerHandlerTest {
       
        
/***********************************
    Method Name: testCollaterCallInsert
    Created Date: 19-09-2019
    Version: 1.0
    Input parameters: None
    Output Parameters: None
    Description: This method is used to test the code coverage for ltvCollateralcalulation method
    
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
         List<LLC_BI__Loan_Collateral2__c> collateralPledge=TestDataFactoryUtility.createCollateralPledge(2,loanId,collateralId);
        
         }
        
/****************************************************************
* Method: validateLTVCalculationonInsert
* Description: To validate ltv calcualtion on Collateral
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
       static testMethod void validateLTVCalculationonInsert() {
           
             Test.StartTest();
            List<LLC_BI__Collateral__c> collaterals= TestDataFactoryUtility.createCollaterals(2);
            Test.StopTest();
           
           
       }
  
/****************************************************************
* Method: validateLTVCalculationOnUpdate
* Description: To validate ltv calcualtion on Collateral
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
       static testMethod void validateLTVCalculationOnUpdate() {
           
            LLC_BI__Collateral__c collateral=[Select id,Advance_Rate__c from LLC_BI__Collateral__c LIMIT 1];
             Test.StartTest();
             collateral.Advance_Rate__c=30;
             Update collateral;
            Test.StopTest();
           
           
       }
   
  /****************************************************************
* Method: validateLTVCalculationOnDelete
* Description: To validate ltv calcualtion on Collateral
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
       static testMethod void validateLTVCalculationOnDelete() {
           
            LLC_BI__Collateral__c collateral=[Select id from LLC_BI__Collateral__c LIMIT 1];
             Test.StartTest();
             delete collateral;
            Test.StopTest();
           
           
       }      
        
    }