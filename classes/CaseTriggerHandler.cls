/* --------------------------------------------------------------------------------------------------
     Name:            CaseTriggerHandler.cls 
     Description:     Handler class for CaseTrigger
     Test class:      CaseTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public without sharing class CaseTriggerHandler {

    private static final String BDP_RECORD_TYPE = 'BDP Record';
    private static final String CLOSED = 'Closed';
    private static final String CLOSE_TASK_ERROR = 'Case cannot be closed until next task(s) are completed: ';
    private static final String COMMA = ',';
    private static final String BDP_COMPANY_ERROR = 'This J Number is associated with Other BDP Company - " ';
    private static final String J_NUMBER_ERROR = ' Please select the same company for J Number -';
    private static final String BLANK_VALUE = '';
    private static final String DOUBLE_QUOTES = '"' ;
    private static final string SLA_TIME = '14:00:00';
    private static final String QUERY_RECORD_TYPE = 'Servicing Request';
    private static final String COMPLAINT_RECORD_TYPE = 'Complaint';
    private static final String AUTO_APPROVEMENT_ERROR = 'FC Ops Users are unable to approve their own Cases';
    private static final String CSC_RECORD_TYPE ='CSC';
    private static final String TIME_FORMAT ='HH:mm:ss';
    @testVisible 
    private static final String FC_OPS_APPROVED_STATUS = 'Approved - FC Ops';
	private static final String ONBOARDING_RECORD_TYPE = 'Onboarding';
    private static final String CLOSE_CASE_ERROR = 'You cannot close the Case since the J Number is Blank';

    /** 
     * @description : Calculate SLA
     **/
    public void processBeforeInsert(List<case> caseList) {
        try {
			updateFNumbers(caseList);
            setBusinessHours(caseList);
            calculateSLA(caseList);         
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /** 
     * @description : Close task before closing the case
     **/
    public void processBeforeUpdate(List<case> caseList, Map<Id, Case> oldCaseMap) {
        try {
            calculateSLA(caseList);
            closeTaskBeforeCaseClose(caseList, oldCaseMap);
            preventCaseAutoApprovement(caseList, oldCaseMap);
        }
        catch(Exception e) {
            throw e;
        }
    }

    /** 
     * @description : Create BDP Company based on J Number
	 **/
    public void processAfterInsert(List<case> caseList) {
        try {
            createBdpCompanyOnInsert(caseList);
        }
        catch(Exception e) {
            throw e;
        }
    }

    /** 
     * @description : Create BDP Company and Delete Irrelevant task.
     **/
    public void processAfterUpdate(List<case> caseList, Map<Id, Case> oldCaseMap) {
        try {
            //bdpRecordCreateOnUpdate(caseList, oldCaseMap);
			createBdpCompanyOnUpdate(caseList, oldCaseMap);
            deleteIrrelevantTask(caseList);
        }
        catch(Exception e) {
            throw e;
        }
    }

    /**
     * @description Close Task before closing the case .
     * 
     **/
    private void closeTaskBeforeCaseClose(List<case> caseList, Map<Id, Case> oldCaseMap) {

        Map<Id, List<String>> casesTasksListMap = new Map<Id, List<String>> ();

        for (Case updatedCase : caseList) {
            Case oldValue = oldCaseMap.get(updatedCase.Id);

            // Only those cases will be picked up where Irrelavent Alert Checkbox is not checked.
            if (updatedCase.Status == CLOSED && oldValue.Status != CLOSED && (!updatedCase.Irrelevant_alert__c)) {
                casesTasksListMap.put(updatedCase.Id, new List<String> ());
            }
        }

        if (casesTasksListMap.size() > 0) {

            // Checking if there is any open task for incoming case

            for (Task taskToVerify :[SELECT Id, IsClosed, whatId, Subject
                 FROM Task
                 WHERE whatId IN :casesTasksListMap.keySet() AND IsClosed = false LIMIT 1000
                 ]) {
                if (!taskToVerify.IsClosed) {
                    casesTasksListMap.get(taskToVerify.whatId).add(taskToVerify.Subject);
                }
            }

            for (Id caseId : casesTasksListMap.keySet()) {
                List<String> openedTasksList = casesTasksListMap.get(caseId);

                //Giving Error Message if there is any Open task.
                if (openedTasksList.size() > 0) {
                    Trigger.newMap.get(caseId).addError(CLOSE_TASK_ERROR +
                                                        String.join(openedTasksList, COMMA)
                  );   
                }
            }
        }
    }

    /**
     * @description Delete Irrelevant Task  .
     * 
     **/
    private void deleteIrrelevantTask(List<Case> caseList) {

        Set<Id> idSet = new Set<Id> ();
        for (Case c : caseList)
        {
            if (c.IsClosed && (c.Irrelevant_Alert__c == true)) {
                idSet.add(c.Id);
            }

        }
        List<Task> taskList = [SELECT Id
                               FROM Task
                               WHERE whatId IN :idSet LIMIT 10000];
        try {
            Database.delete(taskList);
        }
        Catch(Exception e) {
            throw e;
        }
    }

    
    /**
    * @description Checks if Case Creator attempts to Approve own Case when assigned to Fin Crime team, then add an error
    **/
    private void preventCaseAutoApprovement(List<Case> caseList, Map<Id, Case> oldCaseMap){
    	Id currentUserId = UserInfo.getUserId();
    	for (Case newValue : caseList) {
    		Case oldValue = oldCaseMap.get(newValue.Id);
    		if (newValue.Approval_Status_New_Case__c == FC_OPS_APPROVED_STATUS &&
    			oldValue.Approval_Status_New_Case__c != FC_OPS_APPROVED_STATUS &&
    			newValue.CreatedById == currentUserId){
    			newValue.addError(AUTO_APPROVEMENT_ERROR);
    		}
    	}
    }
    

	/**
     * @description This method creates BDP company for Insert of an Onboarding Case.
     * 
     **/
    private void createBdpCompanyOnInsert(List<Case> caseList){
		Id onboardingRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ONBOARDING_RECORD_TYPE).getRecordTypeId();
		Map<String, Id> jNumAcctMap = new Map<String, Id> ();
		Map<String, BDP_Company__c> bdpMap = new Map<String, BDP_Company__c> ();
        List<BDP_Company__c> bdpComList = new List<BDP_Company__c> ();
        BDP_Company__c bdpComToInsert;

		for(Case caseObj : caseList){
			if(caseObj.RecordTypeId == onboardingRecordType && caseObj.J_Number__c != null &&
			   (caseObj.Status == 'Completed')){
					jNumAcctMap.put(caseObj.J_Number__c, caseObj.AccountId);
			}
		}
		
		if(!jNumAcctMap.isEmpty()) {
			for (BDP_Company__c bdpCompany :[SELECT Id, Name, BDP_Customer_Number__c, Company__r.Name, Company__c 
											 FROM BDP_Company__c
											 WHERE BDP_Customer_Number__c IN :jNumAcctMap.keySet() LIMIT 10000]) { 

                bdpMap.put(bdpCompany.BDP_Customer_Number__c, bdpCompany);
            }
		}
        
        for (Case cs : caseList) {
			if(cs.RecordTypeId == onboardingRecordType && 
			   (cs.Status == 'Completed')){
				if(cs.J_Number__c != null && (!bdpMap.isEmpty())){
					if (jNumAcctMap.get(cs.J_Number__c) != bdpMap.get(cs.J_Number__c).Company__c) {
						cs.addError(BDP_COMPANY_ERROR + bdpMap.get(cs.J_Number__c).Company__r.Name + DOUBLE_QUOTES);
					}
				} else if(cs.J_Number__c != null && (!jNumAcctMap.isEmpty())){
					bdpComToInsert = new BDP_Company__c();
					bdpComToInsert.Name = cs.J_Number__c;
					bdpComToInsert.Company__c = jNumAcctMap.get(cs.J_Number__c);
					bdpComToInsert.BDP_Customer_Number__c = cs.J_Number__c;
					bdpComToInsert.BDP_Last_Updated_Date__c = DateTime.newInstance(1900, 1, 1);
					bdpComList.add(bdpComToInsert);
				} else if (cs.J_Number__c == null) {
					cs.addError(CLOSE_CASE_ERROR);
				}
			}
        }

		if (!bdpComList.isEmpty()) {
            try {
                Database.insert(bdpComList); 
            }
            catch(Exception e) {
                throw e;
            }
        }
	}

	/**
     * @description This method creates BDP company for Update of an Onboarding Case.
     * 
     **/
    private void createBdpCompanyOnUpdate(List<Case> caseList, Map<Id, Case> oldCaseMap){
		Id onboardingRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ONBOARDING_RECORD_TYPE).getRecordTypeId();
		Map<String, Id> caseMap = new Map<String, Id> ();
		Map<String, BDP_Company__c> bdpCompanyMap = new Map<String, BDP_Company__c> ();
        List<BDP_Company__c> bdpCompanyToInsert = new List<BDP_Company__c> ();
        BDP_Company__c newBdpCompany;

		for(Case newCase : caseList){
			Case oldCase = oldCaseMap.get(newCase.Id);
			if(newCase.RecordTypeId == onboardingRecordType && 
			   (newCase.Status == 'Completed')){
				if ((newCase.J_Number__c != null && newCase.J_Number__c != oldCase.J_Number__c) || 
					(newCase.J_Number__c != null && newCase.AccountID != oldCase.AccountId)) {
						caseMap.put(newCase.J_Number__c, newCase.AccountId);
                } 
			}
		}
		
		if(!caseMap.isEmpty()) {
			for (BDP_Company__c bdpCompany :[SELECT Id, Name, BDP_Customer_Number__c, Company__r.Name, Company__c 
											 FROM BDP_Company__c
											 WHERE BDP_Customer_Number__c IN :caseMap.keySet() LIMIT 10000]) { 

                bdpCompanyMap.put(bdpCompany.BDP_Customer_Number__c, bdpCompany);
            }
		}
        
        for (Case newValue : caseList) {
			Case oldValue = oldCaseMap.get(newValue.Id);
			if(newValue.RecordTypeId == onboardingRecordType && 
			   (newValue.Status == 'Completed')){
				if(newValue.J_Number__c != null && (newValue.J_Number__c != oldValue.J_Number__c) && (!bdpCompanyMap.isEmpty())){
					if (caseMap.get(newValue.J_Number__c) != bdpCompanyMap.get(newValue.J_Number__c).Company__c) {
						newValue.addError(BDP_COMPANY_ERROR + bdpCompanyMap.get(newValue.J_Number__c).Company__r.Name + DOUBLE_QUOTES);
					}
				} else if(newValue.J_Number__c != null && (newValue.J_Number__c != oldValue.J_Number__c) && (!caseMap.isEmpty())){
					newBdpCompany = new BDP_Company__c();
					newBdpCompany.Company__c = caseMap.get(newValue.J_Number__c);
					newBdpCompany.BDP_Customer_Number__c = newValue.J_Number__c;
					newBdpCompany.BDP_Last_Updated_Date__c = DateTime.newInstance(1900, 1, 1);
					bdpCompanyToInsert.add(newBdpCompany);
				} else if (newValue.J_Number__c == null) {
					newValue.addError(CLOSE_CASE_ERROR);
				}
			}
        }

		if (!bdpCompanyToInsert.isEmpty()) {
            try {
                Database.insert(bdpCompanyToInsert); 
            }
            catch(Exception e) {
                throw e;
            }
        }
	}
    
    
    
    /**
     * @description Set Business Hours.
     * 
     **/
    private void setBusinessHours(List<case> caseList){
        
        Id queryRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(QUERY_RECORD_TYPE).getRecordTypeId();
        Id complaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(COMPLAINT_RECORD_TYPE).getRecordTypeId();        
    
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name=: CSC_RECORD_TYPE LIMIT 10000];
        for(case c1: caseList ){
            if(c1.RecordTypeId == queryRecordType || c1.RecordTypeId == complaintRecordType ) {
                c1.BusinessHoursId = bh.Id;
            }
        } 
    }
	
    /**
     * @description Calculate SLA.
     * 
     **/
    private void calculateSLA(List<Case> caseList) {
        
        List<SLA_Mapping__c> listSLAObject = SLA_Mapping__c.getall().values();

        for (Case c : caseList) {
            for (SLA_Mapping__c slaObject : listSLAObject) {
                if (c.Tracker_Process_Lv1__c == slaObject.Tracker_Process_Level1__c &&
                    c.Tracker_Process_Lv2__c == slaObject.Tracker_Process_Level2__c &&
                    c.Tracker_Process_Lv3__c == slaObject.Tracker_Process_Level3__c && c.BusinessHoursId != null )  {
                    
                    Long days = System.long.valueOf(BLANK_VALUE + (slaObject.Date_Calculation__c));
                    Long interval = days * 10 * 60 * 60 * 1000;
                    
                    if(c.H_O_DateTime__c != null){
                        string timeFormat = c.H_O_DateTime__c.format(TIME_FORMAT);
                        
                        if(timeFormat > SLA_TIME){
                            DateTime lateHoSla = BusinessHours.add(c.BusinessHoursId, c.H_O_DateTime__c, interval);
                            DateTime slaDateTime = BusinessHours.add(c.BusinessHoursId, lateHoSla, 1 * 10 * 60 * 60 * 1000);
                            Time slaTime = Time.newInstance(09, 00, 0, 0);
                            c.Due_DateTime_SLA__c = DateTime.newInstance(slaDateTime.date(),slaTime);
                        } else {
                            DateTime earlyHoSla = BusinessHours.add(c.BusinessHoursId, c.H_O_DateTime__c, interval);
                            c.Due_DateTime_SLA__c = earlyHoSla;
                        }
                    } else {
                        DateTime dT = BusinessHours.add(c.BusinessHoursId, c.Date_Time_Received__c, interval);
                        c.Due_DateTime_SLA__c = dT;
                    }
                    c.Next_Steps__c = slaObject.Next_Steps__c;
                    c.SLA_Value__c = slaObject.Date_Calculation__c;
                }
            }
        }
    }

	private void updateFNumbers(List<Case> caseList){

		Id rtbfRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.RTBF_RECORD_TYPE).getRecordTypeId();
        Id rtdpRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.RTDP_RECORD_TYPE).getRecordTypeId();
        Id sarRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SAR_RECORD_TYPE).getRecordTypeId();
		Set<Id> contactIds = new Set<Id>();
		List<String> fNumberList = new List<String>();
		String fDetails = BLANK_VALUE;
		
		for (Case caseObj : caseList) {
			if ((caseObj.RecordTypeId.equals(rtbfRecordType) || caseObj.RecordTypeId.equals(rtdpRecordType)
                || caseObj.RecordTypeId.equals(sarRecordType)) 
                && caseObj.ContactId != null) {
				contactIds.add(caseObj.ContactId);
			}
		}

		if (! contactIds.isEmpty()) {
			for (BDP_Contact_Relationship__c bdpRel : [SELECT Id, BDP_Contact__r.F_Number__c
													   FROM BDP_Contact_Relationship__c
													   WHERE BDP_Contact__r.Salesforce_Contact__c IN :contactIds]) {
				fNumberList.add(bdpRel.BDP_Contact__r.F_Number__c);
			}
		}

		for(string fNumber : fNumberList){
			if ((fDetails != '') && (fDetails != null)) {fDetails += '\n';}
			if ((fNumber != null)) {fDetails += fNumber;}
		}

		
		for (Case caseValue : caseList) {
			if ((caseValue.RecordTypeId.equals(rtbfRecordType) || caseValue.RecordTypeId.equals(rtdpRecordType)  
                || caseValue.RecordTypeId.equals(sarRecordType)) 
                && caseValue.ContactId != null) {
				caseValue.F_List__c = fDetails;
			}
		}
	} 
}