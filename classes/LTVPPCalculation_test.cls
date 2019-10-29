@isTest
private class LTVPPCalculation_test { 
    
    static testmethod void LTVPP(){
       List<Account> accounts  =  TestDataFactoryUtility.createAccounts(1);
       Id AccountId = [select id from account LIMIT 1].id;
       
       List<LLC_BI__Product_Package__c> productPackage = TestDataFactoryUtility.createProductPackageswithAccount(1,AccountId);
       Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
        
        //List<Risk_Group__c> riskgroup=TestDataFactoryUtility.createRiskGroup(2, productpackageId);
       // Id riskgroupIdId =[ Select id from Risk_Group__c where id IN:riskgroup LIMIT 1].Id;
       
        List<LLC_BI__Loan__c> loans = TestDataFactoryUtility.createLoanswithProductpackage(2,productpackageId);
        Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
       
        List<LLC_BI__Collateral__c> collaterals= TestDataFactoryUtility.createCollaterals(2);
       	id collateralId = [Select id from LLC_BI__Collateral__c where id IN:collaterals LIMIT 1].Id;
        
        list<LLC_BI__Collateral_Valuation__c> collateralValuation = TestDataFactoryUtility.createCollateralsValuation(1,collateralId);
       
       List<LLC_BI__Loan_Collateral2__c> collateralPledge=TestDataFactoryUtility.createCollateralPledge(2,loanId,collateralId);
    
    
        test.startTest();
        	LTVPPCalculation.LTVCalculation(productpackageId);
        	LTVPPCalculation.getPPCalculations(productpackageId);
        
        test.stopTest();
    
    
    }
    
    
    static testmethod void LTVPPwithRiskGroup(){
       List<Account> accounts  =  TestDataFactoryUtility.createAccounts(1);
       Id AccountId = [select id from account LIMIT 1].id;
       
       List<LLC_BI__Product_Package__c> productPackage = TestDataFactoryUtility.createProductPackageswithAccount(1,AccountId);
       Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
        
       //List<Risk_Group__c> riskgroup=TestDataFactoryUtility.createRiskGroup(null, productpackageId);
       //Id riskgroupIdId =[ Select id from Risk_Group__c where id IN:riskgroup LIMIT 1].Id;
       
        List<LLC_BI__Loan__c> loans = TestDataFactoryUtility.createLoanswithProductpackage(1,productpackageId);
        Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
       
        List<LLC_BI__Collateral__c> collaterals= TestDataFactoryUtility.createCollaterals(1);
       	Id collateralId = [ Select id from LLC_BI__Collateral__c where id IN:collaterals LIMIT 1].Id;
        
        list<LLC_BI__Collateral_Valuation__c> collateralValuation = TestDataFactoryUtility.createCollateralsValuation(0,null);
         
       
       List<LLC_BI__Loan_Collateral2__c> collateralPledge=TestDataFactoryUtility.createCollateralPledge(0,loanId,collateralId);
    
    
        test.startTest();
        	LTVPPCalculation.LTVCalculation(productpackageId);
        	LTVPPCalculation.getPPCalculations(productpackageId);
        
        test.stopTest();
    
    
    }
    
    static testmethod void LTVPPwithzeroRecords(){
       List<Account> accounts  =  TestDataFactoryUtility.createAccounts(1);
       Id AccountId = [select id from account LIMIT 1].id;
       
       List<LLC_BI__Product_Package__c> productPackage = TestDataFactoryUtility.createProductPackageswithAccount(1,AccountId);
       Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
        
       List<Risk_Group__c> riskgroup=TestDataFactoryUtility.createRiskGroup(2, productpackageId);
       Id riskgroupId =[ Select id from Risk_Group__c where id IN:riskgroup LIMIT 1].Id;
       
        List<LLC_BI__Loan__c> loans = TestDataFactoryUtility.createLoanswithRiskGroup(2,riskgroupId);
        Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
       
        List<LLC_BI__Collateral__c> collaterals= TestDataFactoryUtility.createCollateralsforRiskGroup(2,riskgroupId);
       	Id collateralId = [ Select id from LLC_BI__Collateral__c where id IN:collaterals LIMIT 1].Id;
        
        list<LLC_BI__Collateral_Valuation__c> collateralValuation = TestDataFactoryUtility.createCollateralsValuation(1,collateralId);
         
       
       List<LLC_BI__Loan_Collateral2__c> collateralPledge=TestDataFactoryUtility.createCollateralPledge(2,loanId,collateralId);
    
    
        test.startTest();
        	LTVPPCalculation.LTVCalculation(productpackageId);
        	LTVPPCalculation.getPPCalculations(productpackageId);
        
        test.stopTest();
    
    
    }
   
        
   
    

}