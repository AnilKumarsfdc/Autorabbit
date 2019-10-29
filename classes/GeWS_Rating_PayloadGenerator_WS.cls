public class GeWS_Rating_PayloadGenerator_WS {
    
    public static final Map<String,GeWS_Rating_Payload_Mappings__mdt> acticoIdMap = GeWS_ActicoUtils.generatePayloadActicoIdMap();
    
    public static string extractCustomerSpreadsData(Ratings_Model__c ratingRecord, String sectionName){
        try{
            String financialTemplateName;
            Map<String,String> metaInfoMap = new Map<String,String>();
            Map<String, String> generalInfoMap = new Map<String, String>();
            Map<String, String> financialStatementInfoMap = new Map<String, String>();
            Map<String, GeWS_Rating_Payload_Mappings__mdt> shpdFinancialAttributes = new Map<String, GeWS_Rating_Payload_Mappings__mdt>();
            
            
            Map<String,String> spreadDataValueMap = new Map<String,String>();
            List<GeWS_Financial_Wrapper.Spreads_Record_Value>  spreadRecordValues = new List<GeWS_Financial_Wrapper.Spreads_Record_Value>();
            Map<String,List<GeWS_Financial_Wrapper.Spreads_Record_Value>> sheetDataMap = new Map<String,List<GeWS_Financial_Wrapper.Spreads_Record_Value>>();
            List<GeWS_Financial_Wrapper.Spreads_Data>  spreadData = new List<GeWS_Financial_Wrapper.Spreads_Data>();
            
            for(String acticoIdString : acticoIdMap.keyset()){
               
                
                List<String> fieldRoute = acticoIdMap.get(acticoIdString).Field_Name__c.split('\\.',-1);
                List<String> acticoIdSplit = acticoIdString.split('\\.',-1);
        
                if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('General_Info')){
                    String ratingValue = fieldRoute.size() > 1 ? ( ratingRecord.getSObject(fieldRoute.get(0)) != null ? String.valueOf(ratingRecord.getSObject(fieldRoute.get(0)).get(fieldRoute.get(1))) : null ) : String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                    if(String.isNotBlank(ratingValue)){
                        generalInfoMap.put(acticoIdSplit.get(acticoIdSplit.size()-1), ratingValue);
                    }  
                    //generalInfoMap.put(acticoIdString, String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c)));
                }
                
                if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('Financial_SHPD')){
                    shpdFinancialAttributes.put(acticoIdString, acticoIdMap.get(acticoIdString));
                }
            }
            
            if(String.isBlank(sectionName)){
                Account currentCustomer;
                
                if(ratingRecord.SME_Company_Spreads__c != null){
                    currentCustomer = GeWS_ActicoUtils.extractCustomerData(ratingRecord.SME_Company_Spreads__c);
                }
                else{
                    currentCustomer = GeWS_ActicoUtils.extractCustomerData(ratingRecord.Company__c);
                }
                
                Map<String,GeWS_Financial_Setting__mdt> acticoIdKeyMap = new Map<String,GeWS_Financial_Setting__mdt>();
                Set<String> spreadTemplates = new Set<String>();
                Set<String> spreadUnderwritingBundles = new Set<String>();
                Set<String> spreadRecordNames = new Set<String>();  
                Set<String> valuesFromPeriodTot = new Set<String>();
                Set<String> valuesFromRecordVal = new Set<String>();
                
                Set<Id> currentSpreadTemplateIds = new Set<Id>();
                
                String financialMetadataQuery = GeWS_ActicoUtils.composeQueryFields('GeWS_Financial_Setting__mdt');
                
                for(GeWS_Financial_Setting__mdt mapping : Database.query(financialMetadataQuery)){
                    if(!mapping.Sheet_Technical_Name__c.equalsIgnoreCase('TBD')){
                        acticoIdKeyMap.put(mapping.Record_Name__c,mapping);
                        spreadUnderwritingBundles.add(mapping.Underwriting_Bundle_Name__c);
                        spreadTemplates.add(mapping.Spreads_Statement_Template__c);
                        if(mapping.Value_Object_Name__c.equalsIgnoreCase('LLC_BI__Spread_Statement_Record_Value__c')){
                            valuesFromRecordVal.add(mapping.Record_Name__c);
                        }
                        else if(mapping.Value_Object_Name__c.equalsIgnoreCase('LLC_BI__Spread_Statement_Period_Total__c')){
                            valuesFromPeriodTot.add(mapping.Record_Name__c);
                        }
                    }
                }
                
                
                LLC_BI__Underwriting_Bundle__c currentUnderwritingBundle = (LLC_BI__Underwriting_Bundle__c)currentCustomer.getSObjects('LLC_BI__Underwriting_Bundle__r')[0];
                
                LLC_BI__Spread_Statement_Period__c latestStatementPeriod =  (LLC_BI__Spread_Statement_Period__c)Database.query(GeWS_ActicoUtils.composeQueryFields('LLC_BI__Spread_Statement_Period__c') + ' where Id = \''+ratingRecord.Spread_Statement_Period__c+'\'')[0];
                
                String templateQuery = GeWS_ActicoUtils.composeQueryFields('LLC_BI__Spread_Statement_Type__c') + ' where LLC_BI__Bundle__r.LLC_BI__Relationship__c = \''+currentCustomer.Id +'\' and LLC_BI__Type__c in :spreadTemplates';
        
                for( LLC_BI__Spread_Statement_Type__c template : Database.query(templateQuery)){
                    currentSpreadTemplateIds.add(template.Id);
                }   
                
                String fieldValue;
                for(String acticoIdString : acticoIdMap.keyset()){
                   
                    
                    List<String> fieldRoute = acticoIdMap.get(acticoIdString).Field_Name__c.split('\\.',-1);
                    List<String> acticoIdSplit = acticoIdString.split('\\.',-1);
                    if(acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Financial_Info')){
                        
                        if( acticoIdSplit.size() == 3 ){
                        
                            String metaInfoKey = acticoIdSplit.get(1);  
                            String acticoId = acticoIdSplit.get(2);     
                            
                            fieldValue = (acticoIdMap.get(acticoIdString).Object_Name__c.equalsIgnoreCase('LLC_BI__Underwriting_Bundle__c')  && currentUnderwritingBundle.get(acticoIdMap.get(acticoIdString).Field_Name__c) != null ) ? String.valueOf(currentUnderwritingBundle.get(acticoIdMap.get(acticoIdString).Field_Name__c)) : ( acticoIdMap.get(acticoIdString).Object_Name__c.equalsIgnoreCase('LLC_BI__Spread_Statement_Period__c') && latestStatementPeriod.get(acticoIdMap.get(acticoIdString).Field_Name__c) != null ) ? String.valueOf(latestStatementPeriod.get(acticoIdMap.get(acticoIdString).Field_Name__c)) : null;
                            
                            if(String.isNotBlank(fieldValue)){
                                metaInfoMap.put(acticoId, fieldValue);
                            }
                        }
                        else if( acticoIdSplit.size() == 2 ){
                            financialStatementInfoMap.put(acticoIdSplit.get(1), String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c)));
                        }
                    }
                    
                }
                
                String spreadsRecordValueQuery = GeWS_ActicoUtils.composeQueryFields('LLC_BI__Spread_Statement_Record_Value__c') + ' where LLC_BI__Spread_Statement_Record__r.Name in :valuesFromRecordVal and LLC_BI__Spread_Statement_Record__r.LLC_BI__Spread_Statement_Type__c in :currentSpreadTemplateIds and LLC_BI__Spread_Statement_Period__r.LLC_BI__Year__c ='+latestStatementPeriod.LLC_BI__Year__c;
                
                
                for( LLC_BI__Spread_Statement_Record_Value__c recordValue : Database.query(spreadsRecordValueQuery)){
                    if(acticoIdKeyMap.containsKey(recordValue.LLC_BI__Spread_Statement_Record__r.Name)){
                        spreadDataValueMap.put(recordValue.LLC_BI__Spread_Statement_Record__r.Name,String.valueOf(recordValue.llc_bi__value__c));
                    }
                }
                
                String spreadsPeriodTotalComposeQueryFields = GeWS_ActicoUtils.composeQueryFields('LLC_BI__Spread_Statement_Period_Total__c') + ' where LLC_BI__Spread_Statement_Record_Total__r.Name in :valuesFromPeriodTot and LLC_BI__Spread_Statement_Record_Total__r.LLC_BI__Spread_Statement_Type__c in :currentSpreadTemplateIds and LLC_BI__Spread_Statement_Period__r.LLC_BI__Year__c ='+latestStatementPeriod.LLC_BI__Year__c;
                
                for( LLC_BI__Spread_Statement_Period_Total__c periodTotal : Database.query(spreadsPeriodTotalComposeQueryFields)){
                    if(acticoIdKeyMap.containsKey(periodTotal.LLC_BI__Spread_Statement_Record_Total__r.Name)){
                        spreadDataValueMap.put(periodTotal.LLC_BI__Spread_Statement_Record_Total__r.Name,String.valueOf(periodTotal.llc_bi__value__c));
                    }
                }
                
                for(String attribute : spreadDataValueMap.keySet()){    
                    
                    if(sheetDataMap.containsKey(acticoIdKeyMap.get(attribute).Sheet_Technical_Name__c)){
                        sheetDataMap.get(acticoIdKeyMap.get(attribute).Sheet_Technical_Name__c).add(new GeWS_Financial_Wrapper.Spreads_Record_Value(acticoIdKeyMap.get(attribute).Technical_Key__c, null, null, acticoIdKeyMap.get(attribute).Is_Negative__c ? '-'+spreadDataValueMap.get(attribute) : spreadDataValueMap.get(attribute), null, null, null));
                    }
                    else{
                        sheetDataMap.put(acticoIdKeyMap.get(attribute).Sheet_Technical_Name__c, new List<GeWS_Financial_Wrapper.Spreads_Record_Value>{new GeWS_Financial_Wrapper.Spreads_Record_Value(acticoIdKeyMap.get(attribute).Technical_Key__c, null, null, acticoIdKeyMap.get(attribute).Is_Negative__c ? '-'+spreadDataValueMap.get(attribute) : spreadDataValueMap.get(attribute), null, null, null)});
                    }
                }
                
                for(String sheetName : sheetDataMap.keySet()){
                    spreadData.add(new GeWS_Financial_Wrapper.Spreads_Data(sheetName,new GeWS_Financial_Wrapper.Spreads_Record_Element(sheetDataMap.get(sheetName))));
                }
                
                if( sheetDataMap.isEmpty() || sheetDataMap.values().isEmpty() ){
                    NoDataFoundException noDataExp = new NoDataFoundException();
                    noDataExp.setMessage('Spreads Statement Sheets do not have data');
                    throw noDataExp;
                }
                
                /*
                if(GeWS_ActicoUtils.checkRatingMandatoryValues(metaInfoMap, '') || GeWS_ActicoUtils.checkRatingMandatoryValues(financialStatementInfoMap, '') || GeWS_ActicoUtils.checkRatingMandatoryValues(generalInfoMap, '')){
                    NoDataFoundException noDataExp = new NoDataFoundException();
                    noDataExp.setMessage('Required Fields missing ! Please fill all mandatory details and try again.');
                    throw noDataExp; 
                }*/
            }
            
            else{
                for( String acticoIdString : shpdFinancialAttributes.keyset() ){
                    spreadDataValueMap.put(acticoIdString,string.ValueOf(ratingRecord.get(shpdFinancialAttributes.get(acticoIdString).Field_Name__c)));
                }
                
                for(String acticoIdString : spreadDataValueMap.keyset()){
                    if(sheetDataMap.containsKey('SHPD')){
                        sheetDataMap.get('SHPD').add(new GeWS_Financial_Wrapper.Spreads_Record_Value(acticoIdString, null, null, spreadDataValueMap.get(acticoIdString), null, null, null));
                    }
                    else{
                        sheetDataMap.put('SHPD', new List<GeWS_Financial_Wrapper.Spreads_Record_Value>{new GeWS_Financial_Wrapper.Spreads_Record_Value(acticoIdString, null, null, spreadDataValueMap.get(acticoIdString), null, null, null)});
                    }
                }
                
                spreadData.add(new GeWS_Financial_Wrapper.Spreads_Data('SHPD',new GeWS_Financial_Wrapper.Spreads_Record_Element(sheetDataMap.get('SHPD'))));
                
            }
            
            if(String.isNotBlank(sectionName)){
                financialTemplateName = 'SH_PD Spreading Template';
            }
            else{
                financialTemplateName = financialStatementInfoMap.get('template_name');
            }
            
            
            GeWS_Financial_Wrapper.Spreads_Statement spreadsStatement = new GeWS_Financial_Wrapper.Spreads_Statement(metaInfoMap,financialTemplateName,financialStatementInfoMap.get('target_state'),new GeWS_Financial_Wrapper.Spreads_Data_Element(spreadData), null, null );
            GeWS_Financial_Wrapper.Financial_Request finiancialRequest = new GeWS_Financial_Wrapper.Financial_Request(generalInfoMap.get('ncino_process_id'), generalInfoMap.get('bdp_id'), generalInfoMap.get('test_flag'), spreadsStatement );
            GeWS_Financial_Wrapper.Financial_Data financialData = new GeWS_Financial_Wrapper.Financial_Data(finiancialRequest);
            GeWS_Financial_Wrapper.Financial_Request_Data financialReqData = new GeWS_Financial_Wrapper.Financial_Request_Data(financialData);
            GeWS_Financial_Wrapper.Financial_Request_Wrap financialReqWrap = new GeWS_Financial_Wrapper.Financial_Request_Wrap(generalInfoMap.get('event'),generalInfoMap.get('id'),generalInfoMap.get('referenceId'), financialReqData);
            GeWS_Financial_Wrapper.Financial_Request_Payload financialReqPayload = new GeWS_Financial_Wrapper.Financial_Request_Payload(financialReqWrap);
            
            String jsonPayload = JSON.serializePretty(financialReqPayload, true );
            
            return jsonPayload;
        
        }
        
        catch(Exception exc){
            System.debug('exc.getMessage() >>>>'+exc.getMessage());
            throw exc; 
        }
        
    }
    
    public static string extractPayloadData(Ratings_Model__c ratingRecord, String sectionName, String ratingModel, Boolean isRatingRequestCallout, Boolean isRatingStatusUpdateCallout, String financialStatementId, Boolean isQuantitative ){
        
        Map<String, Map<String,String>> smeSubjectiveMap = new Map<String, Map<String,String>>();
        Map<String, Map<String,String>> payloadAttributesMap = new Map<String, Map<String,String>>();
        Map<String, String> generalInfoMap = new Map<String, String>();
        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> industryCodeMap = new Map<String, String>();
        Map<String, String> ratingConductorMap = new Map<String, String>();
        Map<String, String> ratingApproverMap = new Map<String, String>();
        Map<String, String> financialInfoMap = new Map<String, String>();
        Map<String,String> manualRatingMap = new Map<String,String>();
        GeWS_Ratings_Wrapper.SME_Wrap smeCollection;
        GeWS_Ratings_Wrapper.IPRE_Wrap ipreCollection;
        GeWS_Ratings_Wrapper.SHPD_Wrap shpdCollection;
        GeWS_Ratings_Wrapper.SHLGD_Wrap shlgdCollection;
        
        try{
            String action;
            
            String fieldValue;
            
            for(String acticoIdString : acticoIdMap.keyset()){
                String sectionKey;
                String acticoId;
                String categoryKey;
                String manualRatingKey;
                
                List<String> fieldRoute = acticoIdMap.get(acticoIdString).Field_Name__c.split('\\.',-1);
                List<String> acticoIdSplit = acticoIdString.split('\\.',-1);
                
                if(isRatingRequestCallout){
                    if(ratingModel.containsIgnoreCase('SME') && !isQuantitative){
                        if(acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Subjective_SME')){
                            categoryKey = acticoIdSplit.get(2);
                            acticoId = acticoIdSplit.get(3);
                            fieldValue = String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                            if(String.isNotBlank(fieldValue)){
                                if(smeSubjectiveMap.containsKey(categoryKey)){
                                    smeSubjectiveMap.get(categoryKey).put(acticoId, fieldValue);
                                }
                                else{
                                    smeSubjectiveMap.put(categoryKey, new Map<String,String>{ acticoId => fieldValue } );
                                }
                            }
                        }
                        if(acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Manual_Rating')){
                            manualRatingKey = acticoIdSplit.get(1);
                            acticoId = acticoIdSplit.get(2);
                            
                            fieldValue = String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                            if(String.isNotBlank(fieldValue)){
                                manualRatingMap.put(acticoId, fieldValue);
                                
                            }
                        }
                        
                        if( manualRatingMap.size() > 0){
                            action = 'manual';
                            smeSubjectiveMap.clear();
                        }
                        else{
                            action = 'indicative';
                        }
                    }
                
                    else if(!isQuantitative && ( (ratingModel.containsIgnoreCase('IPRE') && acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Subjective_IPRE')) || (ratingModel.containsIgnoreCase('PD') && acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Attribute_SHPD')) || (ratingModel.containsIgnoreCase('LGD') && acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Attribute_SHLGD') ) ) ){
                        
                        if(acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Subjective_IPRE')){   
                            sectionKey = acticoIdSplit.get(2);
                            acticoId = acticoIdSplit.get(3);
                        }
                        else if(acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Attribute_SHPD') || acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Attribute_SHLGD')){
                            if( acticoIdSplit.size() == 3 ){
                                sectionKey = acticoIdSplit.get(1);
                                acticoId = acticoIdSplit.get(2);
                            }
                            else if( acticoIdSplit.size() == 2 ){
                                sectionKey = sectionName;
                                acticoId = acticoIdSplit.get(1);
                            }
                        } 
                        
                        fieldValue = String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                        if(String.isNotBlank(fieldValue) && ( (GeWS_ActicoUtils.sectionKeyMap.containsKey(sectionName) && sectionKey.containsIgnoreCase(GeWS_ActicoUtils.sectionKeyMap.get(sectionName))) || sectionName.equalsIgnoreCase('Total') ) && !acticoId.containsIgnoreCase('approve')){
                            if(payloadAttributesMap.containsKey(sectionKey)){ 
                                payloadAttributesMap.get(sectionKey).put(acticoId, fieldValue);
                            }
                            else{
                                payloadAttributesMap.put(sectionKey, new Map<String,String>{ acticoId => fieldValue } );
                            }
                        }
                        
                        if(sectionName.equalsIgnoreCase('Total')){
                            if(ratingModel.containsIgnoreCase('IPRE') ){
                                action = 'calc_auto_rating';
                            }
                            else if(ratingModel.containsIgnoreCase('PD') ){
                                action = 'calculate_rating';
                            }
                            else if(ratingModel.containsIgnoreCase('LGD') ){
                                action = 'calc_LGD';
                            }
                        }
                        else{
                            action = GeWS_ActicoUtils.sectionActionMap.get(sectionName);
                        }
                    }
                }
                
                else if( isRatingStatusUpdateCallout && ratingModel.containsIgnoreCase('PD') && acticoIdMap.get(acticoIdString).Type__c.containsIgnoreCase('Attribute_SHPD') ) {
                    sectionKey = acticoIdSplit.get(1);
                    acticoId = acticoIdSplit.get(2);
                    
                    fieldValue = String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                    
                    if(String.isNotBlank(fieldValue) && sectionKey.equalsIgnoreCase('assessment') && acticoId.startsWithIgnoreCase('approver')){
                        if(payloadAttributesMap.containsKey(sectionKey)){
                            payloadAttributesMap.get(sectionKey).put(acticoId, fieldValue);
                        }
                        else{
                            payloadAttributesMap.put(sectionKey, new Map<String,String>{ acticoId => fieldValue } );
                        }
                    }
                }
                
                if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('General_Info')){
                    String ratingValue = fieldRoute.size() > 1 ? ( ratingRecord.getSObject(fieldRoute.get(0)) != null ? String.valueOf(ratingRecord.getSObject(fieldRoute.get(0)).get(fieldRoute.get(1))) : null ) : String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                    if(String.isNotBlank(ratingValue)){
                        generalInfoMap.put(acticoIdSplit.get(acticoIdSplit.size()-1), ratingValue);
                    }
                    //generalInfoMap.put(acticoIdSplit.size() > 1 ? acticoIdSplit.get(1) : acticoIdString, String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c)));
                }
                
                else if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('Financial_Info')){
                    if(acticoIdSplit.size() == 2){
                        financialInfoMap.put(acticoIdSplit.get(1), String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c)));
                    }
                }
                
                else if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('Rating_Conductor') && isRatingRequestCallout ){
                    
                    String ratingValue = fieldRoute.size() > 1 ? ( ratingRecord.getSObject(fieldRoute.get(0)) != null ? String.valueOf(ratingRecord.getSObject(fieldRoute.get(0)).get(fieldRoute.get(1))) : null ) : String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                    if(String.isNotBlank(ratingValue)){
                        ratingConductorMap.put(acticoIdSplit.get(acticoIdSplit.size()-1), ratingValue);
                    }
                }
                else if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('Rating_Approver') && isRatingStatusUpdateCallout ){
                    
                    String ratingValue = fieldRoute.size() > 1 ? ( ratingRecord.getSObject(fieldRoute.get(0)) != null ? String.valueOf(ratingRecord.getSObject(fieldRoute.get(0)).get(fieldRoute.get(1))) : null ) : String.valueOf(ratingRecord.get(acticoIdMap.get(acticoIdString).Field_Name__c));
                    if(String.isNotBlank(ratingValue)){
                        ratingApproverMap.put(acticoIdSplit.get(acticoIdSplit.size()-1), ratingValue);
                    }
                }
                else if(acticoIdMap.get(acticoIdString).Type__c.equalsIgnoreCase('Industry_Code')){
                    
                    String industryValue = ratingRecord.getSObject(fieldRoute.get(0)) != null && ratingRecord.getSObject(fieldRoute.get(0)).getSObject(fieldRoute.get(1)) != null ? String.valueOf(ratingRecord.getSObject(fieldRoute.get(0)).getSObject(fieldRoute.get(1)).get(fieldRoute.get(2))) : null;
                    if(String.isNotBlank(industryValue)){
                        industryCodeMap.put(acticoIdSplit.get(acticoIdSplit.size()-1), industryValue);
                    }    
                }
            }    
            
            if( isRatingRequestCallout ){
            
                if(ratingModel.containsIgnoreCase('SME')){
                    smeCollection = new GeWS_Ratings_Wrapper.SME_Wrap(String.isNotBlank(financialStatementId) ? financialStatementId : generalInfoMap.get('financial_statement_id'), industryCodeMap.keySet().size() > 0 ? industryCodeMap : null, smeSubjectiveMap.keySet().size() > 0 ? smeSubjectiveMap : null, manualRatingMap.keySet().size() > 0 ? manualRatingMap : null, generalInfoMap.get('group_id'));
                }
                else if(ratingModel.containsIgnoreCase('IPRE')){
                    ipreCollection = new GeWS_Ratings_Wrapper.IPRE_Wrap(String.isNotBlank(financialStatementId) ? financialStatementId : generalInfoMap.get('financial_statement_id'), generalInfoMap.get('group_id'), generalInfoMap.get('krg_id'), generalInfoMap.get('acm_customer_id'), payloadAttributesMap.keySet().size() > 0 ? payloadAttributesMap : null);
                }
                else if(ratingModel.containsIgnoreCase('PD')){
                    shpdCollection = new GeWS_Ratings_Wrapper.SHPD_Wrap(String.isNotBlank(financialStatementId) ? financialStatementId : generalInfoMap.get('financial_statement_id'), generalInfoMap.get('impersonal_or_indicative_pd'), generalInfoMap.get('guarantor'), generalInfoMap.get('direct_borrower'), generalInfoMap.get('business_plan_approval'), generalInfoMap.get('charity_status'), payloadAttributesMap.get('area_and_interest_cover'),payloadAttributesMap.get('mgmt_info'),payloadAttributesMap.get('rev_and_lev'),payloadAttributesMap.get('voids_and_bad_debts'),payloadAttributesMap.get('assessment'));
                }
                else if(ratingModel.containsIgnoreCase('LGD')){
                    shlgdCollection = new GeWS_Ratings_Wrapper.SHLGD_Wrap(String.isNotBlank(financialStatementId) ? financialStatementId : generalInfoMap.get('financial_statement_id'), generalInfoMap.get('counterparty_name'), generalInfoMap.get('impersonal_or_indicativePD_or_personal'), generalInfoMap.get('guarantor'), generalInfoMap.get('business_plan_approval'), generalInfoMap.get('charity_status'), payloadAttributesMap.get('facility'), payloadAttributesMap.get('assessment'));
                }
            }
            else if( isRatingStatusUpdateCallout ){
                if(ratingModel.containsIgnoreCase('SME')){
                    smeCollection = new GeWS_Ratings_Wrapper.SME_Wrap( generalInfoMap.get('proposed_adjustment_comment'), generalInfoMap.get('proposed_adjustment'), generalInfoMap.get('final_rating'), generalInfoMap.get('override_reason'));
                }
                else if(ratingModel.containsIgnoreCase('IPRE')){
                    ipreCollection = new GeWS_Ratings_Wrapper.IPRE_Wrap(generalInfoMap.get('proposed_adjustment'), generalInfoMap.get('proposed_adjustment_comment'), generalInfoMap.get('override_rating'), generalInfoMap.get('override_comment') );
                }
                else if(ratingModel.containsIgnoreCase('PD')){
                    shpdCollection = new GeWS_Ratings_Wrapper.SHPD_Wrap(payloadAttributesMap.get('assessment'));
                }
                
                action = 'accept';
            }
            
            
            GeWS_Ratings_Wrapper.Request_Wrap ratingRequestWrap = new GeWS_Ratings_Wrapper.Request_Wrap(generalInfoMap.get('ncino_process_id'), isRatingRequestCallout ? GeWS_ActicoUtils.ruleModelMap.get(ratingModel) : null,action, isRatingStatusUpdateCallout ? generalInfoMap.get('rating_id') : null,generalInfoMap.get('test_flag'), isRatingRequestCallout ? generalInfoMap.get('bdp_id') : null, isRatingStatusUpdateCallout ? ratingApproverMap : null, isRatingStatusUpdateCallout ? generalInfoMap.get('approval_comment') : null, isRatingStatusUpdateCallout && ratingModel.containsIgnoreCase('SME') ? generalInfoMap.get('cascade_to_group') : null, isRatingStatusUpdateCallout && ratingModel.containsIgnoreCase('SME') ? new GeWS_Ratings_Wrapper.cascade_bdp_element(new List<String>()) : null, isRatingRequestCallout ? ratingConductorMap : null, smeCollection, ipreCollection, shpdCollection, shlgdCollection);
            GeWS_Ratings_Wrapper.Request_Data_Wrap ratingRequestData = new GeWS_Ratings_Wrapper.Request_Data_Wrap(ratingRequestWrap);
            GeWS_Ratings_Wrapper.Rating_Request ratingRequest = new GeWS_Ratings_Wrapper.Rating_Request(generalInfoMap.get('event_id'), generalInfoMap.get('id'),generalInfoMap.get('referenceId'), ratingRequestData);
            GeWS_Ratings_Wrapper.Ratings_Request_Payload ratingRequestPayload = new GeWS_Ratings_Wrapper.Ratings_Request_Payload(isRatingRequestCallout ? ratingRequest : null, isRatingStatusUpdateCallout ? ratingRequest : null );
            
            String jsonPayload = JSON.serializePretty(ratingRequestPayload, true );
            
            return jsonPayload;
        }
        
        catch(Exception exc){
            System.debug('exc.getMessage() >>>>'+exc.getMessage());
            System.debug('exc.getStackTraceString() >>>>'+exc.getStackTraceString());
            throw exc; 
        }
    }
    
}