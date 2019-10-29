@IsTest
public class ExternalEntitySearchCX_Test {

    @testSetup static void setup() {
        // Create common test accounts
       
        
        Id ProspectRCId = RecordTypeSelectorWOS.getProspectRecordTypeId();
        List<Account> accountList = (List<Account>)TestFactory.createNewSobject('Account', 5);
        List<Account> formatedAccountList = new List<Account>();
        for(Account acc : accountList){
            acc.AccountNumber = TestFactory.generateRandomString(5);
            acc.Country_of_Incorporation__c = 'GB';
            acc.BillingStreet = 'Test Street';
            acc.BillingCity = 'Test City';
            acc.BillingPostalCode = 'Test Postal Code';
            acc.SIC_Description_Level_2__c = 'Test Data';
            acc.SIC_Description_Level_3__c = 'Test Data';
            acc.SIC_Description_Level_4__c = 'Test Data';
            acc.Name = 'Tata';
            formatedAccountList.add(acc);
        }

        insert formatedAccountList;
        
        system.debug('+++++++++++++test33 acc formatedAccountList+++++++++'+formatedAccountList);
        
        ExceptionHandlingSettings__c settings = new ExceptionHandlingSettings__c();
        settings.name = 'Global Settings';
            Insert settings;
    }
    
 
     static testmethod void SearchResponseCompany(){
        Test.startTest(); 
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];
        
        try {       
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('MockCompanyJson');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            // Call method to test
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.SearchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchCompanyByName(acc.Name,acc.Country_Of_Incorporation__c,'company',1,10); 
            System.assertNotEquals(null,searchResponse,'The callout returned a null response.'); 
            
            ExternalEntitySearchCX.getComponentConfig();
        }
        catch(exception e){
                 system.debug('+++++++++++++test1+++++++++'+e);
        }   
        
