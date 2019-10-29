public class AccountService {
    public static List<Account> getPaginatedAccountsByNameAndCountryCode(String pSelectedAccountName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        return AccountSelectorWS.getPaginatedAccountsByNameAndCountryCode(pSelectedAccountName, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
    }
    
    public static List<Account> getPaginatedCharitiesByNameAndCountryCode(String pCharityName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        return AccountSelectorWS.getPaginatedCharitiesByNameAndCountryCode(pCharityName, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
    }
    
    public static Integer getTotalCountMatchingNameAndCountryCode(String pAccountName, String pCountryCode){
        return AccountSelectorWS.getTotalCountMatchingNameAndCountryCode(pAccountName, pCountryCode);
    }
    
    public static Integer getTotalCharityCountMatchingNameAndCountryCode(String pCharityName, String pCountryCode){
        return AccountSelectorWS.getTotalCharityCountMatchingNameAndCountryCode(pCharityName, pCountryCode);
    }
    
    public static void updateAccounts(List<Account> pAccountsToUpdate){
        AccountSelectorWS.updateAccounts(pAccountsToUpdate);
    }
    
    
    public static void insertAccounts(List<Account> pAccountsToInsert){
        AccountSelectorWS.insertAccounts(pAccountsToInsert);
    }

    public static Database.QueryLocator getCompaniesForRefresh(){
        return AccountSelectorWS.getCompaniesForRefresh();
    }

    public static Database.QueryLocator getChartiesForRefresh(){
        return AccountSelectorWS.getCharitiesForRefresh();
    }
    
    public static void setRecordTypeToProspect(List<Account> incomingAccounts){
        Id prospectRecordTypeId = RecordTypeSelectorWOS.getProspectRecordTypeId();
        
        if(EntitySearchSettingService.getCurrentEntitySearchSetting().BulkIntegrationUserEmail__c.equalsIgnoreCase(UserInfo.getUserEmail())){
            for(Account acc : incomingAccounts){
                acc.RecordTypeId = prospectRecordTypeId;
            }
        }
        
    }
    
    public static List<Account> getAccountsByUniqueKeyIdentifierSet(Set<String> pSetUniqueKeyIdentifiers){
        return AccountSelectorWS.getAccountsByUniqueKeyIdentifierSet(pSetUniqueKeyIdentifiers);
    }
    
    public static String removeCommonCompanyAbbreviationsAndTermsFromName(String strCompanyName){
        //Pattern cleanupPattern = Pattern.compile('((?i)ltd\\s*\\.*|(?i)(limited|(?i)ltd\\s*\\.*) (partnership)?|(?i)plc\\s*\\.*|(?i)GmbH)');
        //Pattern cleanupPattern = Pattern.compile('((?i)(limited|(?i)ltd\\.?)? partnership|(?i)ltd\\.?|(?i)plc\\s*\\.*|(?i)GmbH)');
        Pattern cleanupPattern = Pattern.compile('((?i)\\b(limited|(?i)ltd\\.?) \\bpartnership$|(?i)\\bltd\\.*$|(?i)\\blimited$|(?i)\\bplc\\.*$|(?i)\\bGmbH$|(?i)\\bpublic limited company$)');
        return cleanupPattern.matcher(strCompanyName).replaceAll('').trim();
    }
}