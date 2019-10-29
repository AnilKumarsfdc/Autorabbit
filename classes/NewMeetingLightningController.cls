/* --------------------------------------------------------------------------------------------------
     Name:            NewMeetingLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  of creating Metting Record on Company
	 Test class:      NewMeetingLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class NewMeetingLightningController {
    
    private static Map<String, Schema.DescribeFieldResult> meetingFields = null;	
    
     static {
        meetingFields = getAvailableFields(Meeting__c.sObjectType);
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
    
    /**
	 * @description: aura method prepopulates Meeting info while creating new Meeting on Company
	 * 
	 **/
	@AuraEnabled
    public static MeetingWrapper getMeetingInfo(string recordId) {
        
        Account accountObj = null; 
        Meeting__c meetingObj = null;
        MeetingWrapper meetingWrapperObj = null;
        try {
            if (!String.isBlank(recordId)) {   
                Id sObjId = Id.valueOf(recordId);
                String sObjName = sObjId.getSObjectType().getDescribe().getName();
                if(sObjName.equalsIgnoreCase(GlobalConstants.SOJBECT_ACCOUNT)){
                    accountObj = [SELECT Id, Name, 
                                  BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                                  ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode                                                
                                  FROM Account
                                  WHERE Id =: recordId LIMIT 1];                   
                }else{
                    
                    meetingObj = [SELECT Id, Name,Account__c,RecordType.Name,Other_Attendees__c,
                                  Start_DateTime__c,End_DateTime__c,Meeting_Address_Type__c,Is_Cancelled__c,
                                  Meeting_Address__c,Incomplete__c,Meeting_Note__c,Needs_Changed__c,Needs_Changed_Detail__c,
                                  Customers_Changed__c,Customers_Changed_Detail__c,Nature_Changed__c,Nature_Change_Detail__c,
                                  Business_Operating_Expectations__c,Business_Operating_Detail__c,Pricing__c,Pricing_Desc__c,
                                  Credit_Decline_Notification__c,Decline_Appeal__c,Fraud_Protection_Discussed__c,Fraud_Protection_Detail__c,
                                  Preferences_Discussed__c,Include_me_as_an_attendee__c,CreatedDate
                                  FROM Meeting__c
                                  WHERE Id =: recordId LIMIT 1];
                    accountObj = [SELECT Id, Name, 
                                  BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                                  ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode                                                
                                  FROM Account
                                  WHERE Id =: meetingObj.Account__c LIMIT 1];
                }
                
                meetingWrapperObj = new MeetingWrapper();
                meetingWrapperObj.setMeetingDetails(meetingObj,accountObj);
                
            }
        } catch(AuraHandledException e) {
            throw e;
        }
        
        return meetingWrapperObj;
    }

    /**
	 * @description Get meeting related attendies/ related companies by meeting id
	 * @returns PillWrapper class object
	 **/
    @AuraEnabled
    public static List<PillWrapper> getMeetingRelatedEntities(Meeting__c meetingObj) {
        List<PillWrapper> pwObjList = new List<PillWrapper>();
        try{    
            for(User_Attendee__c userAtt : [SELECT Id,Name,User__r.Name,User__c FROM User_Attendee__c WHERE Meeting__c =:meetingObj.Id]){
                pwObjList.add(new PillWrapper(
                    userAtt.User__r.Name,
                    userAtt.User__r.Name,
                    GlobalConstants.SOJBECT_USER,
                    userAtt.User__c,
                    userAtt.Id
                ));
            }
            for(Contact_Attendee__c compAtt : [SELECT Id,Name,Contact__r.Name,Contact__c FROM Contact_Attendee__c WHERE Meeting__c =:meetingObj.Id]){
                pwObjList.add(new PillWrapper(
                    compAtt.Contact__r.Name,
                    compAtt.Contact__r.Name,
                    GlobalConstants.SOJBECT_CONTACT,
                    compAtt.Contact__c,
                    compAtt.Id
                ));
            }
            if(meetingObj.Other_Attendees__c!=null){
                for(String unlistedAtt : meetingObj.Other_Attendees__c.split(',')){
                    pwObjList.add(new PillWrapper(
                        unlistedAtt,
                        unlistedAtt,
                        GlobalConstants.UNLISTED_TYPE,
                        unlistedAtt,
                        null
                    ));
                }
            }          
            for(Meeting_Company_Relation__c mcRel : [SELECT Id,Name,Company__c,Company__r.Name
                                                     FROM Meeting_Company_Relation__c 
                                                     WHERE Meeting__c =:meetingObj.Id
                                                    	]){                                                          
               pwObjList.add(new PillWrapper(
                    mcRel.Company__r.Name,
                    mcRel.Company__r.Name,
                    GlobalConstants.SOJBECT_ACCOUNT,
                    mcRel.Company__c,
                    mcRel.Id
                ));
            }
           
        } catch(Exception exc) {
            throw exc;
        }
        return pwObjList;
    }
    
    /**
	 * @description: aura method returns available list of fields configured in custom metadata as per record type
	 * 
	 **/
    @AuraEnabled public static List<MeetingFieldDescription> getFieldDescription(String recordType){
        List<MeetingFieldDescription> fieldList = null;
        try{
            fieldList = new List<MeetingFieldDescription>();
            Meeting_Layout_Metadata__mdt[] fieldMetadataList = getFieldMetadataList(recordType); 
            Schema.DescribeFieldResult fieldDescribe = null;      
            for (Meeting_Layout_Metadata__mdt fieldMdt : fieldMetadataList){
                fieldDescribe = meetingFields.get(fieldMdt.Field_API_Name__c.toLowerCase());             
                fieldList.add(new MeetingFieldDescription(fieldMdt, fieldDescribe));
            }
        }catch(Exception exc){
            throw exc;
        }
        return fieldList;
    }
    
    /**
	 * @description: aura method returns plus 1 hour end datetime for selected start date time
	 * 
	 **/
    @AuraEnabled public static Meeting__c populateDateAction(String meetingJSONString){
        Meeting__c meetingObj = null;
        try{
            meetingObj = (Meeting__c)JSON.deserialize(meetingJSONString, Meeting__c.class);           
            String[] meetingName = meetingObj.Name.split(GlobalConstants.DELIMITER_DASH);
           
            if(meetingObj.Start_DateTime__c!=null){
                Integer day = meetingObj.Start_DateTime__c.day();
                Integer month = meetingObj.Start_DateTime__c.month();
                Integer year = meetingObj.Start_DateTime__c.year();                
                
                DateTime nowTime = System.now();
                
                DateTime startDate = DateTime.newInstance(year, month, day,nowTime.hour(),nowTime.minute(),nowTime.second());
                meetingObj.Start_DateTime__c = startDate;
                meetingObj.End_DateTime__c = startDate.addHours(1);
                
                String formattedMeetingDate = startDate.format(GlobalConstants.DATE_FORMAT);                
                meetingObj.Name  = meetingName[0] + GlobalConstants.DELIMITER_DASH + formattedMeetingDate;   
            }else{
                 meetingObj.End_DateTime__c = null; 
           		 meetingObj.Name= meetingName[0]+ GlobalConstants.DELIMITER_DASH + system.now().format(GlobalConstants.DATE_FORMAT);
            }
              
            
        }catch(Exception exc){
            throw exc;
        }
        return meetingObj;
    }
    
    /*
    * @description Returns list of Meeting Field Metadata for specific Record Type
    */
    private static Meeting_Layout_Metadata__mdt[] getFieldMetadataList(String recordType){
        return [SELECT Field_API_Name__c, Object_Name__c, Order__c, Required__c, Dependent_On__c,
                       Record_Type__c, Field_Label__c, Read_Only__c, Section_Name__c
                FROM Meeting_Layout_Metadata__mdt
                WHERE Record_Type__c = :recordType
                ORDER BY Record_Type__c ,Section_Name__c, Order__c ASC
                LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
    }
    
       
    /**
	 * @description: returns address string from BillingAddress and ShippingAddress compound field values
	 * 
	 **/
    private static String appendString(String existingString,String newString){  
        String tempExistingString = existingString;
        if(!String.isBlank(existingString)) {
            tempExistingString += GlobalConstants.DELIMITER_COMMA + newString; 
        }else{
            tempExistingString = newString;
        }
        return tempExistingString;        
    }
    
	/**
	 * @description: aura method creates New Meeting on Company 
	 * 
	 **/
    @AuraEnabled
    public static String saveNewMeetingAction(string meetingRecord,string recordType) { 
        Meeting__c meetingObj = null;
        try{            
            if (!String.isBlank(meetingRecord)) {
                meetingObj = (Meeting__c) JSON.deserialize(meetingRecord,Meeting__c.class);
            }
            if(!String.isBlank(recordType) && !String.isBlank(meetingRecord)){
                Id recordTypeId = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
                meetingObj.RecordTypeId = recordTypeId;
                meetingObj.Meeting_Type__c=recordType;
                Database.UpsertResult saveResult = Database.upsert(meetingObj);               
                meetingObj.Id = saveResult.getId();                
            }
        }catch(Exception exc){
            throw exc;           
        }
        return meetingObj.Id;
    }
        
    /**
	 * @description Get user/contact/account info by id
	 * @returns PillWrapper class object
	 **/
    @AuraEnabled
    public static PillWrapper getNameById(String sObjTypeId) {
        PillWrapper pwObj = null;
        try{           
            String sObjectName = Id.valueOf(sObjTypeId).getSObjectType().getDescribe().getName();
            String queryString =    GlobalConstants.SOQL_QUERY_SELECT+                                   
                                    GlobalConstants.SOBJECT_FIELD_ID + 
               					    GlobalConstants.DELIMITER_COMMA +
                                    GlobalConstants.SOBJECT_FIELD_NAME +                                   
                                    GlobalConstants.SOQL_QUERY_FROM +                                   
                                    sObjectName +                                    
                                    GlobalConstants.SOQL_QUERY_WHERE +                                  
                                    GlobalConstants.SOBJECT_FIELD_ID +                 
                                    GlobalConstants.SOQL_QUERY_EQUAL +                                    
                                    ':sObjTypeId';          
            sObject objectData = Database.query(queryString);
            String recordName = (String)objectData.get(GlobalConstants.SOBJECT_FIELD_NAME);
            String recordId = (String)objectData.get(GlobalConstants.SOBJECT_FIELD_ID);
            pwObj = new PillWrapper(recordName,recordName,sObjectName,sObjTypeId,null); 
        } catch(Exception exc) {
            throw exc;
        }
        return pwObj;
    }
    
    /**
	 * @description save Meeting related Enitiy Santander Attendees,Company Attendees or Related Companies
	 * @returns error or success of save result
	 **/
    @AuraEnabled
    public static String saveRelatedEnititiesAction(String selectedEntitiesListJSON,String deletedEntitiesListJSON,String meetingId) {
        List<PillWrapper> selectedEntityList = 
            (List<PillWrapper>) JSON.deserialize(selectedEntitiesListJSON, List<PillWrapper>.class);
        List<sObject> allEntitiesToSaveList = new List<sObject>();       
        List<PillWrapper> deletedEntityList = 
            (List<PillWrapper>) JSON.deserialize(deletedEntitiesListJSON, List<PillWrapper>.class);
        
        List<Id> allEntitiesToDeleteList = new List<Id>(); 
        
        String unlistedAttendees='';
        try {               
            for(PillWrapper pwObj : selectedEntityList){               
                if(!String.isBlank(pwObj.sObjTypeId) && String.isBlank(pwObj.objId) && !pwObj.sObjType.equalsIgnoreCase('UnlistedAttendee')){                  
                    Schema.sObjectType objectType = Id.valueOf(pwObj.sObjTypeId).getSObjectType();
                    if (objectType == User.sObjectType){
                        allEntitiesToSaveList.add(new User_Attendee__c(
                            User__c = pwObj.sObjTypeId,
                            Meeting__c = meetingId
                        ));
                    }else if(objectType == Contact.sObjectType){
                        allEntitiesToSaveList.add(new Contact_Attendee__c(
                            Contact__c = pwObj.sObjTypeId,
                            Meeting__c = meetingId
                        ));
                    }else if(objectType == Account.sObjectType){
                        allEntitiesToSaveList.add(new Meeting_Company_Relation__c(
                            Company__c = pwObj.sObjTypeId,
                            Meeting__c = meetingId
                        ));
                    }
                }else if(String.isBlank(pwObj.objId) && pwObj.sObjType.equalsIgnoreCase(GlobalConstants.UNLISTED_TYPE)){
                    unlistedAttendees = appendString(unlistedAttendees,pwObj.name);   
                }               
            }
            if(!String.isBlank(unlistedAttendees)){
                Meeting__c meetingObj = new Meeting__c(Id = meetingId);
                meetingObj.Other_Attendees__c = unlistedAttendees;
                Database.upsert(meetingObj);
            }
            if(allEntitiesToSaveList.size()>0){
                Database.insert(allEntitiesToSaveList); 
            }
            
            if(deletedEntityList.size()>0){             
                Meeting__c meetingObj = [SELECT Id, Other_Attendees__c FROM Meeting__c WHERE ID =: meetingId];               
                List<String> deletedOtherEntities = new List<String>();   
                for(PillWrapper pwObj : deletedEntityList){                                
                    if(!String.isBlank(pwObj.objId) && !pwObj.sObjType.equalsIgnoreCase(GlobalConstants.UNLISTED_TYPE)){ 
                        allEntitiesToDeleteList.add(pwObj.objId);
                    }else{
                        deletedOtherEntities.add((pwObj.name).trim().toLowerCase());                
                    }
                }              
                if(deletedOtherEntities.size()>0)   {
                    String updatedUnlistedAttendees = GlobalConstants.BLANK_SPACE;
                    List<String> existingOtherAttendee = meetingObj.Other_Attendees__c.split((GlobalConstants.DELIMITER_COMMA).trim());
                    Meeting__c meetObj = new Meeting__c(Id=meetingId);
                    for(String existingAttendee : existingOtherAttendee) {
                        if(!deletedOtherEntities.contains(existingAttendee.trim().toLowerCase())){
                            updatedUnlistedAttendees =appendString(updatedUnlistedAttendees,existingAttendee.trim());
                        }
                    }
                    meetObj.Other_Attendees__c = updatedUnlistedAttendees.length()>0?updatedUnlistedAttendees:null;
                    Database.upsert(meetObj);
                }
                if(allEntitiesToDeleteList.size()>0){
                    Database.delete(allEntitiesToDeleteList);
                }
                
            }
        } catch(Exception e) {
            return GlobalConstants.ERROR;
        }   
        return GlobalConstants.SUCCESS; 
    }
    
    /**
	 * @description: populates Record Types of Meeting record 
	 * 
	 **/
    public static List<RecordTypeWrapper> getRecordTypes(Meeting__c meetingObj) {
        List<RecordTypeWrapper> options=null;
        try{
            options = new List<RecordTypeWrapper>();             
            for (RecordTypeInfo info: Meeting__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable()) {
                    String recordTypeName = info.getName();                
                    if(!recordTypeName.equalsIgnoreCase(GlobalConstants.SYSTEM_DEFAULT_RECORD_TYPE)){
                        if(meetingObj!=null && meetingObj.RecordType.Name.equals(recordTypeName)){
                            options.add( new RecordTypeWrapper(recordTypeName,recordTypeName,true));
                        }else if(meetingObj==null && info.isDefaultRecordTypeMapping()){
                            options.add( new RecordTypeWrapper(recordTypeName,recordTypeName,true));
                        }else{
                            options.add( new RecordTypeWrapper(recordTypeName,recordTypeName,false));
                        }
                    }
                }
            }   
        } catch(Exception exc) {  
            throw exc;
        }       
        return options;
    }
    /**
	 * @description: main wrapper class contains company name, primary/secondary address information 
	 * of related company and meeting record object
	 * 
	 **/
    public with sharing class MeetingWrapper {
        @AuraEnabled public List<RecordTypeWrapper> recordTypeWrapperList {get; set;}
        @AuraEnabled public Meeting__c meetingObj {get; set;}      
        @AuraEnabled public String companyName {get; set;}
        @AuraEnabled public String billingAddress {get; set;}
        @AuraEnabled public String shippingAddress {get; set;}
        @AuraEnabled public List<MeetingFieldDescription> fieldList {get; set;}
        @AuraEnabled public boolean isEditMode {get; set;}
        @AuraEnabled public List<PillWrapper> meetingRelatedEnities {get; set;}
         
        /**
         * Description: constructor
         * 
         **/       
        public MeetingWrapper(){             
             fieldList = new List<MeetingFieldDescription>();
             meetingRelatedEnities = new List<PillWrapper>();
             isEditMode = false;
        }
        
        public void setMeetingDetails(Meeting__c meetingObj,Account accObj){
            
            if(meetingObj!=null){
                this.meetingObj = meetingObj;
                this.isEditMode = true;
                this.recordTypeWrapperList = getRecordTypes(meetingObj);  
                this.fieldList = getFieldDescription(meetingObj.RecordType.Name);
                this.meetingRelatedEnities = getMeetingRelatedEntities(meetingObj);
            }else{
                Datetime nowTime = System.now();
                String todaysDate = nowTime.format(GlobalConstants.DATE_FORMAT);
                this.recordTypeWrapperList = getRecordTypes(meetingObj);  
                this.fieldList = getFieldDescription(GlobalConstants.MEETING_DEFAULT_RECORD_TYPE);
                this.meetingObj = new Meeting__c(
                    Name =  accObj.Name.left(49) + GlobalConstants.DELIMITER_DASH + todaysDate,
                    Account__c = accObj.Id                    
                );
            }
            
            setMeetingAddress(accObj);
            
        }
        
        public void setMeetingAddress(Account accObj){            
                this.companyName= accObj.Name.left(49);                
                String billingAddress = GlobalConstants.BLANK_SPACE;
                if(!String.isBlank(accObj.BillingStreet)){
                    billingAddress = appendString(billingAddress,accObj.BillingStreet);
                }
                if(!String.isBlank(accObj.BillingCity)){
                    billingAddress = appendString(billingAddress,accObj.BillingCity);
                }
                if(!String.isBlank(accObj.BillingState)){
                    billingAddress = appendString(billingAddress,accObj.BillingState);
                }
                if(!String.isBlank(accObj.BillingCountry)){
                    billingAddress = appendString(billingAddress,accObj.BillingCountry);
                }
                if(!String.isBlank(accObj.BillingPostalCode)){
                    billingAddress = appendString(billingAddress,accObj.BillingPostalCode);
                }
                
                if(!String.isBlank(billingAddress)){
                    this.billingAddress = billingAddress;
                }else{
                    this.billingAddress = GlobalConstants.ADDRESS_NOT_FOUND;
                }
                
                String shippingAddress = GlobalConstants.BLANK_SPACE;
                if(!String.isBlank(accObj.ShippingStreet)){
                    shippingAddress = appendString(shippingAddress,accObj.ShippingStreet);
                }
                if(!String.isBlank(accObj.ShippingCity)){
                    shippingAddress = appendString(shippingAddress,accObj.ShippingCity);
                }
                if(!String.isBlank(accObj.ShippingState)){
                    shippingAddress = appendString(shippingAddress,accObj.ShippingState);
                }
                if(!String.isBlank(accObj.ShippingCountry)){
                    shippingAddress = appendString(shippingAddress,accObj.ShippingCountry);
                }
                if(!String.isBlank(accObj.ShippingPostalCode)){
                    shippingAddress = appendString(shippingAddress,accObj.ShippingPostalCode);
                }
                
                if(!String.isBlank(shippingAddress)){
                    this.shippingAddress = shippingAddress;
                }else{
                    this.shippingAddress = GlobalConstants.ADDRESS_NOT_FOUND;
                } 
            
        }
    }
    
    /**
	 * @description: child wrapper class for creating picklist of Meeting record types
	 * 
	 **/
    public with sharing class RecordTypeWrapper{        
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean selected {get; set;} 
        /**
        * @description : public construction
        **/
        public RecordTypeWrapper(String label, String value, Boolean selected){
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }
    /**
	 * @description: wrapper class for getting user or contact
	 * 
	 **/
    public with sharing class PillWrapper{        
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String sObjType {get; set;}
        @AuraEnabled public String objId {get; set;}
        @AuraEnabled public String sObjTypeId {get; set;}
       /**
        * @description : public construction
        **/
        public PillWrapper(String label, String name, String sObjType,String sObjTypeId,String objId){
            this.label = label;
            this.name = name;
            this.sObjType = sObjType;
            this.sObjTypeId = sObjTypeId;
            this.objId = objId;           
        }
    }
    
    /**
     * @class AuraEnabled representation of Field Description
     **/
    public with sharing class MeetingFieldDescription{
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
        public String sectionName {get; set;}
        @AuraEnabled
        public String dependentOn {get; set;}
        @AuraEnabled
        public String helpText {get; set;}
       
	    /**
	     * @description Retrieves Lighting Component specific input type based on Schema.DisplayType
	     **/
        private String getInputType(Schema.DisplayType fieldType, Boolean isRichText){        	
            if (fieldType == Schema.DisplayType.Boolean)       { inputType = GlobalConstants.INPUT_TYPE_CHECKBOX; }
            else if (fieldType == Schema.DisplayType.TEXTAREA && isRichText) {
                inputType = GlobalConstants.INPUT_TYPE_RICHTEXT;
            } else if (fieldType == Schema.DisplayType.TextArea) { inputType = GlobalConstants.INPUT_TYPE_TEXTAREA; }
            else { inputType = GlobalConstants.INPUT_TYPE_TEXT; }
            return inputType;
        }
       
    	 /**
          * @description : public construction
          **/
        public MeetingFieldDescription(Meeting_Layout_Metadata__mdt fieldMdt, 
                                         Schema.DescribeFieldResult fieldDescribe){
            objectName = fieldMdt.Object_Name__c;
            fieldName = fieldMdt.Field_API_Name__c;
            required = fieldMdt.Required__c;
            sectionName = fieldMdt.Section_Name__c;  
            dependentOn = fieldMdt.Dependent_On__c; 
            label = (fieldMdt.Field_Label__c != null) ? fieldMdt.Field_Label__c 
                									  : fieldDescribe.getLabel();
            inputType = getInputType(fieldDescribe.getType(), fieldDescribe.isHtmlFormatted());
            editable = fieldDescribe.isUpdateable() && !fieldMdt.Read_Only__c; 
            helpText = fieldDescribe.getInlineHelpText();
        }
    }    
   
}