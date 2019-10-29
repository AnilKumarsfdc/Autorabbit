/* --------------------------------------------------------------------------------------------------
Name:            AnnualReviewTriggerHandler.cls 
Description:     Handler class for AnnualReviewTrigger
Test class:      AnnualReviewTriggerHandlerTest.cls 
------------------------------------------------------------------------------------------------ */
public without sharing class AnnualReviewTriggerHandler {
      
    /** 
	* @description : This method is used to process After Insert Functionalities
	**/
    public static void processAfterInsert(List<Annual_Review__c> annualReviewList) {
        try{
            createUpdateAnnualReviewTasks(annualReviewList,null);
        }catch(Exception exc){
            throw exc; 
        }
    }
    
    /** 
    * @description : This method is used to process after Update Functionalities
	**/
    public static void processAfterUpdate(List<Annual_Review__c> annualReviewList, Map<ID, Annual_Review__c> oldValuesMap) {
        try{
            createUpdateAnnualReviewTasks(annualReviewList, oldValuesMap);
            deleteTasksOnReject(annualReviewList, oldValuesMap);
        }catch(Exception exc){
            throw exc; 
        }
    }
    
    /** 
	* @description : This method will create annual review tasks as per configuration in Annual Review Plan metadata
	**/
    private static void createUpdateAnnualReviewTasks(List<Annual_Review__c> annualReviewList,Map<Id,Annual_Review__c> oldValuesMap){
        
        List<Annual_Review_Plan__mdt> annualReviewPlanList = getAnnualReviewPlanMetadataList();  // annual review plan custom meta data
        
        List<Task> taskToUpsertList = new List<Task>(); 
        
        Map<Id,Id> annualReviewToCompanyIdMap =new Map<Id,Id>();
        Map<Id,Id> annualReviewToOwnerIdMap =new Map<Id,Id>();
        
        Set<Id> annualReviewId = new Set<Id>();      
        Map<String,Task> existingAllTaskMap = new Map<String,Task>();     
        
        for(Annual_Review__c annualReview : annualReviewList){
            annualReviewId.add(annualReview.Id);
        }
        
        for(Annual_Review__c annualReview : [SELECT Id,Annual_Review_Date__c,Company__r.OwnerId,Company__c 
                                             FROM Annual_Review__c
                                             WHERE Id IN : annualReviewId
                                             LIMIT :GlobalConstants.SOQL_QUERY_LIMIT]){
                   annualReviewToCompanyIdMap.put(annualReview.Id,annualReview.Company__c);
                   annualReviewToOwnerIdMap.put(annualReview.Id,annualReview.Company__r.OwnerId);                                                                                  
        }
        
        if(oldValuesMap!=null ){
            for( Task taskObj :[SELECT Id, ActivityDate,Subject,WhatId,OwnerId,Status
                                FROM Task
                                WHERE WhatId IN : oldValuesMap.keySet()
                                LIMIT :GlobalConstants.SOQL_QUERY_LIMIT]){
                                    
                   existingAllTaskMap.put(taskObj.Subject + GlobalConstants.DELIMITER + taskObj.WhatId,taskObj);  
            }
        }
        
        for(Annual_Review_Plan__mdt annualReviewPlan : annualReviewPlanList){
            for(Annual_Review__c annualReview : annualReviewList){                
                String key = annualReviewPlan.Task_Subject__c + GlobalConstants.DELIMITER + annualReview.Id; 
                if(!existingAllTaskMap.containsKey(key)){  // if create
                    if((annualReview.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_CRITERIA_YES &&
                        (annualReviewPlan.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_PLAN_SHORT ||
                         annualReviewPlan.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_PLAN_BOTH 
                        )
                       ) ||
                       (annualReview.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_CRITERIA_NO &&
                        (annualReviewPlan.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_PLAN_LONG ||
                         annualReviewPlan.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_PLAN_BOTH 
                        )
                       ) ||
                       
                       (annualReviewPlan.Short_Form_Criteria_Met__c == GlobalConstants.ANNUAL_REVIEW_PLAN_IMMEDIATE 
                        && annualReview.Short_Form_Criteria_Met__c == null)) {                    	                           
                            Task annualReviewNewTask = createTask(annualReview,annualReviewPlan);
                            annualReviewNewTask.OwnerId = annualReviewToOwnerIdMap.get(annualReview.Id);
                            taskToUpsertList.add(annualReviewNewTask);                          
                        }                      
                }else{
                    if(annualReview.Annual_Review_Date__c != oldValuesMap.get(annualReview.Id).Annual_Review_Date__c
                      && oldValuesMap.get(annualReview.Id).Annual_Review_Date__c != null){ //if company review date change
                          Integer priorDays = Integer.valueOf(annualReviewPlan.Due_Date__c);
                          taskToUpsertList.add(new Task(Id= existingAllTaskMap.get(key).Id,
                                                      ActivityDate =  annualReview.Annual_Review_Date__c.addDays(-priorDays)
                                                     ));
                        
                    } 
                }
            }
        } 
        
        if(taskToUpsertList.size()>0){            
            Database.upsert(taskToUpsertList);
        } 
    }    
    

  /*
    * @description deletes Task if annual review is rejected
    */
    private static void deleteTasksOnReject(List<Annual_Review__c> annualReviewList, Map<Id,Annual_Review__c> annualReviewMap){        
        List<Task> tasksToDelete = new List<Task>();
        List<Account> companiesToUpdateList = new List<Account>();    // if annual review is rejected then company review date and 
        																 // annual review is set as null
        for (Annual_Review__c annualReview : [SELECT Id,Status__c,Company__c,
                                              (select Id,Status FROM Tasks) 
                                              FROM Annual_Review__c  
                                              WHERE Id IN : annualReviewMap.keySet()
                                              LIMIT :GlobalConstants.SOQL_QUERY_LIMIT]) {
            if(annualReview.Status__c == GlobalConstants.ANNUAL_REVIEW_TASK_REJECTED){
                tasksToDelete.addAll(annualReview.tasks);
                companiesToUpdateList.add(new Account(Id=annualReview.Company__c,
                                                      Active_Annual_Review__c = null,
                                                      Annual_Review_Date__c = null));
            }
        }
        
        if(tasksToDelete.size()>0){
            Database.delete(tasksToDelete);
        }
        if(companiesToUpdateList.size()>0){
            Database.update(companiesToUpdateList);
        }
    }
    
    /*
    * @description Return Task with prepopulated values
    */
    private static Task createTask(Annual_Review__c annualReview, Annual_Review_Plan__mdt annualReviewPlan){        
        Id taskRecordId = Schema.SObjectType.Task.getRecordTypeInfosByName().
            get(GlobalConstants.ANNUAL_REVIEW_TASK_REC_TYPE).getRecordTypeId();
        Integer priorDays = Integer.valueOf(annualReviewPlan.Due_Date__c);
       
        Task newTask = new Task(Subject = annualReviewPlan.Task_Subject__c ,                                                             
                                ActivityDate = annualReview.Annual_Review_Date__c.addDays(-priorDays),                                                              
                                WhatId = annualReview.Id,
                                Type = GlobalConstants.ANNUAL_REVIEW_TASK_TYPE,
                                Priority = GlobalConstants.ANNUAL_REVIEW_TASK_PRIORITY,
                                Status = GlobalConstants.ANNUAL_REVIEW_TASK_OPEN,
                                RecordTypeId = taskRecordId);
        
        return newTask;
    }
    /*
    * @description Returns Map of Annual Review Plan Metadata 
    */
    private static List<Annual_Review_Plan__mdt> getAnnualReviewPlanMetadataList(){
        return [SELECT Short_Form_Criteria_Met__c,Due_Date__c,Task_Subject__c
                										FROM Annual_Review_Plan__mdt                
                										ORDER BY Due_Date__c ASC
                                                        LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
    }
    
}