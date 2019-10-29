@isTest
public class ChangeMemo_Test {
    static testmethod void ChangeMemo(){
        List<Account> accounts  =  TestDataFactoryUtility.createAccounts(1);
        Id AccountId = [select id from account LIMIT 1].id;
        List<LLC_BI__Product_Package__c> productPackage = TestDataFactoryUtility.createProductPackageswithAccount(1,AccountId);
        Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
        List<LLC_BI__Loan__c> loans = TestDataFactoryUtility.createLoanswithProductpackage(2,productpackageId);
        Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
        /************Loan stage to Qualification********/
        LLC_BI__Loan__c ln = new LLC_BI__Loan__c();
        ln.id = loanId;
        ln.LLC_BI__Stage__c='Qualification';
        update ln;
        /************Create change memo record**********/
        LLC_BI__Credit_Memo_Modifcation__c cm = new LLC_BI__Credit_Memo_Modifcation__c();
        cm.LLC_BI__Loan__c = loanId;
        cm.LLC_BI__Approval_Status__c = 'Approved';
        cm.LLC_BI__Collateral_Change__c = True;
        cm.Covenant_Change__c = True;
        cm.Credit_Policy_Exception_Change__c = True;
        cm.Repayment_Structure_Change__c = True;
        cm.Product_Change__c = True;
        cm.Valuation_Change__c = True;
        cm.Availability_Period__c = True;
        cm.LLC_BI__Other__c = True;
        cm.Sanction_Validity_Date__c = False;
        insert cm;
        
        LLC_BI__Credit_Memo_Modifcation__c cm1 = [Select id,LLC_BI__Loan__c,LLC_BI__Loan__r.LLC_BI__Stage__c,LLC_BI__Approval_Status__c,LLC_BI__Collateral_Change__c,Covenant_Change__c,Credit_Policy_Exception_Change__c,Repayment_Structure_Change__c,
                                                 Product_Change__c,Valuation_Change__c,Availability_Period__c,LLC_BI__Other__c from LLC_BI__Credit_Memo_Modifcation__c where LLC_BI__Approval_Status__c =:'Approved' LIMIT 1];
	    cm1.LLC_BI__Loan__r.PolicyAcknowledgement__c = True;
        cm1.LLC_BI__Loan__r.LLC_BI__Stage__c='Application';
        Test.startTest();
        update cm1;
        Test.stopTest();
        LLC_BI__Credit_Memo_Modifcation__c cm2 = [Select LLC_BI__Loan__r.LLC_BI__Stage__c from LLC_BI__Credit_Memo_Modifcation__c where id =:cm1.id];
        System.assertEquals('Application',cm2.LLC_BI__Loan__r.LLC_BI__Stage__c);
    }
 		
    	/***********False scenario***************/
 		static testmethod void ChangeMemo1(){
        List<Account> accounts  =  TestDataFactoryUtility.createAccounts(1);
        Id AccountId = [select id from account LIMIT 1].id;
        List<LLC_BI__Product_Package__c> productPackage = TestDataFactoryUtility.createProductPackageswithAccount(1,AccountId);
        Id productpackageId =[ Select id from LLC_BI__Product_Package__c where id IN:productPackage LIMIT 1].Id;
        List<LLC_BI__Loan__c> loans = TestDataFactoryUtility.createLoanswithProductpackage(2,productpackageId);
        Id loanId =[ Select id from LLC_BI__Loan__c where id IN:loans LIMIT 1].Id;
        /************Loan stage to Qualification********/
        LLC_BI__Loan__c ln = new LLC_BI__Loan__c();
        ln.id = loanId;
        ln.LLC_BI__Stage__c='Qualification';
        update ln;   
        LLC_BI__Credit_Memo_Modifcation__c c1 = new LLC_BI__Credit_Memo_Modifcation__c();
        c1.LLC_BI__Loan__c = loanId;
        c1.LLC_BI__Approval_Status__c = 'Rejected';
        c1.LLC_BI__Collateral_Change__c = True;
        c1.Covenant_Change__c = True;
        c1.Credit_Policy_Exception_Change__c = True;
        c1.Repayment_Structure_Change__c = True;
        c1.Product_Change__c = True;
        c1.Valuation_Change__c = True;
        c1.Availability_Period__c = True;
        c1.LLC_BI__Other__c = True;
        c1.Sanction_Validity_Date__c = False;
        insert c1;
     
   
        LLC_BI__Credit_Memo_Modifcation__c cm3 = [Select id,LLC_BI__Loan__c,LLC_BI__Loan__r.LLC_BI__Stage__c,LLC_BI__Approval_Status__c,LLC_BI__Collateral_Change__c,Covenant_Change__c,Credit_Policy_Exception_Change__c,Repayment_Structure_Change__c,
                                                 Product_Change__c,Valuation_Change__c,Availability_Period__c,LLC_BI__Other__c from LLC_BI__Credit_Memo_Modifcation__c where LLC_BI__Approval_Status__c =:'Rejected' LIMIT 1];
        cm3.LLC_BI__Loan__r.PolicyAcknowledgement__c = True;
        cm3.LLC_BI__Loan__r.LLC_BI__Stage__c='Qualification';
        Test.startTest();
        update cm3;
        Test.stopTest();
        LLC_BI__Credit_Memo_Modifcation__c cm4 = [Select LLC_BI__Loan__r.LLC_BI__Stage__c from LLC_BI__Credit_Memo_Modifcation__c where id =:cm3.id];
		System.assertEquals('Qualification',cm4.LLC_BI__Loan__r.LLC_BI__Stage__c);    
    }
}