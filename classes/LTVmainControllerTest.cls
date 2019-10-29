/****************************************************************
* ClassName: LTVmainControllerTest
* Description: test class for the LTVMainController Class, invoked from LTVMainScreen lightning Component
* Date: 03/10/2019
* Description: LTV
* *************************************************************/

@isTest
private class LTVmainControllerTest {
    
 
    
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
         List<Risk_Group__c> ridkgroup=TestDataFactoryUtility.createRiskGroup(2,productpackageId);
         Id riskgroupIdId =[ Select id from Risk_Group__c where id IN:ridkgroup LIMIT 1].Id;
            
    }

 /****************************************************************
* Method: validateuserpermission
* Description: To validate user permission on Risk Group Object
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
       static testMethod void validateuserpermission() {
           
           String profileName= 'SAN 17';
           Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
           User u=TestDataFactoryUtility.createUser(profileName);
            system.debug('user details'+ u);
           
           Test.StartTest();
           system.runAs(u){
               
            LTVMainController.getRiskGroups(productpackageId);               
           }
           
           Test.StopTest();
           
       }
  
 /****************************************************************
* Method: validateGetLoan
* Description: To validate the loan records
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateGetLoan() {
         
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
         Test.StartTest();
         LTVMainController.getLoan(productpackageId);
         Test.StopTest();
         
     }
    
 /****************************************************************
* Method: validateGetCollaterals
* Description: To validate the collateral records
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateGetCollaterals() {
         
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
         Test.StartTest();
         LTVMainController.getCollaterals(productpackageId);
         Test.StopTest();
         
     }
  /****************************************************************
* Method: validateGetRelationships
* Description: To validate the Relationship records
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateGetRelationships() {
        
         Account accOne =new Account();
         accOne.Name='TestOne';
         accOne.Status__c='Active Customer';
          insert accOne;
         Account accTwo =new Account();
         accTwo.Name='Testwo';
         accTwo.Status__c='Active Customer';
          insert accTwo;
         LLC_BI__Product_Package__c ppdone= new LLC_BI__Product_Package__c();
         ppdone.Name='TestPPOne';
         insert ppdone;
         LLC_BI__Product_Package__c ppdtwo= new LLC_BI__Product_Package__c();
          ppdtwo.Name='TestPPTwo';
         insert ppdtwo;
         
         LLC_BI__Legal_Entities__c legalenttione=new LLC_BI__Legal_Entities__c();
         legalenttione.LLC_BI__Account__c=accOne.Id;
         legalenttione.LLC_BI__Borrower_Type__c='Borrower';
         legalenttione.LLC_BI__Product_Package__c=ppdone.id;
         insert legalenttione;
         
         LLC_BI__Legal_Entities__c legalenttiTwo=new LLC_BI__Legal_Entities__c();
         legalenttiTwo.LLC_BI__Account__c=accTwo.Id;
         legalenttiTwo.LLC_BI__Borrower_Type__c='Borrower';
         legalenttiTwo.LLC_BI__Product_Package__c=ppdone.id;
         insert legalenttiTwo;
         Test.StartTest();
         LTVMainController.getRelationships(ppdone.id);
         Test.StopTest();
         
     }   
    
/****************************************************************
* Method: validateRiskGroupInsertion
* Description: To validate the Risk group creation
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateRiskGroupCreation() {
         
          List<LTVWrapper.realtionshipWrapper> relwrap=new List< LTVWrapper.realtionshipWrapper>();
          List<LTVWrapper.loanWrapper> loanwrap=new List< LTVWrapper.loanWrapper>();
          List<LTVWrapper.CollateralWrapper> collatralwrap=new List< LTVWrapper.CollateralWrapper>();
          List<LTVWrapper.riskGroupWrapper> riskgroupListWrap=new List<LTVWrapper.riskGroupWrapper>();
          LTVWrapper wrapobj= new LTVWrapper();
       
         String RiskGroupName='TestRG'; 
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c where Name='Test Product Package1' LIMIT 1].Id;
         List<Account> relationship=[Select Id,JFNumber__c,Active_Account_LTV__c,Name,Status__c,Type from Account where Name='Test Account Name1' LIMIT 1];
         LTVWrapper.realtionshipWrapper relobj=new  LTVWrapper.realtionshipWrapper();
         relobj.accountcheck=relationship[0].Active_Account_LTV__c ;
         relobj.JFNumber=relationship[0].JFNumber__c;
         relobj.Name=relationship[0].Name;
         relobj.relatinshipId=relationship[0].id;
         relobj.relStatus=relationship[0].Status__c;
         relobj.Type=relationship[0].Type;
         relwrap.add(relobj);
         wrapobj.selectedRealtionshipslist=relwrap;
         wrapobj.relRelationshipList=relationship;
         String relList=JSON.serialize(relwrap);
        List< LLC_BI__Loan__c> loans=[Select Id,Name,LLC_BI__Amount__c,Active_Loan_LTV__c ,LLC_BI__Status__c,LLC_BI__Stage__c from LLC_BI__Loan__c where Name='Test Loan1' LIMIT 1];
         LTVWrapper.loanWrapper loanobj= new LTVWrapper.loanWrapper();
         loanobj.Amount=loans[0].LLC_BI__Amount__c;
         loanobj.loanCheck=loans[0].Active_Loan_LTV__c;
         loanobj.loanId=loans[0].Id;
         loanobj.loanStatus=loans[0].LLC_BI__Status__c;
         loanobj.Name=loans[0].Name;
         loanobj.Stage=loans[0].LLC_BI__Stage__c;
         loanwrap.add(loanobj);
         String loanList=JSON.serialize(loanwrap);
         wrapobj.relLoanList=loans;
         wrapobj.selectedloanslist=loanwrap;
         LTVWrapper.CollateralWrapper colobj= new LTVWrapper.CollateralWrapper();
         
         List< LLC_BI__Collateral__c> collaterals=[Select Id,LLC_BI__Collateral_Name__c,Active_Collateral_LTV__c,Collateral_Type_Formula__c,LLC_BI__Status__c from LLC_BI__Collateral__c LIMIT 1];
         colobj.collateralCheck=collaterals[0].Active_Collateral_LTV__c ;
         colobj.collateralId=collaterals[0].id;
         colobj.collateralNumber='1234';
         colobj.collStatus=collaterals[0].LLC_BI__Status__c;
         colobj.Name=collaterals[0].LLC_BI__Collateral_Name__c;
         colobj.Type=collaterals[0].Collateral_Type_Formula__c;
         collatralwrap.add(colobj);  
         String collList=JSON.serialize(collatralwrap);
         wrapobj.relCollateralList=collaterals;
         wrapobj.selectedCollateralslist=collatralwrap;
         
         
             
         List<Risk_Group__c>  rgList=[Select id ,Name from Risk_Group__c LIMIT 1];
         LTVWrapper.riskGroupWrapper rgWrap = new LTVWrapper.riskGroupWrapper();
         Id rgId=[ Select Id from Risk_Group__c LIMIT 1].Id;
         List<Risk_Group__c> riskgroupList=[Select Id, Name from Risk_Group__c];
         String ridkgrouplist= JSON.serialize(rgList);
         rgWrap.riskGroupRec=riskgroupList[0];
         rgWrap.inactiveLoan=true;
         rgWrap.inactiveCollateral=true;
         rgWrap.inactiveRelationship=true;
         rgWrap.noLoan=true;
         rgWrap.noCollateral=true;
         riskgroupListWrap.add(rgWrap);
         wrapobj.riskGroupLst=riskgroupListWrap;
         wrapobj.profileName ='SAN 13';
         
         String ser= JSON.serialize(wrapobj);
         
         Test.StartTest();
         // LTVMainController.getRiskGroups(productpackageId);
          

          
          LTVMainController.getRiskGroupRelatedObjects(productpackageId,rgId);
          LTVMainController.fetchRelatedRecords(productpackageId,rgId,wrapobj);
          LTVMainController.riskGroupLTVCalculation(productpackageId);
          LTVMainController.validateDuplicateCheck(RiskGroupName,ridkgrouplist,productpackageId);
         // LTVMainController.insertRiskGroupRecord(ridkgrouplist,RiskGroupName,productpackageId);
           LTVMainController.createRiskGrouprelationships(productpackageId,RiskGroupName,relList,loanList,collList,ridkgrouplist);
          LTVMainController.getRiskGroups(productpackageId);
          LTVMainController.updateRelatedRecords(rgId,relList,loanList,collList,ridkgrouplist);
          LTVMainController.createRelatedRecords(rgId,relList,loanList,collList,ridkgrouplist);
          LTVMainController.saveRiskGroup(productpackageId,RiskGroupName,relList,loanList,collList,ridkgrouplist);
          LTVMainController.getRiskGroupWrap(productpackageId,wrapobj);
          Test.StopTest();      
        
    }
    
 /****************************************************************
* Method: validateDeleteAssociatedRecordLoan
* Description: To validate deassociation of Loans from Risk group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateDeleteAssociatedRecordLoan() {
         
         String operationLoan ='DeleteLoan';
         
         Id loanId =[ Select id from LLC_BI__Loan__c LIMIT 1].Id;  
        
         Test.StartTest();
         LTVMainController.deleteAssociatedRecordRef(operationLoan,loanId);
         Test.StopTest();
         
         LLC_BI__Loan__c loans =[ Select id,Risk_Group__c  from LLC_BI__Loan__c LIMIT 1]; 
         System.assertEquals(loans.Risk_Group__c,null);
         
     }
    
/****************************************************************
* Method: validateDeleteAssociatedRecordCollateral
* Description: To validate deassociation of collaterals from Risk group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateDeleteAssociatedRecordCollateral() {
         
         String operationCollateral ='DeleteCollateral';
         Id collateralId =[ Select id from LLC_BI__Collateral__c LIMIT 1].Id;
          Test.StartTest();
          LTVMainController.deleteAssociatedRecordRef(operationCollateral,collateralId);
          Test.StopTest();
         
         LLC_BI__Collateral__c collaterals =[ Select id,Risk_Group__c  from LLC_BI__Collateral__c LIMIT 1]; 
         System.assertEquals(collaterals.Risk_Group__c,null);
         
     }
    
/****************************************************************
* Method: validateDeleteAssociatedRecordRelationship
* Description: To validate deassociation of collaterals from Risk group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateDeleteAssociatedRecordRelationship() {
         
         String operationRelationship ='DeleteRelationship';
         Id AccountId = [ Select id from Account LIMIT 1].Id;
       
         Test.StartTest();
         LTVMainController.deleteAssociatedRecordRef(operationRelationship,AccountId);
         Test.StopTest();
         
          Account accnt =[ Select id,Risk_Group__c  from Account LIMIT 1]; 
         System.assertEquals(accnt.Risk_Group__c,null);
         
         
     }
           
       

   /****************************************************************
* Method: validateRiskGroupDeletion
* Description: To validate the Risk group Deletion
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateRiskGroupDeletion() { 
         
         
         Id deletergId=[ Select Id from Risk_Group__c LIMIT 1].Id;
         Test.StartTest();
         LTVMainController.riskGroupDelete(deletergId);
         Test.StopTest();
         Risk_Group__c rg=[Select id,IsDeleted , Name from Risk_Group__c where id=:deletergId ALL ROWS];
         System.assertEquals(rg.IsDeleted, true);
          
         
     }
    
    /****************************************************************
* Method: validateRiskGroupErrorMessage
* Description: To validate the error messages on Risk Group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateRiskGroupErrorMessage() {
         
         List<LTVWrapper.riskGroupWrapper> riskgroupListWrap=new List<LTVWrapper.riskGroupWrapper>();
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
         LLC_BI__Product_Package__c ppobj=new LLC_BI__Product_Package__c();
         ppobj.name='Test';
         insert ppobj;
         LTVWrapper wrapobj= new LTVWrapper();
         wrapobj.riskGroupLst=null;
         wrapobj.isReadAllowed=false;
         LTVMainController.getRiskGroupWrap(ppobj.id,wrapobj);
         Test.StartTest();
             LTVMainController.getRiskGroups(ppobj.id);
         Test.StopTest();
         
         
         
     } 
    
    /****************************************************************
* Method: validateRiskGroupPermissionErrorMessage
* Description: To validate the error messages on Risk Group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateRiskGroupPermissionErrorMessage() {
         
         List<LTVWrapper.riskGroupWrapper> riskgroupListWrap=new List<LTVWrapper.riskGroupWrapper>();
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
         LLC_BI__Product_Package__c ppobj=new LLC_BI__Product_Package__c();
         String profileName='SAN 17';
         User u=TestDataFactoryUtility.createUser(profileName);   
         ppobj.name='Test';
         insert ppobj;
         LTVWrapper wrapobj= new LTVWrapper();
         wrapobj.riskGroupLst=null;
         wrapobj.isReadAllowed=false;
         LTVMainController.getRiskGroupWrap(ppobj.id,wrapobj);
         Test.StartTest();
         system.runas(u){
             LTVMainController.getRiskGroups(ppobj.id);
         }
         Test.StopTest();
         
         
         
     } 
      
/****************************************************************
* Method: validateSaveRiskGroupErrorMessage
* Description: To validate the error messages on Risk Group
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void validateSaveRiskGroupErrorMessage() { 
         
         
         String riskgroupIdId ='';
         Risk_Group__c rgobj=new Risk_Group__c();
         insert rgobj;
         List<Account> accounts= [Select Id, name from account LIMIT 1];
         List<LLC_BI__Loan__c> loans=[Select Id, name from LLC_BI__Loan__c LIMIT 1];
         List<LLC_BI__Collateral__c> collaterals=[Select Id, name from LLC_BI__Collateral__c LIMIT 1];
         String relList=JSON.serialize(accounts);
         String loanList=JSON.serialize(loans);
         String collList=JSON.serialize(collaterals);
         String rgList=JSON.serialize(rgobj);
         
        
         Id productpackageId =[ Select id from LLC_BI__Product_Package__c LIMIT 1].Id;
         string ppid=null;
         String rgName='testtesteeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrryyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyytesttesteeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrryyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy';
         String profileName='SAN 17';
         User u=TestDataFactoryUtility.createUser(profileName); 
         Test.StartTest();
      		system.runas(u){
            // LTVMainController.insertRiskGroupRecord(rgobj,null,ppid);
             LTVMainController.updateRelatedRecords(riskgroupIdId,null,null,null,null);
             }
             LTVMainController.saveRiskGroup(productpackageId,rgName,relList,loanList,collList,rgList);
          Test.StopTest();
         
     }
    

}