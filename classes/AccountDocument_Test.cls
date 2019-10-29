/******************************************************************
 * Class Name-AccountDocument_Test
 * Description-Test class for Process Builder on AccountDocument Object
 * Created By-Nikita Kamble 
 * Created Date-9/31/2019 
 * ****************************************************************/
@isTest
public class AccountDocument_Test {
   @testSetup static void setup(){
      /******Create record for Account******/
        Account acc= new Account();
        acc.RecordTypeId=Schema.sObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        acc.Name='Test Account';
        insert acc;
        id accId = [Select id from Account where id=: acc.id].id;
     /******Create record for DocManager************/
       LLC_BI__DocManager__c  docMan= new LLC_BI__DocManager__c();
       docMan.Name='Account';
       docMan.LLC_BI__namespacePrefix__c='LLC_BI';
       insert docMan;
       id docManId = [Select id from LLC_BI__DocManager__c where id=:docMan.id].id;
      /******Create record for Doc type R&R permission******/
       LLC_BI__DocType__c docType=new LLC_BI__DocType__c();
       docType.Name='R&R Alerts';
       docType.LLC_BI__docManager__c = docManId;
       insert docType;
       id docTypeId = [Select id from LLC_BI__DocType__c where id=:docType.id].id;
       /********Create record for Doc type standard permission********/
       LLC_BI__DocType__c docType1=new LLC_BI__DocType__c();
       docType1.Name='Account Products & Services';
       docType1.LLC_BI__docManager__c = docManId;
       insert docType1;
       id docTypeId1 = [Select id from LLC_BI__DocType__c where id=:docType1.id].id;
       
          
      /******Create record for AccountDocument****/
      LLC_BI__AccountDocument__c accdoc= new LLC_BI__AccountDocument__c();
      accdoc.Name='Account DocMan1';
      accdoc.LLC_BI__docType__c = docTypeId;
      accdoc.LLC_BI__docManager__c = docManId;
      accdoc.LLC_BI__Account__c = accId;
      accdoc.LLC_BI__reviewStatus__c='Open';
      insert accdoc;
      
      /************Create record for AccountDocument*******/
      LLC_BI__AccountDocument__c accd1 = new LLC_BI__AccountDocument__c();
      accd1.Name='Account DocMan2';
      accd1.LLC_BI__docType__c = docTypeId1;
      accd1.LLC_BI__docManager__c = docManId;
      accd1.LLC_BI__Account__c = accId;
      accd1.LLC_BI__reviewStatus__c='Open';
      insert accd1;
    
   }
   @isTest static void AccountDocumentProcessBuilderTrue(){
      
      LLC_BI__AccountDocument__c ad = [Select id,LLC_BI__reviewStatus__c,LLC_BI__Approval_Roles__c,LLC_BI__Account__c,LLC_BI__docManager__c,LLC_BI__docType__c from LLC_BI__AccountDocument__c  LIMIT 1]; 
      ad.LLC_BI__Approval_Roles__c ='SAN 14;SAN System Admin';
      test.startTest();
      update ad;
      test.stopTest();
      LLC_BI__AccountDocument__c ad1 = [Select LLC_BI__Approval_Roles__c from LLC_BI__AccountDocument__c where id=:ad.id];
      System.assertEquals('SAN 14;SAN System Admin',ad1.LLC_BI__Approval_Roles__c);
       
    }
    
    @isTest static void AccountDocumentProcessBuilderFalse(){
        List<LLC_BI__AccountDocument__c> ad2 = new List<LLC_BI__AccountDocument__c>();
        
        for(LLC_BI__AccountDocument__c acd: ad2){
        ad2=[Select id,LLC_BI__reviewStatus__c,LLC_BI__Approval_Roles__c,LLC_BI__Account__c,LLC_BI__docManager__c,LLC_BI__docType__c from LLC_BI__AccountDocument__c  where LLC_BI__docType__c=:'Account Products & Services' ];
        ad2.add(acd);
        acd.LLC_BI__Approval_Roles__c='SAN 13;SAN 14;SAN 15;SAN System Admin';
        test.startTest();
        update acd;
        test.stopTest();
        
        List<LLC_BI__AccountDocument__c> ad3 = [Select LLC_BI__Approval_Roles__c from LLC_BI__AccountDocument__c where id=:acd.id];
        System.assertEquals('SAN 13;SAN 14;SAN 15;SAN System Admin',acd.LLC_BI__Approval_Roles__c);
    }
    }
    }