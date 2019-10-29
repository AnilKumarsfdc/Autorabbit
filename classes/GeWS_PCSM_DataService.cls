/****************************************************************
* @Author: Alagar
* @Class: GeWS_PCSMautoDecision
* @Description: This class generates the payload request
                for PCSM Get Decision API
*****************************************************************/
public class GeWS_PCSM_DataService{
    
    //pulls company address data
    public static Map<Id,Map<String,String>> financialsData(Set<Id> allCompanyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
        
        Map<String,String> recordJsonMap = new Map<String,String>();
        for(GeWS_PCSM_Field_Mapping__mdt mappings: fieldMappings.get('financials')){
            recordJsonMap.put( mappings.Field_API_Name__c , mappings.JSON_Key__c);
        }
        
        
        Map<Id,Map<String,String>> financialsMap = new Map<Id,Map<String,String>>();
        for(LLC_BI__Spread_Statement_Record_Total__c  statementTotalGroup : [Select id,LLC_BI__Source_Group__r.Name, LLC_BI__Spread_Statement_Type__r.LLC_BI__Type__c, LLC_BI__Spread_Statement_Type__r.LLC_BI__Bundle__r.Name,
                                                                                    LLC_BI__Spread_Statement_Type__r.LLC_BI__Bundle__r.LLC_BI__Relationship__c, 
                                                                                    LLC_BI__Spread_Statement_Type__r.LLC_BI__Bundle__r.LLC_BI__Relationship__r.Name,
                                                                                    (Select Id,LLC_BI__Value__c,LLC_BI__Spread_Statement_Period__r.LLC_BI__Statement_Date__c from LLC_BI__Spread_Statement_Period_Totals__r 
                                                                                            Order by LLC_BI__Spread_Statement_Period__r.LLC_BI__Statement_Date__c desc Limit 1) from LLC_BI__Spread_Statement_Record_Total__c 
                                                                                    where LLC_BI__Spread_Statement_Type__r.LLC_BI__Bundle__r.LLC_BI__Relationship__c IN:allCompanyIds
                                                                                    AND  LLC_BI__Spread_Statement_Type__r.LLC_BI__Type__c IN ('P&L Account','Balance Sheet') AND LLC_BI__Source_Group__r.Name IN ('Total Turnover','EBITDA (Div + Central)','Total Net Profit','Total Debtors','Total Gross Profit (subT)')]){ //'0019E000011viLJ'
            
            String accId = statementTotalGroup.LLC_BI__Spread_Statement_Type__r.LLC_BI__Bundle__r.LLC_BI__Relationship__c;
            Decimal d = 0;
            if(statementTotalGroup.LLC_BI__Spread_Statement_Period_Totals__r.size() > 0 ){
                d = statementTotalGroup.LLC_BI__Spread_Statement_Period_Totals__r[0].LLC_BI__Value__c; 
                
            }
                
            if(financialsMap.containsKey(accId)){
                                                
                Map<String,String> recordsMap = financialsMap.get(accId);
                recordsMap.put( recordJsonMap.get( statementTotalGroup.LLC_BI__Source_Group__r.Name ), String.valueOf(d));
                
                if(statementTotalGroup.LLC_BI__Spread_Statement_Period_Totals__r.size() > 0 ){
                    recordsMap.put( 'lastFinancialsYearEnd', String.valueOf( statementTotalGroup.LLC_BI__Spread_Statement_Period_Totals__r[0].LLC_BI__Spread_Statement_Period__r.LLC_BI__Statement_Date__c ) );
                }else{
                    recordsMap.put( 'lastFinancialsYearEnd', '' );
                }
                
                financialsMap.put( accId , recordsMap);
                
            }else{
                financialsMap.put( accId , new Map<String,String> { recordJsonMap.get( statementTotalGroup.LLC_BI__Source_Group__r.Name ) => String.valueOf(d) } );
            }
             
            //'annualTurnover' attribute
            if(statementTotalGroup.LLC_BI__Source_Group__r.Name == 'Total Turnover'){
                Map<String,String> recordsMap = financialsMap.get(accId);
                recordsMap.put( 'annualTurnover', String.valueOf(d));
                financialsMap.put( accId , recordsMap);
            }         
                 
        }
        
        for(Id accIds: financialsMap.keySet()){
            
            Map<String,String> financialRecords = financialsMap.get(accIds);
            Decimal d = 0;
            if(Decimal.valueOf( financialRecords.get('annualTurnover') ) != 0 ){
                d = (Decimal.valueOf( financialRecords.get('grossProfitPct') ) / Decimal.valueOf( financialRecords.get('annualTurnover') ) )*100;
            }
            
            financialRecords.put( 'grossProfitPct', string.valueOf(d.setScale(2)) );
            financialsMap.put( accIds , financialRecords );
        }
        
        System.debug('financialsMap --> '+ financialsMap);
        return financialsMap;
    }
    
