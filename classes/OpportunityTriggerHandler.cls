/* --------------------------------------------------------------------------------------------------
     Name:            OpportunityTriggerHandler.cls 
     Description:     Trigger handler class, responsible on validation of Stage-dependent field requirements.
                      Script is fetching data from Sales Path Metadata to recognize list of required fields
     Test class:      OpportunityTriggerHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class OpportunityTriggerHandler {
    private static final String STAGE_CHANGE_ERROR = 'Cannot change Stage of Opportunity from "{0}" to "{1}". ' +
                                                     'Stages should be changed consistently';
    private static final String PRODUCT_ERROR = 'Primary product is required to finish Stage "{0}"';
    private static final String OPPORTUNITY_FIELD_ERROR = 'Field {0} is required to enter Stage "{1}"';
    private static final String PRODUCT_FIELD_ERROR = 'Field {0} on Primary Product is required to enter Stage "{1}"';
    @testVisible //Flag to Disable test execution, used for Test Purposes Only
    private static Boolean DISABLE_EXECUTION = false;
    
    /**
     * @description Public constructor
     **/
    public OpportunityTriggerHandler(){
        
    }
    
    /**
     * @description Inital method which runs throug the list of opportunities to filter only those, for which Stage is changing
     **/
    public void onBeforeUpdate(List<Opportunity> opportunityList, Map<Id, Opportunity> oldValues){
        List<Opportunity> opportunitiesToValidate = new List<Opportunity>();
        for (Opportunity oppRecord : opportunityList) {
            Opportunity oldValue = oldValues.get(oppRecord.Id);
            if (oppRecord.StageName != oldValue.StageName) {
                opportunitiesToValidate.add(oppRecord);
            }
        }
        
        if (opportunitiesToValidate.size() > 0 && !DISABLE_EXECUTION){
            validateOpportunities(opportunitiesToValidate, oldValues);
        }
    }
    
    /**
     * @description Get list of all Field Api Names which are available for User for a specific sObject
     **/
    private static List<String> getAvailableFields(Schema.sObjectType objectType){
        List<String> fieldList = new List<String>();
        Map<String, Schema.SObjectField> sObjectFieldMap = objectType.getDescribe().fields.getMap();
        Schema.SObjectField objectField;
        Schema.DescribeFieldResult fieldDescribe;
        for (String fieldName : sObjectFieldMap.keySet()){
            objectField = sObjectFieldMap.get(fieldName);
            fieldDescribe = objectField.getDescribe();
            if (fieldDescribe.isAccessible()){
                fieldList.add(fieldName);
            }
        }        
        return fieldList;
    }
    
    /**
     * @description For specific Opportunity Ids return list of Primary Products
     **/
    private Map<Id, Opportunity_Product__c> getPrimaryProductMap(Set<Id> opportunityIdSet) {
        List<String> opportunityProductFields = getAvailableFields(Opportunity_Product__c.sObjectType);
        String opportunityProductQuery = ' SELECT ' + String.join(opportunityProductFields, ', ') 
                                       + ' FROM Opportunity_Product__c '
                                       + ' WHERE Opportunity__c IN :opportunityIdSet'
                                       + ' AND Product__r.Primary__c = true '
                                       + ' LIMIT ' + GlobalConstants.MAX_QUERY_LIMIT;       
        Map<Id, Opportunity_Product__c> opportunityProductMap = new Map<Id, Opportunity_Product__c>();
        for (Opportunity_Product__c opportunityProduct : Database.query(opportunityProductQuery)) {
            opportunityProductMap.put(opportunityProduct.Opportunity__c, opportunityProduct);
        }   
        return opportunityProductMap;                             
    }
    
    
    /**
     * @description Run through the Opportunity list to validate if there are any required fields left blank for state
     * If there are Script adds them as Trigger execution errors
     **/
    private void validateOpportunities(List<Opportunity> opportunityList, Map<Id, Opportunity> oldValues) {
        SalesPathValidator validator = new SalesPathValidator(opportunityList, oldValues);
        Set<Id> opportunityIdSet = (new Map<Id, Opportunity>(opportunityList)).keySet();
        
        Map<Id, Opportunity_Product__c> opportunityProductMap = getPrimaryProductMap(opportunityIdSet);
        for (Opportunity newValue : opportunityList) {
            try {
                validator.validateOpportunityStageChange(
                    newValue,
                    oldValues.get(newValue.Id).StageName,
                    opportunityProductMap.get(newValue.Id)
                );
            } catch (Exception e) {
                System.debug(e);
                newValue.addError(e);
            }
        }
    } 
    
    /**
    * @class SalesPathValidator
    * @description Class responsible for validation of
    **/
    private class SalesPathValidator {
        private Map<Id, RecordType> opportunityRecordTypeMap;
        private Map<Id, BusinessProcess> businessProcessMap;
        private Map<String, Sales_Path_Stage_Metadata__mdt> stageMetadata;
        private Map<String, List<Sales_Path_Field_Metadata__mdt>> fieldMetadata;
        private Map<String, String> opportunityLabelMap;
        private Map<String, String> productLabelMap;
            
        /*
        * @description Retrieves Map of Field pairs Api Name/Field Label for a speicific object
        */
        private Map<String, String> getFieldMap(Schema.sObjectType objectType) {
            Map<String, String> fieldMap = new Map<String, String>();
            Map<String, Schema.SObjectField> sObjectFieldMap = objectType.getDescribe().fields.getMap();
            Schema.SObjectField objectField;
            Schema.DescribeFieldResult fieldDescribe;
            for (String fieldName : sObjectFieldMap.keySet()){
                objectField = sObjectFieldMap.get(fieldName);
                fieldDescribe = objectField.getDescribe();
                fieldMap.put(fieldName.toLowerCase(), fieldDescribe.getLabel());
            }        
            return fieldMap;
        }
    
        /*
        * @description Returns Map of Record Type objects for specified Ids
        */
        private Map<Id, RecordType> getRecordTypeMap(Set<Id> recordTypeIdSet) {
            return new Map<Id, RecordType>([  SELECT Id, Name, BusinessProcessId 
                                              FROM RecordType 
                                              WHERE Id IN :recordTypeIdSet
                                              LIMIT :GlobalConstants.MAX_QUERY_LIMIT]);
        }
        
        /*
        * @description Returns Map of Business Process objects for specified Ids
        */
        private Map<Id, BusinessProcess> getBusinessProcessMap(Set<Id> businessProcessIdSet) {
            return new Map<Id, BusinessProcess>( [SELECT Id, Name 
                                                FROM BusinessProcess
                                                WHERE Id IN :businessProcessIdSet
                                                LIMIT :GlobalConstants.MAX_QUERY_LIMIT] );
        }
        
        /*
        * @description Returns List of Stage Metadata for selected Business Processes and Stages
        */
        private Map<String, Sales_Path_Stage_Metadata__mdt> getStageMetadataMap(Map<Id, BusinessProcess> businessProcessMap, 
                                                                                Set<String> stageSet) {
            Set<String> salesProcessNameSet = new Set<String>();
            for (BusinessProcess salesProcess : businessProcessMap.values()) {
                salesProcessNameSet.add(salesProcess.Name);
            }
            
            Map<String, Sales_Path_Stage_Metadata__mdt> metadataMap = new Map<String, Sales_Path_Stage_Metadata__mdt>();
            for (Sales_Path_Stage_Metadata__mdt stageMetadata : [SELECT Id, Order__c, 
                     Sales_Process__c, Stage__c, Is_Primary_Product_Required__c
                     FROM Sales_Path_Stage_Metadata__mdt
                     WHERE Stage__c IN :stageSet
                     AND Sales_Process__c IN :salesProcessNameSet
                     LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
                     metadataMap.put(
                        stageMetadata.Sales_Process__c + ':' + stageMetadata.Stage__c,
                        stageMetadata
                     ); 
            }
            return metadataMap;
        }
        
        /*
        * @description Returns List of Field Metadata for selected Business Processes and Stages (Returns only required fields)
        */
        private Map<String, List<Sales_Path_Field_Metadata__mdt>> getRequiredFieldsMetadata(Set<String> stageSet, 
                                                                                            Set<String> recordTypeSet){
            Map<String, List<Sales_Path_Field_Metadata__mdt>> metadataMap = new Map<String, List<Sales_Path_Field_Metadata__mdt>>();
            List<Sales_Path_Field_Metadata__mdt> metadataList;
            String stageKey;
            for (Sales_Path_Field_Metadata__mdt fieldMetadata : [ SELECT Id, Object_Name__c, Field_Name__c, 
                            Required__c, Stage__c, Sales_Process__c
                            FROM Sales_Path_Field_Metadata__mdt
                            WHERE Required__c = :true
                            AND Stage__c IN : stageSet
                            AND Sales_Process__c IN :recordTypeSet
                            LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
                stageKey = fieldMetadata.Sales_Process__c + ':' + fieldMetadata.Stage__c;
                metadataList = metadataMap.get(stageKey);
                if (metadataList == null) {
                    metadataList = new List<Sales_Path_Field_Metadata__mdt>();
                    metadataMap.put(stageKey, metadataList);
                }
                metadataList.add(fieldMetadata);
            }
            
            return metadataMap;
        }       
        
        /*
        * @description Public constructor which pre-fetch Record Types, Busines Processes and Stage/Field Metadata
        * based on values, present in Trigger Opportunities
        */
        public SalesPathValidator(List<Opportunity> opportunityList, Map<Id, Opportunity> oldValues){
            Set<Id> recordTypeIdSet = new Set<Id>();
            Set<String> stageSet = new Set<String>(); 
            for (Opportunity oppRecord : opportunityList) {
                Opportunity oldValue = oldValues.get(oppRecord.Id);
                recordTypeIdSet.add(oppRecord.RecordTypeId);
                stageSet.add(oppRecord.StageName);
                stageSet.add(oldValue.StageName);
            }
            
            opportunityRecordTypeMap = getRecordTypeMap(recordTypeIdSet);
            
            Set<Id> businessProcessIdSet = new Set<Id>();
            Set<String> recordTypeNameSet = new Set<String>();
            for (RecordType oppRecordType: opportunityRecordTypeMap.values()) {
                businessProcessIdSet.add(oppRecordType.BusinessProcessId);
                recordTypeNameSet.add(oppRecordType.Name);
            }
            
            businessProcessMap = getBusinessProcessMap(businessProcessIdSet);
            stageMetadata = getStageMetadataMap(businessProcessMap, stageSet);
            fieldMetadata = getRequiredFieldsMetadata(stageSet, recordTypeNameSet);
            opportunityLabelMap = getFieldMap(Opportunity.sObjectType);
            productLabelMap = getFieldMap(Opportunity_Product__c.sObjectType);
        }
        
        /*
        * @description Returns Stage Metadata for a specific Record Type and Stage
        */
        private Sales_Path_Stage_Metadata__mdt getStageMetadata(Id recordTypeId, String stageName){
            Sales_Path_Stage_Metadata__mdt  resultMetadata = null;
            RecordType opportunityRecordType = opportunityRecordTypeMap.get(RecordTypeId);
            if (opportunityRecordType != null){
                BusinessProcess salesProcess = businessProcessMap.get(opportunityRecordType.BusinessProcessId);
                if (salesProcess != null) {
                    resultMetadata = stageMetadata.get(salesProcess.Name + ':' + stageName);
                }
            }
            return resultMetadata;
        }
        
        /*
        * @description Returns List of Required Fields Metadata for a specific Record Type and Stage
        */
        private List<Sales_Path_Field_Metadata__mdt> getRequiredFieldsMetadata(Id recordTypeId, String stageName) {
            List<Sales_Path_Field_Metadata__mdt> fieldsMetadataList = null;
            RecordType opportunityRecordType = opportunityRecordTypeMap.get(RecordTypeId);
            if (opportunityRecordType != null){
                fieldsMetadataList = fieldMetadata.get(opportunityRecordType.Name + ':' + stageName);
            }
            return fieldsMetadataList;
        }
        
        /*
        * @description Does field validation checking that there is no empty required fields for Opportunity
        * and for a specific Opportunity Product, when moving to different Stage
        */
        private void validateFieldRequirements(Opportunity newValue, Sales_Path_Stage_Metadata__mdt metadataToValidate,
                                               Opportunity_Product__c opportunityProduct){
            List<Sales_Path_Field_Metadata__mdt> fieldMetadataList;
            fieldMetadataList = getRequiredFieldsMetadata(newValue.RecordTypeId, metadataToValidate.Stage__c);
            if (fieldMetadataList != null){
                String fieldLabel;
                for (Sales_Path_Field_Metadata__mdt fieldMetadata : fieldMetadataList){
                    //Validate required field for Opportunity
                    if (fieldMetadata.Object_Name__c == GlobalConstants.OPPORTUNITY_VALUE) {
                        try {
                            fieldLabel  = opportunityLabelMap.containsKey(fieldMetadata.Field_Name__c.toLowerCase()) 
                                        ? opportunityLabelMap.get(fieldMetadata.Field_Name__c.toLowerCase())  
                                        : fieldMetadata.Field_Name__c;
                                              
                            if (newValue.get(fieldMetadata.Field_Name__c) == null) {
                                newValue.addError(String.format(
                                    OPPORTUNITY_FIELD_ERROR, new String[]{fieldLabel, newValue.StageName}
                                ));
                            }
                        } catch (Exception e) {
                            newValue.addError(e);
                        }
                    }
                    //Validate required field for Opportunity Product
                    if (fieldMetadata.Object_Name__c == GlobalConstants.OPPORTUNITY_PRODUCT_VALUE 
                        && opportunityProduct != null) {
                        try {
                            if (opportunityProduct.get(fieldMetadata.Field_Name__c) == null) {
                                fieldLabel  = productLabelMap.containsKey(fieldMetadata.Field_Name__c.toLowerCase()) 
                                            ? productLabelMap.get(fieldMetadata.Field_Name__c.toLowerCase())  
                                            : fieldMetadata.Field_Name__c;
                                                  
                                newValue.addError(String.format(
                                    PRODUCT_FIELD_ERROR, new String[]{fieldLabel, newValue.StageName}
                                ));
                            }
                        } catch (Exception e) {
                            newValue.addError(e);
                        }
                    }                           
                }
            }           
        }
        
        /*
        * @description Does all Validations required for specific Opportunity to change Stage:
        * 1) Validate that Opportunity Stage should change in Particular object and it's impossible to "jump" a couple stages ahead
        * 2) Validate that Primary Opportunity Product should be created, before moving to next stage, when specified
        * 3) Call method which does Required Field Validation
        */
        public void validateOpportunityStageChange(Opportunity newValue, String oldStage, 
                                                    Opportunity_Product__c opportunityProduct){
            Boolean isClosedLost = newValue.IsClosed && !newValue.IsWon;
            Sales_Path_Stage_Metadata__mdt oldStageMetadata = getStageMetadata(newValue.RecordTypeId, oldStage);
            Sales_Path_Stage_Metadata__mdt newStageMetadata = getStageMetadata(newValue.RecordTypeId, newValue.StageName);
            //If User tries to change Opportunity Stage a couple steps ahead, then show error
            if (!isClosedLost && oldStageMetadata != null && newStageMetadata != null &&
                newStageMetadata.Order__c > oldStageMetadata.Order__c + 1){
                newValue.addError(String.format(
                    STAGE_CHANGE_ERROR, new String[]{oldStageMetadata.Stage__c, newStageMetadata.Stage__c}
                ));
                return;
            }
            
            Sales_Path_Stage_Metadata__mdt metadataToValidate = isClosedLost ? newStageMetadata : oldStageMetadata;
            if (metadataToValidate != null && oldStageMetadata != null && newStageMetadata != null && 
                (newStageMetadata.Order__c > oldStageMetadata.Order__c  || isClosedLost)) {
                //If User hasn't created Primary Product before Stage, when required, then show an error
                if (metadataToValidate.Is_Primary_Product_Required__c == true && opportunityProduct == null){
                    //newValue.addError(String.format(PRODUCT_ERROR, new String[]{oldStage}));
                    return;
                }
                
                //Validate that all required fields are populated
                validateFieldRequirements(newValue, metadataToValidate, opportunityProduct);
            }
        }
    }
    
    /**
     * @description opprtunity trigger handler method on event onAfterInsert to
     *  create map of account and Set of related opportunity id and creating junction records
     **/
    public void onAfterInsert(List<Opportunity> opportunityList){
        Map<Id, Set<Id>> opportunityAccountMap = new Map<Id,Set<id>>(); 
        for(Opportunity oppObj : opportunityList){            
            if(opportunityAccountMap.keySet().contains(oppObj.AccountId)){                
                opportunityAccountMap.get(oppObj.AccountId).add(oppObj.Id);
            }else{                
                Set<Id> newOppSet = new Set<id>();
                newOppSet.add(oppObj.Id);
                opportunityAccountMap.put(oppObj.AccountId,newOppSet);
            }
        }       
        if(opportunityAccountMap.size()>0){
            OpportunityInternationalHelper.createJunctionsForNewOpportunities(JSON.serialize(opportunityAccountMap));
        }     
    }
}