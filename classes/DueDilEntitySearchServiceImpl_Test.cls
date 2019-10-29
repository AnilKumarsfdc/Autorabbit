@IsTest
public class DueDilEntitySearchServiceImpl_Test { 
    static testmethod void test1(){
        Test.startTest(); 
        //searchCompanyByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse)
        //
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockCompanyJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        DueDilEntitySearchServiceImpl obj = new DueDilEntitySearchServiceImpl();
         
        ExternalEntitySearchService.CompanySearchResult results = new ExternalEntitySearchService.CompanySearchResult();
        
        results = obj.searchCompanyByCRN('TATA','GB',0,1);  
        
        System.assert(results != null);
         
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('MockCharityJson');
        mock1.setStatusCode(200);
        mock1.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock1);        
        ExternalEntitySearchService.CharitySearchResult charityresults = new ExternalEntitySearchService.CharitySearchResult();
         
        charityresults = obj.searchCharityByName('TATA','GB',0,1);  
         
        System.assert(charityresults != null);
         
         
        Test.stopTest();     
    }
        static testmethod void test2(){
        Test.startTest(); 
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockIndividualJson'); 
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        DueDilEntitySearchServiceImpl obj = new DueDilEntitySearchServiceImpl();
        ExternalEntitySearchService.IndividualSearchResult individualresults = new ExternalEntitySearchService.IndividualSearchResult();
        individualresults = obj.searchIndividualByName('TATA','GB',0,1);  
        
        System.assert(individualresults != null);
        
        Test.stopTest();     
    }

        static testmethod void test3(){
        Test.startTest(); 
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockGetCompanyByIDJson'); 
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);        

        DueDilEntitySearchServiceImpl obj3 = new DueDilEntitySearchServiceImpl();
        ExternalEntitySearchService.GetCompanyDataResult companyResult =  obj3.getCompanyInformationByCompanyIdAndCountryCode('01724995','GB');
        System.assert(companyResult != null);
        Test.stopTest();     
    }  
       
	   static testmethod void test4(){
        Test.startTest(); 
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockGetCharityByIDJson'); 
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);        

        DueDilEntitySearchServiceImpl obj3 = new DueDilEntitySearchServiceImpl();
        ExternalEntitySearchService.GetCharityDataResult charityResult = obj3.getCharityInformationByCompanyIdAndCountryCode('ew-1089464-0','GB');
    	System.assert(charityResult != null);
    	Test.stopTest();     
    }   
       
	   static testmethod void test5(){
        Test.startTest(); 
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockGetOfficerByIDJson'); 
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);        

        DueDilEntitySearchServiceImpl obj3 = new DueDilEntitySearchServiceImpl();
        ExternalEntitySearchService.GetIndividualDataResult individualResult = obj3.getOfficerInformationByCompanyIdAndCountryCode('701657098','GB');
        System.assert(individualResult != null);
        Test.stopTest();     
    }   

}