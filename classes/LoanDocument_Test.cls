/******************************************************************
 * Class Name-LoanDocument_Test
 * Description-Test class for Process Builder on LoanDocument Object
 * Created By-Nikita Kamble 
 * Created Date-10/07/2019 
 ******************************************************************/
@isTest
public class LoanDocument_Test {
    static testmethod void LoanDoc(){
        /**********Create record for Loan**************/
        LLC_BI__Loan__c Loan = new LLC_BI__Loan__c();
        Loan.Name='Test';
        insert loan;
        id loanId = [Select id from LLC_BI__Loan__c where id=:loan.id].id;
        /******Create record for DocManager************/
       LLC_BI__DocManager__c  docMan= new LLC_BI__DocManager__c();
       docMan.Name='llc_bi__loan__c';
       docMan.LLC_BI__namespacePrefix__c='LLC_BI';
       insert docMan;
       id docManId = [Select id from LLC_BI__DocManager__c where id=:docMan.id].id;
        /**********Create record for DocType***************/
       LLC_BI__DocType__c docType=new LLC_BI__DocType__c();
       docType.Name='Credit Monitoring';
       docType.LLC_BI__docManager__c = docManId;
       insert docType;
       id docTypeId = [Select id from LLC_BI__DocType__c where id=:docType.id].id;
       /***********Create record for DocClass**************/
       LLC_BI__DocClass__c docClass = new LLC_BI__DocClass__c();
       docClass.LLC_BI__DocType__c = docTypeId;
       docClass.LLC_BI__docManager__c = docManId;
       docClass.Name='Credit Monitoring';
       insert docClass;
       id docClassId = [Select id from LLC_BI__DocClass__c where id=:docClass.id].id;
       /***********Create record for Closing checklist********/
       	LLC_BI__ClosingChecklist__c cc = new LLC_BI__ClosingChecklist__c();
        cc.Name = 'Credit Monitoring';
        cc.LLC_BI__docClass__c= docClassId;
        cc.LLC_BI__docType__c = docTypeId;
        cc.LLC_BI__docManager__c = docManId;
        insert cc;
        id CCId = [select id from LLC_BI__ClosingChecklist__c where id=:cc.id].id;
       /***********Create record for LoanDocument***********/
        LLC_BI__LLC_LoanDocument__c loandoc = new 	LLC_BI__LLC_LoanDocument__c();
        loandoc.Name = 'Credit Monitoring';
        loandoc.LLC_BI__Loan__c = loanId;
        loandoc.LLC_BI__closingChecklist__c = CCId;
        loandoc.LLC_BI__docClass__c = docClassId;
        loandoc.LLC_BI__docManager__c = docManId;
        loandoc.LLC_BI__docType__c = docTypeId;
        insert loandoc;
  
        LLC_BI__LLC_LoanDocument__c ld = [Select id,LLC_BI__reviewStatus__c,NDOC__Placeholder_Approval_Roles__c,LLC_BI__Approval_Roles__c,	LLC_BI__closingChecklist__c from LLC_BI__LLC_LoanDocument__c where LLC_BI__docType__r.name=:'Credit Monitoring' LIMIT 1];
        ld.LLC_BI__Approval_Roles__c='SAN 13;SAN 14;SAN 15;SAN System Admin';
        test.startTest();
        update ld;
        test.stopTest();
        LLC_BI__LLC_LoanDocument__c ld1 = [Select LLC_BI__Approval_Roles__c from LLC_BI__LLC_LoanDocument__c where id=:ld.id];
      System.assertEquals('SAN 13;SAN 14;SAN 15;SAN System Admin',ld1.LLC_BI__Approval_Roles__c);
    }
   
    
    static testmethod void LoanDoc1(){
        /**********Create record for Loan**************/
        LLC_BI__Loan__c Loan = new LLC_BI__Loan__c();
        Loan.Name='Test';
        insert loan;
        id loanId = [Select id from LLC_BI__Loan__c where id=:loan.id].id;
        /******Create record for DocManager************/
       LLC_BI__DocManager__c  docMan= new LLC_BI__DocManager__c();
       docMan.Name='llc_bi__loan__c';
       docMan.LLC_BI__namespacePrefix__c='LLC_BI';
       insert docMan;
       id docManId = [Select id from LLC_BI__DocManager__c where id=:docMan.id].id;
        /**********Create record for DocType***************/
       LLC_BI__DocType__c docType=new LLC_BI__DocType__c();
       docType.Name='R&R Correspondence';
       docType.LLC_BI__docManager__c = docManId;
       insert docType;
       id docTypeId = [Select id from LLC_BI__DocType__c where id=:docType.id].id;
       /***********Create record for DocClass**************/
       LLC_BI__DocClass__c docClass = new LLC_BI__DocClass__c();
       docClass.LLC_BI__DocType__c = docTypeId;
       docClass.LLC_BI__docManager__c = docManId;
       docClass.Name='R&R Correspondence';
       insert docClass;
       id docClassId = [Select id from LLC_BI__DocClass__c where id=:docClass.id].id;
       /***********Create record for Closing checklist********/
       	LLC_BI__ClosingChecklist__c cc = new LLC_BI__ClosingChecklist__c();
        cc.Name = 'R&R Correspondence';
        cc.LLC_BI__docClass__c= docClassId;
        cc.LLC_BI__docType__c = docTypeId;
        cc.LLC_BI__docManager__c = docManId;
        insert cc;
        id CCId = [select id from LLC_BI__ClosingChecklist__c where id=:cc.id].id;
       /***********Create record for LoanDocument***********/
        LLC_BI__LLC_LoanDocument__c loandoc1 = new 	LLC_BI__LLC_LoanDocument__c();
        loandoc1.Name = 'R&R Correspondence';
        loandoc1.LLC_BI__Loan__c = loanId;
        loandoc1.LLC_BI__closingChecklist__c = CCId;
        loandoc1.LLC_BI__docClass__c = docClassId;
        loandoc1.LLC_BI__docManager__c = docManId;
        loandoc1.LLC_BI__docType__c = docTypeId;
        insert loandoc1;
        
        LLC_BI__LLC_LoanDocument__c ld2 = [Select id,LLC_BI__reviewStatus__c,NDOC__Placeholder_Approval_Roles__c,LLC_BI__Approval_Roles__c,	LLC_BI__closingChecklist__c from LLC_BI__LLC_LoanDocument__c where LLC_BI__docType__r.name=:'R&R Correspondence' LIMIT 1];
        ld2.LLC_BI__Approval_Roles__c='SAN 14;SAN System Admin;';
        test.startTest();
        update ld2;
        test.stopTest();
        LLC_BI__LLC_LoanDocument__c ld3 = [Select LLC_BI__Approval_Roles__c from LLC_BI__LLC_LoanDocument__c where id=:ld2.id];
      System.assertEquals('SAN 14;SAN System Admin;',ld3.LLC_BI__Approval_Roles__c);
    }
    
