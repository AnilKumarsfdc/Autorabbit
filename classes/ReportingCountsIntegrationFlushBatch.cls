/* --------------------------------------------------------------------------------------------------
   Name:            ReportingCountsIntegrationFlushBatch.cls 
   Description:     Batch runs through existing Reporting Counts Integration object and deletes record which are 
                    older than 7 days.
   Test class:      ReportingIntegrationFlushTest.cls 
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   23-Jan-2018         0.1        Vijay Sonawane           Intial
  ------------------------------------------------------------------------------------------------ */ 
global class ReportingCountsIntegrationFlushBatch implements Database.Batchable<sObject>{
        public final static Integer DEFAULT_BATCH_SIZE = 200;
        /*
        * @description Interface start method, which returns all Reporting_Counts_Integration__c records modified for specific period
        */
        global Database.QueryLocator start(Database.BatchableContext BC){
            Date dateValue = system.today()-7;
            string query = 'select Id from Reporting_Counts_Integration__c where createdDate <:dateValue';
            return Database.getQueryLocator(query);
        }
        /*
        * @description Main batch execute method, which will delete Reporting_Counts_Integration__c objects        
        */
        global void execute(Database.BatchableContext BC, List<Reporting_Counts_Integration__c > scope){              
               if(scope.size()>0){
                   Database.delete(scope);
               }   
        }       
       /*
       * @description No final actions are required, so function is empty
       */
       global void finish(Database.BatchableContext BC){
           
       }
    }