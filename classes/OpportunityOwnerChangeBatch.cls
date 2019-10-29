/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityOwnerChangeBatch.cls 
   Description:     Batch runs through existing Opportunity records and changes its owner to company owner 
                    excluding integration user records
                    Opportunity Owner needs to match Company Owner, except when Company Owner = Integration
                    
   Test class:      OpportunityOwnerChangeTest.cls 
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   07-Feb-2018         0.1        Vijay Sonawane           Intial
  ------------------------------------------------------------------------------------------------ */  
global class OpportunityOwnerChangeBatch implements Database.Batchable<sObject> {
       public final static Integer DEFAULT_BATCH_SIZE = 200;
       
      
       /*
        * @description Interface start method, which returns all opportunity records whose owner doesn't match
        * company owner, except when company owner=Integration [ Formula field: Is_Owner_Does_not_Match__c==true]
        */
        global Database.QueryLocator start(Database.BatchableContext BC){
            
            string query = 'select Id,OwnerId,Account.OwnerId,Is_Owner_Does_not_Match__c from Opportunity where Is_Owner_Does_not_Match__c=true';
            return Database.getQueryLocator(query);
        }
       /*
        * @description Main batch execute method, which will update owner of opportunity records        
        */
        global void execute(Database.BatchableContext BC, List<Opportunity> scope){ 
            List<Opportunity> itemsToUpdate = new List<Opportunity>();
            if(scope != null && scope.size() > 0){
                for(Opportunity opp : scope){  
                    if (opp.OwnerId != opp.Account.OwnerId) {                  
                        itemsToUpdate.add( new Opportunity(
                           Id = opp.Id,
                           OwnerId = opp.Account.OwnerId
                        ));
                    }
                }
            }
            if (itemsToUpdate.size() > 0) {
                Database.update(itemsToUpdate, false);
            }
       }
      /*
       * @description No final actions are required, so function is empty
       */
       global void finish(Database.BatchableContext BC){ 
       }
}