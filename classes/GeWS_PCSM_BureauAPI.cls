/****************************************************************
* @Author: Alagar
* @Class: GeWS_PCSMautoDecision
* @Description: This is a Util class for PCSM API's
*****************************************************************/
public class GeWS_PCSM_BureauAPI{
    
    public static Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings { get; set; }
    
    public static string generatePayload(List<Id> companyIds, Boolean isBureauCallOnly){
        
        //field mappings from metadata types
        fieldMappings = GeWS_PCSM_Utility.metadataMapping();
        
        Map<Id,List<Id>> accWithContactMap = new Map<Id,List<Id>>();
        Set<Id> conIds = new Set<Id>();
        Map<Id,Map<String,String>> accountInfo = new Map<Id,Map<String,String>>();
        Map<Id,Id> bdpWithSFaccountIdMap = new Map<Id,Id>();
        Map<Id,String> contactWithFnumber = new Map<Id,String>();
        
        //Pull the director Ids for the customers
        for(BDP_Contact_Relationship__c bdpRel: [Select Id,BDP_Company__c, BDP_Company__r.Company__c, BDP_Company__r.Company__r.Legal_Status__c, 
                                                        BDP_Company__r.Company__r.Company_Registration_Number__c,BDP_Company__r.BDP_Customer_Number__c,BDP_Company__r.Company__r.JFNumber__c,
                                                        BDP_Contact__c,BDP_Contact__r.F_Number__c from BDP_Contact_Relationship__c 
                                                        where BDP_Company__r.Company__c IN:companyIds ]){ //AND Role__c='Director'
            
             if(accWithContactMap.containsKey(bdpRel.BDP_Company__c) ){
            
                List<Id> contactList = accWithContactMap.get(bdpRel.BDP_Company__c);
                contactList.add( bdpRel.BDP_Contact__c );
                
                accWithContactMap.put( bdpRel.BDP_Company__c, contactList );
                
            }else{                 
                accWithContactMap.put(bdpRel.BDP_Company__c, new List<String> { bdpRel.BDP_Contact__c } );
            }
            
            if( !accountInfo.containsKey( bdpRel.BDP_Company__c) ){
                accountInfo.put( bdpRel.BDP_Company__c, customerInfo(bdpRel));
            }
            
            contactWithFnumber.put(bdpRel.BDP_Contact__c, bdpRel.BDP_Contact__r.F_Number__c );
            conIds.add(bdpRel.BDP_Contact__c);
            bdpWithSFaccountIdMap.put( bdpRel.BDP_Company__c,bdpRel.BDP_Company__r.Company__c);
        }
        
        System.debug( 'Account with contacts --> '+ accWithContactMap );
        System.debug( 'Account Info --> '+ accountInfo );
        
        //Payload for director personal info & address
        Map<Id,Map<String,String>> directorInfo = new Map<Id,Map<String,String>>();
        Map<Id,String> directorInfoMap = new Map<Id,String>();
        for(BDP_Contact__c bdpCon: [Select Id,Name,Country_of_Residence__c,Is_UK_Resident__c,Accommodation_Status__c,F_Number__c,Annual_Income__c, Salesforce_Contact__r.Accommodation_Status__c,
                                            Gender__c,Date_of_Birth__c,Alias__c,Last_Name__c,Middle_Name__c,First_Name__c,Salutation__c, Salesforce_Contact__r.Consent_to_perform_credit_check__c,
                                            Salesforce_Contact__r.NumberDependants__c,Salesforce_Contact__r.Time_in_Industry__c,
                                            (Select id,Address_Line_1__c,Address_Line_2__c,Start_Date__c,End_Date__c,Post_Code__c,City__c,
                                            Country__c,Town__c,Is_this_Current_Address__c,Start_Date_In_Months__c,Start_Date_In_Years__c,
                                            End_Date_In_Months__c,End_Date_In_Years__c,Time_at_Address_In_Months__c
                                            from BDP_Address__r ) from BDP_Contact__c where Id IN: conIds]){
            
            Map<String,String> currDirectorAddressInfo = new Map<String,String>();
            List<Map<String,String>> prevDirectorAddressInfo = new List<Map<String,String>>();
                        
            for(BDP_Address__c bdpAddr: bdpCon.BDP_Address__r){
            
                if(bdpAddr.Is_this_Current_Address__c){
                    //currAddress
                    currDirectorAddressInfo = addressInfo(bdpAddr);
                }else{
                    //prevAddress
                    
                    Map<String,String> innerMap = addressInfo(bdpAddr);
                    prevDirectorAddressInfo.add( innerMap );
                    
                }
            }
            
            Map<String,String> finalContactMap = new Map<String,String>();
            finalContactMap = directorInfo(bdpCon,bdpCon.Salesforce_Contact__c);
            finalContactMap.put('currAddr', JSON.serialize( currDirectorAddressInfo ) );
            finalContactMap.put('prevAddr', JSON.serialize( prevDirectorAddressInfo ) );           
          
        
            if( !directorInfo.containsKey( bdpCon.Id) ){
                directorInfo.put( bdpCon.Id, finalContactMap);
                directorInfoMap.put( bdpCon.Id, formatString( JSON.serialize(finalContactMap) ) );                
            }
        }
        
        //Customer block payload
        List<String> customerList = new List<String>();
        Map<Id,String> finalGetDecisionMap = new Map<Id,String>(); //this is used only on get decision call
        
        for(Id accounts: accWithContactMap.keyset()){
            
            List<GeWS_PCSM_payloadStructure.PersonalInfo> personalInfoList = new List<GeWS_PCSM_payloadStructure.PersonalInfo>();
                        
            for(Id contacts: accWithContactMap.get( accounts ) ){
                
                GeWS_PCSM_payloadStructure.PersonalInfo persnlCls = new GeWS_PCSM_payloadStructure.PersonalInfo();
                persnlCls.personalType = 'F';
                persnlCls.personalCode = contactWithFnumber.get( contacts );
                persnlCls.personalInfo = (String) directorinfoMap.get( contacts);
                personalInfoList.add(persnlCls);
            }            
            
            Map<String,String> finalCustomerInfo = new Map<String,String>();
            finalCustomerInfo = accountInfo.get( accounts );
            finalCustomerInfo.put( 'Director', formatString(JSON.Serialize(personalInfoList)) ); 
            
            customerList.add( formatString(JSON.Serialize( finalCustomerInfo ) ) ); 
            
            finalGetDecisionMap.put( bdpWithSFaccountIdMap.get(accounts), formatString(JSON.Serialize( personalInfoList ) ) );           
        }
        
        if(isBureauCallOnly){
        
            //Combined Control & Customer block
            GeWS_PCSM_payloadStructure.request payloadCtr = new GeWS_PCSM_payloadStructure.request();
            payloadCtr.control = controlBlock('1234', companyIds.size(), 'Bureau');
            payloadCtr.customer = formatString( JSON.Serialize(customerList) );
           
            return formatString( JSON.Serialize(payloadCtr) ); 
       }else{
           return formatString( JSON.Serialize(finalGetDecisionMap) );
       }
    }
    
    
    public static String controlBlock(String appId, Integer noOfCustomer, String callType){
        
        Map<String,String> ctrlMap = new Map<String,String>();
        ctrlMap.put('applicationID', appId);
        ctrlMap.put('applicationDateTime', String.valueOf( DateTime.now() ));
        ctrlMap.put('reprocessUser', UserInfo.getUserId() );
        ctrlMap.put('callType', callType);
        ctrlMap.put('numCustomers', String.valueOf( noOfCustomer ) );
        ctrlMap.put('reprocessCounter', String.valueOf( 2 ) );
        
        return formatString( JSON.serialize(ctrlMap) );
    }
        
    
    public static Map<String,String> addressInfo(BDP_Address__c bdpAdr){
        
        List<GeWS_PCSM_Field_Mapping__mdt> addressfields =  fieldMappings.get('DirectorAddress');
                    
        Map<String,String> tempMap = new Map<String,String>();
        
        for(GeWS_PCSM_Field_Mapping__mdt fld: addressfields ){
            tempMap.put( fld.JSON_Key__c , String.valueOf( bdpAdr.get( fld.Field_API_Name__c ) ) );    
        }
        
        return tempMap;
        
    }
    
