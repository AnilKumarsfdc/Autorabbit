/* --------------------------------------------------------------------------------------------------
     Name:            DataFixerBatch.cls 
     Description:     Batch class which will fix all changes related to data update
  					  in one run.
  	 Test class:      DataFixerBatch.cls 
    ------------------------------------------------------------------------------------------------ */
global without sharing class DataFixerBatch implements Database.Batchable<sObject>{
	global enum JobType {FIX_TP_RATE, SET_OPPORTUNITY_VARIABLES, UPDATE_USER_ROLES, 
						 SET_PRIMARY_PRODUCT_LOOKUP, ESTIMATED_INCOME_RECALCULATION, 
						 FIX_FEE_AMOUNT, UPDATE_CUSTOMER_COMPANY, FIX_LAST_CONTACTED_DATE,
						 INTERNATIONAL_OPPORTUNITY_FLAG,FIX_COMPANY_FOLDER,FIX_CONTACTS}
	@testVisible 
	private final static Decimal EMPTY_TP_RATE = Test.isRunningTest() ? -9 : null;
	private final static Integer MAX_OPP_PRODUCT_DML_SIZE = 20;
	private static final String ACCOUNT_ID ='accId';
	private static final String EVENT_DATE ='evtDt';
    private static final String NEW_FOLDER_NAME ='Sales Docs';
    @testVisible private static final String CUSTOMER_RECORD_TYPE = 'Customer';
	@testVisible private final static Decimal PROPER_RATE = 1.0;
	@testVisible private final static String TEST_USER_LASTNAME = 'TestTestTest';
	
	global final JobType selectedJobType;
	global Map<String,Id> roleMap;
	
	/*
	* @description Public constructor which takes job type parameter and inits role map
	*/
	global DataFixerBatch(JobType typeToProcess){
		selectedJobType = typeToProcess;
		
		if (selectedJobType == JobType.UPDATE_USER_ROLES) {
			UserRole[] userRoles = [Select Id, Name FROM UserRole LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
			roleMap = new Map<String, Id>();
			for (UserRole r : userRoles) {
				roleMap.put(r.Name, r.Id);
			} 
		}
	}
    
    /*
    * @description Interface start method, which returns query base on selected job type
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	Database.QueryLocator resultLocator;
    	if (selectedJobType == JobType.FIX_TP_RATE) {
    		resultLocator = getTpRateQueryLocator();
    	} else if (selectedJobType == JobType.SET_OPPORTUNITY_VARIABLES) {
    		resultLocator = getOpporunityFixLocator();
    	} else if (selectedJobType == JobType.SET_PRIMARY_PRODUCT_LOOKUP) {
    		resultLocator = getPrimaryProductLookupFixLocator();
    	} else if (selectedJobType == JobType.UPDATE_USER_ROLES) {
    		resultLocator = getUserQueryLocator();
    	} else if (selectedJobType == JobType.FIX_FEE_AMOUNT) { 
    		resultLocator = getFeeAmountQueryLocator();
    	} else if (selectedJobType == JobType.ESTIMATED_INCOME_RECALCULATION) {
    		resultLocator = getEstimatedIncomeFixLocator();
    	} else if (selectedJobType == JobType.UPDATE_CUSTOMER_COMPANY) {
    		resultLocator = getCustomerCompanyFixLocator();
    	} else if (selectedJobType == JobType.FIX_LAST_CONTACTED_DATE) {
    		resultLocator = getLastContactedDateFixLocator();
    	} else if (selectedJobType == JobType.INTERNATIONAL_OPPORTUNITY_FLAG) {
    		resultLocator = getOpportunityInternationalLocator();
    	}else if (selectedJobType == JobType.FIX_COMPANY_FOLDER) {
    		resultLocator = getCompanyFolderLocator();
    	}else if (selectedJobType == JobType.FIX_CONTACTS) {
    		resultLocator = getGdprContactsLocator();
    	}
		return resultLocator;
	}
	
    /*
    * @description Query for fixing TP Rate
    */
	private Database.QueryLocator getTpRateQueryLocator() {
		return Database.getQueryLocator([
    			SELECT Id, TP_Rate__c 
    			FROM Opportunity_Product__c
    			WHERE TP_Rate__c = :EMPTY_TP_RATE
    	]);
	}	
		
    /*
    * @description Query for fixing Fee Income for Related Products
    */
	private Database.QueryLocator getFeeAmountQueryLocator() {
		return Database.getQueryLocator([
    			SELECT Id, Estimated_Income__c, Fee_Amount__c
    			FROM Opportunity_Product__c
    			WHERE Product__r.Primary__c = false
    			AND Fee_Amount__c = null
    	]);
	}
	
    /*
    * @description Query for fixing Opportunity fields, which should be set by workflow 
    */
	private Database.QueryLocator getOpporunityFixLocator() {
		return Database.getQueryLocator([
    			SELECT Id, Opportunity__r.Id, Opportunity__r.Primary_Product__c,
    				Opportunity__r.Net_Margin__c, Net_Margin_Percentage__c, 
    				Product__r.Name, Name
    			FROM Opportunity_Product__c
    			WHERE Product__r.Primary__c = true 
    			AND Opportunity__r.Primary_Product__c = null
    	]);
	}
	
		
    /*
    * @description Query for fixing Estimated Income calculations
    */
	private Database.QueryLocator getEstimatedIncomeFixLocator() {
		return Database.getQueryLocator([
    			SELECT Id, Estimated_Income__c, Estimated_Income_First_Year__c,
    				   Estimated_Income_First_Year_Copy__c, Estimated_Income_Formula__c
    			FROM Opportunity_Product__c
    	]);
	}
	
		
    /*
    * @description Query for fixing Primary Product Lookup On Opportunity 
    */
	private Database.QueryLocator getPrimaryProductLookupFixLocator() {
		return Database.getQueryLocator([
    			SELECT Id, Opportunity__c
    			FROM Opportunity_Product__c
    			WHERE Product__r.Primary__c = true 
    			AND Opportunity__r.Primary_Product_Lookup__c = null
    	]);
	}
	
    /*
    * @description Query for fixing User Roles
    */
	private Database.QueryLocator getUserQueryLocator() {
		return Test.isRunningTest() ? Database.getQueryLocator([
    		SELECT Id, LastName, UserRoleId, Profile.Name 
    		FROM User
    		WHERE LastName = :TEST_USER_LASTNAME
    	]) : Database.getQueryLocator([
    		SELECT Id, LastName, UserRoleId, Profile.Name 
    		FROM User
    	]);	
	}
    
    /*
    * @description Query for fixing Customer Companies with Santander Id
    */
	private Database.QueryLocator getCustomerCompanyFixLocator() {
		
		Id customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CUSTOMER_RECORD_TYPE).getRecordTypeId();
		return Database.getQueryLocator([
    			SELECT Id, SAN_Id__c, RecordTypeId 
    			FROM Account
    			WHERE RecordTypeId = :customerRecordType
				AND SAN_Id__c = null
    	]);
	}

	/*
    * @description Query for fixing Last Contacted Date on Company
    */
	private Database.QueryLocator getLastContactedDateFixLocator() {
		return Database.getQueryLocator([
    			SELECT Id, Last_Contacted_Date__c, Last_Meeting_Date__c 
    			FROM Account
    			WHERE Last_Contacted_Date__c = null
    	]);
	}
	
	/**
	* @description Query get Opportunity International Fix Locator
	*/
	private Database.QueryLocator getOpportunityInternationalLocator() {
		return Database.getQueryLocator([
			SELECT International__c, Primary_Product_Lookup__r.Product__r.International__c
			FROM Opportunity
			WHERE Primary_Product_Lookup__c != null
		]);
	}
    
    /**
	* @description Query gets Company Fix Locator for creation of Company folder
	*/
	private Database.QueryLocator getCompanyFolderLocator() {
		return Database.getQueryLocator([
			SELECT Id FROM Account			
		]);
	}
    
    /**
	* @description: Query gets Contacts Fix Locator for updating GDPR_Salesforce_Mastered__c
					and HasOptedOutOfEmail  fields
	*/
	private Database.QueryLocator getGdprContactsLocator() {
		return Database.getQueryLocator([
			SELECT Id FROM Contact			
		]);
	}
   
    /*
    * @description Main batch execute method, which will fix all data
    */
    global void execute(Database.BatchableContext BC,List<sObject> scope) {
    	List<sObject> objectsToUpdate = new List<sObject>();
        List<sObject> objectsToInsert = new List<sObject>();
    	sObject fixedSObject = null;    	
		Map<Id,SObject> predefinedData = null;

		if(selectedJobType == JobType.FIX_LAST_CONTACTED_DATE){
			predefinedData = getPredefinedData(scope);
		}

    	for (sObject scopeObject : scope) {
    		fixedSObject = null;
    		if (selectedJobType == JobType.FIX_TP_RATE) {
    			fixedSObject = getTPRateFix((Opportunity_Product__c) scopeObject);
    		} else if (selectedJobType == JobType.SET_OPPORTUNITY_VARIABLES) {
    			fixedSObject = getOpportunityVariablesFix((Opportunity_Product__c) scopeObject);
    		} else if (selectedJobType == JobType.SET_PRIMARY_PRODUCT_LOOKUP) {
    			fixedSObject = getPrimaryProductLookupFix((Opportunity_Product__c) scopeObject);
    		} else if (selectedJobType == JobType.FIX_FEE_AMOUNT) { 
    			fixedSObject = getFeeAmountFix((Opportunity_Product__c) scopeObject);
    		} else if (selectedJobType == JobType.ESTIMATED_INCOME_RECALCULATION) {
    			fixedSObject = getEstimatedIncomeFix((Opportunity_Product__c) scopeObject);
    		} else if (selectedJobType == JobType.UPDATE_USER_ROLES) {
    			fixedSObject = getUserFix((User) scopeObject);
    		} else if (selectedJobType == JobType.UPDATE_CUSTOMER_COMPANY) {
    			fixedSObject = getSanIdFix((Account) scopeObject);
    		} else if (selectedJobType == JobType.FIX_LAST_CONTACTED_DATE) {
    			fixedSObject = getLastContactedDateFix((Account) scopeObject, predefinedData);
    		} else if (selectedJobType == JobType.INTERNATIONAL_OPPORTUNITY_FLAG) {
    			fixedSObject = getOpportunityInternationalFix((Opportunity) scopeObject);
    		} else if (selectedJobType == JobType.FIX_COMPANY_FOLDER) {
    			fixedSObject = getCompanyFolderFix((Account)scopeObject);
    		} 
    		
    		if (fixedSObject != null && selectedJobType != JobType.FIX_COMPANY_FOLDER ){
    			objectsToUpdate.add(fixedSObject);
    		}
            if (fixedSObject != null && selectedJobType == JobType.FIX_COMPANY_FOLDER ){
    			objectsToInsert.add(fixedSObject);
    		}
            if (selectedJobType == JobType.FIX_CONTACTS ){
    			objectsToUpdate.add(scopeObject);
    		}
            
    		
    		if (shouldSplitDMLBatch() && objectsToUpdate.size() >= MAX_OPP_PRODUCT_DML_SIZE) {
				Database.update(objectsToUpdate);
				objectsToUpdate = new List<sObject>();
			}    			
    	}
    	
    	if (objectsToUpdate.size() > 0) {
            If(selectedJobType == JobType.FIX_CONTACTS){
                Set<Id> contactIds = new Set<Id>();
                for(sObject sObj : objectsToUpdate){
                    contactIds.add(sObj.Id);
                }
                BDPContactTriggerHandler.recalculateContactDepenencies(contactIds);
            }else{
                Database.update(objectsToUpdate);
            }
    	}        
        if (objectsToInsert.size() > 0) {            
    		Database.Insert(objectsToInsert);
    	}
	}
	
    /*
    * @description Checks if batch runs through Opportunity Products
    */
	private Boolean shouldSplitDMLBatch() {
		return selectedJobType == JobType.FIX_TP_RATE || 
			   selectedJobType == JobType.FIX_FEE_AMOUNT ||
			   selectedJobType == JobType.ESTIMATED_INCOME_RECALCULATION;				
	}
	
    /*
    * @description Sets Default Value of TP Rate for all Opportunity Products
    */
   	private sObject getTPRateFix(Opportunity_Product__c oppProduct){
    	oppProduct.TP_Rate__c = PROPER_RATE;
    	return oppProduct;		
	}
	
	
    /*
    * @description Sets International flag value for Opportunity
    */
	private sObject getOpportunityInternationalFix(Opportunity opportunityRecord) {
		return new Opportunity(
			Id = opportunityRecord.Id,
			International__c = opportunityRecord.Primary_Product_Lookup__r.Product__r.International__c
		);
	}
    
    /*
    * @description creates sales doc company folder for accounts
    */
	private sObject getCompanyFolderFix(Account accountRecord) {
        return new Company_Folder__c(
            Company__c = accountRecord.Id,
            Name = NEW_FOLDER_NAME,
            Number_of_Attached_Documents__c = 0 
        );      	           
	}	
	
    /*
    * @description Sets Proper values of Net Margin and Primary Product for all Opportunity Products
    */
	private sObject getOpportunityVariablesFix(Opportunity_Product__c oppProduct){
		Opportunity oppRecord = oppProduct.Opportunity__r;
		oppRecord.Net_Margin__c = oppProduct.Net_Margin_Percentage__c;
		oppRecord.Primary_Product__c = oppProduct.Product__r.Name;
		return oppRecord;
	}
	
    /*
    * @description Sets proper Lookup to Primary Product of Opportunity
    */			
	private sObject getPrimaryProductLookupFix(Opportunity_Product__c oppProduct){
		return new Opportunity(
			Id = oppProduct.Opportunity__c,
			Primary_Product_Lookup__c = oppProduct.Id
    	);
	}	
				
    /*
    * @description Copies Fee Amount for Opportunity Product from Estimated Income Value
    */			
	private sObject getFeeAmountFix(Opportunity_Product__c oppProduct){
		oppProduct.Fee_Amount__c = oppProduct.Estimated_Income__c;
		return oppProduct;
	}	
				
    /*
    * @description Recalculates Estimated Income and Estimated Income First Year for Opportunity Product
    */			
	private sObject getEstimatedIncomeFix(Opportunity_Product__c oppProduct) {
		Opportunity_Product__c resultProduct = null;
		if (oppProduct.Estimated_Income_Formula__c != oppProduct.Estimated_Income__c ||
			oppProduct.Estimated_Income_First_Year_Copy__c != oppProduct.Estimated_Income_First_Year__c ||
			Test.isRunningTest()) {
			oppProduct.Estimated_Income__c = oppProduct.Estimated_Income_Formula__c;
			oppProduct.Estimated_Income_First_Year_Copy__c = oppProduct.Estimated_Income_First_Year__c;
			resultProduct = oppProduct;
		} 		
		return resultProduct;	
	}	
						
    /*
    * @description Sets proper Role Id for User based on User Profile
    */			
	private sObject getUserFix(User u){
		return roleMap.containsKey(u.Profile.Name) ? new User(
			Id = u.Id, 
			UserRoleId = roleMap.get(u.Profile.Name) 
		) : null;
	}
    
    /*
    * @description Sets Santander Id Value for all Customer Companies
    */
   	private sObject getSanIdFix(Account customerAccount){
        customerAccount.SAN_Id__c = 'SFDC_' + customerAccount.Id;
    	return customerAccount;		
	}

	/*
    * @description Checks for Event date and returns to predefinedData Map.
    */
   	private Map<Id,sObject> getPredefinedData(List<sObject> sObjectList){

		Map<Id, sObject> sObjectMap = new Map<Id,sObject>(sObjectList);
		Map<Id, SObject> sObjEventMap =  new Map<Id,sObject>();

		for (AggregateResult aggRes : [SELECT MAX(StartDateTime)evtDt, AccountId accId 
								      FROM Event 
									  WHERE AccountId IN :sObjectMap.keyset() 
									  Group By AccountId]) {
			
			sObjEventMap.put((Id)aggRes.get(ACCOUNT_ID), aggRes);					
		}		

    	return sObjEventMap;		
	}

	/*
    * @description Checks and sets Last Contacted Date on Companies
    */
   	private sObject getLastContactedDateFix(Account company, Map<Id,sObject> sObjMap){
		
		SObject aggR = sObjMap.get(company.Id);
		Date eventDate = null;
		Date lastMeetingDate = null;

		if (company.Last_Meeting_Date__c != null) {
			lastMeetingDate = company.Last_Meeting_Date__c.date();
		}

		if (aggR != null) {
			Datetime eventDateTime = (Datetime)aggR.get(EVENT_DATE);
			eventDate = eventDateTime.date();	
		}
		
		if (eventDate != null && lastMeetingDate != null) {
			if (eventDate > lastMeetingDate) {
				company.Last_Contacted_Date__c = eventDate;
			} else if (lastMeetingDate > eventDate) {
				company.Last_Contacted_Date__c = lastMeetingDate;
			}
		} else if (eventDate != null) {
			company.Last_Contacted_Date__c = eventDate;
		} else if (lastMeetingDate != null) {
			company.Last_Contacted_Date__c = lastMeetingDate;
		} else {
			company.Last_Contacted_Date__c = null;
		}		

		return company;
	}
	
	
    /*
    * @description No final actions are required, so function is empty
    */
	global void finish(Database.BatchableContext BC) {		
	}
}