/****************************************************************
* @Author: Alagar
* @Class: GeWS_PCSMautoDecision
* @Description: This is a Util class for PCSM API's
*****************************************************************/
public class GeWS_PCSM_Utility {
    
    //NEEDED
    public static Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> metadataMapping(){
        
        Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> jsonGrouppingMap = new Map<String,List<GeWS_PCSM_Field_Mapping__mdt>>();
        
        for(GeWS_PCSM_Field_Mapping__mdt pcs:[Select Id,Object_API_Name__c,Field_API_Name__c,JSON_Key__c,JSON_Block__c,Default_Value__c
                                                     from GeWS_PCSM_Field_Mapping__mdt]){
                                                     
            if(jsonGrouppingMap.containsKey(pcs.JSON_Block__c) ){
            
                List<GeWS_PCSM_Field_Mapping__mdt> objList = jsonGrouppingMap.get(pcs.JSON_Block__c);
                objList.add( pcs );
                
                jsonGrouppingMap.put( pcs.JSON_Block__c, objList );
                
            }else{                 
                jsonGrouppingMap.put(pcs.JSON_Block__c, new List<GeWS_PCSM_Field_Mapping__mdt> { pcs } );
            }
        }
        
        return jsonGrouppingMap;
    }
    
    //NEEDED
    public static Map<String,String> JSONfieldMapping(List<GeWS_PCSM_Field_Mapping__mdt> mappingRecords,sObject record, String relatedRecord){
        
        //List<GeWS_PCSM_Field_Mapping__mdt> addressfields =  fieldMappings.get('DirectorPerrsonalInfo');
        Map<String,String> tempMap = new Map<String,String>();
        
        for(GeWS_PCSM_Field_Mapping__mdt fld: mappingRecords ){
            
            if( String.isNotBlank( fld.Default_Value__c )){
                tempMap.put( fld.JSON_Key__c ,  fld.Default_Value__c );
                
            }else if(fld.Field_API_Name__c.contains('.') ){
                
                if(relatedRecord == NULL){
                    tempMap.put( fld.JSON_Key__c , '');
                }else{
                    String relatedObj = fld.Field_API_Name__c.split('\\.')[0];
                    String relatedObjField = fld.Field_API_Name__c.split('\\.')[1];
                    
                    tempMap.put( fld.JSON_Key__c , String.ValueOf( record.getSobject( relatedObj ).get( relatedObjField) ) );
                }
            }else{
                tempMap.put( fld.JSON_Key__c , String.valueOf( record.get( fld.Field_API_Name__c ) ) );    
            }
        }
        
        return tempMap;
    }
    
    //NEEDED
    public static String formatString(String str){
       
        str = str.replace('"[{\\"', '[{"');
        str = str.replaceAll('\\\\"', '"');
        str = str.replaceAll('\\\\"}]"', '"}]');
        str = str.replace(':"{', ':{');
        str = str.replaceAll(']"', ']');
        str = str.replace(',"{', ',{');
        str = str.replaceAll('}"', '}');
        str = str.replace('"["', '['); 
        str = str.replace(':"[', ':[');
        
        return str;
    }
    
    /********************************************************************
    * @Author: Alagar
    * @Method: queryFormation
    * @Description: Forms the dynamic query from the custom meatdata type
    *********************************************************************/
    public static void queryFormation(String serviceName){
        
        //helps to prepare the query
        Map<String,List<String>> objWithFieldsMap = new Map<String,List<String>>(); 
        //holds the mapping between JSON and object fields
        Map<String,Map<String,String>> JsonKeyMap = new Map<String,Map<String,String>>();
        
        for(GeWS_PCSM_Field_Mapping__mdt pcs:[Select Id,Object_API_Name__c,Field_API_Name__c,JSON_Key__c
                                                     from GeWS_PCSM_Field_Mapping__mdt]){
                                                     
            if(objWithFieldsMap.containsKey(pcs.Object_API_Name__c) ){
            
                List<String> fieldList = objWithFieldsMap.get(pcs.Object_API_Name__c);
                fieldList.add( pcs.Field_API_Name__c );
                
                objWithFieldsMap.put( pcs.Object_API_Name__c, fieldList );
                
            }else{                 
                objWithFieldsMap.put(pcs.Object_API_Name__c, new List<String> { pcs.Field_API_Name__c } );
            }
            
            if( JsonKeyMap.containsKey(pcs.Object_API_Name__c) ){
                
                Map<String,String> innerMap = JsonKeyMap.get( pcs.Object_API_Name__c );
                innerMap.put( pcs.JSON_Key__c, pcs.Field_API_Name__c  );
                 
                JsonKeyMap.put(pcs.Object_API_Name__c,innerMap);
                
            }else{
                JsonKeyMap.put(pcs.Object_API_Name__c, new Map<String,String> { pcs.JSON_Key__c => pcs.Field_API_Name__c } );
            }
        }
        
        System.debug('JSON Mapping --> '+ JsonKeyMap);
        
        Map<String,String> queryMap = new Map<String,String>();
        for(String st: objWithFieldsMap.keySet()){
            
            List<String> fieldList = objWithFieldsMap.get(st);
            String allFields = String.join(fieldList,',');
            
            String qry = 'Select Id,'+ allFields +' from '+st;
            queryMap.put( st, qry);
            
            System.debug('Object --> '+ st +'QUERY --> '+ qry);
        }
        
        //Call next method
        jsonFieldMapping(queryMap,JsonKeyMap);
    }
    
    public static void jsonFieldMapping(Map<String,String> queryMap, Map<String, Map<String,String>> JsonKeyMap){
        
        Map<String,String> jsonSpecMap = new Map<String,String>();
        for(GeWS_PCSM_JSONspec__mdt spc:[Select Id,Object_API_Name__c,JSON_Header_Name__c,Field_Map_Definition__c 
                                                from GeWS_PCSM_JSONspec__mdt]){
            jsonSpecMap.put( spc.JSON_Header_Name__c, spc.Object_API_Name__c);
        }
        
        for(String key: queryMap.keySet()){
            
            Map<String,String> fields = JsonKeyMap.get(key);
            //System.debug('Query Object name  --> ' + key);
            //System.debug('Json fields  --> ' + fields);
            
            List<String> listOfData = new List<String>();
            for(sObject sObj: Database.Query( queryMap.get(key) )){
                System.debug('records --> ' + sObj.Id);
                
                Map<String,String> fieldValues = new Map<String,String>();
                for(String jsn: fields.keyset()){
                    
                    String fVal = String.valueOf(sObj.get( fields.get(jsn) ) );
                    
                    fieldValues.put( jsn, fVal);
                }
                
                listOfData.add( JSON.serialize( fieldValues) );
                
            }
            
            System.debug('final json:::: '+ String.join(listOfData , ',') );
        }
        
        
    }
    
}