        Test.stopTest();
     }
     
     static testmethod void SearchResponseCompanyCalloutException(){
        Test.startTest(); 
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];
        
        try {       
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('MockCompanyJson');
            mock.setStatusCode(401);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            // Call method to test
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.SearchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchCompanyByName(acc.Name,acc.Country_Of_Incorporation__c,'company',1,10); 
            System.assertNotEquals(null,searchResponse,'The callout returned a null response.'); 
            
            ExternalEntitySearchCX.getComponentConfig();
        }
        catch(exception e){
                 system.debug('+++++++++++++test1+++++++++'+e);
        }   
        
        Test.stopTest();
     }

     static testmethod void SearchResponseCharity(){
                
        Test.startTest();  
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];

        try{     
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('MockCharityJson');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.SearchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchCharityByName(acc.Name,acc.Country_Of_Incorporation__c,'charity',1,10); 
            // Verify mock response is not null
            System.assertNotEquals(null,searchResponse,'The callout returned a null response.');
        }
        catch(exception e){
            system.debug('+++++++++++++test2+++++++++'+e);
        }   

        Test.stopTest();
     }
     
     static testmethod void SearchResponseCharityCalloutException(){
                
        Test.startTest();  
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];

        try{     
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('MockCharityJson');
            mock.setStatusCode(401);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.SearchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchCharityByName(acc.Name,acc.Country_Of_Incorporation__c,'charity',1,10); 
            // Verify mock response is not null
            System.assertNotEquals(null,searchResponse,'The callout returned a null response.');
        }
        catch(exception e){
            system.debug('+++++++++++++test2+++++++++'+e);
        }   

        Test.stopTest();
     }
    
     static testmethod void SearchResponseIndividual(){
        Test.startTest();        
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];
        
        try{
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            List<Account> queriedAccounts;
            mock.setStaticResource('MockIndividualJson');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.searchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchIndividualByName(acc.Name,acc.Country_Of_Incorporation__c,'individual',1,10); //individual 
            
            ExternalEntitySearchCX.SalesforceAccountSearchResponse salesforceAccSearchResponse = new ExternalEntitySearchCX.SalesforceAccountSearchResponse();
            salesforceAccSearchResponse =  ExternalEntitySearchCX.SalesforceAccountSearchResponse.querySalesforceForSuggestedCompaniesByNameAndCountryCode(acc.name,acc.Country_Of_Incorporation__c,1,10); 
            
            System.assert(salesforceAccSearchResponse != null);

            queriedAccounts = AccountService.getPaginatedAccountsByNameAndCountryCode(acc.name,acc.Country_Of_Incorporation__c,1,10);
            system.debug('+++++++++++++test33+++++++++'+queriedAccounts);
        }
        catch(exception e){
            system.debug('+++++++++++++test3+++++++++'+e);
        }   
        Test.stopTest();
    } 
    
    static testmethod void SearchResponseIndividualCalloutException(){
        Test.startTest();        
        
        Account acc = [Select Id, Name, Country_of_Incorporation__c from Account limit 1];
        
        try{
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            List<Account> queriedAccounts;
            mock.setStaticResource('MockIndividualJson');
            mock.setStatusCode(401);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            ExternalEntitySearchCX.SearchResponse searchResponse = new ExternalEntitySearchCX.searchResponse();
            searchResponse =  ExternalEntitySearchCX.SearchResponse.searchIndividualByName(acc.Name,acc.Country_Of_Incorporation__c,'individual',1,10); //individual 
            
            ExternalEntitySearchCX.SalesforceAccountSearchResponse salesforceAccSearchResponse = new ExternalEntitySearchCX.SalesforceAccountSearchResponse();
            salesforceAccSearchResponse =  ExternalEntitySearchCX.SalesforceAccountSearchResponse.querySalesforceForSuggestedCompaniesByNameAndCountryCode(acc.name,acc.Country_Of_Incorporation__c,1,10); 
            
            System.assert(salesforceAccSearchResponse != null);

            queriedAccounts = AccountService.getPaginatedAccountsByNameAndCountryCode(acc.name,acc.Country_Of_Incorporation__c,1,10);
            system.debug('+++++++++++++test33+++++++++'+queriedAccounts);
        }
        catch(exception e){
            system.debug('+++++++++++++test3+++++++++'+e);
        }   
        Test.stopTest();
    } 
    
    static testmethod void searchCompanyByNameException(){
        Test.startTest();
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        try{
            ExternalEntitySearchCX.SearchResponse companySearchResponse = ExternalEntitySearchCX.searchCompanyByName(null, null, null, null, null);
            System.assert(companySearchResponse != null);
        }
        catch(exception e){
            system.debug('+++++++++++++searchCompanyByNameSuccessTest+++++++++'+e);
        }
        Test.stopTest();
    }
    
    static testmethod void searchCharityByNameException(){
        Test.startTest();
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        
        try{
            ExternalEntitySearchCX.SearchResponse charitySearchResponse = ExternalEntitySearchCX.searchCharityByName(null, null, null, null, null);
            System.assert(charitySearchResponse != null);
        }
        catch(Exception e){
            system.debug('++++++++++++searchCharityByNameSuccessTest+++++++++'+e);
        }
        Test.stopTest();
    }
    
    static testmethod void searchIndividualByNameException(){
        Test.startTest();
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        try{
            ExternalEntitySearchCX.SearchResponse individualSearchResponse = ExternalEntitySearchCX.searchIndividualByName(null, null, null, null, null);
            System.assert(individualSearchResponse != null);
        }
        catch(Exception e){
             system.debug('++++++++++++searchIndividualByNameSuccessTest+++++++++'+e);
        }
        Test.stopTest();
    }
    
    static testmethod void triggerCompanyUpdateSuccess(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
            ExternalEntitySearchCX.triggerCompanyUpdate(acc.Id, acc.UniquekeyIdentifier__c, 'US', 'company');
            Account accUpd = [Select Id, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account where Id = :acc.Id ];
            System.assert(accUpd.Country_Of_Incorporation__c.equalsIgnoreCase('US'));
        }
        catch(exception e){
            system.debug('+++++++++++++triggerCompanyUpdateSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
     static testmethod void triggerCharityUpdateSuccess(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
            ExternalEntitySearchCX.triggerCompanyUpdate(acc.Id, acc.UniquekeyIdentifier__c, 'US', 'charity');
            Account accUpd = [Select Id, CharityCountryCode__c, UniquekeyIdentifier__c from Account where Id = :acc.Id ];
            System.assert(accUpd.CharityCountryCode__c.equalsIgnoreCase('US'));
        }
        catch(exception e){
            system.debug('+++++++++++++triggerCompanyUpdateSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
     static testmethod void triggerCharityUpdateFail(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
            ExternalEntitySearchCX.triggerCompanyUpdate(null, null, null, 'charity');
            Account charityUpd = [Select Id, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account where Id = :acc.Id ];
            System.assert(charityUpd.Country_Of_Incorporation__c.equalsIgnoreCase(charityUpd.Country_Of_Incorporation__c));
        }
        catch(exception e){
            system.debug('+++++++++++++triggerCompanyUpdateSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
       static testmethod void createNewRecordTestCompany(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
            Id companyIdCreated = ExternalEntitySearchCX.createNewRecord('Company', acc.UniquekeyIdentifier__c, 'GB', acc.AccountNumber);
            System.assert(companyIdCreated != null);
        }
        catch(exception e){
            system.debug('+++++++++++++createNewRecordSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    static testmethod void createNewRecordTestCharity(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
           Id charityIdCreated = ExternalEntitySearchCX.createNewRecord('Charity', acc.UniquekeyIdentifier__c, 'GB', acc.AccountNumber);
           System.assert(charityIdCreated != null);
        }
        catch(exception e){
            system.debug('+++++++++++++createNewRecordSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
    static testmethod void createNewRecordTestException(){
        Test.startTest();

        try{                        
            ExternalEntitySearchCX.createNewRecord('Company',null,'IN',null);
            List<Account> acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account Where Country_Of_Incorporation__c = 'IN'];
            System.assert(acc == null);
            
        }
        catch(exception e){
            system.debug('+++++++++++++createNewRecordSuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
    static testmethod void getMoreCompanyData(){
        Test.startTest();
        
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        try{
            
            ExternalEntitySearchCX.GetCompanyDataResponse companyDataResponse = ExternalEntitySearchCX.getMoreCompanyData(acc.id, 'GB');
            System.assert(companyDataResponse != null);
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreCompanyData1SuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    static testmethod void getMoreCompanyDataException(){
        Test.startTest();
        try{
            
            ExternalEntitySearchCX.GetCompanyDataResponse companyDataResponse = ExternalEntitySearchCX.getMoreCompanyData(null,null);
            System.assert(companyDataResponse == null);
            
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreCompanyData2SuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
    static testmethod void getMoreOfficerDataTest(){
        Test.startTest();        

        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];

        try{                        
            ExternalEntitySearchCX.GetIndividualDataResponse officerDataResponse = ExternalEntitySearchCX.getMoreOfficerData(acc.Id, acc.Country_Of_Incorporation__c);
            System.assert(officerDataResponse != null);
            
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreOfficerDataTest1SuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
     static testmethod void getMoreOfficerDataTestException(){
        Test.startTest();        

        try{                        
            ExternalEntitySearchCX.GetIndividualDataResponse officerDataResponse = ExternalEntitySearchCX.getMoreOfficerData(null, null);
            System.assert(officerDataResponse == null);
            
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreOfficerDataTest2SuccessTest+++++++++'+e);
        }   
        Test.stopTest();
    }
    
    static testmethod void getMoreCharityDataTest(){
        Test.startTest();
        
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        try{
            ExternalEntitySearchCX.GetCharityDataResponse charityDataResponse = ExternalEntitySearchCX.getMoreCharityData(acc.Id, acc.Country_Of_Incorporation__c);
            System.assert(charityDataResponse != null);
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreCharityDataTest1SuccessTest+++++++++'+e);
        }
        Test.stopTest();
    }
    
    static testmethod void getMoreCharityDataTestException(){
        Test.startTest();
        try{
            ExternalEntitySearchCX.GetCharityDataResponse charityDataResponse = ExternalEntitySearchCX.getMoreCharityData(null, null);
            System.assert(charityDataResponse == null);
        }
        catch(exception e){
            system.debug('+++++++++++++getMoreCharityDataTest2SuccessTest+++++++++'+e);
        }
        Test.stopTest();
    }
    
    
    static testmethod void querySalesforceForSuggestedCompaniesByNameAndCountryCodeFailure(){
        Test.startTest();
        Account acc = [Select Id, AccountNumber, Country_Of_Incorporation__c, UniquekeyIdentifier__c from Account LIMIT 1];
        try{
            ExternalEntitySearchCX.SalesforceAccountSearchResponse salesforceAccSearchResponse = ExternalEntitySearchCX.querySalesforceForSuggestedCompaniesByNameAndCountryCode(null, null, null, null);
            System.assert(salesforceAccSearchResponse != null);
        }
        catch(Exception e){
            system.debug('++++++++++++searchIndividualByNameSuccessTest+++++++++'+e);
        }
        Test.stopTest();    
    }
    
    static testmethod void createExceptionLogRecord(){
        Test.startTest();
            
            ExternalEntitySearchCX.ExceptionWrapper exceptionWrap = new ExternalEntitySearchCX.ExceptionWrapper();
            exceptionWrap.exceptionMessage = 'Exception Message';
            exceptionWrap.exceptionStackTrace = 'Exception Stack Trace';
            exceptionWrap.userFriendlyMessage='This is Test Class MEssage';
            exceptionWrap.isAuthenticationException = true;
            exceptionWrap.isCalloutException = true;
            exceptionWrap.isGenericException = false;
            exceptionWrap.isAppLoadException = true;
            exceptionWrap.className ='ExternalEntitySearchCX';
            exceptionWrap.methodName='getComponentConfig';
            exceptionWrap.priority = 'FATAL';
            exceptionWrap.lineNumber= 10;
            ExternalEntitySearchCX.createExceptionLogRecord(JSON.serialize(exceptionWrap));
            
            ExternalEntitySearchCX.CountryPicklistEntry wrap2 = new  ExternalEntitySearchCX.CountryPicklistEntry();   
            
            wrap2.label='GB';
            wrap2.value='GB';
            
            System.assert( exceptionWrap != null );
        
            
        Test.stopTest();
    }
    
}