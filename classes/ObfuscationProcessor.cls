/* --------------------------------------------------------------------------------------------------
Name:      	  ObfuscationProcessor.cls 
Description: 	Class which executes Obscuration functionality (Data Anonimization), as a part of deployment 
				 This method also contains methods, which should be a part of related object Trigger.
				 Also this class contains information 
Test class:	  ObfuscationProcessorTest.cls 
------------------------------------------------------------------------------------------------ */
global abstract without sharing class ObfuscationProcessor implements Database.Batchable<sObject>, Database.Stateful {
	public static final String ACTION_OBSCURE = 'Obscure';
	public static final String ACTION_COPY = 'Copy';
	public static final String ACTION_SET_SF_ID = 'Set Salesforce Id';
	public static final String ACTION_SET_CURRENT_DATE = 'Set Current Date';
	public static final String ACTION_CLEAR = 'Clear';
	
	public static final String ACTION_DEFAULT = ACTION_CLEAR;
	public static final String OBFUSCATION_FLAG_FIELD = 'GDPR_Obscuration_Requested__c';
	public static final String OBFUSCATION_STATUS_FIELD = 'GDPR_Obscuration_Status__c';
	public static final String OBFUSCATION_STATUS_OK = 'OK';
	public static final Integer OBFUSCATION_BATCH_SIZE = Test.isRunningTest() ? 100 : 1;
	@TestVisible
	private static Boolean isDebugMode = false;
	
	global protected Set<String> objectsExcludedFromReparenting;
	
	global final String objectApiName;
	global final Schema.SObjectType sObjectTypeValue;
	global protected Set<Id> recordIds;
	global protected Map<Id, Id> transferedRecordsIdMap;
	global List<ObscurationFieldInformation> fieldConfiguration;
	global protected Boolean isPostProcessingRequired;
	
	private static Schema.DescribeSObjectResult objectDescribe;
	
	/*
	* @describe Constructor for Object Name without predefined list of Records to Obfuscate
	*/
	global ObfuscationProcessor(Schema.SObjectType sObjectTypeValue) {
		this.sObjectTypeValue = sObjectTypeValue;
		objectDescribe = sObjectTypeValue.getDescribe();
		this.objectApiName  = objectDescribe.getName();
		this.recordIds = new Set<Id>();
		this.objectsExcludedFromReparenting = new Set<String>();
		this.transferedRecordsIdMap = new Map<Id, Id>();
	}	
	
	/*
	* @describe Constructor for Object with predefined list of Recrods to Obfuscate
	*/
	global ObfuscationProcessor(Schema.SObjectType sObjectTypeValue, Set<Id> recordIdsToObfuscate) {
		this(sObjectTypeValue);
		this.recordIds = recordIdsToObfuscate;
		this.fieldConfiguration = getFieldObscurationInformation();
	}	
		
	/*
	* @describe Service layer function, which is a part of trigger functionality. It runs through the list 
	* of trigger records, checks for which of them Obfuscation flag has been requested and starts Async Batch Job for that items
	*/
	public void checkObfuscationOnTrigger(List<sObject> sObjectList, Map<Id, sObject> oldValues) {
		recordIds = new Set<Id>();
		Boolean oldValue = false, newValue = false;
		for (sObject objectToCheck : sObjectList) {
			oldValue = (!oldValues.containsKey(objectToCheck.Id)) ? false 
					 : (Boolean)oldValues.get(objectToCheck.Id).get(OBFUSCATION_FLAG_FIELD);
			newValue = (Boolean)objectToCheck.get(OBFUSCATION_FLAG_FIELD);
			if (newValue && !oldValue) {
				recordIds.add(objectToCheck.Id);
			}
		}
		
		if (recordIds.size() > 0) {
			this.fieldConfiguration = getFieldObscurationInformation();
			Database.executeBatch(this, OBFUSCATION_BATCH_SIZE);
		}
	}
	
	/*
	* @describe Returns information about all updatable fields, their type, Metadata Information
	* and action which should be executed for those fields as a part of obscuration process based on custom metadata
	*/
	private List<ObscurationFieldInformation> getFieldObscurationInformation(){ 
		List<ObscurationFieldInformation> fieldInfoList = new List<ObscurationFieldInformation>();
		Map<String, GDPR_Obscuration_Settings__mdt> settingsMap = getCustomMetadataMap();
		
		String fieldApiName = null;
		Schema.DescribeFieldResult fieldDescribe = null;
		GDPR_Obscuration_Settings__mdt fieldObscureSettings = null;
		for (Schema.sObjectField field : objectDescribe.fields.getMap().values()) {
			fieldDescribe = field.getDescribe();
			fieldApiName = fieldDescribe.getName();
			fieldObscureSettings = settingsMap.get(fieldApiName.toLowerCase());
			
			if (fieldDescribe.isCreateable() && fieldDescribe.isUpdateable()) {
				fieldInfoList.add( new ObscurationFieldInformation(
					fieldApiName, fieldDescribe, fieldObscureSettings
				));			 
			}
		}
			
		return fieldInfoList;
	}
	
	/*
	* @describe Query and returns GDPR Obscuration settings for particular object
	*/
	private Map<String, GDPR_Obscuration_Settings__mdt> getCustomMetadataMap() {
		Map<String, GDPR_Obscuration_Settings__mdt> customMetadataMap = new Map<String, GDPR_Obscuration_Settings__mdt>();
		for (GDPR_Obscuration_Settings__mdt obscurationSettingsMdt : [
			SELECT Field_API_Name__c, Obscuration_Action__c, Process_After_Merge__c
			FROM GDPR_Obscuration_Settings__mdt
			WHERE Salesforce_Object__c = :objectApiName
			LIMIT :GlobalConstants.MAX_QUERY_LIMIT
		]) {
			customMetadataMap.put(obscurationSettingsMdt.Field_API_Name__c.toLowerCase(), obscurationSettingsMdt);
		}
		return customMetadataMap;
	}
	
	/*
	* @description Interface start method, which returns all BDP records modified in specific range period
	*/
	global virtual Database.QueryLocator start(Database.BatchableContext BC) { 
		List<String> fieldsToQuery = new List<String>{'Id'};
		for (ObscurationFieldInformation fieldInfo : fieldConfiguration) {
			fieldsToQuery.add(fieldInfo.fieldApiName);
		}
		return Database.getQueryLocator(
			' SELECT ' + String.join(fieldsToQuery, ', ') + 
			' FROM ' + objectApiName +
			' WHERE Id IN :recordIds '
		);	  
	}	
	
	/*
	* @description Main batch execute method. Next steps are part of this method for each record:
	* 1) Create Obscured clone of original record
	* 2) Reassign child objects
	* 3) Hard-Delete original record
	* 4) Do post-processing record update
	*/  
	global virtual void execute(Database.BatchableContext BC, List<sObject> scopeList) {
		Map<Id, sObject> cloneSObjectMap = new Map<Id, sObject>();
		List<sObject> recordsToDelete = new List<sObject>();
		Id newRecordId = null;
		sObject obscuredRecord = null;
		
		for (sObject originRecord : scopeList) {
			obscuredRecord = getObscuredClone(originRecord);
			cloneSObjectMap.put(originRecord.Id, obscuredRecord);
			recordsToDelete.add(this.sObjectTypeValue.newSObject(originRecord.Id));
		}
		
		//Insert new Obscured Records to Salesforce
		Database.SaveResult[] saveResults = Database.insert(cloneSObjectMap.values(), isDebugMode);
		System.debug('New BDP Records Results: ' + saveResults);
		
		//Set Obscured Ids Map
		Map<Id, Id> obscuredIdsMap = new Map<Id, Id>();
		for (sObject originRecord : scopeList) {
			newRecordId = cloneSObjectMap.get(originRecord.Id).Id;
			if (newRecordId != null) {
				obscuredIdsMap.put(originRecord.Id, newRecordId);
				transferedRecordsIdMap.put(originRecord.Id, newRecordId);			   
			}
		}
		
		//Reassign all existing records before deletion of original record
		reassignAllRelatedRecords(obscuredIdsMap);
		
		//Delete original Records
		Database.DeleteResult[] deleteResults = Database.delete(recordsToDelete, isDebugMode);
		System.debug('Results of old record deletion: ' + deleteResults);
				
		//Do post-processing recrods with obscured clones after update
		Map<Id, sObject> valuesToUpdate = new Map<Id, sObject>();
		for (sObject originRecord : scopeList) {
			newRecordId = obscuredIdsMap.get(originRecord.Id);
			if (newRecordId != null) {
				obscuredRecord = getPostProcessingUpdate(newRecordId, originRecord);
				valuesToUpdate.put(originRecord.Id, obscuredRecord);
			}
		}
		Database.update(valuesToUpdate.values(), isDebugMode);
		
		//Hard Delete Items which were not updated successfully
		Database.emptyRecycleBin(recordsToDelete);
	}   
	
	/*
	* @describe Retrieves Obscured clone of original record base on custom metadata
	*/
	protected virtual sObject getObscuredClone(sObject origin) {
		sObject obscuredClone = this.sObjectTypeValue.newSObject();
		Object obscuredValue = null;
		for (ObscurationFieldInformation fieldInfo : fieldConfiguration) {
			if (!fieldInfo.processAfterMerge) {
				obscuredValue = getObscuredValue(origin, fieldInfo);
				if (obscuredValue != null) {
					obscuredClone.put(fieldInfo.fieldApiName, obscuredValue);
				}
			}
		}
		return obscuredClone;
	}
	
	/*
	* @describe Get record for updates, with list of fields which should be set after original record is deleted
	*/
	protected virtual sObject getPostProcessingUpdate(Id recordId, sObject origin) {
		sObject obscuredClone = this.sObjectTypeValue.newSObject(recordId);
		Object obscuredValue = null;
		for (ObscurationFieldInformation fieldInfo : fieldConfiguration) {
			if (fieldInfo.processAfterMerge) {
				obscuredValue = getObscuredValue(origin, fieldInfo);
				if (obscuredValue != null) {
					obscuredClone.put(fieldInfo.fieldApiName, obscuredValue);
				}
			}
		}
		return obscuredClone;	   
	}
	
	/*
	* @describe Returns processed/obscured value of particular field based on obscuration metadata
	*/
	private Object getObscuredValue(sObject origin, ObscurationFieldInformation fieldInfo) {
		Object resultValue = null;
		if (fieldInfo.obscurationAction == ACTION_COPY) {
			resultValue = origin.get(fieldInfo.fieldApiName);
		} else if (fieldInfo.obscurationAction == ACTION_SET_SF_ID) {
			resultValue = origin.Id;
		} else if (fieldInfo.obscurationAction == ACTION_SET_CURRENT_DATE) {
			if (fieldInfo.displayType == Schema.DisplayType.Date) {
				resultValue = Date.today();
			} else {
				resultValue = DateTime.now();
			}
		} else if (fieldInfo.obscurationAction == ACTION_OBSCURE) {
			resultValue = getObscuredValueForType(fieldInfo.soapType, fieldInfo.displayType, origin.Id);
		}
		return resultValue;
	}
	
	/*
	* @describe Returns default Obscuration value for particular field type
	*/
	private Object getObscuredValueForType(Schema.SoapType soapType, Schema.DisplayType displayType, Id originId) {
		Object resultValue = null;
		if (displayType == Schema.DisplayType.Email) {
			resultValue = originId + String.valueOf(Math.round(Math.random() * 1000000)) + '@noreply.gdpr';
		} else if (soapType == Schema.SOAPType.Boolean) {
			resultValue = false;
		} else if (soapType == Schema.SOAPType.String) {
			resultValue = 'GDPR';
		} else if (soapType == Schema.SOAPType.Date) {
			resultValue = Date.today().addDays(10 - Math.round(Math.random() * 20));
		} else if (soapType == Schema.SOAPType.DateTime) {
			resultValue = DateTime.now().addMinutes(2000 - Math.round(Math.random() * 4000));		   
		} else if (soapType == Schema.SOAPType.Integer || soapType == Schema.SOAPType.Double) {
			resultValue = Math.round(Math.random() * 4000);
		}
		return resultValue;
	}
	
	/*
	* @describe Reassigns all child records from original record to it's obscured copy
	*/
	protected void reassignAllRelatedRecords(Map<Id, Id> obscuredIdsMap){
		if (obscuredIdsMap.size() > 0) {
			Set<Id> recordIdsSet = obscuredIdsMap.keySet();
			Schema.DescribeSObjectResult objectDescribe = sObjectTypeValue.getDescribe();
			String relatedField = null;
			Schema.DescribeSObjectResult relatedObjectDecribe = null;
			
			for (Schema.ChildRelationship relationshipDescribe : objectDescribe.getChildRelationships()) {
				relatedObjectDecribe = relationshipDescribe.getChildSObject().getDescribe();
				
				if (relatedObjectDecribe.isUpdateable() && relatedObjectDecribe.isQueryable()
					&& !objectsExcludedFromReparenting.contains('' + relationshipDescribe.getChildSObject())
					&& relationshipDescribe.getField().getDescribe().isUpdateable()) {
					relatedField = relationshipDescribe.getField().getDescribe().getName();
								 
					List<sObject> relatedObjects = Database.query(' SELECT Id, ' + relatedField
												 + ' FROM ' + relationshipDescribe.getChildSObject()
												 + ' WHERE ' + relatedField + ' IN :recordIdsSet ');
					if (relatedObjects.size() > 0) {
						for (sObject relatedObject : relatedObjects) {
							relatedObject.put(relatedField, obscuredIdsMap.get((Id)relatedObject.get(relatedField)));
						}
						Database.SaveResult[] reassignmentResults = Database.update(relatedObjects, isDebugMode);
						System.debug('ReassignmentResults: ' + reassignmentResults);
					}
				}
			}
		}
	}
		
	/*
	* @description Final steps of Batch execution. Sets final obscuration status as successful/failed 
	*/
	global virtual void finish(Database.BatchableContext BC) {  
		List<sObject> finalConfirmationList = getStatusConfirmationList();
		Database.update(finalConfirmationList, isDebugMode);
	}	 
	
	/*
	* @describe Retrieves record values to update to specify successful obscuration status
	*/
	protected virtual List<sObject> getStatusConfirmationList() {
		List<sObject> statusConfirmationList = new List<sObject>();
		sObject objectToChangeStatus = null;
		Id newRecordId = null;
		for (Id recordId : recordIds) {
			newRecordId = transferedRecordsIdMap.get(recordId);
			if (newRecordId != null) {
				objectToChangeStatus = sObjectTypeValue.newSObject(newRecordId);
				objectToChangeStatus.put(OBFUSCATION_STATUS_FIELD, OBFUSCATION_STATUS_OK);
				statusConfirmationList.add(objectToChangeStatus);
			}
		}
		return statusConfirmationList;
	}
	
	
	/*
	* @describe Wrapper class which contains information about 
	*/
	global class ObscurationFieldInformation {
		global String fieldApiName;
		global Schema.DescribeFieldResult fieldDescribe;
		global String obscurationAction;
		global Boolean processAfterMerge;
		global Schema.SOAPType soapType;
		global Schema.DisplayType displayType; 
		
		/*
		*@description Public wrapper constructor
		*/
		public ObscurationFieldInformation(String fieldApiName, Schema.DescribeFieldResult fieldDescribe, 
										  GDPR_Obscuration_Settings__mdt obscureSettings) {
			this.fieldApiName = fieldApiName;
			this.soapType = fieldDescribe.getSoapType();
			this.displayType = fieldDescribe.getType();
			this.obscurationAction = (obscureSettings == NULL) ? ACTION_DEFAULT : obscureSettings.Obscuration_Action__c;
			this.processAfterMerge = (obscureSettings == NULL) ? false : obscureSettings.Process_After_Merge__c;
		}
	}  
}