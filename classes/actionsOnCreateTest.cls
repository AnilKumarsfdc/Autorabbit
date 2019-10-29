@isTest
public class actionsOnCreateTest {
    @testSetup static void setup() {
   //***Create record for Covenant mgmt***
       LLC_BI__Covenant2__c Comgmt=new LLC_BI__Covenant2__c();
       Comgmt.Covenant_Type2__c='Budget';
       Comgmt.Test_Date__c=date.parse('04/12/2019');
       Comgmt.Information_Due_in_Days__c='42';
       Comgmt.LLC_BI__Frequency__c='weekly';
       Comgmt.RecordTypeId=Schema.sObjectType.LLC_BI__Covenant2__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
       insert Comgmt;
       Id CovenantId =[ Select id from LLC_BI__Covenant2__c where Id=:Comgmt.id].Id;
      
  //***Create Record for Covenant Compliance     
       LLC_BI__Covenant_Compliance2__c obj=new LLC_BI__Covenant_Compliance2__c();
       obj.LLC_BI__Status__c='Pending';
       obj.LLC_BI__Covenant__c = CovenantId;
       insert obj;   
  }   
   @isTest public static void CovenantprocesBuilderTrue() {
       LLC_BI__Covenant_Compliance2__c Co=[SELECT id, LLC_BI__Status__c,LLC_BI__Covenant__c from LLC_BI__Covenant_Compliance2__c];
       Test.startTest();
       Update Co;
       Test.stopTest();
   } 
   @isTest public static void CovenantprocesBuilderFalse1(){
           
           
       }
    
   }