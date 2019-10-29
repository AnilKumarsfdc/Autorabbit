/**
  * Name:        CaseTriggerHandlerTest.cls
  * Description: Test Class for CaseTriggerHandler Class           
  * Created By:  Ujjwala Gavhane 
  **/
@isTest(SeeAllData = false)
Private class CaseTriggerHandlerTest {


    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final String FC_OPS_PROFILE = 'SAN 8';
    private static final String PROSPECT_COMPANY_RECORD_TYPE = 'Prospect';
    private static final String CUSTOMER_COMPANY_RECORD_TYPE = 'Customer';
    private static final String SR_CASE_RECORD_TYPE = 'Servicing Request';
    private static final String COMPLAINT_CASE_RECORD_TYPE = 'Complaint';
    //private static final String CRA_CASE_RECORD_TYPE = 'Customer Risk Assessment';
    private static final String DOC_TYPE = 'KYC';
    private static final String DOC_DATA_TYPE = 'Date of Birth';
    //private static final String ONBOARDING_RECORD_TYPE = 'Onboarding';

    /**
     * @description Test for creating case and checking the task 
     **/
    @isTest private static void runPositiveTests() {
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);

        system.runAs(user) {
            Test.startTest();
            
            Time hoBefore2 = Time.newInstance(13, 00, 0, 0);
            Time hoAfter2 = Time.newInstance(14, 10, 0, 0);
            DateTime hodTBefore = DateTime.newInstance(system.today(), hoBefore2);
            DateTime hodTAfter = DateTime.newInstance(system.today(), hoAfter2);

            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

            Schema.DescribeSObjectResult cfrCaseSchema = Schema.SObjectType.Case;
            Map<String, Schema.RecordTypeInfo> caseRecordTypeInfo = cfrCaseSchema.getRecordTypeInfosByName();

            List<Case> caseList = new List<Case> ();
            List<Account> accList = new List<Account> ();
            List<BDP_Company__c> bdpComList = new List<BDP_Company__c> ();

            Account acct = new Account(Name = 'Prospect Company Test', DunsNumber = '516',
                                       RecordTypeId = accountRecordTypeInfo.get(PROSPECT_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(acct);
            
            Account bdpAcct = new Account(Name = 'BDP Company Test', RecordTypeId = accountRecordTypeInfo.get(CUSTOMER_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(bdpAcct);
            Account acct1 = new Account(Name = 'Test');
            accList.add(acct1);
            Database.insert(accList);

            BDP_Company__c bdpCompany = new BDP_Company__c(Name = '12345678', Company__c = acct.Id, BDP_Customer_Number__c = '12345678');
            bdpComList.add(bdpCompany);
            BDP_Company__c bdpCompanyNew = new BDP_Company__c(Name = '12365478', Company__c = bdpAcct.Id, BDP_Customer_Number__c = '12365478');
            bdpComList.add(bdpCompanyNew);
            Database.insert(bdpComList);

            SLA_Mapping__c slaObj = new SLA_Mapping__c();
            slaObj.Name = 'TEST';
            slaObj.Tracker_Process_Level1__c = 'Cards';
            slaObj.Tracker_Process_Level2__c = 'Blocks';
            slaObj.Tracker_Process_Level3__c = 'Block Card - Fraud';
            slaObj.Date_Calculation__c = 1;
            slaObj.Next_Steps__c = 'Email: CBGroupFraud@santander.co.uk ';
            database.insert(slaObj);

            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'CSC' LIMIT 10000];
			DateTime CurrentDate = DateTime.now();
            Case case1 = new Case(AccountId = acct.Id, Status = 'New', Type = 'Create J Number', J_Number__c = 'J1234568',
                                  Origin = 'Phone', Irrelevant_Alert__c = true, RecordTypeId = caseRecordTypeInfo.get(SR_CASE_RECORD_TYPE).getRecordTypeId(),
                                  Tracker_Process_Lv1__c = slaObj.Tracker_Process_Level1__c, Tracker_Process_Lv2__c = slaObj.Tracker_Process_Level2__c,
                                  BusinessHoursId = bh.Id, Date_Time_Received__c = CurrentDate.addDays(-1),
                                  Tracker_Process_Lv3__c = slaObj.Tracker_Process_Level3__c);
            caseList.add(case1);
            /*Case onboardingCase1 = new Case(AccountId = acct.Id, Status='Pre AOS', J_Number__c = 'J123456',
                                           RecordTypeId = caseRecordTypeInfo.get(ONBOARDING_RECORD_TYPE).getRecordTypeId());
            caseList.add(onboardingCase1);*/
            Database.insert(caseList);

            Task caseTask = new Task(WhatId = case1.Id, Subject = 'Test Task');
            Database.insert(caseTask);

            caseTask.Status = 'Open';
            Database.update(caseTask);

            case1.H_O_DateTime__c = hodTBefore;
            Database.update(case1);

            case1.H_O_DateTime__c = hodTAfter;
            case1.Irrelevant_Alert__c = false;
            case1.Status = 'Closed';
            Database.SaveResult closeResult = Database.update(case1, false);
            
            /*onboardingCase1.J_Number__c = 'J123654';
            onboardingCase1.Status = 'Completed';
            Database.update(onboardingCase1);*/
            
          /*  onboardingCase1.J_Number__c = 'J12365490';
            onboardingCase1.Status = 'Completed';
            Database.update(onboardingCase1);*/
            
            /*Case onboardingCase = new Case(AccountId = bdpAcct.Id, Status='Completed', J_Number__c = 'J123654909',
                                           RecordTypeId = caseRecordTypeInfo.get(ONBOARDING_RECORD_TYPE).getRecordTypeId());
            Database.insert(onboardingCase);*/
			
           /* BDP_Company__c bdpComNew = [SELECT BDP_Customer_Number__c, Name, Company__c
                                        FROM BDP_Company__c
                                        WHERE BDP_Customer_Number__c =: onboardingCase.J_Number__c];*/
            
            Database.SaveResult accountChangeResult = Database.update(case1, false);

            Test.stopTest();
            
            System.assert(!closeResult.isSuccess());
            System.assert(!accountChangeResult.isSuccess());
           // System.assertEquals(onboardingCase.AccountId, bdpComNew.Company__c);
           // System.assertEquals(onboardingCase.J_Number__c, bdpComNew.BDP_Customer_Number__c);
        }
    }
    
    /**
     * @description Checks that FC_Ops_User cannot auto-approve their own Cases
     **/
    @isTest private static void testCaseAutoApprovement() {
        User fcOpsUser = PrepareTestData.getRunningUser(FC_OPS_PROFILE);
        System.runAs(fcOpsUser){
        	Account testAccount = PrepareTestData.getDefaultAccount();
        	Database.insert(testAccount);
        	Case testCase = PrepareTestData.getDefaultCase(testAccount.Id);
        	testCase.Approval_Status_New_Case__c = null;
        	Database.insert(testCase);
        	
        	Test.startTest();
        	testCase.Approval_Status_New_Case__c = CaseTriggerHandler.FC_OPS_APPROVED_STATUS;
        	Database.SaveResult updateResult = Database.update(testCase, false);
        	Test.stopTest();
        	
        	System.assertEquals(false, updateResult.isSuccess());
        }
    }
    
        
    /**
     * @description Checks that FC_Ops_User cannot auto-approve their own Cases
     **/
    @isTest private static void testCaseNonAutoApprovement() {
    	Account testAccount = PrepareTestData.getDefaultAccount();
    	Database.insert(testAccount);
    	Case testCase = PrepareTestData.getDefaultCase(testAccount.Id);
    	testCase.Approval_Status_New_Case__c = null;
    	Database.insert(testCase);
    	
        User fcOpsUser = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        Database.insert(fcOpsUser);
        System.runAs(fcOpsUser){        	
        	Test.startTest();
        	testCase.Approval_Status_New_Case__c = CaseTriggerHandler.FC_OPS_APPROVED_STATUS;
        	Database.SaveResult updateResult = Database.update(testCase, false);
        	Test.stopTest();
        	
        	System.assert(updateResult.isSuccess());
        }
    }
}