    //pulls company address data
    public static Map<Id,String> companyAddressData(Set<Id> allCompanyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
        
        Map<Id,String> companyAddressMap = new Map<Id,String>();
        
        for(BDP_Company__c bdpComp: [Select id,Company__c,Primary_Address_Line_1__c,Primary_Address_Line_2__c,Primary_Address_Line_3__c,
                                            Primary_City__c,Primary_Country__c,Primary_County__c,Primary_Postcode__c
                                            from BDP_Company__c where Company__c IN:allCompanyIds]){
            Map<String,String> companyAddressfieldValMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('CompanyAddress'), bdpComp, NULL );
            companyAddressMap.put(bdpComp.Company__c, GeWS_PCSM_Utility.formatString( JSON.serialize(companyAddressfieldValMap) ));
        }
        
        return companyAddressMap;
    }
    
    //pulls serviceAbility data
    public static String serviceAbilityData(Id productPackageId, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
    
        String serviceAbilityfieldVals;
        for(LLC_BI__Product_Package__c prodPackage: [Select Id,LLC_BI__Loan_Facilities_Count__c 
                                 from LLC_BI__Product_Package__c where Id =: productPackageId]){
                                 
            Map<String,String> serviceAbilityfieldValMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('serviceability'), prodPackage, NULL );
            serviceAbilityfieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize(serviceAbilityfieldValMap) );
        }
        
        return serviceAbilityfieldVals;
    }
    
    //pulls existing products data
    public static Map<Id,List<String>> existingProductsData(List<Id> newloanIds,Set<Id> allCompanyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
    
        Map<Id,List<String>> existingProductsMap = new Map<Id,List<String>>();
        for(LLC_BI__Loan__c loan: [Select Id,LLC_BI__Account__c,Purpose_of_Borrowing__c,LLC_BI__Product__c,Maturity_Terms_in_Months__c,
                                          LLC_BI__nCino_Loan_Number__c,Application_Type__c,LLC_BI__Principal_Balance__c,LLC_BI__Amount__c,
                                          LLC_BI__Spread__c,LLC_BI__InterestRate__c,LLC_BI__Interest_Only_Months__c,LLC_BI__Payment_Type__c,
                                          LLC_BI__Pricing_Basis__c,LLC_BI__Term_Months__c,IRHP_Sub_Product__c,Contractual_Start_Date__c,
                                          Lending_on_Government_Guarantee_Scheme__c,Arrangement_Fee__c
                                          from LLC_BI__Loan__c where Id NOT IN:newLoanIds AND LLC_BI__Stage__c ='Booked' AND LLC_BI__Account__c IN:allCompanyIds]){
            
            Map<String,String> existingProductsFieldMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('existingProducts'), loan, NULL );
            String existingProductsfieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize( existingProductsFieldMap ) );                              
            
            if(existingProductsMap.containsKey(loan.LLC_BI__Account__c)){
            
                List<String> existingProdList= existingProductsMap.get(loan.LLC_BI__Account__c);
                existingProdList.add( existingProductsFieldVals );
                
                existingProductsMap.put( loan.LLC_BI__Account__c , existingProdList);
                
            }else{
                existingProductsMap.put( loan.LLC_BI__Account__c , new List<String> { existingProductsFieldVals } );
            }                                 
        }
        
        return existingProductsMap;
    }
    
    //pulls new products data
    public static Map<Id,List<String>> newProductsData(List<Id> newLoanIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
    
        Map<Id,List<String>> newProductsMap = new Map<Id,List<String>>();
        
        for(LLC_BI__Loan__c loan: [Select Id,LLC_BI__Account__c,Purpose_of_Borrowing__c,LLC_BI__Product__c,LLC_BI__Spread__c,Maturity_Terms_in_Months__c,
                                          LLC_BI__nCino_Loan_Number__c,Application_Type__c,LLC_BI__Amount__c,LLC_BI__InterestRate__c,
                                          LLC_BI__Interest_Only_Months__c,LLC_BI__Payment_Type__c,LLC_BI__Pricing_Basis__c,LLC_BI__Term_Months__c,
                                          IRHP_Sub_Product__c, Contractual_Start_Date__c,Lending_on_Government_Guarantee_Scheme__c,Arrangement_Fee__c 
                                          from LLC_BI__Loan__c where Id IN:newLoanIds]){
                                          
            Map<String,String> newProductsFieldMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('NewProducts'), loan, NULL );
            String newProductsfieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize( newProductsFieldMap ) );                              
            
            if(newProductsMap.containsKey(loan.LLC_BI__Account__c)){
            
                List<String> newProdList= newProductsMap.get(loan.LLC_BI__Account__c);
                newProdList.add( newProductsFieldVals );
                
                newProductsMap.put( loan.LLC_BI__Account__c , newProdList);
                
            }else{
                newProductsMap.put( loan.LLC_BI__Account__c , new List<String> { newProductsFieldVals } );
            }
        }
        
        return newProductsMap;
    }
    
    //pulls Policy exception data
    public static Map<Id,List<String>> policyExceptionData(Set<Id> companyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
    
        Map<Id,List<String>> policyExcMap = new Map<Id,List<String>>();
        for(LLC_BI__Policy_Exception__c excp: [SELECT Id, LLC_BI__Code__c, Policy_Exception_Template_Id__c, LLC_BI__Relationship__c, LLC_BI__Severity__c, Mitigation_Status__c,
                                                      LLC_BI__Status__c, LLC_BI__Type__c FROM LLC_BI__Policy_Exception__c where LLC_BI__Relationship__c IN: companyIds]){
            
            Map<String,String> exceptionFieldMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('PolicyException'), excp, NULL );
            String exceptionfieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize( exceptionFieldMap) );
            
            if(policyExcMap.containsKey(excp.LLC_BI__Relationship__c)){
            
                List<String> exceptList= policyExcMap.get(excp.LLC_BI__Relationship__c);
                exceptList.add( exceptionfieldVals );
                
                policyExcMap.put( excp.LLC_BI__Relationship__c , exceptList);
                
            }else{
                policyExcMap.put( excp.LLC_BI__Relationship__c , new List<String> { exceptionfieldVals } );
            }
            
            //System.debug( '#### Exception --> '+ fieldvals );
        }
        
        return policyExcMap;
    }
    
    //pulls Ratings data
    public static Map<Id,String> ratingsData(Set<Id> companyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
    
        Map<Id,String> ratingsMap = new Map<Id,String>();
        
        for(Account acc: [Select Id,Rating_Age_Months__c,MRO_Grade_If_Applicable__c,Rating_Approval_Date__c,
                                 Rating_Override_Reason__c,Ratings_Model__c,Current_Rating__c 
                                 from Account where Id IN: companyIds]){
                                 
            Map<String,String> ratingsfieldValMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('Ratings'), acc, NULL );
            String ratingsfieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize(ratingsfieldValMap) );
            ratingsMap.put( acc.Id, ratingsfieldVals);
        }
        
        return ratingsMap;
    }
    
    //pulls collateral data
    public static Map<Id,List<String>> collateralData(Set<Id> companyIds, Map<String,List<GeWS_PCSM_Field_Mapping__mdt>> fieldMappings){
        
        //Get collateral data - pledged collateral object
        Map<Id,List<String>> collateralMap = new Map<Id,List<String>>();
        for(LLC_BI__Loan_Collateral2__c coll: [Select id,LLC_BI__Loan__r.LLC_BI__Account__c,LLC_BI__Collateral__c,LLC_BI__Collateral_Type__c,Collateral_SubType__c
                                                     from LLC_BI__Loan_Collateral2__c where LLC_BI__Loan__r.LLC_BI__Account__c IN:companyIds]){
                                                     
            Map<String,String> fieldValMap = GeWS_PCSM_Utility.JSONfieldMapping( fieldMappings.get('Collateral'), coll, NULL );
            String fieldVals = GeWS_PCSM_Utility.formatString( JSON.serialize(fieldValMap) );
            
            if(collateralMap.containsKey(coll.LLC_BI__Loan__r.LLC_BI__Account__c)){
            
                List<String> collatList= collateralMap.get(coll.LLC_BI__Loan__r.LLC_BI__Account__c);
                collatList.add( fieldVals );
                
                collateralMap.put(coll.LLC_BI__Loan__r.LLC_BI__Account__c, collatList);
                
            }else{
                collateralMap.put(coll.LLC_BI__Loan__r.LLC_BI__Account__c, new List<String> { fieldVals } );
            }
            
            //System.debug( '#### '+ fieldvals );
        }
        
        return collateralMap;
    }
}