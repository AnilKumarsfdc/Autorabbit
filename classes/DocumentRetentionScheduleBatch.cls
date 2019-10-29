/* --------------------------------------------------------------------------------------------------
Name:            DocumentRetentionScheduleBatch.cls 
Description:     Scheduled Batch class which is responsible for relocation of all Items 
Test class:      DocumentRetentionScheduleBatchTest.cls 
------------------------------------------------------------------------------------------------ */
global without sharing class DocumentRetentionScheduleBatch implements Database.Batchable<sObject>, Schedulable  {
    private static final String SHARE_TYPE = 'I';
    private static final String CRON_SCHEDULE = '0 0 2 * * ?';
    private static final String SCHEDULED_NAME = 'Documet Retention';
    private static final String SCHEDULED_TEST_NAME = 'Document Retention Test';    
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    private final Boolean executeForAllItems;
    
    /*
    * @description Public constructor method
    */
    global DocumentRetentionScheduleBatch(Boolean runForAllItems) {
    	executeForAllItems = runForAllItems;
    }
    
    /*
    * @description Interface start method, which returns query to get all/new Content Documents
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	DateTime createdDateLowerLimit = executeForAllItems ? DateTime.newInstance(0)
    														: DateTime.now().addDays(-1);
    	return Database.getQueryLocator([SELECT Id 
    									 FROM ContentDocument
    									 WHERE CreatedDate >= :createdDateLowerLimit]);
    }

    /*
    * @description Main Batch method, which links all documents to Document Retention Library
    */
    global void execute(Database.BatchableContext BC, List<ContentDocument> scope) {
    	Config_Settings__c config = Config_Settings__c.getInstance();
    	if (config != null && config.Document_Retention_Library__c != null) {
			Id libraryId = config.Document_Retention_Library__c;
			List<ContentDocumentLink> retentionLinks = new List<ContentDocumentLink>();
			for (ContentDocument document : scope) {
				retentionLinks.add(new ContentDocumentLink(
                   ContentDocumentId = document.Id,
                   LinkedEntityId = libraryId,
                   ShareType = SHARE_TYPE    									
				));
			}
			
			if (retentionLinks.size() > 0) {
				Database.insert(retentionLinks, false);
			}
    	}
    } 

    /*
    * @description Empty batch interface finish method
    */
    global void finish(Database.BatchableContext BC) {
    }
    
    /*
    * @description Schedule execute method, which start batch from this class
    */
    global void execute(SchedulableContext sc) {
        Database.executebatch(this, DEFAULT_BATCH_SIZE);
    }

    /*
    * @description Static class which automatically starts schedule job
    */
	public static void startScheulable() {
		DocumentRetentionScheduleBatch scheduleBatch = new DocumentRetentionScheduleBatch(false);
		String scheduleName = Test.isRunningTest() ? SCHEDULED_TEST_NAME : SCHEDULED_NAME;
		System.schedule(scheduleName, CRON_SCHEDULE, scheduleBatch);
	}
	
    /*
    * @description Static class which automatically starts batch job to link all existing content to library
    */
	public static void executeBatchForAllItems() {
		DocumentRetentionScheduleBatch allItemsRunBatch = new DocumentRetentionScheduleBatch(true);
        Database.executebatch(allItemsRunBatch, DEFAULT_BATCH_SIZE);		
	}
}