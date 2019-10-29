@isTest
private class PCSMLoanTriggerHandlerTest {

    static testMethod void updateCreditApprovalDecision() {
        Credit_Approval_History__c CAH ;
        
        LLC_BI__Product_Package__c  PPtest = new LLC_BI__Product_Package__c(Name='TestingPP',Requires_Manual_Approval__c='Yes',
                                                                           LLC_BI__Status__c='Open',Purpose__c='New Monies');
        System.debug('Data before inserting new Product Package:--> '+PPtest.Name);
        insert PPtest;
        
        LLC_BI__Loan__c loanTest = new LLC_BI__Loan__c(Name='TestingLoan',LLC_BI__Product_Package__c=PPtest.Id ,LLC_BI__Stage__c ='Application' , LLC_BI__Is_Review_Ready__c=true);
      	insert loanTest;
        
        CAH =new Credit_Approval_History__c(loan__c=loanTest.id,Product_Package__c=loanTest.LLC_BI__Product_Package__c);
       
         loanTest.Decision_Reason__c='TBC';
         loanTest.Manual_Decision__c='Approved';
         loanTest.Comments_CAH__c='Testin';
        
        Test.startTest();
        update loanTest;
        System.debug('Data before inserting new Loan:--> '+loanTest.name);
        Test.stopTest();
        
        Credit_Approval_History__c CAH1 = [Select id,Decision_Reason__c,Manual_Decision__c,Comments_CAH__c 
                                          from Credit_Approval_History__c where Loan__c=:loanTest.Id ];
        System.debug('Data After inserting Credit Approval History:--> '+CAH1.Decision_Reason__c+'|Manual_Decision__c:--> '+CAH1.Manual_Decision__c+'|Comments_CAH__c:--> '+CAH1.Comments_CAH__c);
    }
}