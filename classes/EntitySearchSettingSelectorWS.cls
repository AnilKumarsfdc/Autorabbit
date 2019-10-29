public with sharing class EntitySearchSettingSelectorWS {    
    
    public static EntitySearchSettings__mdt getCurrentEntitySearchSetting(){
        EntitySearchSettings__mdt entitySearchSettings =   [SELECT ID,NamedCredentialsAPIName__c,QueryPageSize__c,SearchProvider__c,SearchRequestTimeout__c,NameParameter__c,PageNumberParameter__c, CountryCodeParameter__c, PageSize__c,CalloutAttempts__c,CompanySearchEndpointPath__c,CharitySearchEndpointPath__c,OfficerSearchEndpointPath__c,BulkCompanyUpdateEndpointPath__c,BulkCharityUpdateEndpointPath__c, AuthenticationFailureRecipientEmail__c, BulkIntegrationUserEmail__c,
                                                              (SELECT MasterLabel, CountryCode__c, DisplayOrder__c,EntityType__c, SelectByDefaultForThisEntity__c
                                                               FROM EntitySearchSupportedCountries__r ORDER BY DisplayOrder__c ASC NULLS LAST,MasterLabel NULLS LAST)
                                                            FROM EntitySearchSettings__mdt where IsCurrentSetting__c=true LIMIT 1];
        return entitySearchSettings;
    }  
}