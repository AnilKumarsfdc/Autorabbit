/* --------------------------------------------------------------------------------------------------
   Name:            ReportingControlsIntegrationFlushBatch.cls 
   Description:     Batch runs through existing Reporting Controls Integration object and deletes record which are 
                    older than 7 days OR records created today only
   Test class:      ReportingIntegrationFlushTest.cls 
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   23-Jan-2018          0.2         Vijay Sonawane      Intial
  ------------------------------------------------------------------------------------------------ */  
global class ReportingControlsIntegrationFlushBatch implements Database.Batchable<sObject>{        
        public final static Integer DEFAULT_BATCH_SIZE = 200;
        @TestVisible private boolean todayOnly;
    
       /*
       * @ constructor 
      */  
        global ReportingControlsIntegrationFlushBatch (){  
            todayOnly=false;
        } 
        /*
       * @ constructor 
      */  
        global ReportingControlsIntegrationFlushBatch (boolean todayOnly){  
           this.todayOnly=todayOnly;
        } 
         /*
        * @description Interface start method, which returns all Reporting_Controls_Integration__c records modified for specific period
        */
        global Database.QueryLocator start(Database.BatchableContext BC){
            Integer lastNdays = todayOnly ? 0 : 7;
            String operand = todayOnly ? '=' : '<';
            string query='SELECT Id FROM Reporting_Controls_Integration__c ';
            query += 'WHERE CreatedDate ' + operand + ' LAST_N_DAYS:' + lastNdays;
            return Database.getQueryLocator(query);
        }      
     
         /*
        * @description Main batch execute method, which will delete Reporting_Controls_Integration__c records        
        */
        global void execute(Database.BatchableContext BC, List<Reporting_Controls_Integration__c> scope){              
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