public class SpringCMDocumentOffloadHandler {

 public Set<Id> LoanIds= new Set<Id>();

/************************************************
Method Name:springCMtoDocOffloader
Descritption:This method is used to Offload doc from SPringCM to nCino.
Input Parameters:List of Loans
Output Parameters:None
**************************************************/     

public void springCMtoDocOffloader(List<SpringCM_Document_Detail__c> newLoanList)
{
Set<ID> DocumentDetailIDs = new Set<ID>(); 
Set<ID> LoanIDs = new Set<ID>(); 

system.debug('===========newLoanList========='+newLoanList);

        for(SpringCM_Document_Detail__c cvVar: newLoanList){
                DocumentDetailIDs.add(cvVar.id);
                LoanIDs .add(cvVar.Loan__c);
        }   

SpringCMtoDocManFileOffloader o = new SpringCMtoDocManFileOffloader();
SpringCMtoDocManFileOffloader.attachmentLoader(DocumentDetailIDs,LoanIDs);


//SpringCMtoDocManFileOffloader o = new SpringCMtoDocManFileOffloader();
//SpringCMtoDocManFileOffloader.attachmentLoader(newLoanList[0].SpringCM_Doc_Id__c,newLoanList[0].SpringCM_Doc_Name__c,newLoanList[0].id);

}

}