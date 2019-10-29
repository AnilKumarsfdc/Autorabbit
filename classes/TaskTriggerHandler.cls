/* --------------------------------------------------------------------------------------------------
     Name:            TaskTriggerHandler.cls 
     Description:     Handler class for TaskTrigger
     Test class:      TaskTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public without sharing class TaskTriggerHandler { 
    private static final String[] PROFILES = new String[]{'System Administrator','SAN System Admin'};
    private static final String ERROR_MESSAGE = 'You don\'t have permission to delete current task';
    public static Boolean isFirstTime = true;
    /** 
     * @description : validate current user is task owner for allowing task deletion
     **/
    public void processBeforeDelete(List<Task> taskList) {
        try{           
           User usr = [SELECT Id,Profile.Name 
                       FROM User
                      WHERE Id =: Userinfo.getUserId() LIMIT 1]; 
           for(Task tsk : taskList){ 
              
               if(tsk.createdById != usr.Id && ! PROFILES.contains(usr.Profile.Name)){
                      tsk.addError(ERROR_MESSAGE);
               }
           }             
        }catch(Exception ex) {
            throw ex;
        }
    }    
    
    /** 
     * @description : Find Task which are related to annual review.
     **/
    public void processAfterUpdate(List<Task> taskList) {
        try{
            List<String> taskIdsList = new List<String>();    	
            Set<String> annualReviewIds = new Set<String>();
            
            for(Task taskObj:taskList){
                if(taskObj.whatId !=null && String.valueOf(taskObj.WhatId.getSObjectType()) == GlobalConstants.ANNUAL_REVIEW){
                    taskIdsList.add(taskObj.id);
                    annualReviewIds.add(taskObj.whatId);
                }
            }   	     
            
            if (annualReviewIds.size()>0) {
	            if(!System.isBatch() && !System.isFuture() && !System.isScheduled()){
	                closeTaskForAnnualReviewAsync(annualReviewIds);
	            } else {
	            	closeTaskForAnnualReview(annualReviewIds);
	            }
            }
        }catch(Exception e){         
            throw e;
        }
    }
    
    /** 
     * @description : All task related to Annual review is completed then it will complete Annual Review and
     *  set new Annual Review Date for company. Asynchronous version of method.
     **/
    @future
    public static void closeTaskForAnnualReviewAsync(Set<String> annualReviwIds){
    	closeTaskForAnnualReview(annualReviwIds);
    }
    
    /** 
     * @description : All task related to Annual review is completed then it will complete Annual Review and
     *  set new Annual Review Date for company
     **/
    public static void closeTaskForAnnualReview(Set<String> annualReviwIds){
    	
    	List<Annual_Review__c> annualReviewList = new List<Annual_Review__c>();
    	annualReviewList = [SELECT id FROM Annual_Review__c 
    							WHERE id in :annualReviwIds 
    							AND (Short_Form_Criteria_Met__c = :GlobalConstants.ANNUAL_REVIEW_CRITERIA_YES OR Short_Form_Criteria_Met__c = :GlobalConstants.ANNUAL_REVIEW_CRITERIA_NO) 
    	                        AND (Status__c != :GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED OR Status__c != :GlobalConstants.ANNUAL_REVIEW_TASK_REJECTED) 
    	                        LIMIT :GlobalConstants.SOQL_QUERY_LIMIT];
    	                               
    	Set<String> annualReviewShortCriteriaMetIds = new Set<String>();
    	
    	if(annualReviewList.size()>0){
	    	for(Annual_Review__c AnnualObj:annualReviewList){
	    		annualReviewShortCriteriaMetIds.add(AnnualObj.id);
	    	}
    	}
    	 
    	List<String> annualwithTaskOpenStatus = new List<String>();
    	
    	for(AggregateResult AggObj:[SELECT whatId FROM task 
    											WHERE whatId in :annualReviewShortCriteriaMetIds and Status = :GlobalConstants.ANNUAL_REVIEW_TASK_OPEN GROUP BY whatId]){
    		annualwithTaskOpenStatus.add(String.valueOf(AggObj.get(GlobalConstants.TASK_WHATID))); 	
    	}
    	           
    	// Removed Annual review Ids if they are having Task's status is Open
    	if(annualwithTaskOpenStatus.size()>0){
    		annualReviewShortCriteriaMetIds.removeAll(annualwithTaskOpenStatus);
    	}

    	if(annualReviewShortCriteriaMetIds.size()>0){
    		List<Annual_Review__c> updateAnnualReviewList = new List<Annual_Review__c>();
    		List<Account> companyToUpdate = new List<Account>();
    		
    		for(Annual_Review__c annualReviewObj:[SELECT id,Annual_Review_Date__c,Actual_Completion_Date__c,Status__c,Company__c,Company__r.Annual_Review_Date__c,Company__r.Active_Annual_Review__c 
    														      FROM Annual_Review__c WHERE id in:annualReviewShortCriteriaMetIds 
    														      LIMIT :GlobalConstants.SOQL_QUERY_LIMIT]){
    			annualReviewObj.Actual_Completion_Date__c = Date.TODAY();
    			annualReviewObj.Company__r.Annual_Review_Date__c = (annualReviewObj.Annual_Review_Date__c).addMonths(12);
    			annualReviewObj.Company__r.Active_Annual_Review__c = null;
    			annualReviewObj.Status__c = GlobalConstants.ANNUAL_REVIEW_TASK_COMPLETED;
    			updateAnnualReviewList.add(annualReviewObj);
    			companyToUpdate.add(annualReviewObj.Company__r);
    		}

    		Database.update(updateAnnualReviewList);
    		Database.update(companyToUpdate);
    	}
    	
    }
}