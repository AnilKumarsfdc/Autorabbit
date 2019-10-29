/* --------------------------------------------------------------------------------------------------
     Name:            ConvertToServicingControllerTest.cls 
     Description:     Test Class for controller ConvertToServicingController.cls
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
public class ConvertToServicingControllerTest {
   /* private static final String CSC_PROFILE = 'SAN 5';
    private static final String QUERY_RECORD_TYPE = 'Refunds / Write Offs';
    private static final String SERVICE_RECORD_TYPE = 'Servicing Request';*/

    /** 
     * @description : This method runs runPositiveTests
     **/
   /* private static testMethod void runPositiveTests1() {      
        User u = PrepareTestData.getRunningUser(CSC_PROFILE);
		Id caseRecordId = null, caseRecord2Id = null;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
		
        System.runAs(u) {            
            List<Case> caseList = new List<Case>();
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open';
            caseRecord.Origin = 'FC Ops';
			caseRecord.Account_Number__c = '1234';
            caseList.add(caseRecord);
            
            Case caseRecord2 = new Case();
            caseRecord2.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord2.Status = 'Open';
            caseRecord2.Origin = 'FC Ops';
			caseRecord2.Account_Number__c = '4321';
            caseList.add(caseRecord2);
            Database.insert(caseList);
            
            ApexPages.StandardController sController = new ApexPages.StandardController(caseRecord);
            ConvertToServicingController caseExtension = new ConvertToServicingController(sController);
            
            PageReference pageRef = page.ConvertToComplaint;
            pageRef.getParameters().put('Id', caseRecord.Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
            caseExtension.cachedCaseId = caseRecord.Id;
            caseExtension.save();
            ConvertToServicingController.changeRecordType(caseRecord2.Id);
            Test.stopTest();
            
            caseRecordId = caseRecord.Id;
            caseRecord2Id = caseRecord2.Id;
        }
        
        Id serviceRecordType = caseRecordTypeInfo.get(SERVICE_RECORD_TYPE).getRecordTypeId();
        Case caseObj = [SELECT Id, RecordTypeId, Formerly_Query__c
                        FROM Case WHERE Id =:caseRecordId LIMIT 1];
        system.assertEquals(serviceRecordType, caseObj.RecordTypeId);
        system.assertEquals(true, caseObj.Formerly_Query__c);
        
        Case caseLO = [SELECT Id, RecordTypeId, Formerly_Query__c, OwnerId
                        FROM Case WHERE Id = :caseRecord2Id LIMIT 1];
        System.assertEquals(serviceRecordType, caseLO.RecordTypeId);
        System.assertEquals(true, caseLO.Formerly_Query__c);       
    }
    
    /** 
     * @description : This method runs runPositiveTests
     **/
   /* private static testMethod void runPositiveTests2() {      
        User u = PrepareTestData.getRunningUser('SAN 5');

        System.runAs(u) {
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
           
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open';
            caseRecord.Origin = 'FC Ops';
			caseRecord.Account_Number__c = '758567';
            Database.insert(caseRecord);            
           
            Test.startTest();
            	Boolean hasAccess = ConvertToServicingController.hasAccess(caseRecord.Id);
            Test.stopTest();
            
            system.assertEquals(true, hasAccess);
        }
    }
    
     /** 
     * @description : This method runs runNegativeTests
     **/
   /* private static testMethod void runNegativeTests() {      
        User u = PrepareTestData.getRunningUser('SAN Relationship Director');

        System.runAs(u) {
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();           
          
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open';
            caseRecord.Origin = 'FC Ops';
			caseRecord.Account_Number__c = '99999';
            Database.insert(caseRecord);         
           
            Test.startTest();
            	Boolean hasAccess = ConvertToServicingController.hasAccess(caseRecord.Id);
            Test.stopTest();
            
            system.assertEquals(false, hasAccess);
        }
    }*/
}