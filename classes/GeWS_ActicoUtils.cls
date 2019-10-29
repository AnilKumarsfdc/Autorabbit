public class GeWS_ActicoUtils {
    
    public static final Map<String,GeWS_Rating_Payload_Mappings__mdt> acticoIdMap = generatePayloadActicoIdMap();
    
    public static final Map<String, String> sectionKeyMap = new Map<String, String>{ 'Cash Flow' => 'cash_flow',
                                                                                     'Transaction' => 'transaction',
                                                                                     'Asset' => 'asset',
                                                                                     'Obligor' => 'obligor',
                                                                                     'Security' => 'security',
                                                                                     'Additional Information' => 'additional_info',
                                                                                     'Management Information' => 'mgmt_info',
                                                                                     'Revenue and Leverage' => 'rev_and_lev',
                                                                                     'Area and Interest Cover' => 'area_and_interest_cover',
                                                                                     'Voids and Bad Debts' => 'voids_and_bad_debts',
                                                                                     'Assessment' => 'assessment'
                                                                                   };
                                                                   
        
    public static final Map<String, String> sectionActionMap = new Map<String, String>{ 'Cash Flow' => 'calc_cash_flow',
                                                                                        'Transaction' => 'calc_transaction',
                                                                                        'Asset' => 'calc_asset',
                                                                                        'Obligor' => 'calc_obligor',
                                                                                        'Security' => 'calc_security',
                                                                                        'Additional Information' => 'calc_additional_info',
                                                                                        'Management Information' => 'management_information',
                                                                                        'Revenue and Leverage' => 'revenue_and_leverage',
                                                                                        'Area and Interest Cover' => 'area_and_interest_cover',
                                                                                        'Voids and Bad Debts' => 'voids_and_bad_debts',
                                                                                        'Assessment' => 'conductor_override'
                                                                                       };
                                                                       
    public static final Map<String, String> ruleModelMap = new Map<String, String>{ 'SME' => 'SME',
                                                                                    'IPRE' => 'IPRE',
                                                                                    'SH - PD' => 'SH_PD',
                                                                                    'SH - LGD' => 'SH_LGD'
                                                                                  };
                                                                                  
    public static final Map<String, String> ratingResponseModelMap = new Map<String, String>{ 'SME' => 'SME',
                                                                                    'IPRE' => 'IPRE',
                                                                                    'SH - PD' => 'SHPD',
                                                                                    'SH - LGD' => 'SHLGD'
                                                                                  };
                                                                                  
    public static string composeQueryFields(String sObjectName){
        try{
            String strFields ='Select ';
            Schema.DescribeSObjectResult objectSchema = Schema.describeSObjects(new List<String>{sObjectName})[0];
            Map<String, Schema.SObjectField> fieldMap = objectSchema.fields.getMap();
            
            Set<string> relavantRelationships = new Set<String>{'Contacts','LLC_BI__Underwriting_Bundle__r','LLC_BI__Spread_Statements__r','LLC_BI__Spread_Statement_Total_Groups__r','LLC_BI__Spread_Statement_Records1__r','LLC_BI__Spread_Statement_Record_Values__r','LLC_BI__Spread_Statement_Period__r'};
            Set<string> relavantFields = new Set<string>{'id','email','phone','name','llc_bi__value__c','llc_bi__period_key__c','llc_bi__year__c'}; 
            Map<String,Set<String>> relavantChildObjectFieldMap = new Map<String,Set<String>>();
            
            
            if(sObjectName.equalsIgnoreCase('Account') || sObjectName.equalsIgnoreCase('Ratings_Model__c')){
                strFields += 'RecordType.DeveloperName, Name, RecordType.Name, ';
            }
            else if(sObjectName.equalsIgnoreCase('LLC_BI__Spread_Statement_Record_Value__c')){
                strFields += 'LLC_BI__Spread_Statement_Record__r.LLC_BI__Spread_Statement_Type__c, LLC_BI__Spread_Statement_Record__r.Name, LLC_BI__Spread_Statement_Record__r.LLC_BI__Row_Number__c, ';
            }
            else if(sObjectName.equalsIgnoreCase('LLC_BI__Spread_Statement_Period_Total__c')){
                strFields += 'LLC_BI__Spread_Statement_Record_Total__r.LLC_BI__Spread_Statement_Type__c, LLC_BI__Spread_Statement_Record_Total__r.Name, ';
            }
            
            
            for(GeWS_Rating_Payload_Mappings__mdt mapping : [Select Id, Inactive__c, Object_Name__c, Field_Name__c, ACTICO_Item_Id__c, Type__c from  GeWS_Rating_Payload_Mappings__mdt] ){
                if(mapping.Object_Name__c.equalsIgnoreCase(sObjectName) && !strFields.containsIgnoreCase(mapping.Field_Name__c)){
                    strFields += mapping.Field_Name__c+ ', ';
                }
                else{
                    if(relavantChildObjectFieldMap.containsKey(mapping.Object_Name__c)){
                        relavantChildObjectFieldMap.get(mapping.Object_Name__c).add(mapping.Field_Name__c);
                    }
                    else{
                        relavantChildObjectFieldMap.put(mapping.Object_Name__c, new Set<String>{mapping.Field_Name__c});
                    }
                }
            }
            
            for(String fieldName : fieldMap.keyset() ){ 
                if(!strFields.containsIgnoreCase(fieldName)){
                    strFields += fieldName+ ', ';
                }
                
            }       
            
            strFields = strFields.removeEnd(', '); 
            
            String relationshipName;
            String relatonshipObjectName;
            for(ChildRelationship rel : objectSchema.getChildRelationships()){
                relationshipName = rel.getRelationshipName();
                if(relavantRelationships.contains(relationshipName)){
                    strFields += ', ( Select ';
                    for( String fieldName : rel.getChildSObject().getDescribe().fields.getMap().keyset()){
                        if(relavantFields.contains(fieldName)){                        
                            strFields += fieldName+ ', ';
                        }
                    }
                    
                    relatonshipObjectName = relationshipName.replace('__r','__c');
                    
                    if(relavantChildObjectFieldMap.containsKey(relatonshipObjectName)){
                        for(String childField : relavantChildObjectFieldMap.get(relatonshipObjectName)){
                            strFields += childField+ ', ';
                        }
                    }
                    strFields = strFields.removeEnd(', ');
                    strFields += ' from '+relationshipName+ (relationshipName.equalsIgnoreCase('LLC_BI__Spread_Statement_Period__r') ? ' order by llc_bi__year__c)' :')');
                }
            }
                 
            strFields += ' from '+sObjectName;
    
            return strFields;
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    public static Boolean checkRatingMandatoryValues(Map<String,String> valueMap, String sectionName){
        try{
            Boolean isMissing = false;
            String valueKey;
            String relavantActicoId;
            for(String acticoId : acticoIdMap.keyset()){
                List<String> acticoIdSplit = acticoId.split('\\.',-1);
                valueKey = acticoIdSplit.get(acticoIdSplit.size()-1) != null ? acticoIdSplit.get(acticoIdSplit.size()-1) : acticoId;
                relavantActicoId = String.isBlank(sectionName) ? acticoId : acticoId.containsIgnoreCase(sectionName) ? acticoId : '';
                if(String.isNotBlank(relavantActicoId) && acticoIdMap.get(relavantActicoId).Mandatory__c && valueMap.containsKey(acticoId) && valueMap.get(valueKey) == null){
                    isMissing = true;
                }
            }
            
            return isMissing;
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    public static Schema.DisplayType getRatingFieldType(String fieldName ){
        try{
            Schema.SObjectType t = Schema.getGlobalDescribe().get('Ratings_Model__c');
     
            Schema.DescribeSObjectResult r = t.getDescribe();
            Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
             
            return f.getType();
        }
        Catch(Exception exc){
            throw exc;
        }
        
    }
    
    
    public static Map<String,GeWS_Rating_Payload_Mappings__mdt> generatePayloadActicoIdMap(){
        try{
            Map<String,GeWS_Rating_Payload_Mappings__mdt> acticoIdMap = new Map<String,GeWS_Rating_Payload_Mappings__mdt>();
            String payloadMetadataQuery = GeWS_ActicoUtils.composeQueryFields('GeWS_Rating_Payload_Mappings__mdt');
            
            for(GeWS_Rating_Payload_Mappings__mdt mapping : Database.query(payloadMetadataQuery)){
                if(!mapping.Field_Name__c.equalsIgnoreCase('TBD')){
                    acticoIdMap.put(mapping.ACTICO_Item_Id__c,mapping);
                }
            }
            
            return acticoIdMap;
        }
        Catch( Exception exc ){
            throw exc;
        }
    }
    
    public static Account extractCustomerData(Id customerId){
        try{
            Contact currentContact = new Contact();
            
            String query = GeWS_ActicoUtils.composeQueryFields('Account') + ' where id = \''+customerId+'\'';
    
            Account company = Database.query(query);
    
            return company;
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    public static Map<String,Object> parseDeserialisedResponse( Map<String, Object> deserializedResponse, Boolean generateRating, Boolean financial, String ratingModelType, String sectionName, Boolean ratingResponse, Boolean statusResponse ){
        try{
            Map<String,Object> ratingsMetricsReturned = new Map<String,Object>();
            
            Map<String,Object> responseData = (Map<String,Object>)deserializedResponse.get('data');
            Map<String,Object> responseDoc = (Map<String,Object>)responseData.get('document');
            Map<String,Object> reponseRevisions = (Map<String,Object>)responseDoc.get('revisions');
            Map<String,Object> responseRevision = (Map<String,Object>)reponseRevisions.get('revision');
            Map<String,Object> responseRevisionData = (Map<String,Object>)responseRevision.get('revisionData');
            
            if(financial){
                Map<String,Object> reponseRevData = (Map<String,Object>)responseRevisionData.get('data');
                Map<String,Object> reponseReturned = (Map<String,Object>)reponseRevData.get('response');
                ratingsMetricsReturned = (Map<String,Object>)reponseReturned.get('statement');
                    
            }
            else if(generateRating){
                
                Map<String,Object> reponseReturned = (Map<String,Object>)responseRevisionData.get('response');
                Map<String,Object> ratingResponseReturned = (Map<String,Object>)reponseReturned.get(GeWS_ActicoUtils.ratingResponseModelMap.get(ratingModelType));
                
                System.debug('ratingModelType >>>>'+ratingModelType);
                System.debug('reponseReturned >>>>'+reponseReturned);
                System.debug('ratingResponseReturned >>>>'+ratingResponseReturned);
                
                if(ratingResponse){
                    
                    if(ratingModelType.containsIgnoreCase('SME')){
                        ratingsMetricsReturned = ratingResponseReturned;
                    }
                    else if(ratingModelType.containsIgnoreCase('IPRE')){
                        
                        if(GeWS_ActicoUtils.sectionKeyMap.containsKey(sectionName)){
                            Map<String,Object> responseSubjectives = (Map<String,Object>)ratingResponseReturned.get('subjectives');
                            ratingsMetricsReturned = (Map<String,Object>)responseSubjectives.get(GeWS_ActicoUtils.sectionKeyMap.get(sectionName));
                        }
                        else{
                            ratingsMetricsReturned = (Map<String,Object>)ratingResponseReturned.get('results');
                        }
                    }
                    else if(ratingModelType.containsIgnoreCase('PD') || ratingModelType.containsIgnoreCase('LGD')){
                        if(GeWS_ActicoUtils.sectionKeyMap.containsKey(sectionName)){
                            ratingsMetricsReturned = (Map<String,Object>)ratingResponseReturned.get(GeWS_ActicoUtils.sectionKeyMap.get(sectionName));
                        }
                        else{
                            ratingsMetricsReturned = (Map<String,Object>)ratingResponseReturned.get('assessment');
                        }
                    }
                }
                else if(statusResponse){
                    
                    if(ratingModelType.containsIgnoreCase('PD')){
                        ratingsMetricsReturned = (Map<String,Object>)ratingResponseReturned.get('assessment');
                        ratingsMetricsReturned.put('final_decision_ts', ratingResponseReturned.get('final_decision_ts'));
                    }
                    else{
                        ratingsMetricsReturned = ratingResponseReturned;
                    }
                }
            }
            
            return ratingsMetricsReturned;
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    
    public static void processRatingsReturnedAndStore( Ratings_Model__c ratingsRecord, Map<String,Object> ratingMetricsReceived){
        System.debug('ratingMetricsReceived >>>>'+ratingMetricsReceived);
        try{
            if(ratingMetricsReceived != null){
                for( String metricKey : ratingMetricsReceived.keySet()){
                    for( String acticoId : acticoIdMap.keyset() ){
                        List<String> acticoIdSplit = acticoId.split('\\.',-1);
                        if(acticoIdSplit.get(acticoIdSplit.size()-1) != null && acticoIdSplit.get(acticoIdSplit.size()-1).equalsIgnoreCase(metricKey)){
                            Schema.DisplayType fieldType = GeWS_ActicoUtils.getRatingFieldType(acticoIdMap.get(acticoId).Field_Name__c);
                            System.debug('acticoIdMap.get(acticoId).Field_Name__c >>>>'+acticoIdMap.get(acticoId).Field_Name__c);
                            System.debug('fieldType >>>>'+fieldType);
                            if(fieldType == Schema.DisplayType.String){
                                ratingsRecord.put(acticoIdMap.get(acticoId).Field_Name__c, String.valueOf(ratingMetricsReceived.get( metricKey )));
                            }
                            else{
                                ratingsRecord.put(acticoIdMap.get(acticoId).Field_Name__c, Double.valueOf(ratingMetricsReceived.get( metricKey )));
                            }
                        }
                    }
                }
                
                update ratingsRecord;
            }
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    public static void processStatusUpdateBatchResponses(Map<String, GeWS_ActicoUtils.StatusUpdateBatchWrapper> statusUpdateResponseMap){
        try{
            List<String> ratingIdList = new List<String>( statusUpdateResponseMap.keyset() );
            
            String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id in :ratingIdList ';
            list<Ratings_Model__c> ratingRecords = (list<Ratings_Model__c>)Database.query(ratingsRecordQuery);
            String jsonPayload;
            Map<String,Object> ratingMetricsReceived;
            List<Exception_Log__c> payloadInfoLogList = new List<Exception_Log__c>();
            
            for( Ratings_Model__c ratingRecord : ratingRecords){
                jsonPayload = statusUpdateResponseMap.get(ratingRecord.Id).statusUpdateCalloutPayload;
                ratingMetricsReceived = statusUpdateResponseMap.get(ratingRecord.Id).ratingsMetricsReturned;
                if(ratingMetricsReceived != null){
                    for( String metricKey : ratingMetricsReceived.keySet()){
                        for( String acticoId : acticoIdMap.keyset() ){
                            List<String> acticoIdSplit = acticoId.split('\\.',-1);
                            if(acticoIdSplit.get(acticoIdSplit.size()-1) != null && acticoIdSplit.get(acticoIdSplit.size()-1).equalsIgnoreCase(metricKey)){
                                Schema.DisplayType fieldType = GeWS_ActicoUtils.getRatingFieldType(acticoIdMap.get(acticoId).Field_Name__c);
                                
                                System.debug('acticoIdMap.get(acticoId).Field_Name__c >>>>'+acticoIdMap.get(acticoId).Field_Name__c);
                                System.debug('fieldType >>>>'+fieldType);
                                
                                if(fieldType == Schema.DisplayType.String){
                                    ratingRecord.put(acticoIdMap.get(acticoId).Field_Name__c, String.valueOf(ratingMetricsReceived.get( metricKey )));
                                }
                                else{
                                    ratingRecord.put(acticoIdMap.get(acticoId).Field_Name__c, Double.valueOf(ratingMetricsReceived.get( metricKey )));
                                }
                            }
                        }
                    }
                }
                payloadInfoLogList.add(new Exception_Log__c(  Class__c = 'GeWS_ActicoUtils', 
                                                              Method__c = 'processStatusUpdateBatchResponses', 
                                                              Message__c = jsonPayload, 
                                                              Priority__c = 'INFO',
                                                              Running_User__c = UserInfo.getUserName()
                                                           ));
            }
            
            update ratingRecords;
            insert payloadInfoLogList;
        }
        Catch(Exception exc){
            throw exc;
        }
        
    }
    
    
    public static void createLog(string className, String MethodName, string msg, boolean createLog, string errType){
        Exception_Log__c exceptionObj = new Exception_Log__c();
        exceptionObj.Class__c = className;
        exceptionObj.Method__c = MethodName;
        exceptionObj.Message__c = msg;
        exceptionObj.Priority__c = errType;
        exceptionObj.Running_User__c = UserInfo.getUserName();
        if(createLog && msg != ''){
            insert exceptionObj;
        }
    
    }
    
    public class StatusUpdateBatchWrapper{
        public Map<String,Object> ratingsMetricsReturned;
        public String statusUpdateCalloutPayload;
        
        public StatusUpdateBatchWrapper( Map<String,Object> ratingsMetricsReturnedArg,
                                         String statusUpdateCalloutPayloadArg ){
                                             
            this.ratingsMetricsReturned = ratingsMetricsReturnedArg;
            this.statusUpdateCalloutPayload = statusUpdateCalloutPayloadArg;
            
        }
        
    }
}