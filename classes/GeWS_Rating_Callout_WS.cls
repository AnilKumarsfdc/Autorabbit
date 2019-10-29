public with sharing class GeWS_Rating_Callout_WS {
    
    @AuraEnabled
    public static void processFinancialRatingCallout(Id ratingRecordId){
        
        Map<String,Object> ratingsMetricsReturned = new Map<String,Object>();
        String financialStatementId;
        
        try{
            String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id = \''+ratingRecordId +'\'';
            System.debug('ratingsRecordQuery >>>>'+ratingsRecordQuery);
            Ratings_Model__c ratingRecord = (Ratings_Model__c)Database.query(ratingsRecordQuery)[0];
            System.debug('ratingRecord >>>>'+ratingRecord);
            String jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractCustomerSpreadsData(ratingRecord, '');
            
            System.debug('Financial Payload >>>>'+jsonPayload);
            
            if(String.isNotBlank(jsonPayload)){
                GeWS_ActicoService_WS acticoServiceCallout = new GeWS_ActicoService_WS();
                String response = acticoServiceCallout.SendFinancialData(jsonPayload);
            
                String ratingModelType = ratingRecord.RecordType.Name ;
                
                if(ratingModelType.containsIgnoreCase('SME') || ratingModelType.containsIgnoreCase('Qualitative')){
                    ratingModelType = 'SME';
                }
                
                
                Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                System.debug('deserializedResponse >>>>'+deserializedResponse);
                
                if(deserializedResponse.containsKey('data') && !deserializedResponse.containsKey('errors')){
                    
                    financialStatementId = String.valueOf(GeWS_ActicoUtils.parseDeserialisedResponse(deserializedResponse, false, true,'','',false,false ).get( 'financial_statement_id' ));
                    
                    ratingRecord.put(GeWS_ActicoUtils.acticoIdMap.get('statement.financial_statement_id').Field_Name__c, Integer.valueOf(financialStatementId));
                    //update ratingRecord;
                    
                    jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractPayloadData( ratingRecord, 'Total', ratingModelType , true, false, financialStatementId, true);
                    
                    System.debug('Rating Serial Payload >>>>'+jsonPayload);
                    
                    if(String.isNotBlank(jsonPayload)){
                        retreiveAndStoreRating(jsonPayload, ratingRecord, ratingModelType, 'Total');
                    }
                }
                else{
                    CalloutException calloutExp = new CalloutException();
                    calloutExp.setMessage('Financial Callout did not go through.');
                    throw calloutExp; 
                }
                
                
            }
        }
        Catch(Exception exc){
            System.debug('exc.getStackTraceString() >>>>'+exc.getStackTraceString());
            GeWS_ActicoUtils.createLog('GeWS_Rating_Callout_WS', 'processFinancialRatingCallout', exc.getMessage(), true, 'ERROR');
        }
    }
    
    @AuraEnabled
    public static void processRatingsCallout(Id ratingRecordId, String sectionName){
        
        Map<String,Object> ratingsMetricsReturned = new Map<String,Object>();
        
        String jsonPayload;
        
        try{
        
            String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id = \''+ratingRecordId +'\'';
            Ratings_Model__c ratingRecord = (Ratings_Model__c)Database.query(ratingsRecordQuery)[0];
            
            
            String ratingModelType = ratingRecord.RecordType.Name ;
            
            if(ratingModelType.containsIgnoreCase('SME') || ratingModelType.containsIgnoreCase('Qualitative')){
                ratingModelType = 'SME';
            }
            
            if(ratingModelType.containsIgnoreCase('PD')){
                String financialStatementId;
                jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractCustomerSpreadsData(ratingRecord, sectionName);
                
                System.debug('Financial Payload >>>>'+jsonPayload);
                
                if(String.isNotBlank(jsonPayload)){
                    GeWS_ActicoService_WS acticoServiceCallout = new GeWS_ActicoService_WS();
                    String response = acticoServiceCallout.SendFinancialData(jsonPayload);
                    
                    
                    Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                    System.debug('deserializedResponse >>>>'+deserializedResponse);
                    
                    if(deserializedResponse.containsKey('data') && !deserializedResponse.containsKey('errors')){
                        
                        financialStatementId = String.valueOf(GeWS_ActicoUtils.parseDeserialisedResponse(deserializedResponse, false, true,'','',false,false ).get( 'financial_statement_id' ));
                        jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractPayloadData( ratingRecord, sectionName, ratingModelType , true, false, financialStatementId, true);
                        
                        
                        System.debug('PD Rating Serial Payload >>>>'+jsonPayload);
                        
                        if(String.isNotBlank(jsonPayload)){
                            retreiveAndStoreRating(jsonPayload, ratingRecord, ratingModelType, sectionName);
                        }
                    }
                    else{
                        CalloutException calloutExp = new CalloutException();
                        calloutExp.setMessage('Financial Callout did not go through.');
                        throw calloutExp; 
                    }
                }
            }
            else{
                jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractPayloadData( ratingRecord, sectionName, ratingModelType, true, false, '', false);
                
                System.debug('Rating Payload >>>>'+jsonPayload);
                
                if(String.isNotBlank(jsonPayload)){
                    retreiveAndStoreRating(jsonPayload, ratingRecord, ratingModelType, sectionName);
                }
            }
        }
        Catch(Exception exc){
            System.debug('exc.getStackTraceString() >>>>'+exc.getStackTraceString());
            GeWS_ActicoUtils.createLog('GeWS_Rating_Callout_WS', 'processRatingsCallout', exc.getMessage(), true, 'ERROR');
        }
    }
    
    public static GeWS_ActicoUtils.StatusUpdateBatchWrapper processStatusUpdateCallout(GeDM_Batch_Transaction__c batchTransactionRecord){
        GeWS_ActicoUtils.StatusUpdateBatchWrapper statusUpdateWrap; 
        Map<String,Object> ratingsMetricsReturned = new Map<String,Object>();
        String jsonPayload;
        
        try{
        
            String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id = \''+batchTransactionRecord.Parent_Record_Id__c +'\'';
    
            Ratings_Model__c ratingRecord = (Ratings_Model__c)Database.query(ratingsRecordQuery)[0];
            
            jsonPayload = GeWS_Rating_PayloadGenerator_WS.extractPayloadData(ratingRecord, '', ratingRecord.RecordType.Name, false, true, '', false);
            
            System.debug('jsonPayload >>>>'+jsonPayload);
            
            if(String.isNotBlank(jsonPayload)){
                
                GeWS_ActicoService_WS acticoServiceCallout = new GeWS_ActicoService_WS();
                String response = acticoServiceCallout.SendStatusUpdateData(jsonPayload);
                
                batchTransactionRecord.Request_Payload_Sent__c = jsonPayload;
                
                if(String.isNotBlank(response)){
                    batchTransactionRecord.Is_Batch_Successful__c = true;
                }
                
                Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                System.debug('deserializedResponse >>>>'+deserializedResponse);
                
                if(deserializedResponse.containsKey('data') && !deserializedResponse.containsKey('errors')){
                
                    ratingsMetricsReturned = GeWS_ActicoUtils.parseDeserialisedResponse(deserializedResponse, true, false, ratingRecord.RecordType.Name, '', false, true);
                
                }
                
                statusUpdateWrap = new GeWS_ActicoUtils.StatusUpdateBatchWrapper(ratingsMetricsReturned, jsonPayload);
            }
            
            return statusUpdateWrap;
        }
        Catch(Exception exc){
            new Exception_Log__c(  Class__c = 'GeWS_Rating_Callout_WS', 
                                   Method__c = 'processStatusUpdateCallout', 
                                   Message__c = 'Batch record with Id :'+batchTransactionRecord.Id+' for parent rating record with Id: '+batchTransactionRecord.Parent_Record_Id__c+' failed. \n'+exc.getMessage(), 
                                   Priority__c = 'ERROR',
                                   Running_User__c = UserInfo.getUserName()
                                );
            return null;
        }
    }
    
    public static void retreiveAndStoreRating( String jsonPayload,  Ratings_Model__c ratingRecord, String ratingModelType, String sectionName){
        try{
            GeWS_ActicoService_WS acticoServiceCallout = new GeWS_ActicoService_WS();
            String response = acticoServiceCallout.SendRatingsData(jsonPayload);
            
            Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
            System.debug('deserializedResponse >>>>'+deserializedResponse);
            
            if(deserializedResponse.containsKey('data') && !deserializedResponse.containsKey('errors')){
                
                GeWS_ActicoUtils.processRatingsReturnedAndStore(ratingRecord, GeWS_ActicoUtils.parseDeserialisedResponse(deserializedResponse, true, false, ratingModelType, sectionName, true, false));
            
            }
        }
        Catch(Exception exc){
            throw exc;
        }
    }
    
    
}