    public static Map<String,String> customerInfo(BDP_Contact_Relationship__c bdpRel){
    
        List<GeWS_PCSM_Field_Mapping__mdt> addressfields =  fieldMappings.get('BureauCustomerInfo');
        Map<String,String> tempMap = new Map<String,String>();
        
        for(GeWS_PCSM_Field_Mapping__mdt fld: addressfields ){
            
            if( String.isNotBlank( fld.Default_Value__c )){
                tempMap.put( fld.JSON_Key__c ,  fld.Default_Value__c );
                
            }else if(fld.Field_API_Name__c.contains('.')){
                
                List<String> relatedObjFields = fld.Field_API_Name__c.split('\\.');
                
                //String relatedObj = relatedObjFields[0];
                //String field1 = relatedObjFields[1];
                
                if(relatedObjFields.size()  == 2){
                    tempMap.put( fld.JSON_Key__c , String.ValueOf( bdpRel.getSobject( relatedObjFields[0] ).get( relatedObjFields[1] ) ) );
                }else if(relatedObjFields.size()  == 3){
                
                    //String field2 = fld.Field_API_Name__c.split('\\.')[2];
                    tempMap.put( fld.JSON_Key__c , String.ValueOf( bdpRel.getSobject( relatedObjFields[0] ).getSobject( relatedObjFields[1] ).get( relatedObjFields[2] ) ) );
                }
                
            }else{
                tempMap.put( fld.JSON_Key__c , String.valueOf( bdpRel.get( fld.Field_API_Name__c ) ) );    
            }
        }
        
        return tempMap;
    }
    
