public with sharing class AccountSelectorWS {
    public static List<Account> getPaginatedAccountsByNameAndCountryCode(String pSelectedAccountName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        //TODO: Exactly which record types should we be filtering on here
        return [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, AccountNumber, SimplifiedStatus__c, AnnualRevenue, Currency__c,
                SicDesc, SIC_Description_Level_2__c, SIC_Description_Level_3__c,SIC_Description_Level_4__c
                FROM Account 
                WHERE Name LIKE :pSelectedAccountName+'%' AND (Country_of_Incorporation__c=:pCountryCode OR Country_of_Incorporation__c = NULL)
                AND RecordType.Name IN ('Customer','Prospect')
                ORDER BY Name ASC NULLS LAST, Country_of_Incorporation__c ASC NULLS LAST
                LIMIT :pQueryLimitToUse OFFSET :pQueryOffsetToUse];
    }
    
    public static List<Account> getPaginatedCharitiesByNameAndCountryCode(String pCharityName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        //TODO: Which record types should we be looking for here? Design decision for Harris to chase Paul about - concept of prospect charities and customer charities
        System.debug('pCharityName: ' + pCharityName);
        System.debug('pCountryCode: ' + pCountryCode);
        return [SELECT Id, Name, CharityId__c, CurrentCharityStatus__c
                FROM Account 
                WHERE Name =:pCharityName AND (CharityCountryCode__c=:pCountryCode OR CharityCountryCode__c = NULL)
                ORDER BY Name ASC NULLS LAST, CharityCountryCode__c ASC NULLS LAST
                LIMIT :pQueryLimitToUse OFFSET :pQueryOffsetToUse];
    }
    
    public static Integer getTotalCountMatchingNameAndCountryCode(String pAccountName, String pCountryCode){
        //TODO: Exactly which record types should we be filtering on here
        return [SELECT COUNT() FROM Account WHERE Name LIKE :pAccountName+'%' AND (Country_of_Incorporation__c=:pCountryCode OR Country_of_Incorporation__c = NULL)
               AND RecordType.Name IN ('Customer','Prospect')];
    }
    
    public static Integer getTotalCharityCountMatchingNameAndCountryCode(String pAccountName, String pCountryCode){
        //TODO: Exactly which record types should we be filtering on here
        return [SELECT COUNT() FROM Account WHERE Name =:pAccountName AND (CharityCountryCode__c=:pCountryCode OR CharityCountryCode__c = NULL)
               AND RecordType.Name IN ('Charity')];
    }
    
    public static void updateAccounts(List<Account> pAccountsToUpdate){
        update pAccountsToUpdate;
    }
    
    public static void insertAccounts(List<Account> pAccountsToInsert){
        insert pAccountsToInsert;
    }

    public static Database.QueryLocator getCompaniesForRefresh(){
        return Database.getQueryLocator([SELECT Id, Country_of_Incorporation__c, AccountNumber from Account 
                                                                      where Country_of_Incorporation__c != null 
                                                                        and AccountNumber != null 
                                                                        and RecordTypeId in (Select Id from RecordType where DeveloperName in ('Customer','ConfidentialProject', 'Other','Prospect'))
                ]);                                                  
    }

    public static Database.QueryLocator getCharitiesForRefresh(){
        return Database.getQueryLocator([SELECT Id, CharityCountryCode__c, CharityId__c from Account 
                                                                      where CharityCountryCode__c != null 
                                                                        and CharityId__c != null 
                                                                        and RecordTypeId in (Select Id from RecordType where DeveloperName in ('Customer','ConfidentialProject', 'Other','Prospect'))
                ]);                                                  
    }
    
    public static List<Account> getAccountsByUniqueKeyIdentifierSet(Set<String> pSetUniqueKeyIdentifiers){
        return [Select Id, UniquekeyIdentifier__c From Account Where UniquekeyIdentifier__c IN:pSetUniqueKeyIdentifiers];
    }
}