/* --------------------------------------------------------------------------------------------------
     Name:            ConvertToComplaintControllerTest.cls 
     Description:     Test Class for controller ConvertToComplaintController.cls
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
public class ConvertToComplaintControllerTest {
    private static final String CSC_PROFILE = 'SAN 5';
    private static final String QUERY_RECORD_TYPE = 'Servicing Request';
    private static final String COMPLAINT_RECORD_TYPE = 'Complaint';

    /** 
     * @description : This method runs runPositiveTests
     **/
    private static testMethod void runPositiveTests1() {      
        User u = PrepareTestData.getRunningUser(CSC_PROFILE);
		Id caseRecordId = null, caseRecord2Id = null;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
		
        System.runAs(u) {            
            List<Case> caseList = new List<Case>();
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open - Servicing Team';
            caseRecord.Origin = 'RD';
            caseRecord.Tracker_Process_Lv1__c = 'Cards';
            caseRecord.Tracker_Process_Lv2__c = 'Blocks';
            caseRecord.Tracker_Process_Lv3__c = 'Block Card - Fraud';
            caseList.add(caseRecord);
            
            Case caseRecord2 = new Case();
            caseRecord2.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord2.Status = 'Open - Servicing Team';
            caseRecord2.Origin = 'RD';
            caseRecord2.Tracker_Process_Lv1__c = 'Cards';
            caseRecord2.Tracker_Process_Lv2__c = 'Blocks';
            caseRecord2.Tracker_Process_Lv3__c = 'Block Card - Fraud';
            caseList.add(caseRecord2);
            Database.insert(caseList);
            
            ApexPages.StandardController sController = new ApexPages.StandardController(caseRecord);
            ConvertToComplaintController caseExtension = new ConvertToComplaintController(sController);
            
            PageReference pageRef = page.ConvertToComplaint;
            pageRef.getParameters().put('Id', caseRecord.Id);
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
            caseExtension.cachedCaseId = caseRecord.Id;
            caseExtension.save();
            ConvertToComplaintController.changeRecordType(caseRecord2.Id);
            Test.stopTest();
            
            caseRecordId = caseRecord.Id;
            caseRecord2Id = caseRecord2.Id;
        }
        
        Id complaintRCT = caseRecordTypeInfo.get(COMPLAINT_RECORD_TYPE).getRecordTypeId();
        Case caseObj = [SELECT Id, RecordTypeId, Formerly_Query__c
                        FROM Case WHERE Id =:caseRecordId LIMIT 1];
        system.assertEquals(complaintRCT, caseObj.RecordTypeId);
        system.assertEquals(true, caseObj.Formerly_Query__c);
        
        Case caseLO = [SELECT Id, RecordTypeId, Formerly_Query__c, OwnerId
                        FROM Case WHERE Id = :caseRecord2Id LIMIT 1];
        System.assertEquals(complaintRCT, caseLO.RecordTypeId);
        System.assertEquals(true, caseLO.Formerly_Query__c);       
    }
    
    /** 
     * @description : This method runs runPositiveTests
     **/
    private static testMethod void runPositiveTests2() {      
        User u = PrepareTestData.getRunningUser('SAN 5');

        System.runAs(u) {
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
           
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open - Servicing Team';
            caseRecord.Origin = 'RD';
            caseRecord.Tracker_Process_Lv1__c = 'Cards';
            caseRecord.Tracker_Process_Lv2__c = 'Blocks';
            caseRecord.Tracker_Process_Lv3__c = 'Block Card - Fraud';
            Database.insert(caseRecord);            
           
            Test.startTest();
            	Boolean hasAccess = ConvertToComplaintController.hasAccess(caseRecord.Id);
            Test.stopTest();
            
            system.assertEquals(true, hasAccess);
        }
    }
    
     /** 
     * @description : This method runs runNegativeTests
     **/
    private static testMethod void runNegativeTests() {      
        User u = PrepareTestData.getRunningUser('SAN Relationship Director');

        System.runAs(u) {
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();           
          
            Case caseRecord = new Case();
            caseRecord.RecordTypeId = caseRecordTypeInfo.get(QUERY_RECORD_TYPE).getRecordTypeId();
            caseRecord.Status = 'Open - Servicing Team';
            caseRecord.Origin = 'RD';
            caseRecord.Tracker_Process_Lv1__c = 'Cards';
            caseRecord.Tracker_Process_Lv2__c = 'Blocks';
            caseRecord.Tracker_Process_Lv3__c = 'Block Card - Fraud';
            Database.insert(caseRecord);         
           
            Test.startTest();
            	Boolean hasAccess = ConvertToComplaintController.hasAccess(caseRecord.Id);
            Test.stopTest();
            
            system.assertEquals(false, hasAccess);
        }
    }
}