    static testmethod void LoanDoc2(){
        /**********Create record for Loan**************/
        LLC_BI__Loan__c Loan = new LLC_BI__Loan__c();
        Loan.Name='Test';
        insert loan;
        id loanId = [Select id from LLC_BI__Loan__c where id=:loan.id].id;
        /******Create record for DocManager************/
       LLC_BI__DocManager__c  docMan= new LLC_BI__DocManager__c();
       docMan.Name='llc_bi__loan__c';
       docMan.LLC_BI__namespacePrefix__c='LLC_BI';
       insert docMan;
       id docManId = [Select id from LLC_BI__DocManager__c where id=:docMan.id].id;
        /**********Create record for DocType***************/
       LLC_BI__DocType__c docType=new LLC_BI__DocType__c();
       docType.Name='Pricing';
       docType.LLC_BI__docManager__c = docManId;
       insert docType;
       id docTypeId = [Select id from LLC_BI__DocType__c where id=:docType.id].id;
       /***********Create record for DocClass**************/
       LLC_BI__DocClass__c docClass = new LLC_BI__DocClass__c();
       docClass.LLC_BI__DocType__c = docTypeId;
       docClass.LLC_BI__docManager__c = docManId;
       docClass.Name='Pricing';
       insert docClass;
       id docClassId = [Select id from LLC_BI__DocClass__c where id=:docClass.id].id;
       /***********Create record for Closing checklist********/
       	LLC_BI__ClosingChecklist__c cc = new LLC_BI__ClosingChecklist__c();
        cc.Name = 'Pricing';
        cc.LLC_BI__docClass__c= docClassId;
        cc.LLC_BI__docType__c = docTypeId;
        cc.LLC_BI__docManager__c = docManId;
        insert cc;
        id CCId = [select id from LLC_BI__ClosingChecklist__c where id=:cc.id].id;
       /***********Create record for LoanDocument***********/
        LLC_BI__LLC_LoanDocument__c loandoc2 = new 	LLC_BI__LLC_LoanDocument__c();
        loandoc2.Name = 'Pricing';
        loandoc2.LLC_BI__Loan__c = loanId;
        loandoc2.LLC_BI__closingChecklist__c = CCId;
        loandoc2.LLC_BI__docClass__c = docClassId;
        loandoc2.LLC_BI__docManager__c = docManId;
        loandoc2.LLC_BI__docType__c = docTypeId;
        insert loandoc2;
        
        LLC_BI__LLC_LoanDocument__c ld4 = [Select id,LLC_BI__reviewStatus__c,NDOC__Placeholder_Approval_Roles__c,LLC_BI__Approval_Roles__c,	LLC_BI__closingChecklist__c from LLC_BI__LLC_LoanDocument__c where LLC_BI__docType__r.name=:'Pricing' LIMIT 1];
        ld4.LLC_BI__Approval_Roles__c='SAN Relationship Director;SAN BRD;SAN 3;SAN 13;SAN 14;SAN 15;SAN System Admin;';
        test.startTest();
        update ld4;
        test.stopTest();
        LLC_BI__LLC_LoanDocument__c ld5 = [Select LLC_BI__Approval_Roles__c from LLC_BI__LLC_LoanDocument__c where id=:ld4.id];
      System.assertEquals('SAN Relationship Director;SAN BRD;SAN 3;SAN 13;SAN 14;SAN 15;SAN System Admin;',ld5.LLC_BI__Approval_Roles__c);
    }
    
