/****************************************************************
* @Author: Alagar
* @Class: GeWS_PCSMautoDecision
* @Description: This class generates the payload request
                for PCSM Get Decision API
*****************************************************************/
public class GeWS_PCSM_GetDecisionAPI{
    
    public static Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings { get; set; }
    public static Set<Id> allCompanyIds { get; set; }
    
    public static string generatePayload(Id productPackageId,List<Id> loanIds){
        
        System.debug('Heap size start --> '+ Limits.getHeapSize());
        
        //field mappings from metadata types
        fieldMappings = GeWS_PCSM_Utility.metadataMapping( );
        
        //Pulls customer and associated customer from entity involvment object
        Map<Id,Set<Id>> associatedCustomerMap = associatedCustomer( loanIds );
        
        //Get collateral data - pledged collateral object
        Map<Id,List<String>> collateralDataMap = GeWS_PCSM_DataService.collateralData( allCompanyIds, fieldMappings );
        
        //Get ratings data
        Map<Id,String> ratingsDataMap = GeWS_PCSM_DataService.ratingsData( allCompanyIds, fieldMappings );
        
        //Get policy exception data
        Map<Id,List<String>> policyExcpDataMap = GeWS_PCSM_DataService.policyExceptionData( allCompanyIds, fieldMappings );
        
        //Get New Products data
        Map<Id,List<String>> newProductsDataMap = GeWS_PCSM_DataService.newProductsData( loanIds, fieldMappings );
        
        //Get existing Products data
        Map<Id,List<String>> existingProductsDataMap = GeWS_PCSM_DataService.existingProductsData( loanIds, allCompanyIds, fieldMappings );
                
        //Get seviceability data
        String serviceAbilityDataStr = GeWS_PCSM_DataService.serviceAbilityData( productPackageId, fieldMappings );
        
        //Get company address data
        Map<Id,String> companyAddressDataStr = GeWS_PCSM_DataService.companyAddressData( allCompanyIds, fieldMappings );
        
        System.debug( 'companyAddressDataStr  --> ' + companyAddressDataStr ); 
        
        //financial data
        Map<Id,Map<String,String>> financialDataMap = GeWS_PCSM_DataService.financialsData( allCompanyIds, fieldMappings);
        
        //Get Director Block
        List<Id> allAccountIdList = new List<Id>();
        allAccountIdList.addAll(allCompanyIds );
        String directorInfo = GeWS_PCSM_BureauAPI.generatePayload( allAccountIdList , FALSE);
        Map<String,Object> directorDataMap = (Map<String,Object>) JSON.deserializeUntyped(directorInfo);
        System.debug( 'directorDataMap --> ' + directorDataMap ); 
        
        List<GeWS_PCSM_payloadStructure.customer> finalCustomerData = new List<GeWS_PCSM_payloadStructure.customer>();
        for(Id acc: allCompanyIds){
            
            List<String> collateralList = new List<String>();
            if( collateralDataMap.containsKey( acc ) ){
                collateralList = collateralDataMap.get( acc );
            }    
                        
            List<String> policyExceptionList = new List<String>();
            if( policyExcpDataMap.containsKey( acc ) ){
                policyExceptionList = policyExcpDataMap.get( acc );
            }
            
            List<String> newProductsList = new List<String>();
            if( newProductsDataMap.containsKey( acc ) ){
                newProductsList = newProductsDataMap.get( acc );
            }
            
            List<String> existingProductsList = new List<String>();
            if( existingProductsDataMap.containsKey( acc ) ){
                existingProductsList = existingProductsDataMap.get( acc );
            }
            
            
            List<Object> directorList = new List<String>();
            if( directorDataMap.containsKey( acc ) ){
                directorList= (List<Object>)directorDataMap.get( acc );
            }
            //Create the payload
            GeWS_PCSM_payloadStructure.customer payloadCls = new GeWS_PCSM_payloadStructure.customer();
            payloadCls.customerId = acc;
            payloadCls.collateral = GeWS_PCSM_Utility.formatString( JSON.Serialize(collateralList) );
            payloadCls.ratings = ( ratingsDataMap.containsKey( acc ) ? ratingsDataMap.get( acc ) : '');
            payloadCls.policyException = GeWS_PCSM_Utility.formatString( JSON.Serialize(policyExceptionList) );
            payloadCls.newProducts = GeWS_PCSM_Utility.formatString( JSON.Serialize( newProductsList ) ); 
            payloadCls.existingProducts = GeWS_PCSM_Utility.formatString( JSON.Serialize( existingProductsList ) ); 
            payloadCls.serviceAbility = serviceAbilityDataStr;
            payloadCls.director = GeWS_PCSM_Utility.formatString( JSON.Serialize(directorList) );
            payloadCls.address = ( companyAddressDataStr.containsKey( acc ) ? companyAddressDataStr.get( acc ) : '');
            
            //reverse the condition
            payloadCls.financials = ( financialDataMap.containsKey( '0019E000011viLJ' ) ? GeWS_PCSM_Utility.formatString( JSON.Serialize(financialDataMap.get( '0019E000011viLJ' ) ) )  : '');
            
            finalCustomerData.add( payloadCls );
        }
        
        System.debug('Heap size end --> '+ Limits.getHeapSize());
               
        return GeWS_PCSM_Utility.formatString(JSON.Serialize(finalCustomerData));
    }
    
        
    //to associated customer from entity involvement
    public static Map<Id,Set<Id>> associatedCustomer(List<Id> loanIds){
        
        Map<Id,Set<Id>> associatedCompanyMap = new Map<Id,Set<Id>>();
        allCompanyIds = new Set<Id>();
        
        for(LLC_BI__Loan__c loan: [Select Id,LLC_BI__Account__c, (Select Id,LLC_BI__Account__c from LLC_BI__Legal_Entities__r) 
                                          from LLC_BI__Loan__c where Id IN:loanIds]){ //Id IN:loanIds
            
            for(LLC_BI__Legal_Entities__c ent: loan.LLC_BI__Legal_Entities__r){
            
                if(associatedCompanyMap.containsKey(loan.LLC_BI__Account__c)){
                    
                    Set<Id> compSet = associatedCompanyMap.get(loan.LLC_BI__Account__c);
                    compset.add( ent.LLC_BI__Account__c );
                    
                    associatedCompanyMap.put(loan.LLC_BI__Account__c, compset);
                }else{
                    associatedCompanyMap.put(loan.LLC_BI__Account__c, new Set<Id> { ent.LLC_BI__Account__c } );
                }
                
                allCompanyIds.add( ent.LLC_BI__Account__c );
            }
            
            allCompanyIds.add( loan.LLC_BI__Account__c );
        }
        
        System.debug('associatedCompanyMap --> '+ associatedCompanyMap);
        System.debug('allCompanyIds --> '+ allCompanyIds );
        
        return associatedCompanyMap;
    }
    
}