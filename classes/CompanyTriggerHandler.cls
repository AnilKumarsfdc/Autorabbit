/* --------------------------------------------------------------------------------------------------
Name:            CompanyTriggerHandler.cls 
Description:     Handler class for CompanyTrigger
Test class:      CompanyTriggerHandlerTest.cls 
------------------------------------------------------------------------------------------------ */
public without sharing class CompanyTriggerHandler {
  
    private static final String ERROR_MESSAGE = Label.Primary_Contact;
    
    
    /** 
	* @description : This method is used to process Before Update Functionalities
	**/
    public static void processBeforeUpdate(List<Account> accountList, Map<ID, Account> oldValuesMap) {
        try{
            updateBragStatus(accountList, oldValuesMap);
            checkPrimaryContact(accountList, oldValuesMap);
            setNewToBankDate(accountList, oldValuesMap);
            updateAnnualReviewTasksOwner(accountList, oldValuesMap);
        }catch(Exception exc){
            throw exc;     
        }
    }
    
    
    /** 
	* @description : This method is used to process after Update Functionalities
	**/
    public static void processAfterUpdate(List<Account> accountList, Map<ID, Account> oldValuesMap) {
        try{
            renameRelationshipPlanRecords(accountList, oldValuesMap);
            processAnnualReviewUpdates(accountList, oldValuesMap);
        }catch(Exception exc){
            throw exc;     
        }
    }
    
    /** 
	* @description : This method is used to process After Insert Functionalities
	**/
    public static void processAfterInsert(List<Account> accountList) {
        try{
            addCompanyFolder(accountList);
        }catch(Exception exc){
            throw exc;     
        }
    }
    
    /** 
	* @description : This method is used to process Before Insert Functionalities
	**/
    public static void processBeforeInsert(List<Account> accountList) {
        try{
            setBragStatus(accountList);
            checkPrimaryContact(accountList, new Map<Id, Account>());
            setNewToBankDate(accountList, new Map<Id, Account>()); 
        }catch(Exception exc){
            throw exc;     
        }
    }    
    
    
    /**
    * @description Process Annual Review Date updates or updates related to changing ownership of company
    * which affects Annual Review update
    **/
    private static void processAnnualReviewUpdates(List<Account> accountList, Map<ID, Account> oldValuesMap) {
        Map<Id,Account> annualRevChangedAccMap = new Map<Id,Account>(); 
        for(Account accObj : accountList){
            if(accObj.Annual_Review_Date__c != null  &&  
               (accObj.Annual_Review_Date__c != oldValuesMap.get(accObj.Id).Annual_Review_Date__c ||
               accObj.Active_Annual_Review__c != oldValuesMap.get(accObj.Id).Active_Annual_Review__c 
              )) {
                 annualRevChangedAccMap.put(accObj.Id,accObj);
            } 
        }
        if(annualRevChangedAccMap.size()>0){
            createUpdateAnnualReviews(annualRevChangedAccMap);
        }
    }
    
    /** 
	* @description : This method will create annual review record when Active_Annual_Review__c lookup is populated or changed
	**/
    private static void createUpdateAnnualReviews(Map<Id,Account> annualRevChangedAccMap){
        
        
        List<Annual_Review__c> newAnnualReviewList = new List<Annual_Review__c>();
        for(Account accObj : annualRevChangedAccMap.values()){
            Date annualReviewDate = accObj.Annual_Review_Date__c;
            Datetime dtTime =   Datetime.newInstance(annualReviewDate.year(),
                                                     annualReviewDate.month(),
                                                     annualReviewDate.day());
            String formattedDate = dtTime.format(GlobalConstants.DATE_FORMAT);	
            String reviewName = accObj.Name + GlobalConstants.DELIMITER_DASH + formattedDate;
            Annual_Review__c annualReviewObj = new Annual_Review__c(
            	Name = reviewName,
                Annual_Review_Date__c = accObj.Annual_Review_Date__c,
                Company__c = accObj.Id,
                Id = accObj.Active_Annual_Review__c
            );
            newAnnualReviewList.add(annualReviewObj);
        }
              
        if(newAnnualReviewList.size()>0){          
            Database.upsert(newAnnualReviewList,false);
            List<Account> companiesToUpdate = new List<Account>();
            for (Annual_Review__c annualReview : newAnnualReviewList) {
                Account reviewCompany = annualRevChangedAccMap.get(annualReview.Company__c);           
                if (annualReview.Company__c == reviewCompany.Id && annualReview.Id != reviewCompany.Active_Annual_Review__c){
                    companiesToUpdate.add(new Account(
                        Id = reviewCompany.Id,
                        Active_Annual_Review__c = annualReview.Id
                    ));  
                }
            } 
            
            if(companiesToUpdate.size()>0){
                Database.update(companiesToUpdate);
            }
        }
    }
    
     /** 
	* @description : This method will update related annual review task ownership as per company owner
	**/
    private static void updateAnnualReviewTasksOwner(List<Account> acctList,Map<ID, Account> acctMap) {
        
        Map<Id,Id> annualReviewIdToOwnerMap = new Map<Id,Id> ();
        Map<Id, List<Task>> annualReviewIdToTasksMap = new Map<Id, List<Task>> ();
        List<Task> taskToUpdate = new List<Task>();
        
        for (Account acct : acctList) {
            if (acct.OwnerId != acctMap.get(acct.Id).OwnerId && acct.Active_Annual_Review__c != NULL) {
                annualReviewIdToOwnerMap.put(acct.Active_Annual_Review__c,acct.OwnerId);
            }
        }
        
        //To retrive the list of values from custom setting .
        for (Task task :[SELECT Id,OwnerId,WhatId  
                         FROM Task
                         WHERE WhatId IN :annualReviewIdToOwnerMap.keySet() 
                         AND Status = : GlobalConstants.ANNUAL_REVIEW_TASK_OPEN
                         LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
             if(annualReviewIdToTasksMap.containsKey(task.WhatId)){
                      List<Task> taskList =annualReviewIdToTasksMap.get(task.WhatId);
                 	  task.OwnerId = annualReviewIdToOwnerMap.get(task.WhatId);
                      taskList.add(task);
                      annualReviewIdToTasksMap.put(task.WhatId,taskList);           
             }else{
                  List<Task> taskList = new List<Task>();
                  task.OwnerId = annualReviewIdToOwnerMap.get(task.WhatId);
                  taskList.add(task);
                  annualReviewIdToTasksMap.put(task.WhatId,taskList);  
             }
        }
        
        for(Id annualReviewId : annualReviewIdToTasksMap.keySet()){
            taskToUpdate.addAll(annualReviewIdToTasksMap.get(annualReviewId));
        }
        
        if(taskToUpdate.size()>0){
            Database.update(taskToUpdate);
        }
        
        
    }
    
    private static void setNewToBankDate(List<Account> accountList, Map<ID, Account> accountMap) {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id customerRecordTypeId = accountRecordTypeInfo.get(GlobalConstants.CUSTOMER_RECORD_TYPE).getRecordTypeId();
        
        for (Account company : accountList) {
            if (company.RecordTypeId == customerRecordTypeId) {
                Account oldValue = accountMap.get(company.Id);
                if (oldValue == null || oldValue.RecordTypeId != company.RecordTypeId) {
                    company.New_To_Bank_Date__c = Date.today();
                }
            }
        }
    }
    
    
    /** 
	* @description : This method will set the Brag Status and Sector Policy based on SIC code on create of company record
	**/
    private static void setBragStatus(List<Account> acctList) {
        
        List<String> accounttoSet = new List<String> ();
        Map<String, Santander_Lending_Policy__c> bragStatusValueMap = new Map<String, Santander_Lending_Policy__c> ();
        
        for (Account accountList : acctList) {
            if (accountList.UK_SIC_Code_2007__c != NULL) {
                accounttoSet.add(accountList.UK_SIC_Code_2007__c);
            }
        }
        
        //To retrive the list of values from custom setting .
        for (Santander_Lending_Policy__c slp :[SELECT Brag_Status__c, Sector_Policy__c, SIC_Code__c
                                               FROM Santander_Lending_Policy__c
                                               WHERE SIC_Code__c IN :accounttoSet LIMIT 10000]) {
                                                   bragStatusValueMap.put(slp.SIC_Code__c, slp);
                                               }
        
        for (Account acc : acctList) {
            if (bragStatusValueMap.get(acc.UK_SIC_Code_2007__c) != NULL) {
                acc.BRAG_Status__c = bragStatusValueMap.get(acc.UK_SIC_Code_2007__c).Brag_Status__c;
                acc.Sector_Policy_applied__c = bragStatusValueMap.get(acc.UK_SIC_Code_2007__c).Sector_Policy__c;
            }
        }
    }
    
    
    /**
	* @description This method will update the Brag Status and Sector Policy based on SIC code on update of company record
		when we are chaning SIC code . 
	**/
    private static void updateBragStatus(List<Account> acctList, Map<Id, Account> oldMap) {
        try {
            Map<Id, String> updateBragMap = new Map<Id, String> ();
            Map<String, Santander_Lending_Policy__c> bragStatusValueMap = new Map<String, Santander_Lending_Policy__c> ();
            
            for (Account accountList : acctList) {
                if (accountList.UK_SIC_Code_2007__c != NULL &&
                    accountList.UK_SIC_Code_2007__c != oldMap.get(accountList.Id).UK_SIC_Code_2007__c) {
                        updateBragMap.put(accountList.Id, accountList.UK_SIC_Code_2007__c);
                    }
                else if (accountList.UK_SIC_Code_2007__c == NULL) {
                    accountList.BRAG_Status__c = GlobalConstants.BLANK_SPACE;
                    accountList.Sector_Policy_applied__c = GlobalConstants.BLANK_SPACE;
                    return;
                    
                }
            }
            
            //To retrive the list of values from custom setting .
            for (Santander_Lending_Policy__c slp :[SELECT Brag_Status__c, Sector_Policy__c, SIC_Code__c
                                                   FROM Santander_Lending_Policy__c
                                                   WHERE SIC_Code__c IN :updateBragMap.Values() LIMIT 10000]) {
                                                       bragStatusValueMap.put(slp.SIC_Code__c, slp);
                                                   }
            
            for (Account acc : acctList) {
                if (bragStatusValueMap.get(acc.UK_SIC_Code_2007__c) != NULL) {
                    acc.BRAG_Status__c = bragStatusValueMap.get(acc.UK_SIC_Code_2007__c).Brag_Status__c;
                    acc.Sector_Policy_applied__c = bragStatusValueMap.get(acc.UK_SIC_Code_2007__c).Sector_Policy__c;
                }
            }
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /** 
	* @description : Adds Company Folders each time a Company is created
	**/
    private static void addCompanyFolder(List<Account> acctList) {
        //Map<String, List<String>> folderTagMap = new Map<String, List<String>> ();
        List<Company_Folder__c> companyFoldersToInsert = new List<Company_Folder__c> ();
        Set<String> uniqueFolders = new Set<String> ();
        
        Schema.DescribeFieldResult fieldResult = Company_Folder_Metadata__mdt.Folder_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEnt = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry ple : picklistEnt) {
            uniqueFolders.add(ple.getValue());
        }
        
        // Create Company Folders for each Account
        Company_Folder__c companyFolder;
        for (Account account : acctList) {
            for (string name : uniqueFolders) {
                companyFolder = new Company_Folder__c();
                companyFolder.Name = name;
                companyFolder.Company__c = account.Id;
                companyFoldersToInsert.add(companyFolder);
            }
        }
        
        if (companyFoldersToInsert.size() > 0) {
            try {
                Database.insert(companyFoldersToInsert);
            }
            catch(exception e) {
                throw e;
            }
        }
    }
    
    /**
	* @description : Allows adding a primary contact that is only related to the company from AccountContactRelation
	**/
    private static void checkPrimaryContact(List<Account> acctList, Map<Id, Account> oldAccountMap){
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for (Account acc : acctList) {
            Account oldValue = oldAccountMap.get(acc.Id);
            if (acc.Primary_Contact__c != null && (
                oldValue == null || oldValue.Primary_Contact__c != acc.Primary_Contact__c
            )) {
                contactIds.add(acc.Primary_Contact__c);
                accountIds.add(acc.Id);
            } 
        }
        
        if (!accountIds.isEmpty() && !contactIds.isEmpty()) {
            Map<Id, Set<Id>> accRelMap = new Map<Id, Set<Id>>();
            for (AccountContactRelation rel : [SELECT Id, AccountId, ContactId, Roles
                                               FROM AccountContactRelation
                                               WHERE ContactId IN :contactIds 
                                               AND AccountId IN :accountIds LIMIT 10000 ]) {
            	if (accRelMap.containsKey(rel.ContactId)) { 
                	accRelMap.get(rel.ContactId).add(rel.AccountId);
                } else {
                	accRelMap.put(rel.ContactId, new Set<Id>{rel.AccountId});
                }
            } 
            
            for (Account acct : acctList) {
                if (accountIds.contains(acct.Id)) {
                    if (!accRelMap.containsKey(acct.Primary_Contact__c) || 
                        !accRelMap.get(acct.Primary_Contact__c).contains(acct.Id)) {
                            acct.Primary_Contact__c.addError(ERROR_MESSAGE);
                    }
                }
            }				
        }
    }
    
    /*
    *@description Automatically update Realtionship Plan records, after they have been fetched to corresponding records
    */
    private static void renameRelationshipPlanRecords(List<Account> accountList, Map<ID, Account> oldValuesMap) {
    	Map<Id, String> newPlansMap = new Map<Id, String>();
    	Account oldValue = null;
    	for (Account relatedAccount : accountList) {
    		oldValue = oldValuesMap.get(relatedAccount.Id);
    		if (relatedAccount.Relationship_Plan__c != null && 
    			relatedAccount.Relationship_Plan__c != oldValue.Relationship_Plan__c &&
    			!newPlansMap.containsKey(relatedAccount.Relationship_Plan__c)) {
    			newPlansMap.put(relatedAccount.Relationship_Plan__c, relatedAccount.Name);
    		}
    	}
    	
    	if (newPlansMap.size() > 0) {
    		updateRelationshipPlanNames(newPlansMap);
    	}
    }
    
    /*
    *@description Update Relationship plan records to set a new names
    */
    private static void updateRelationshipPlanNames(Map<Id, String> newPlanNamesMap) {
    	List<Relationship_Strategy_Plan__c> plansToUpdate = new List<Relationship_Strategy_Plan__c>();
    	String planId = null; 
    	for (Relationship_Strategy_Plan__c plan : [SELECT Id, Name FROM Relationship_Strategy_Plan__c
    											   WHERE Id IN :newPlanNamesMap.keySet()
    											   LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
    		
    		planId = String.valueOf(plan.Id);
    		if (plan.Name.containsIgnoreCase(planId) || planId.containsIgnoreCase(plan.Name)  || 
    			plan.Name == null || plan.Name == '') {
    			plan.Name = newPlanNamesMap.get(plan.Id);
    			plansToUpdate.add(plan);
    		}
    	}
    	
    	if (plansToUpdate.size() > 0) {
    		Database.update(plansToUpdate);	
    	}
    }
}