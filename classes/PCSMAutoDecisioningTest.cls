/****************************************************************
* ClassName: PCSMAutoDecisioningTest
* Description: test class for the PCSMAutoDecisioningTest Class, invoked from Submit for Auto Decisioning lightning Component.
* Date: 03/10/2019
* *************************************************************/

@isTest

public class PCSMAutoDecisioningTest {
    
   @testSetup static  void setup() {
         
        List<LLC_BI__Product_Package__c> PPlist=TestDataFactoryUtility.createProductPackage_PCSM(1);
	    Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:PPlist LIMIT 1].Id;
        List<LLC_BI__Loan__c> loans=TestDataFactoryUtility.createLoanswithProductpackage_PCSM(2,productpackageId);
	}
    
    /****************************************************************
* Method: validateCreditApprovalInsertion
* Description: To validate the productpackage and loan record for inserting in Credit Approval History
* Input Parameters: NA
* OutPut Parameters: NA
* *************************************************************/  
     static testMethod void getLoanReccord() {
         Id ppIds=[ Select id from LLC_BI__Product_Package__c  LIMIT 1].Id;
         Test.startTest();
         PCSMAutoDecisioning.FetchLoanList(ppIds);
         Test.stopTest();
	}
    
    static testMethod void validateLoanRecord() {
        list<LLC_BI__Loan__c> loanListUpdate =new list<LLC_BI__Loan__c>();
        list<LLC_BI__Loan__c> loanList=[ Select id,PolicyAcknowledgement__c from LLC_BI__Loan__c  LIMIT 100];
       // system.debug('LLC_BI__Loan__c--> '+loanList);
        for(LLC_BI__Loan__c LoanRec:loanList){
            LoanRec.PolicyAcknowledgement__c=false;
            loanListUpdate.add(LoanRec);
                }
        update loanListUpdate;
        Test.startTest();
        PCSMAutoDecisioning.validateLoanDetails(loanListUpdate);
        Test.stopTest();
        
    }
    
    static testMethod void validatePPRecord() {
        LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c from LLC_BI__Product_Package__c  LIMIT 100];
      //  system.debug('LLC_BI__Product_Package__c--> '+ppRec);
        ppRec.Requires_Manual_Approval__c='';
        ppRec.Purpose__c='';
        update ppRec;
        Test.startTest();
        PCSMAutoDecisioning.validatePPDetails(ppRec.id);
        Test.stopTest();
    }
    
     static testMethod void setLoanStageToFinalReview() {
        LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c from LLC_BI__Product_Package__c  LIMIT 100];
      //  system.debug('LLC_BI__Product_Package__c--> '+ppRec);
      	Test.startTest();
        PCSMAutoDecisioning.setLoanStageToFinalReview(ppRec.id);
        Test.stopTest();
    }
    
    //invokeApprovalProcess 
    static testMethod void invokePPApprovalProcess_Yes() {
        LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c,LLC_BI__Status__c from LLC_BI__Product_Package__c  LIMIT 100];
       	ppRec.Requires_Manual_Approval__c='Yes';
        update ppRec;
        User u =TestDataFactoryUtility.createUser('System Administrator');
        Test.startTest();
        PCSMAutoDecisioning.invokeApprovalProcess(ppRec.id);
        Test.stopTest();
    }
    
     static testMethod void invokePPApprovalProcess_No() {
         LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c,LLC_BI__Status__c from LLC_BI__Product_Package__c  LIMIT 100];
         ppRec.Requires_Manual_Approval__c='Yes';
         update ppRec;
         User u =TestDataFactoryUtility.createUser('System Administrator');
         Test.startTest();
         PCSMAutoDecisioning.invokeApprovalProcess(ppRec.id);
         Test.stopTest();
    }
    
    static testMethod void invokeloanApprovalProcess() {
        List<LLC_BI__Product_Package__c> PPlist=TestDataFactoryUtility.createProductPackage_PCSM(1);
        Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:PPlist LIMIT 1].Id;
        list<LLC_BI__Loan__c> loanList= TestDataFactoryUtility.createLoanswithProductpackage_PCSM (2,productpackageId);
        User u =TestDataFactoryUtility.createUser('System Administrator');
        Boolean status = true;
       
        Test.startTest();
        PCSMAutoDecisioning.invokeLoanApprovalProcess(loanList);
        Test.stopTest();
      }

    static testMethod void invokeSendForAutoDecisiontoPCSM_No() {
    	
        LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c,LLC_BI__Status__c from LLC_BI__Product_Package__c  LIMIT 100];
        ppRec.Requires_Manual_Approval__c='No';
        update ppRec;
        Test.startTest();
        PCSMAutoDecisioning.sendForAutoDecisiontoPCSM(ppRec.id);
        Test.stopTest();
    }
     static testMethod void invokeSendForAutoDecisiontoPCSM_Yes() {
    	
        LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c,LLC_BI__Status__c from LLC_BI__Product_Package__c  LIMIT 100];
        ppRec.Requires_Manual_Approval__c='Yes';
        update ppRec;
        Test.startTest();
        PCSMAutoDecisioning.sendForAutoDecisiontoPCSM(ppRec.id);
        Test.stopTest();
    }
    
    static testMethod void SendForAutoDecisiontoPCSMError1() {
    	LLC_BI__Product_Package__c ppRec=[ Select id,Requires_Manual_Approval__c,Purpose__c,LLC_BI__Status__c from LLC_BI__Product_Package__c  LIMIT 100];
        ppRec.Requires_Manual_Approval__c='';
        ppRec.Purpose__c='';
        update ppRec;
        Test.startTest();
        PCSMAutoDecisioning.sendForAutoDecisiontoPCSM(ppRec.id);
        Test.stopTest();
    }
    static testMethod void SendForAutoDecisiontoPCSMError2() {
		List<LLC_BI__Product_Package__c> PPlist=TestDataFactoryUtility.createProductPackage_PCSM(1);
        Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:PPlist LIMIT 1].Id;
        List<LLC_BI__Loan__c> LoanDetails =new List<LLC_BI__Loan__c>();
        List<LLC_BI__Loan__c> LoanList=[ Select id,PolicyAcknowledgement__c from LLC_BI__Loan__c where LLC_BI__Product_Package__c =: productpackageId LIMIT 100]; 
        for(LLC_BI__Loan__c loanRec: LoanList){
            loanRec.PolicyAcknowledgement__c=false;
            LoanDetails.add(loanRec);
        }
        update LoanDetails;
        Test.startTest();
        PCSMAutoDecisioning.sendForAutoDecisiontoPCSM(productpackageId);
        Test.stopTest();
    }
    
    /*
     SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Is_Review_Ready__c,CAHLoanTrigger__c ,Decision_Reason__c,Manual_Decision__c,Comments_CAH__c FROM LLC_BI__Loan__c WHERE LLC_BI__Product_Package__c ='a449E000000BstaQAC' and Id='a3Z9E0000002ttWUAQ'
https://salesforce.stackexchange.com/questions/102887/field-updates-that-are-executed-as-approval-actions-dont-trigger-process
*/

}