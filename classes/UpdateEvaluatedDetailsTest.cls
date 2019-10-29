/******************************************************************
 * Class Name-UpdateEvaluatedDetailsTest
 * Description-Test class for Process Builder on Covenant Compliance Object
 * Created By-Shruti Mestry
 * Created Date-10/22/2019 
 * ****************************************************************/



@isTest
public class UpdateEvaluatedDetailsTest {
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
       LLC_BI__Covenant_Compliance2__c obj = new LLC_BI__Covenant_Compliance2__c();
       obj.RecordTypeId=Schema.sObjectType.LLC_BI__Covenant_Compliance2__c.getRecordTypeInfosByName().get('Ratched').getRecordTypeId();
       obj.LLC_BI__Status__c='Pending';
       obj.LLC_BI__Covenant__c = CovenantId;
       insert obj;   
  }    
@isTest static void CovenantprocesBuilder1() {
 //***Create new User in Profile-SAN Relatiopnship Director***
 
       String uniqueUserName = 'standarduser1' + DateTime.now().getTime() + '@testorg.com';
       Profile p = [SELECT Id FROM Profile WHERE Name='SAN Relationship Director'];
       User u = new User(Alias = 'SANRD', Email='SANRD@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName);
       insert u;
       
       System.runAs(u){
              
       LLC_BI__Covenant_Compliance2__c Co=[SELECT LLC_BI__Status__c,LLC_BI__Evaluated_By__c,LLC_BI__Evaluation_Date__c,Locking_field__c from LLC_BI__Covenant_Compliance2__c LIMIT 1];
      Co.LLC_BI__Status__c='Rejected';
           Co.LLC_BI__Evaluated_By__c='0059E00000728ZMQAY';
           Co.LLC_BI__Evaluation_Date__c=date.parse('04/12/2019');
           Co.Locking_field__c=true;
           
       //Co.RecordTypeId=Schema.sObjectType.LLC_BI__Covenant_Compliance2__c.getRecordTypeInfosByName().get('Ratched').getRecordTypeId();
       test.startTest();
         update Co;
       test.stopTest();
          
       LLC_BI__Covenant_Compliance2__c Co1=[SELECT LLC_BI__Status__c,LLC_BI__Evaluated_By__c,LLC_BI__Evaluation_Date__c,Locking_field__c from LLC_BI__Covenant_Compliance2__c where id=:Co.id];
       System.assertEquals('Rejected',Co1.LLC_BI__Status__c );
       System.assertEquals('0059E00000728ZMQAY',Co1.LLC_BI__Evaluated_By__c );
       System.assertEquals(date.parse('04/12/2019'),Co1.LLC_BI__Evaluation_Date__c );
       System.assertEquals(true,Co1.Locking_field__c );
}  
}    
}