@IsTest
public class SpringCM_DocumentDetailsTest {
    static testmethod void test1(){
        Test.startTest(); 
        Integer i =9;
        List<Id> loanIds =new List<Id>();
        LLC_BI__Loan__c loanobj = new LLC_BI__Loan__c();
        loanobj.Name='Test Loan'+ i;
        loanobj.LLC_BI__Amount__c = 10000 + i;
        loanobj.LLC_BI__Status__c='Open';
        loanobj.SpringCM_Doc_Name__c= '3a09c20a-75eb-e911-9c2e-30e17155e337,Personal Guarantee_20191010_154558.docx';
insert loanobj;
        loanIds.add(loanobj.id);
        SpringCM_DocumentDetails.CreateSpringCMDetail(loanIds);
        Test.stopTest();     
    }
    
    /*


*/

}