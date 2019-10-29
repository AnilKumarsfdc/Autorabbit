/* --------------------------------------------------------------------------------------------------
   Name:            ProductHoldingDataFixerBatch.cls 
   Description:     Batch runs through existing Product Holding records and changes its Product Family and Product Name
                    On basis of its Type and Subtype
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   17-July-2018         0.1         Anjali Nigam           Initial
  ------------------------------------------------------------------------------------------------ */  
global class ProductHoldingDataFixerBatch implements Database.Batchable<sObject>{
	 public final static Integer DEFAULT_BATCH_SIZE = 200;
	  
      /*
       * @description Interface start method, which returns all Product Holding records which are of 
       * Santander Record Type.
       */
	  global Database.QueryLocator start(Database.BatchableContext BC){
          String recordTypeId = Schema.SObjectType.Holding__c.getRecordTypeInfosByName().get(GlobalConstants.PRODUCT_HOLDINGS_SANTANDER).getRecordTypeId();
	  	  return Database.getQueryLocator([Select id,Product_Family__c,Name,BDPRecord__c,Type__c,Sub_Type__c from Holding__c where recordTypeId = :recordTypeId]);
	  }
	  
     /*
      * @description Main batch execute method, which will update Santender Type of Product Holding        
      */
	  global void execute(Database.BatchableContext BC, List<Holding__c> scope){     
          List<Holding__c> SanTanderHoldingToUpdateLst = new List<Holding__c>(); 
          if(scope.size()>0){
          	SanTanderHoldingToUpdateLst = ProductHoldingsTriggerHandler.updateProductHoldings(scope);
          }
          if (SanTanderHoldingToUpdateLst.size() > 0) {
          	Database.update(SanTanderHoldingToUpdateLst, false);
          }
	  
	  }
      
     /*
      * @description No final actions are required, so function is empty
      */
      global void finish(Database.BatchableContext BC){ 
      
      }
}