    public static Map<String,String> directorInfo(BDP_Contact__c bdpRel, String relatedRecord){
        
        List<GeWS_PCSM_Field_Mapping__mdt> addressfields =  fieldMappings.get('DirectorPerrsonalInfo');
        Map<String,String> tempMap = new Map<String,String>();
        
        for(GeWS_PCSM_Field_Mapping__mdt fld: addressfields ){
            
            if( String.isNotBlank( fld.Default_Value__c )){
                tempMap.put( fld.JSON_Key__c ,  fld.Default_Value__c );
                
            }else if(fld.Field_API_Name__c.contains('.') ){
                
                if(relatedRecord == NULL){
                    tempMap.put( fld.JSON_Key__c , '');
                }else{
                    String relatedObj = fld.Field_API_Name__c.split('\\.')[0];
                    String relatedObjField = fld.Field_API_Name__c.split('\\.')[1];
                    
                    tempMap.put( fld.JSON_Key__c , String.ValueOf( bdpRel.getSobject( relatedObj ).get( relatedObjField) ) );
                }
            }else{
                tempMap.put( fld.JSON_Key__c , String.valueOf( bdpRel.get( fld.Field_API_Name__c ) ) );    
            }
        }
        
        return tempMap;
    }
    
    
    public static String formatString(String str){
       
        str = str.replace('"[{\\"', '[{"');
        str = str.replaceAll('\\\\"', '"');
        str = str.replaceAll('\\\\"}]"', '"}]');
        str = str.replace(':"{', ':{');
        str = str.replaceAll(']"', ']');
        //str = str.replace('\\"{', '{');
        str = str.replaceAll('}"', '}');
        str = str.replace('"["', '[');
        
        return str;
    }
        
}