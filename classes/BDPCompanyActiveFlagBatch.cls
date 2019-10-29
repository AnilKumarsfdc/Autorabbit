/* --------------------------------------------------------------------------------------------------
     Name:            BDPCompanyActiveFlagBatch.cls 
     Description:     Batch runs through existing BDP Company objects and copies Active flag to 
  					  corresponding Reporting Controls Integration objects.
  	 Test class:      BDPCompanyActiveFlagTest.cls 
    ------------------------------------------------------------------------------------------------ */
global without sharing class BDPCompanyActiveFlagBatch implements Database.Batchable<sObject>{
	//Batch value which will check Last Modified Date for current date and for regular date
    private final static Integer DAYS_FOR_FULL_UPDATE = 1000;
	private final static Integer DAYS_FOR_SCHEDULED_UPDATE = 2;
	public final static Integer DEFAULT_BATCH_SIZE = 80;
	
	global final Boolean isFullCheck;
    
	/*
	* @description Public constructor which configuration if Batch should update all values or run daily scheduled update
	*/    
    global BDPCompanyActiveFlagBatch(Boolean shouldCheckAllRecords){
    	isFullCheck = shouldCheckAllRecords;
    }
    
    /*
    * @description Starts initial batch which will process execution of Active flag population for all records
    */
    global static void runBatchForAllRecords(){
    	BDPCompanyActiveFlagBatch batchObject = new BDPCompanyActiveFlagBatch(true);
    	Database.executeBatch(batchObject, DEFAULT_BATCH_SIZE);
    }
    
    
    /*
    * @description Interface start method, which returns all BDP records modified in specific range period
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	Integer numberOfDays = isFullCheck ? DAYS_FOR_FULL_UPDATE : DAYS_FOR_SCHEDULED_UPDATE;
    	
    	return Database.getQueryLocator([
    			SELECT Id, Active__c, BDP_Customer_Number__c
    			FROM BDP_Company__c
    			WHERE LastModifiedDate >= :Date.today().addDays(-numberOfDays)
    	]);
	}
	
    /*
    * @description Main batch execute method, which will update reporting controls integration objects
    * with values stored in BDP Company. (It's related to Active__c checkbox.)
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	Map<String, BDP_Company__c> bdpCompanyMap = new Map<String, BDP_Company__c>();
    	BDP_Company__c bdpCompany;
    	for (sObject currentObject : scope) {
    		bdpCompany = (BDP_Company__c) currentObject;
    		if (bdpCompany.BDP_Customer_Number__c != null) {
    			bdpCompanyMap.put(bdpCompany.BDP_Customer_Number__c, bdpCompany);
    		}
    	}
    	
    	Reporting_Controls_Integration__c[] controlsIntegrationList = [
    		SELECT Id, BDP_Identifier__c, BDP_Identifier_String__c, Active__c
    		FROM Reporting_Controls_Integration__c
    		WHERE BDP_Identifier_String__c IN :bdpCompanyMap.keySet()
    	];
    	
    	Reporting_Controls_Integration__c[] itemsToUpdate = new List<Reporting_Controls_Integration__c>();
    	for (Reporting_Controls_Integration__c integrationObject : controlsIntegrationList) {
    		bdpCompany = bdpCompanyMap.get(integrationObject.BDP_Identifier_String__c);
    		if (integrationObject.Active__c == null || integrationObject.Active__c != bdpCompany.Active__c){
    			integrationObject.Active__c = bdpCompany.Active__c;
    			itemsToUpdate.add(integrationObject);
    		}
    	}
    	
    	if (itemsToUpdate.size() > 0) {
    		Database.update(itemsToUpdate);
    	}
	}	
	
	
	
    /*
    * @description No final actions are required, so function is empty
    */
	global void finish(Database.BatchableContext BC) {		
	}	
}