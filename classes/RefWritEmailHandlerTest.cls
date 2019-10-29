@isTest(SeeAllData = false)
private class RefWritEmailHandlerTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final List<String> TO_ADDRESS = new List<String> { 'someaddress@email.com' }; 
    private static final List<String> REFUND_STATUS = new List<String> { 'Approved by SGO', 'Rejected by SGO'}; 
    private static final String REFUND_SUBJECT = 'Refunds Write Off Case Number :';
	private static final String FROM_NAME = 'FirstName LastName';
	private static final String FROM_ADDRESS = 'someaddress@email.com';
    private static final String DOT = '.';
	private static final String HTML_BODY = 'Test HTML body';

    @isTest private static void RefundCaseTestMethod()  {

        Account acct = PrepareTestData.getDefaultAccount();
        Database.insert(acct);
            
        Contact conObj = PrepareTestData.getTestContact(acct.Id);
        Database.insert(conObj);
            
        Id refundRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.REFWRIT_RECORD_TYPE).getRecordTypeId();
            
        Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=refundRecordType, ContactId= conObj.Id,
                       Status='Open');
        insert caseObj;
           
        User user1 = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE); 
            
        // Create an approval request for the case
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(caseObj.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user1.Id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Refunds_Write_Offs_SGO_Approval');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the case
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals(
            'Approved', result2.getInstanceStatus(), 
            'Instance Status'+result2.getInstanceStatus());
    }
    

    @isTest private static void declineRefundCaseTestMethod()  {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
               

        system.runAs(user) {
            Account acct = PrepareTestData.getDefaultAccount();
        	Database.insert(acct);
            
            Contact conObj = PrepareTestData.getTestContact(acct.Id);
            Database.insert(conObj);
            
            Id refundRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.REFWRIT_RECORD_TYPE).getRecordTypeId();
            
            Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=refundRecordType, ContactId= conObj.Id,
                                   Status='Submitted to SGO');
        	Database.insert(caseObj);
            
            Case caseQuery = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            Messaging.InboundEmail inEmail = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            inEmail.subject = REFUND_SUBJECT + caseQuery.CaseNumber;
  			inEmail.fromname = FROM_NAME;
            inEmail.plainTextBody = GlobalConstants.REFWRIT_EMAIL_REPLY_REJ;
            inEmail.htmlBody = HTML_BODY;
            inEmail.toAddresses = TO_ADDRESS;
  			env.fromAddress = FROM_ADDRESS;
            
            EmailMessageHandler emailService = new EmailMessageHandler();

            Test.startTest();
            	emailService.handleInboundEmail(inEmail, env);
            Test.stopTest();
            
            Case resultCase = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            system.assertNotEquals(REFUND_STATUS[1], resultCase.Status);
        }
    }

    
    @isTest private static void approveRefundCaseMethod2() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
               

        system.runAs(user) {
            Account acct = PrepareTestData.getDefaultAccount();
        	Database.insert(acct);
            
            Contact conObj = PrepareTestData.getTestContact(acct.Id);
            Database.insert(conObj);
            
            Id refundRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.REFWRIT_RECORD_TYPE).getRecordTypeId();
            
            Case caseObj = new Case(AccountId=acct.Id, RecordTypeId=refundRecordType, ContactId= conObj.Id,
                                   Status='Approved by SGO');
        	Database.insert(caseObj);
            
            Case caseQuery = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            Messaging.InboundEmail inEmail = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            inEmail.subject = REFUND_SUBJECT + caseQuery.CaseNumber;
  			inEmail.fromname = FROM_NAME;
            inEmail.plainTextBody = GlobalConstants.REFWRIT_EMAIL_REPLY_APP + DOT;
            inEmail.htmlBody = HTML_BODY;
            inEmail.toAddresses = TO_ADDRESS;
  			env.fromAddress = FROM_ADDRESS;
            
            EmailMessageHandler emailService = new EmailMessageHandler();

            Test.startTest();
            	emailService.handleInboundEmail(inEmail, env);
            Test.stopTest();
            
           Case resultCase = [SELECT Id, CaseNumber, Status
                              FROM Case
                              WHERE Id=: caseObj.Id
                              LIMIT 1];
            
            system.assertEquals(REFUND_STATUS[0], resultCase.Status);
		
        }
    }
    
}