/* --------------------------------------------------------------------------------------------------
Name:            ReportingIntegrationFlushController.cls 
Description:     delete all Reporting_Controls_Integration__c
                 records that have a CreatedDate equal to today.
                 This functionality is available only to Admin users.

Test class:      ReportingIntegrationFlushTest.cls 
------------------------------------------------------------------------------------------------ */
public without sharing class ReportingIntegrationFlushController {

    private static Integer count {get;set;}    
    public boolean isJobStarted {get;set;} 
    private final Set<string> job_status =new Set<String> {'Processing','Queued','Holding','Preparing'};  
    
   /**
    * @Description: Constructor
    * */
    public ReportingIntegrationFlushController(){  
    	 isJobStarted=false;
    }      
   /**
    * @Description: Batch execution deletes all those records 
    * that have a CreatedDate equal to today for  Reporting_Controls_Integration__c object     
    * */
    public void executeReportingControlsFlushBatch(){
      try{ 
      ReportingControlsIntegrationFlushBatch batchObject = new ReportingControlsIntegrationFlushBatch(true);     
      String jobId=Database.executeBatch(batchObject, ReportingControlsIntegrationFlushBatch.DEFAULT_BATCH_SIZE);
      AsyncApexJob job = [SELECT status FROM AsyncApexJob WHERE  id=:jobId LIMIT 1];
        
      if(job_status.contains(job.status)){
       	isJobStarted=true;
      }
      }catch(Exception e){
      	throw e;
      }    
    }    
   /**	
    *  @Description: Real time count of Reporting control records created for today
    **/
    @RemoteAction
    @readOnly
    public static Integer getCount() { 
        count=0;
        for(AggregateResult result :[SELECT COUNT(Id) FROM Reporting_Controls_Integration__c where createddate=LAST_N_DAYS:0])
		{
            count+=(Integer)result.get('expr0');
        }
        return count;
    } 
}