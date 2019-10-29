/* --------------------------------------------------------------------------------------------------
   Name:            OpportunitySalesPathLightningController.cls 
   Description:     Aura controller of Lightning component extend existing Sales Paht standard ligtning
					component and gives ability to specify fields requirements, add new Opportunity Products,
					and display not only Opportunity but also Opportunity Product fields
   Test class:		OppSalesPathLightningControllerTest.cls 
   Author: 		    Iegor Nechyporenko
  ------------------------------------------------------------------------------------------------ */
public with sharing class OpportunitySalesPathLightningController {
    private static Map<String, Schema.DescribeFieldResult> opportunityFields = null;
    private static Map<String, Schema.DescribeFieldResult> opportunityProductFields = null;
    private static Map<Id, String> businessProcessMap = null;
    
    /*
    * @description Static constructor of the controller, which initializes Schema/Metadata Variables
    */
    static {
        opportunityFields = getAvailableFields(Opportunity.sObjectType);
        opportunityProductFields = getAvailableFields(Opportunity_Product__c.sObjectType);
        businessProcessMap = getBusinessProcessMap();
    }
    
    /*
    * @description Return Id/Name map of all Opportunity Sales Processes
    */
    private static Map<Id, String> getBusinessProcessMap(){
        Map<Id, String> processMap = new Map<Id, String>();
        for (BusinessProcess bp : [SELECT Id, Name FROM BusinessProcess 
        						   LIMIT :GlobalConstants.MAX_QUERY_LIMIT]){
            processMap.put(bp.Id, bp.Name);
        }
        return processMap;
    }
    
    /*
    * @description Retrieves list of Field Descriptions for all Accessible Fields of current User for specific object
    */
    private static Map<String, Schema.DescribeFieldResult> getAvailableFields(Schema.sObjectType objectType){
        Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> sObjectFieldMap = objectType.getDescribe().fields.getMap();
        Schema.SObjectField objectField = null;
        Schema.DescribeFieldResult fieldDescribe = null;
        for (String fieldName : sObjectFieldMap.keySet()){
            objectField = sObjectFieldMap.get(fieldName);
            fieldDescribe = objectField.getDescribe();
            if (fieldDescribe.isAccessible() || Test.isRunningTest()){
                fieldMap.put(fieldName.toLowerCase(), fieldDescribe);                
            }
        }        
        return fieldMap;
    }
    
    /*
    * @description Generates String with comma separated list of fields for dynamic query
    */
    private static String getQuerySelect(Map<String, Schema.DescribeFieldResult> fieldMap){
        List<String> fieldList = new List<String>(fieldMap.keySet());
        return String.join(fieldList, ', ');
    }
    
    /*
    * @description Retrieves all accessible fields of opportunity record
    */
    private static Opportunity getOpportunityData(String opportunityId){
        String querySelect = getQuerySelect(opportunityFields); 
        querySelect += ', RecordType.Name, RecordType.BusinessProcessId ';
        String opportunityQuery = 'SELECT ' + querySelect + ' FROM Opportunity ' 
                                + 'WHERE Id = \'' + opportunityId + '\' ' 
                                + 'LIMIT 1';
        return Database.query(opportunityQuery);
    }
    
    /*
    * @description Creates new Primary Opportunity Product for a specific Opportunity
    */
    private static Opportunity_Product__c getNewOpportunityProduct(Opportunity opportunityRecord){
        RecordType oppProductRecordType = [SELECT Id, Name FROM RecordType 
                                    WHERE SobjectType='Opportunity_Product__c' 
                                    AND Name = :opportunityRecord.RecordType.Name
                                    LIMIT 1];
        Opportunity_Product__c newOpportunityProduct = new Opportunity_Product__c(
            Opportunity__c = opportunityRecord.Id,
            RecordTypeId = oppProductRecordType.Id,
            Product__r = new Product2()
        );
        return newOpportunityProduct;
    }
    
    /*
    * @description Returns existing primary product with all fields fetched by Product Id
    */
    private static Opportunity_Product__c getExistingPrimaryProduct(String productId){
        String opportunityProductQuery = ' SELECT ' + getQuerySelect(opportunityProductFields) 
                                       + ' , Product__r.Name '
                                       + ' FROM Opportunity_Product__c '
                                       + ' WHERE Id = \'' + productId + '\''
                                       + ' AND Product__r.Primary__c = true '
                                       + ' LIMIT 1';    
         return Database.query(opportunityProductQuery);
    }
    
    /*
    * @description Returns existing primary product based on Oportunity Data, if product does not exists, c
    * then returns new instnace with predefined values
    */
    private static Opportunity_Product__c getPrimaryOpportunityProduct(String opportunityId, Opportunity opp){
        String queryFields = getQuerySelect(opportunityProductFields);
        String opportunityProductQuery = ' SELECT ' + queryFields + ' , Product__r.Name '
                                       + ' FROM Opportunity_Product__c '
                                       + ' WHERE Opportunity__c = \'' + opportunityId + '\''
                                       + ' AND Product__r.Primary__c = true '
                                       + ' LIMIT 1';
        List<Opportunity_Product__c> primaryProducts = Database.query(opportunityProductQuery);
        return (primaryProducts.size() == 0) ? getNewOpportunityProduct(opp) 
                                             : primaryProducts.get(0); 
    }
    
    /*
    * @description Returns list of Sales Path Field Metadata for specific Record Type
    */
    private static Sales_Path_Field_Metadata__mdt[] getFieldMetadataList(String recordType){
        return [SELECT Field_Name__c, Object_Name__c, Order__c, Required__c, 
                       Sales_Process__c, Stage__c, Custom_Field_Label__c, Read_Only__c
                FROM Sales_Path_Field_Metadata__mdt
                WHERE Sales_Process__c = :recordType
                ORDER BY Stage__c ASC, Order__c ASC
                LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
    }
    
    /*
    * @description Returns list of Sales Path Stage Metadata for specific Sales Process
    */
    private static Sales_Path_Stage_Metadata__mdt[] getStageMetadataList(String salesProcess){
        return [SELECT Id, Sales_Process__c, Stage__c, Order__c, Is_Closed__c, 
                        Is_Closed_Lost__c, Is_Primary_Product_Required__c                  
            FROM Sales_Path_Stage_Metadata__mdt
            WHERE Sales_Process__c = :salesProcess
            ORDER BY Is_Closed_Lost__c DESC, Order__c ASC
            LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
    }

    /*
    * @description Initialize Lighting Component method, returns composite object containing next required values:
    * 1) Generated Sales Path, with all stages and fields specific for Opportunity Record Type / Sales Process
    * 2) Opportunity record
    * 3) Opportunity Product, and if not exists then ne Opportunity_Product__c instance with predefined values
    * 4) List of Primary Products available for specific Record Type
    */
    @AuraEnabled public static SalesPathResponse getSalesPathInformation(String opportunityId){
        Opportunity opportunityRecord = getOpportunityData(opportunityId);
        SalesPathResponse result = new SalesPathResponse(opportunityRecord);
        result.opportunityProduct = getPrimaryOpportunityProduct(opportunityId, result.opportunity);
        String salesProcess = businessProcessMap.get(result.opportunity.RecordType.BusinessProcessId);
        String recordType = result.opportunity.RecordType.Name;
        generateSalesPathDescription(result, salesProcess, recordType);
        result.calculateCurrentStageIndex();
        return result;
    }
    
    /*
    * @description Generates Sales Path configuration for Specific Record Type / Sales Process
    */
    private static void generateSalesPathDescription(SalesPathResponse result, String salesProcess, String recordType){
        Sales_Path_Field_Metadata__mdt[] fieldMetadataList = getFieldMetadataList(recordType);
        Sales_Path_Stage_Metadata__mdt[] stageMetadataList = getStageMetadataList(salesProcess);        
        Map<String, List<SalesPathFieldDescription>> fieldStageMap = new Map<String, List<SalesPathFieldDescription>>();
        
        SalesPathStageDescription stageDescription = null;
        for (Sales_Path_Stage_Metadata__mdt stageMdt : stageMetadataList){
            stageDescription = new SalesPathStageDescription(stageMdt);
            fieldStageMap.put(stageMdt.Stage__c, stageDescription.fields);
            result.stageList.add(stageDescription);
        }
        
        Schema.DescribeFieldResult fieldDescribe = null;
        List<SalesPathFieldDescription> stageFieldSet = null;
        Boolean isOpportunityField = false;
        for (Sales_Path_Field_Metadata__mdt fieldMdt : fieldMetadataList){
            stageFieldSet = fieldStageMap.get(fieldMdt.Stage__c);
            isOpportunityField = (fieldMdt.Object_Name__c == 'Opportunity');
            fieldDescribe = isOpportunityField ? opportunityFields.get(fieldMdt.Field_Name__c.toLowerCase())
                                               : opportunityProductFields.get(fieldMdt.Field_Name__c.toLowerCase());
            
            if (fieldDescribe == null) {
                System.debug('WARNING! Field is not found: ' + fieldMdt.Field_Name__c);
                //System.assertEquals('FIELD NOT FOUND', fieldMdt.Field_Name__c.toLowerCase());
                continue;
            }
            if (stageFieldSet != null){
                stageFieldSet.add(new SalesPathFieldDescription(fieldMdt, fieldDescribe));
            }
        }
    }    
    
    /*
    * @description Updates Opportunity and Opportunity Product in Data Base and returns their latest values
    */
    @AuraEnabled public static UpdateResponse updateOpportunityData(String opportunityString, String productString){
        Opportunity oppRecord = null;
        Opportunity_Product__c primaryProduct = null;
        try {
	        oppRecord = (Opportunity)JSON.deserialize(opportunityString, Type.forName('Opportunity'));
	        primaryProduct = (Opportunity_Product__c)JSON.deserialize(productString,
	                                                                  Type.forName('Opportunity_Product__c'));
	        Database.upsert(oppRecord);
	        
	        if (primaryProduct != null && primaryProduct.Product__c != null) {
	            Product2 selectedProduct = [SELECT Id, Name FROM Product2 WHERE Id = :primaryProduct.Product__c LIMIT 1];
	            primaryProduct.Name = selectedProduct.Name;
	            Database.UpsertResult productUpsertResult = Database.upsert(primaryProduct);
	            primaryProduct = getExistingPrimaryProduct(productUpsertResult.getId());
	        }
        } catch (Exception e) {
        	System.debug('Exception has been thrown, while tried to update object: ' + e);
        	throw e;
        }
        
        UpdateResponse response = new UpdateResponse();
        response.opportunity = getOpportunityData(oppRecord.Id);
        response.opportunityProduct = primaryProduct;
        return response;
    }
    
    /*
    * @description Updates Opportunity current Stage
    */
    @AuraEnabled public static UpdateResponse moveOpportunityToStage(Id opportunityId, String newStage, Opportunity opportunity) {
        Opportunity oppRecord = (opportunity == null) ? new Opportunity(Id = opportunityId) : opportunity;
        oppRecord.StageName = newStage;
        try {
        	OpportunityStage oppStage = [SELECT Id, DefaultProbability 
        								 FROM OpportunityStage 
        								 WHERE MasterLabel = :newStage
        								 LIMIT 1];
        	oppRecord.Probability = oppStage.DefaultProbability;
        } catch (Exception e){
        	newStage = null;
        	System.debug('Opportunity Stage: ' + newStage + ' hasn\'t been found for Opportunity');
        }
        Database.update(oppRecord);
        
        UpdateResponse response = new UpdateResponse();
        response.opportunity = getOpportunityData(opportunityId);
        return response;
    }
    
    /*
    * @description Retrieves renewed values of Opportunity and Opportunity Product
    */
    @AuraEnabled public static UpdateResponse getOpportunityUpdates(Id opportunityId){
        UpdateResponse response = new UpdateResponse();
        response.opportunity = getOpportunityData(opportunityId);
        response.opportunityProduct = getPrimaryOpportunityProduct(opportunityId, response.opportunity);
        return response;        
    }
    
    /*
    * @class Generic Modification Response class continaing latest values of Opportunity and Opportunity Product
    */
    public with sharing class UpdateResponse{
        @AuraEnabled public Opportunity opportunity {get; set;}
        @AuraEnabled public Opportunity_Product__c opportunityProduct {get; set;}
    }
    
    /*
    * @class AuraEnabled representation of Schema.PicklistValue
    */
    public with sharing class PicklistValue{
        @AuraEnabled public String label {get; private set;}
        @AuraEnabled public String value {get; private set;}
        public PicklistValue(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    /*
    * @class AuraEnabled representation of Field Description
    */
    public with sharing class SalesPathFieldDescription{
        @AuraEnabled
        public String objectName {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public Boolean editable {get; set;}
        @AuraEnabled
        public Boolean required {get; set;}
        @AuraEnabled
        public String inputType {get; set;}
        @AuraEnabled
        public List<PicklistValue> picklistValues{get; set;}
        
	    /*
	    * @description Retrieves Lighting Component specific input type based on Schema.DisplayType
	    */
        private String getInputType(Schema.DisplayType fieldType){
        	String inputType = 'String';
            if (fieldType == Schema.DisplayType.Boolean)       { inputType = 'Checkbox'; } 
            else if (fieldType == Schema.DisplayType.Currency) { inputType = 'Currency'; }
            else if (fieldType == Schema.DisplayType.Date)     { inputType = 'Date'; }
            else if (fieldType == Schema.DisplayType.DateTime) { inputType = 'DateTime'; }
            else if (fieldType == Schema.DisplayType.Double ||
                     fieldType == Schema.DisplayType.Integer)  { inputType = 'Number'; } 
            else if (fieldType == Schema.DisplayType.Picklist) { inputType = 'Picklist'; }
            else if (fieldType == Schema.DisplayType.MultiPicklist) { inputType = 'Multipicklist'; }
            else if (fieldType == Schema.DisplayType.TextArea) { inputType = 'TextArea'; }
            return inputType;
        }
        
        /*
        * @desciption Public construction
        */
        public SalesPathFieldDescription(Sales_Path_Field_Metadata__mdt fieldMdt, 
                                         Schema.DescribeFieldResult fieldDescribe){
            objectName = fieldMdt.Object_Name__c;
            fieldName = fieldMdt.Field_Name__c;
            required = fieldMdt.Required__c;
            label = (fieldMdt.Custom_Field_Label__c != null) ? fieldMdt.Custom_Field_Label__c 
                											 : fieldDescribe.getLabel();
            inputType = getInputType(fieldDescribe.getType());
            editable = fieldDescribe.isUpdateable() && !fieldMdt.Read_Only__c;
                                             
            picklistValues = new List<PicklistValue>();
            List<Schema.PicklistEntry> picklistEntryList = fieldDescribe.getPicklistValues();
            if (picklistEntryList != null){
                for (Schema.PicklistEntry entry : picklistEntryList){
                    if (entry.isActive()) {
                        picklistValues.add(new PicklistValue(entry.getLabel(), entry.getValue()));    
                    }
                }                                     
            }
        }
    }
    
    /*
    * @class Class which contains representation of Stage Description
    */
    public with sharing class SalesPathStageDescription{
        @AuraEnabled
        public String stageName {get; set;}
        @AuraEnabled
        public Boolean isClosed {get; set;}
        @AuraEnabled
        public Boolean isClosedLost {get; set;}
        @AuraEnabled
        public Boolean isPrimaryProductRequired {get; set;}
        @AuraEnabled
        public List<SalesPathFieldDescription> fields {get; set;}
        //@description Public Constructor
        public SalesPathStageDescription(Sales_Path_Stage_Metadata__mdt stageMdt){
            fields = new List<SalesPathFieldDescription>();
            stageName = stageMdt.Stage__c;
            isClosed = stageMdt.Is_Closed__c;
            isClosedLost = stageMdt.Is_Closed_Lost__c;
            isPrimaryProductRequired = stageMdt.Is_Primary_Product_Required__c;
        }
    }
    
    /*
    * @class Composite Response Object containing next data:
    * 1) Generated Sales Path, with all stages and fields specific for Opportunity Record Type / Sales Process
    * 2) Opportunity record
    * 3) Opportunity Product, and if not exists then ne Opportunity_Product__c instance with predefined values
    * 4) List of Primary Products available for specific Record Type
    */
    public with sharing class SalesPathResponse{
        @AuraEnabled
        public Opportunity opportunity {get; set;}
        @AuraEnabled
        public Opportunity_Product__c opportunityProduct {get; set;}
        @AuraEnabled
        public Integer currentStageIndex { get; private set; }
        @AuraEnabled
        public List<SalesPathStageDescription> stageList {get; set;}
        @AuraEnabled
        public List<Product2> productList {get; set;}
        //@description Public Constructor
        public SalesPathResponse(Opportunity oppRecord){
            this.opportunity = oppRecord;
            this.stageList = new List<SalesPathStageDescription>();
            this.productList = getProductList();
        }
        
	    /*
	    * @description Returns index of Current Stage
	    */
        public void calculateCurrentStageIndex(){
            currentStageIndex = -1;
            for (Integer index = 0; index < stageList.size(); index++) {
                if (stageList[index].stageName == this.opportunity.StageName) {
                    currentStageIndex = index;
                    break;
                }
            }
        }       
            
	    /*
	    * @description Returns List of Primary Products for Opportunity Record Type
	    */
        private Product2[] getProductList(){
            return [SELECT Id, Name FROM Product2 
                    WHERE Family = :this.opportunity.RecordType.Name
                      AND Primary__c = true
                      AND IsActive = true
					  ORDER BY Name
                    LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
        }
        
        
        
    }
}