public with sharing class PCSM_ExperianResponsePDFCTR {
    
    public string responseTxt { get; set; }
    public Map<String, Object> responseMap { get; set; }
    
    public Map<String, String> RegNumberMap { get; set; }
    public Map<String, String> commercialMap { get; set; }
    public Map<String, Map<String,Object>> identificationMap { get; set; }
    public Map<String,Object> inneridentificationMap { get; set; }
    
    public PCSM_ExperianResponsePDFCTR(){
        
       for(BDP_Address__c addr: [SELECT Id, Long_Text_1__c, Long_Text_2__c from BDP_Address__c where Id='a5f9E0000002KhVQAU']){
           responseTxt = addr.Long_Text_1__c + addr.Long_Text_2__c;
       }
       
       responseMap  = (Map<String, Object>) JSON.deserializeUntyped(responseTxt);
       RegNumberMap = new Map<String,String>();
       commercialMap = new Map<String,String>();
       
       identificationMap = new Map<String,Map<String,Object>>();
       inneridentificationMap =  new Map<String,String>();
       
       for(String st: responseMap.keyset() ){
           
           System.debug('key --> '+ st +' ::: '+ responseMap.get(st) );
           
           if( st == 'Identification'){
               
               Map<String,Object> innerMap = (Map<String,Object>) responseMap.get(st);
               for( String innerKey: innerMap.keyset() ){
                   
                   Object vals = (Object)innerMap.get(innerKey);
                   //System.debug('##### innerMap:::: '+ innerMap.get(innerKey) );
                   
                   Map<String,Object> innerMap2 = new Map<String,Object>();
                   String s = '';
                   if( vals instanceof map<string,object> ){
                      innerMap2 = (Map<String,Object>) vals;
                   }else if( vals instanceof string ){
                       s = (string) vals;
                   }
                   
                   System.debug('##### innerMap2 :::: '+ innerMap2 );
                   System.debug('##### s:::: '+ s);
               } 
               
               identificationMap.put( st , (Map<String,Object>) responseMap.get(st));
               
               
               //System.debug('##### '+ identificationMap.get('Bank'));
           }
           
           if( st == 'RegNumber'){
               RegNumberMap.put( st , (String) responseMap.get(st) );
           }
           
           if( st == 'CommercialName'){
               commercialMap.put( st , (String) responseMap.get(st));
           }
       }

    }
}