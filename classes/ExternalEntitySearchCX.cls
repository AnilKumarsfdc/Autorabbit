public with sharing class ExternalEntitySearchCX {
    public class ExceptionWrapper{
        public String exceptionMessage;
        public String exceptionStackTrace;
        public String userFriendlyMessage;
        public Boolean isAuthenticationException = false;
        public Boolean isCalloutException = false;
        public Boolean isGenericException = false;
        public Boolean isAppLoadException = false;
        public String className;
        public String methodName;
        public String priority;
        public Integer lineNumber;
    }
    public class CountryPicklistEntry{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    public class SearchResponse{
        @AuraEnabled public String serialisedSearchResults;
        @AuraEnabled public Integer offsetUsed;
        @AuraEnabled public Integer totalNumberResults;
    }
    
    public class SalesforceAccountSearchResponse{
        @AuraEnabled public String serialisedSearchResults;
        @AuraEnabled public Integer offsetUsed;
        @AuraEnabled public Integer totalNumberResults;
    }
    
    public class SalesforceCharitySearchResponse{
        @AuraEnabled public String serialisedSearchResults;
        @AuraEnabled public Integer offsetUsed;
        @AuraEnabled public Integer totalNumberResults;
    }
    
    public class GetCompanyDataResponse{
        @AuraEnabled public String serialisedResult;
    }
    
    public class GetCharityDataResponse{
        @AuraEnabled public String serialisedResult;
    }
    
    public class GetIndividualDataResponse{
        @AuraEnabled public String serialisedResult;
    }
    
    public class SalesforceCharityGetDataResponse{
        @AuraEnabled public String officialContactName;
        @AuraEnabled public String email;
        @AuraEnabled public String telephoneNumber;
        @AuraEnabled public String address;
    }
    
    public class SalesforceAccountWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public Id recordId;
        @AuraEnabled public String telephone;
        @AuraEnabled public String address;
        @AuraEnabled public String sic;
        @AuraEnabled public String CRN;
        @AuraEnabled public String SimplifiedStatus;
        @AuraEnabled public String CountryName;
        @AuraEnabled public String FormattedSICString;
        @AuraEnabled public String FormattedTurnover;
        @AuraEnabled public String AccountCurrencyISOCode;
    }
    
    public class SalesforceCharityWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public Id recordId;
        @AuraEnabled public String charityId;
        @AuraEnabled public String status;
        @AuraEnabled public String CountryName;
    }
    
    public class SystemError{
        @AuraEnabled public String errorTitle;
        @AuraEnabled public String errorMessage;
    }
    
    public class ComponentConfig{
        @AuraEnabled public String defaultCompanyCountryCode;
        @AuraEnabled public String defaultCharityCountryCode;
        @AuraEnabled public String defaultIndividualCountryCode;
        @AuraEnabled public Integer queryLimit;
        @AuraEnabled public List<CountryPicklistEntry> supportedCountryList;
        @AuraEnabled public List<CountryPicklistEntry> supportedCharityCountryList;
        @AuraEnabled public List<CountryPicklistEntry> supportedIndividualCountryList;
        @AuraEnabled public final String SALESFORCE_BASE_URL = System.URL.getSalesforceBaseUrl().toExternalForm();
    }
  
    @AuraEnabled
    public static SearchResponse searchCompanyByName(String pQueryString, String pCountryCode, String pEntityToQuery, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){       
        SearchResponse searchResponse = new SearchResponse();
        //TODO: Get the class that represents the service provider required here from a custom settings
        
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            //Send Query off to DueDil here
            //transform duedil results into an array of either CompanyResultListItem, CharityResultListItem or IndividualResultListItem (use the pEntityToQuery to determine which array you need to build)
            ExternalEntitySearchService.CompanySearchResult companySearchResult= searchService.searchCompanyByName(pQueryString, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
            searchResponse.serialisedSearchResults = JSON.serialize(companySearchResult.searchResultListItems);
            searchResponse.offsetUsed = pQueryOffsetToUse;
            searchResponse.totalNumberResults = companySearchResult.totalResults;
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
            //searchResponse.serialisedSearchResults = '[{"Name":"some dummy account name here","CRN":"123333","Telephone":"01344544342"},{"Name":"ACME Ltd.","CRN":"444311","Telephone":"02788222122"}]';
        }catch(System.CalloutException calloutException){
            System.debug('callout exception T');
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = calloutException.getMessage();
            exWrapper.exceptionStackTrace = calloutException.getStackTraceString();
            exWrapper.isCalloutException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(DueDilEntitySearchServiceImpl.AccessTokenRetrievalException accessTokenRetrieval){
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = accessTokenRetrieval.getMessage();
            exWrapper.exceptionStackTrace = accessTokenRetrieval.getStackTraceString();
            exWrapper.isAuthenticationException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(Exception e){
            //ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','searchCompanyByName', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            exWrapper.isGenericException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }
        return searchResponse;
    }
    
    @AuraEnabled
    public static SearchResponse searchCharityByName(String pQueryString, String pCountryCode, String pEntityToQuery, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){       
        SearchResponse searchResponse = new SearchResponse();
        //TODO: Get the class that represents the service provider required here from a custom settings

        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            //Send Query off to DueDil here
            //transform duedil results into an array of either CompanyResultListItem, CharityResultListItem or IndividualResultListItem (use the pEntityToQuery to determine which array you need to build)
            ExternalEntitySearchService.CharitySearchResult charitySearchResult= searchService.searchCharityByName(pQueryString, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
            searchResponse.serialisedSearchResults = JSON.serialize(charitySearchResult.searchResultListItems);
            searchResponse.offsetUsed = pQueryOffsetToUse;
            searchResponse.totalNumberResults = charitySearchResult.totalResults;
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
        }catch(System.CalloutException calloutException){
            System.debug('callout exception T');
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = calloutException.getMessage();
            exWrapper.exceptionStackTrace = calloutException.getStackTraceString();
            exWrapper.isCalloutException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(DueDilEntitySearchServiceImpl.AccessTokenRetrievalException accessTokenRetrieval){
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = accessTokenRetrieval.getMessage();
            exWrapper.exceptionStackTrace = accessTokenRetrieval.getStackTraceString();
            exWrapper.isAuthenticationException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(Exception e){
            //ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','searchCompanyByName', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            exWrapper.isGenericException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }
        return searchResponse;
    }
    
    @AuraEnabled
    public static SearchResponse searchIndividualByName(String pQueryString, String pCountryCode, String pEntityToQuery, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){       
        SearchResponse searchResponse = new SearchResponse();
        //TODO: Get the class that represents the service provider required here from a custom settings
        
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            //Send Query off to DueDil here
            //transform duedil results into an array of either CompanyResultListItem, CharityResultListItem or IndividualResultListItem (use the pEntityToQuery to determine which array you need to build)
             
            ExternalEntitySearchService.IndividualSearchResult individualSearchResult= searchService.searchIndividualByName(pQueryString, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
            searchResponse.serialisedSearchResults = JSON.serialize(individualSearchResult.searchResultListItems);
            System.debug('officerResults: '+ searchResponse.serialisedSearchResults);
            searchResponse.offsetUsed = pQueryOffsetToUse;
            searchResponse.totalNumberResults = individualSearchResult.totalResults;
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
        }catch(System.CalloutException calloutException){
            System.debug('callout exception T');
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = calloutException.getMessage();
            exWrapper.exceptionStackTrace = calloutException.getStackTraceString();
            exWrapper.isCalloutException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(DueDilEntitySearchServiceImpl.AccessTokenRetrievalException accessTokenRetrieval){
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = accessTokenRetrieval.getMessage();
            exWrapper.exceptionStackTrace = accessTokenRetrieval.getStackTraceString();
            exWrapper.isAuthenticationException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }catch(Exception e){
            //ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','searchCompanyByName', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            exWrapper.isGenericException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }/*catch(Exception e){
            System.debug(e.getStackTraceString());
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','searchIndividualByName', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }*/
        return searchResponse;
    }
    
    @AuraEnabled
    public static SalesforceAccountSearchResponse querySalesforceForSuggestedCompaniesByNameAndCountryCode(String pCompanyName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        SalesforceAccountSearchResponse searchResponse = new SalesforceAccountSearchResponse();
		String strCleansedAccountName='';
        try{
            strCleansedAccountName = AccountService.removeCommonCompanyAbbreviationsAndTermsFromName(pCompanyName);
            List<Account> queriedAccounts = AccountService.getPaginatedAccountsByNameAndCountryCode(strCleansedAccountName, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
            List<SalesforceAccountWrapper> accountWrappers = new List<SalesforceAccountWrapper>();
            for(Account queriedAccount: queriedAccounts){
                SalesforceAccountWrapper accountWrapper = new SalesforceAccountWrapper();
                accountWrapper.name = queriedAccount.Name;
                accountWrapper.recordId = queriedAccount.Id;
                List<String> lstAddressElements = new List<String>();
                if (String.isNotBlank(queriedAccount.BillingStreet)){
                    lstAddressElements.add(queriedAccount.BillingStreet);
                }
                if (String.isNotBlank(queriedAccount.BillingCity)){
                    lstAddressElements.add(queriedAccount.BillingCity);
                }
                if (String.isNotBlank(queriedAccount.BillingPostalCode)){
                    lstAddressElements.add(queriedAccount.BillingPostalCode);
                }
                accountWrapper.address = String.join(lstAddressElements,', ');
                accountWrapper.CRN = queriedAccount.AccountNumber;
                List<String> lstSicDescriptions = new List<String>();
                if (String.isNotBlank(queriedAccount.SicDesc)){
                    lstSicDescriptions.add(queriedAccount.SicDesc);
                }
                if (String.isNotBlank(queriedAccount.SIC_Description_Level_2__c)){
                    lstSicDescriptions.add(queriedAccount.SIC_Description_Level_2__c);
                }
                if (String.isNotBlank(queriedAccount.SIC_Description_Level_3__c)){
                    lstSicDescriptions.add(queriedAccount.SIC_Description_Level_3__c);
                }
                if (String.isNotBlank(queriedAccount.SIC_Description_Level_4__c)){
                    lstSicDescriptions.add(queriedAccount.SIC_Description_Level_4__c);
                }
                accountWrapper.SimplifiedStatus = queriedAccount.SimplifiedStatus__c;
                accountWrapper.FormattedSICString = String.join(lstSicDescriptions,', ');
                accountWrapper.FormattedTurnover = String.valueOf(queriedAccount.AnnualRevenue);
                accountWrapper.AccountCurrencyISOCode = queriedAccount.Currency__c;
                accountWrappers.add(accountWrapper);
            }
            searchResponse.serialisedSearchResults = JSON.serialize(accountWrappers);
            searchResponse.offsetUsed = pQueryOffsetToUse;
            searchResponse.totalNumberResults = AccountService.getTotalCountMatchingNameAndCountryCode(strCleansedAccountName, pCountryCode);
        }catch(Exception e){
            //ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','searchCompanyByName', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            exWrapper.isGenericException = true;
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }/*catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','querySalesforceForSuggestedCompaniesByNameAndCountryCode', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }*/
        return searchResponse;
    }
    
    /*@AuraEnabled
    public static SalesforceCharitySearchResponse querySalesforceForSuggestedCharities(String pCharityName, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        SalesforceCharitySearchResponse searchResponse = new SalesforceCharitySearchResponse();
        
        try{
            System.debug('**daf**'+pCharityName);
            List<Account> queriedAccounts = AccountService.getPaginatedCharitiesByNameAndCountryCode(pCharityName, pCountryCode, pQueryOffsetToUse, pQueryLimitToUse);
            List<SalesforceCharityWrapper> charityWrappers = new List<SalesforceCharityWrapper>();
            for(Account queriedAccount: queriedAccounts){
                SalesforceCharityWrapper charityWrapper = new SalesforceCharityWrapper();
                charityWrapper.name = queriedAccount.Name;
                charityWrapper.recordId = queriedAccount.Id;
                charityWrapper.charityId = queriedAccount.CharityID__c;
                //List<String> lstAddressElements = new List<String>{queriedAccount.BillingStreet,queriedAccount.BillingCity, queriedAccount.BillingPostalCode};
				//charityWrapper.address = String.join(lstAddressElements,', ');
                charityWrapper.status = queriedAccount.CurrentCharityStatus__c;
                //accountWrapper.SimplifiedStatus = String.valueOf(queriedAccount.IsDeleted);
                charityWrappers.add(charityWrapper);
            }
            searchResponse.serialisedSearchResults = JSON.serialize(charityWrappers);
            searchResponse.offsetUsed = pQueryOffsetToUse;
            searchResponse.totalNumberResults = AccountService.getTotalCharityCountMatchingNameAndCountryCode(pCharityName, pCountryCode);
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','querySalesforceForSuggestedCharities', e.getMessage(), 'ERROR'); 
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }
        return searchResponse;
    }*/
    
    @AuraEnabled
    public static ExternalEntitySearchCX.ComponentConfig getComponentConfig(){
        ComponentConfig componentConfig = new ComponentConfig();
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            //Forcing an exception here to test UI
            if (entitySearchSetting!=null && entitySearchSetting.EntitySearchSupportedCountries__r.size()>0){
                componentConfig.queryLimit = 10;//TODO: get the query limit from a global custom setting. For development of the UI, this has been hardcoded.
                List<CountryPicklistEntry> countryPicklistEntryList = new List<CountryPicklistEntry>();
                List<CountryPicklistEntry> charityCountryPicklistEntryList = new List<CountryPicklistEntry>();
                List<CountryPicklistEntry> individualCountryPicklistEntryList = new List<CountryPicklistEntry>();
                for (EntitySearchSupportedCountry__mdt supportedCountry : entitySearchSetting.EntitySearchSupportedCountries__r){
                    CountryPicklistEntry countryPicklistEntry = new CountryPicklistEntry();
                    countryPicklistEntry.label = supportedCountry.MasterLabel;
                    countryPicklistEntry.value = supportedCountry.CountryCode__c;
                    if(null!= supportedCountry.EntityType__c && supportedCountry.EntityType__c.equalsIgnoreCase('Company')){
                        countryPicklistEntryList.add(countryPicklistEntry);
                        if (supportedCountry.SelectByDefaultForThisEntity__c){
                            componentConfig.defaultCompanyCountryCode = supportedCountry.CountryCode__c;
                        }
                    }else if(null!= supportedCountry.EntityType__c && supportedCountry.EntityType__c.equalsIgnoreCase('Charity')){
                        charityCountryPicklistEntryList.add(countryPicklistEntry);
                        if (supportedCountry.SelectByDefaultForThisEntity__c){
                            componentConfig.defaultCharityCountryCode = supportedCountry.CountryCode__c;
                        }
                    }else if(null!= supportedCountry.EntityType__c && supportedCountry.EntityType__c.equalsIgnoreCase('Individual')){
                        individualCountryPicklistEntryList.add(countryPicklistEntry);
                        if (supportedCountry.SelectByDefaultForThisEntity__c){
                            componentConfig.defaultIndividualCountryCode = supportedCountry.CountryCode__c;
                        }
                    }
                }
                componentConfig.supportedIndividualCountryList = individualCountryPicklistEntryList;
                componentConfig.supportedCountryList = countryPicklistEntryList;
                componentConfig.supportedCharityCountryList = charityCountryPicklistEntryList;
                ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
                exceptionHandlingSettings.EntitySearchAppLoadFailureFlag__c = false;
                update exceptionHandlingSettings;
            }else{
                throw new AuraHandledException('There were either no supported countries found, or no Entity Search Setting Custom Metadata type record with isCurrentSetting set to true found.');
            }
        }catch(Exception e){
            /*ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','getComponentConfig', e.getMessage(), 'FATAL'); */
            ExceptionWrapper exWrapper = new ExceptionWrapper();
            exWrapper.isAppLoadException = true;
            exWrapper.exceptionMessage = e.getMessage();
            exWrapper.userFriendlyMessage = 'There was an issue loading the entity search application. Please see the technical error message for more details.';
            exWrapper.exceptionStackTrace = e.getStackTraceString();
            exWrapper.className='ExternalEntitySearchCX';
            exWrapper.priority='FATAL';
            exWrapper.methodName='getComponentConfig';
            exWrapper.lineNumber = e.getLineNumber();
            throw new AuraHandledException(JSON.serialize(exWrapper));
        }
        
        return componentConfig;
    }
    
    @AuraEnabled
    public static void triggerCompanyUpdate(Id pSalesforceCompanyId, String pCompanyIdentifier, String pCountryCode, String pstrEntity ){
        /*try{
            
            
            AccountService.updateAccounts(new List<Account>{new Account(Id=pSalesforceCompanyId, Country_of_Incorporation__c=pCountryCode, AccountNumber=pCompanyIdentifier)}); 
            
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','triggerCompanyUpdate', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());        
        }*/
        Account newEntity = new Account();
        
        try{
            if(pstrEntity=='company'){
                
                newEntity = new Account(Id=pSalesforceCompanyId, Country_of_Incorporation__c=pCountryCode, AccountNumber=pCompanyIdentifier, UniquekeyIdentifier__c = pCountryCode+'-'+pCompanyIdentifier);
                update newEntity;
                Id statusRecordId = BulkAPIStatusManagement.createBulkJobLogRecord(true); 

                sendRefreshRequest(pCompanyIdentifier, pCountryCode, statusRecordId, 'Company');
                //CompanyDataRefresh.execute(new List<Account>{newEntity});
                //notifyRequestRefreshComplete('Company',statusRecord);
                
                
            }else if (pstrEntity=='charity'){
                
                newEntity = new Account(Id=pSalesforceCompanyId, CharityCountryCode__c=pCountryCode, CharityID__c=pCompanyIdentifier, UniquekeyIdentifier__c = pCompanyIdentifier+'-'+pCountryCode);
                update newEntity;
                CharityDataRefreshCallout.execute(new List<Account>{newEntity});
                Id statusRecord = BulkAPIStatusManagement.createBulkJobLogRecord(true); 
                notifyRequestRefreshComplete('Charity',statusRecord);
                
                
            }
            
            
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','triggerCompanyUpdate', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }
        
        //TODO: call the class to send out a query (the non- batch class)
    }
    
    @AuraEnabled
    public static Id createExceptionLogRecord(String pSerializedExeption){
        ExternalEntitySearchCX.ExceptionWrapper exWrapper = (ExternalEntitySearchCX.ExceptionWrapper) JSON.deserialize(pSerializedExeption, ExternalEntitySearchCX.ExceptionWrapper.class);
        ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
        Id recordId;
        if(exWrapper.isAppLoadException && !exceptionHandlingSettings.EntitySearchAppLoadFailureFlag__c ||  exWrapper.isCalloutException && !exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c || exWrapper.isAuthenticationException && !exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c){
            Exception_Log__c exceptionObj = new Exception_Log__c();
            exceptionObj.Class__c = exWrapper.className;
            exceptionObj.Method__c = exWrapper.methodName;
            exceptionObj.Message__c = exWrapper.exceptionMessage +'/n'+ exWrapper.exceptionStackTrace;
            exceptionObj.Running_User__c = UserInfo.getUserName(); 
            exceptionObj.Priority__c = exWrapper.priority;
            exceptionObj.UserFriendlyMessage__c = exWrapper.userFriendlyMessage;
            exceptionObj.LineNumber__c = String.valueOf(exWrapper.lineNumber);
            recordId = ExceptionLogService.insertExceptionLogRecord(exceptionObj);
        }
        exceptionHandlingSettings.EntitySearchAppLoadFailureFlag__c = exceptionHandlingSettings.EntitySearchAppLoadFailureFlag__c||exWrapper.isAppLoadException;
        exceptionHandlingSettings.GenericExceptionOccurred__c = exceptionHandlingSettings.GenericExceptionOccurred__c||exWrapper.isGenericException;
        exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c||exWrapper.isAuthenticationException;
        exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c||exWrapper.isCalloutException;
        update exceptionHandlingSettings;
        
        /*recordId = ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX', 'getComponentConfig', 
                                                                                       exWrapper.exceptionMessage,exWrapper.exceptionStackTrace , 'FATAL');*/
        
        return recordId;
    }
    
    @AuraEnabled
    public static GetCompanyDataResponse getMoreCompanyData(String pCompanyId, String pCountryCode){
        GetCompanyDataResponse response = new GetCompanyDataResponse();
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            ExternalEntitySearchService.GetCompanyDataResult getCompanyDataResponse = searchService.getCompanyInformationByCompanyIdAndCountryCode(pCompanyId, pCountryCode);
            response.serialisedResult = JSON.serialize(getCompanyDataResponse);
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','GetCompanyDataResponse', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static GetIndividualDataResponse getMoreOfficerData(String pOfficerId, String pCountryCode){
        GetIndividualDataResponse response = new GetIndividualDataResponse();
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            ExternalEntitySearchService.GetIndividualDataResult getOfficerDataResponse = searchService.getOfficerInformationByCompanyIdAndCountryCode(pOfficerId, pCountryCode);
            response.serialisedResult = JSON.serialize(getOfficerDataResponse);
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','GetIndividualDataResponse', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static GetCharityDataResponse getMoreCharityData(String pCharityId, String pCountryCode){
        GetCharityDataResponse response = new GetCharityDataResponse();
        try{
            EntitySearchSettings__mdt entitySearchSetting = EntitySearchSettingService.getCurrentEntitySearchSetting();
            ExternalEntitySearchService.Strategy searchService = (ExternalEntitySearchService.Strategy) Type.forName(entitySearchSetting.SearchProvider__c).newInstance();
            ExternalEntitySearchService.GetCharityDataResult getOfficerDataResponse = searchService.getCharityInformationByCompanyIdAndCountryCode(pCharityId, pCountryCode);
            response.serialisedResult = JSON.serialize(getOfficerDataResponse);
            ExceptionHandlingSettings__c exceptionHandlingSettings = ExceptionHandlingSettings__c.getValues('Global Settings');
            exceptionHandlingSettings.EntitySearchSalesforceSearchFailureFlag__c = false;
            exceptionHandlingSettings.WSO2AuthenticationFailureFlag__c = false;
            update exceptionHandlingSettings;
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','GetIndividualDataResponse', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Id createNewRecord(String pstrEntity, String pstrRecordIdentifier, String pstrCountryCode, String pstrRecordName){
        //TODO: Sneha please create a new record here for companes and charities
        
        Account newEntity = new Account();
        Id RecordTypeIdProspect = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        try{
            if(pstrEntity=='company'){
                
                newEntity = new Account(Name=pstrRecordName, Country_of_Incorporation__c=pstrCountryCode, AccountNumber=pstrRecordIdentifier, RecordTypeId = RecordTypeIdProspect, UniquekeyIdentifier__c = pstrCountryCode+'-'+pstrRecordIdentifier);
                insert newEntity;
                //CompanyDataRefresh.execute(new List<Account>{newEntity});
                Id statusRecordId = BulkAPIStatusManagement.createBulkJobLogRecord(true); 
                sendRefreshRequest(pstrRecordIdentifier, pstrCountryCode, statusRecordId, 'Company');
                //notifyRequestRefreshComplete('Company',statusRecord);
                
            }else if (pstrEntity=='charity'){
                
                newEntity = new Account(Name=pstrRecordName, CharityCountryCode__c=pstrCountryCode, CharityId__c=pstrRecordIdentifier, RecordTypeId = RecordTypeIdProspect, UniquekeyIdentifier__c = pstrRecordIdentifier+'-'+pstrCountryCode);
                insert newEntity;
                CharityDataRefreshCallout.execute(new List<Account>{newEntity});
                Id statusRecord = BulkAPIStatusManagement.createBulkJobLogRecord(true); 
                notifyRequestRefreshComplete('Charity',statusRecord);
                
            }
            
            
            
        }catch(Exception e){
            ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('ExternalEntitySearchCX','createNewRecord', e.getMessage(), 'ERROR'); 
            throw new AuraHandledException(e.getMessage());
        }
        
        return newEntity.Id;
    }
    
    private static void notifyRequestRefreshComplete(String entityType,Id statusRecord){
        DueDilBatchUpdateRequestWrapper requestWrapper = new DueDilBatchUpdateRequestWrapper(null, true, entityType, statusRecord);
        String calloutRequestBody = JSON.serialize(requestWrapper);
        BulkAPIStatusManagement.bulkJobCompletionCallout(calloutRequestBody,statusRecord, entityType);
    }
    
    @future(callout=true)
    private static void sendRefreshRequest(String accountNumber, String countryOfIncorporation, Id statusRecordId, String entity){
        CompanyDataRefresh.execute(new List<Account>{new Account(AccountNumber=accountNumber,Country_of_Incorporation__c=countryOfIncorporation)});
        notifyRequestRefreshComplete(entity,statusRecordId);
    }
}