    static testmethod void LoanDoc3(){
        /**********Create record for Loan**************/
        LLC_BI__Loan__c Loan = new LLC_BI__Loan__c();
        Loan.Name='Test';
        insert loan;
        id loanId = [Select id from LLC_BI__Loan__c where id=:loan.id].id;
        /******Create record for DocManager************/
       LLC_BI__DocManager__c  docMan= new LLC_BI__DocManager__c();
       docMan.Name='llc_bi__loan__c';
       docMan.LLC_BI__namespacePrefix__c='LLC_BI';
       insert docMan;
       id docManId = [Select id from LLC_BI__DocManager__c where id=:docMan.id].id;
        /**********Create record for DocType***************/
       LLC_BI__DocType__c docType=new LLC_BI__DocType__c();
       docType.Name='Pricing';
       docType.LLC_BI__docManager__c = docManId;
       insert docType;
       id docTypeId = [Select id from LLC_BI__DocType__c where id=:docType.id].id;
       /***********Create record for DocClass**************/
       LLC_BI__DocClass__c docClass = new LLC_BI__DocClass__c();
       docClass.LLC_BI__DocType__c = docTypeId;
       docClass.LLC_BI__docManager__c = docManId;
       docClass.Name='Pricing';
       insert docClass;
       id docClassId = [Select id from LLC_BI__DocClass__c where id=:docClass.id].id;
       /***********Create record for Closing checklist********/
       	LLC_BI__ClosingChecklist__c cc = new LLC_BI__ClosingChecklist__c();
        cc.Name = 'Pricing';
        cc.LLC_BI__docClass__c= docClassId;
        cc.LLC_BI__docType__c = docTypeId;
        cc.LLC_BI__docManager__c = docManId;
        insert cc;
        id CCId = [select id from LLC_BI__ClosingChecklist__c where id=:cc.id].id;
       /***********Create record for LoanDocument***********/
        LLC_BI__LLC_LoanDocument__c loandoc3 = new 	LLC_BI__LLC_LoanDocument__c();
        loandoc3.Name = 'Pricing';
        loandoc3.LLC_BI__Loan__c = loanId;
        loandoc3.LLC_BI__closingChecklist__c = CCId;
        loandoc3.LLC_BI__docClass__c = docClassId;
        loandoc3.LLC_BI__docManager__c = docManId;
        loandoc3.LLC_BI__docType__c = docTypeId;
        insert loandoc3;
        
        LLC_BI__LLC_LoanDocument__c ld6 = [Select id,LLC_BI__reviewStatus__c,NDOC__Placeholder_Approval_Roles__c,LLC_BI__Approval_Roles__c,	LLC_BI__closingChecklist__c from LLC_BI__LLC_LoanDocument__c where LLC_BI__docType__r.name=:'Pricing' LIMIT 1];
        ld6.LLC_BI__Approval_Roles__c='SAN 14;SAN System Admin;';
        test.startTest();
        update ld6;
        test.stopTest();
        LLC_BI__LLC_LoanDocument__c ld7 = [Select LLC_BI__Approval_Roles__c from LLC_BI__LLC_LoanDocument__c where id=:ld6.id];
      	System.assertEquals('SAN 14;SAN System Admin;',ld7.LLC_BI__Approval_Roles__c);
    }
    }