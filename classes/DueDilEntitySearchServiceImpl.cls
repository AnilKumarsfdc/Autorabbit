public with sharing class DueDilEntitySearchServiceImpl implements ExternalEntitySearchService.Strategy{    
    
    public ExternalEntitySearchService.CompanySearchResult searchCompanyByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        ExternalEntitySearchService.CompanySearchResult results = new ExternalEntitySearchService.CompanySearchResult();
        Map<String, Id> mapCRNToSalesforceId = new Map<String, Id>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        set<String> CRNset = new set<String>();
        integer pQueryPageNumberToUse;
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        Decimal calloutAttempts;
        
        if(pQueryLimitToUse > 0){   
            pQueryPageNumberToUse =(10+ pQueryOffsetToUse)/pQueryLimitToUse;
        }
        
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();       
        System.debug('=======entitySearchSettings==='+entitySearchSettings);
        
        String encodedpQueryString = EncodingUtil.urlEncode(pQueryString, 'UTF-8');
        //try{
            String accessToken = this.getAccessToken();
            request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.CompanySearchEndpointPath__c+'?'+entitySearchSettings.NameParameter__c +'='+encodedpQueryString+'&'+entitySearchSettings.CountryCodeParameter__c+'='+''+pCountryCode+'&'+entitySearchSettings.PageNumberParameter__c+'='+pQueryPageNumberToUse+'&'+entitySearchSettings.PageSize__c+'='+pQueryLimitToUse);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('authorization', 'Bearer '+accessToken);   
            
            System.debug('accessToken >>>>'+accessToken);
            
            HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);      
            System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                // Deserializes the JSON string into collections of primitive data types.
                DueDilCompanySearchResponse responseBody = DueDilCompanySearchResponse.parse(response.getBody());
                //DueDilCompanySearchResponse responseBody = (DueDilCompanySearchResponse)JSON.deserialize(response.getBody(), DueDilCompanySearchResponse.class);
                system.debug('-------responseBody.data------'+responseBody.data);
                
                for(DueDilCompanySearchResponse.data account : responseBody.data){
                    
                    ExternalEntitySearchService.CompanyResultListItem companyResultListItem = new ExternalEntitySearchService.CompanyResultListItem();
                    companyResultListItem.CountryName = account.countryCode; //This field needs to be retrieved but it isn't displayed
                    companyResultListItem.CountryNameLowerCase = account.countryCode.toLowerCase(); //This field needs to be retrieved but it isn't displayed
                    companyResultListItem.Name = account.name;
                    companyResultListItem.CRN = account.companyId;
                    companyResultListItem.SimplifiedStatus = account.simplifiedStatus;
                    companyResultListItem.Address = (account.registeredAddress!=null && account.registeredAddress.fullAddress!=null)?account.registeredAddress.fullAddress:'';
                    List<String> lstSIC2007IndustryNames = new List<String>();
                    for (DueDilCompanySearchResponse.Industries industry : account.industries){
                        if (industry.type_Z=='SIC2007' && !String.isEmpty(industry.name)){
                            lstSIC2007IndustryNames.add(industry.name);
                        }
                    }
                    companyResultListItem.FormattedSICString = String.join(lstSIC2007IndustryNames, ', ');
                    //TODO: Need to add turnover
                    mapCRNToSalesforceId.put(account.countryCode + '-' + account.companyId,null);
                    results.searchResultListItems.add(companyResultListItem);                  
                }
                
                results.totalResults =responseBody.Paging.totalRecords;
                System.debug('mapCRNToSalesforceId ------------------------'+mapCRNToSalesforceId);
                
                // Fetch CRN from Account 
                if(!mapCRNToSalesforceId.keySet().isEmpty()){
                    System.debug('mapCRNToSalesforceId:' + mapCRNToSalesforceId);
                    for(Account accountsWithMatchingCRN : AccountService.getAccountsByUniqueKeyIdentifierSet(mapCRNToSalesforceId.keySet())){  
                        mapCRNToSalesforceId.put(accountsWithMatchingCRN.UniquekeyIdentifier__c, accountsWithMatchingCRN.Id);
                    }
                }
                System.debug('mapCRNToSalesforceId:' + mapCRNToSalesforceId);
                System.debug('GET mapCRNToSalesforceId ------------------------'+mapCRNToSalesforceId);
                for (ExternalEntitySearchService.CompanyResultListItem searchResultListItem :results.searchResultListItems){
                    searchResultListItem.SalesforceId = mapCRNToSalesforceId.get(searchResultListItem.CountryName+'-'+searchResultListItem.CRN);
                    
                    System.debug('GET searchResultListItem ------------------------'+searchResultListItem);
                }
                System.debug('GET results ------------------------'+results);
            }   
            else{
                System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
            }
        /*}
        catch(Exception e){
            System.debug('Standard Exception ------------------------'+e+ '___Final Exception DueDilEntitySearchServiceImpl searchCompanyByName MyMeThOd');
          //  ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('DueDilEntitySearchServiceImpl','searchCompanyByName',e,'ERROR');
            throw new BulkAPICustomException.customExtendedException(e.getMessage());
        }*/
        
        return results;
    }
    
    // Search Company by CRN    
    public ExternalEntitySearchService.CompanySearchResult searchCompanyByCRN(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){
        ExternalEntitySearchService.CompanySearchResult results = new ExternalEntitySearchService.CompanySearchResult();
        results = searchCompanyByName(pQueryString,pCountryCode,pQueryOffsetToUse,pQueryLimitToUse);
        return results;
        
    }
    
    // GET  Charity data
    public ExternalEntitySearchService.CharitySearchResult searchCharityByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){       
        ExternalEntitySearchService.CharitySearchResult results = new ExternalEntitySearchService.CharitySearchResult();
        Http http = new Http();
        HttpRequest request = new HttpRequest();        
        String accessToken = this.getAccessToken();
        integer pQueryPageNumberToUse;
        Map<String, Id> mapCharityToSalesforceId = new Map<String, Id>();
        Map<String,String> mapCharityToSalesforceId1 = new Map<String,String>();
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        
        if(pQueryLimitToUse > 0){   
            pQueryPageNumberToUse =(10+ pQueryOffsetToUse)/pQueryLimitToUse;
        }
        
        String encodedpQueryString = EncodingUtil.urlEncode(pQueryString, 'UTF-8');     
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();
        system.debug('=======entitySearchSettings==='+entitySearchSettings);
        
        request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.CharitySearchEndpointPath__c+'?'+entitySearchSettings.NameParameter__c +'='+encodedpQueryString+'&'+entitySearchSettings.PageNumberParameter__c+'='+pQueryPageNumberToUse+'&'+entitySearchSettings.CountryCodeParameter__c+'='+pCountryCode+'&'+entitySearchSettings.PageSize__c+'='+pQueryLimitToUse);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('authorization', 'Bearer '+accessToken);        
       //# HttpResponse response = http.send(request);  
		HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);   


		
        System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
        
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            DueDilCharitySearchResponse responseBody = DueDilCharitySearchResponse.parse(response.getBody());
            system.debug('-------responseBody.data------'+responseBody.data);
            
            for(DueDilCharitySearchResponse.data charity : responseBody.data){
                ExternalEntitySearchService.CharityResultListItem charityResultListItem = new ExternalEntitySearchService.CharityResultListItem(); 
                charityResultListItem.Name = charity.name; 
                charityResultListItem.CountryName = charity.countryCode;
                charityResultListItem.CurrentStatus= charity.CurrentStatus.status;
                charityResultListItem.CharityId= charity.CharityId;  
                mapCharityToSalesforceId.put(charity.CharityId +'-'+charity.countryCode,null);
                results.searchResultListItems.add(charityResultListItem);                 
            }
            results.totalResults =responseBody.Paging.totalRecords;
            System.debug('mapCharityToSalesforceId ------------------------'+mapCharityToSalesforceId);
            System.debug('results ------------------------'+results);
             
            // Fetch CRN from Account
            if(!mapCharityToSalesforceId.keySet().isEmpty()){   
                for(Account accountsWithMatchingCharity : AccountService.getAccountsByUniqueKeyIdentifierSet(mapCharityToSalesforceId.keySet())){  // Change WHERE Clause as soon as we get CharityID__c Company_Registration_Number__c as we get
                    mapCharityToSalesforceId.put(accountsWithMatchingCharity.UniquekeyIdentifier__c, accountsWithMatchingCharity.Id);
                }
            }
            
            System.debug('GET mapCharityToSalesforceId ------------------------'+mapCharityToSalesforceId);
            
            for (ExternalEntitySearchService.CharityResultListItem searchResultListItem :results.searchResultListItems){
                System.debug('GET searchResultListItem.CharityId ------------------------'+searchResultListItem.CharityId+'++'+mapCharityToSalesforceId.get(searchResultListItem.CharityId));
                
                //if(mapCharityToSalesforceId.get(searchResultListItem.CharityId) !=  null ){                  
                    searchResultListItem.SalesforceId = mapCharityToSalesforceId.get(searchResultListItem.CharityId+'-'+searchResultListItem.CountryName);
                //}        
                System.debug('GET searchResultListItem ------------------------'+searchResultListItem);
            } 
            System.debug('GET results ------------------------'+results);
        }else{
            System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
        }
        
        return results;
    }
    
    // GET  Individual/Officer data 
    public ExternalEntitySearchService.IndividualSearchResult searchIndividualByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse){      
        ExternalEntitySearchService.IndividualSearchResult results = new ExternalEntitySearchService.IndividualSearchResult();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String accessToken = this.getAccessToken();
        Integer pQueryPageNumberToUse;
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        
        if(pQueryLimitToUse > 0){   
            pQueryPageNumberToUse =(10+ pQueryOffsetToUse)/pQueryLimitToUse;
        }
        
        String encodedpQueryString = EncodingUtil.urlEncode(pQueryString, 'UTF-8');
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();
        system.debug('=======entitySearchSettings==='+entitySearchSettings);
        
        request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.OfficerSearchEndpointPath__c+'?'+entitySearchSettings.NameParameter__c +'='+encodedpQueryString+'&'+entitySearchSettings.PageNumberParameter__c+'='+pQueryPageNumberToUse+'&'+entitySearchSettings.PageSize__c+'='+pQueryLimitToUse+''+'&isCorporate=false');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('authorization', 'Bearer '+accessToken);        
        //HttpResponse response = http.send(request);       
		HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);   
        System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
        
        if (response.getStatusCode() == 200){
            // Deserializes the JSON string into collections of primitive data types.
            DueDilIndividualSearchResponse responseBody = (DueDilIndividualSearchResponse)JSON.deserialize(response.getBody(), DueDilIndividualSearchResponse.class);
            system.debug('-------responseBody.data------'+responseBody.data);
            
            for(DueDilIndividualSearchResponse.data individual : responseBody.data){
                ExternalEntitySearchService.IndividualResultListItem IndividualResultListItem = new ExternalEntitySearchService.IndividualResultListItem();                 

                IndividualResultListItem.IndividualId = individual.officerId;
                if(null!=individual.person){
                    IndividualResultListItem.FirstName= individual.person.firstName;
                    IndividualResultListItem.MiddleName= individual.person.middleName;
                    IndividualResultListItem.LastName =individual.person.lastName;
                    IndividualResultListItem.Title = individual.person.honorific;
                    IndividualResultListItem.MonthOfBirth = String.valueOf(individual.person.dateOfBirth.month);
                    IndividualResultListItem.YearOfBirth = String.valueOf(individual.person.dateOfBirth.year);
                    
                    
                    List<String> nationalities = new List<String>();
                    for(DueDilIndividualSearchResponse.Nationalities nationality: individual.person.nationalities){
                        nationalities.add(nationality.demonym);
                    }
                    IndividualResultListItem.Nationalities = String.join(nationalities,', ');
                    System.debug('IndividualResultListItem '+IndividualResultListItem);
                    //X IndividualResultListItem.CompanyName;
                    //XIndividualResultListItem.IsDisqualified;
                }
                results.searchResultListItems.add(IndividualResultListItem);                 
            } 
            
            results.totalResults =responseBody.Paging.totalRecords;
            System.debug('GET results ------------------------'+results);
        }   
        else{
            System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
        }
        
        return results; 
    }
    
    public ExternalEntitySearchService.GetCompanyDataResult getCompanyInformationByCompanyIdAndCountryCode(String pCompanyId, String pCountryCode){
        ExternalEntitySearchService.GetCompanyDataResult results = new ExternalEntitySearchService.GetCompanyDataResult();
		
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        set<String> CRNset = new set<String>();
        String accessToken = this.getAccessToken();
        
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();       
        System.debug('=======entitySearchSettings==='+entitySearchSettings);
        
                try{
			//https://api.101digital.io/company-information-service/v1.0/companies/GB/01724995?listReturnFields=All
            request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.CompanySearchEndpointPath__c+'/'+pCountryCode+'/'+pCompanyId);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('authorization', 'Bearer '+accessToken);   
            
            System.debug('accessToken >>>>'+accessToken);
            
            HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);      
            System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                DueDilGetCompanyDataResponse responseBody = DueDilGetCompanyDataResponse.parse(response.getBody());
                system.debug('-------responseBody.data------'+responseBody.data);
                results.turnover = responseBody.data.companyVitals.financialSummary.turnover;
                results.currencyString = responseBody.data.companyVitals.accounts.currency_Z;
            }   
            else{
                System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
            }
        }
        catch(Exception e){
            System.debug('Standard Exception ------------------------'+e+ '___Final Exception DueDilEntitySearchServiceImpl searchCompanyByName MyMeThOd'+e.getStackTraceString());
          //  ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('DueDilEntitySearchServiceImpl','searchCompanyByName',e,'ERROR');
            //throw new BulkAPICustomException.customExtendedException(e.getMessage());
        }
        
       //return results;
     return  results;
    }
    
    public ExternalEntitySearchService.GetCharityDataResult getCharityInformationByCompanyIdAndCountryCode(String pCharityId, String pCountryCode){
		
		ExternalEntitySearchService.GetCharityDataResult results = new ExternalEntitySearchService.GetCharityDataResult();
		
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        set<String> CRNset = new set<String>();
        String accessToken = this.getAccessToken();
        
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();       
        System.debug('=======entitySearchSettings==='+entitySearchSettings);
        
                try{
			//https://api.101digital.io/company-information-service/v1.0/charities/GB/ew-1127254-0
            request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.CharitySearchEndpointPath__c+'/'+pCountryCode+'/'+pCharityId);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('authorization', 'Bearer '+accessToken);   
            
            System.debug('accessToken >>>>'+accessToken);
            
            HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);      
            System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                DueDilGetCharityDataResponse responseBody = DueDilGetCharityDataResponse.parse(response.getBody());
                system.debug('-------responseBody FULL------'+responseBody);
                system.debug('-------responseBody.data------'+responseBody.data);
                if(null!= responseBody && null!= responseBody.data && null!= responseBody.data.charityVitals && null!= responseBody.data.charityVitals.officialContact){
                    results.officialContactEmail = responseBody.data.charityVitals.officialContact.email;
                    results.officialContactPhone = responseBody.data.charityVitals.officialContact.telephoneNumber;
                    results.officialContactFullAddress = responseBody.data.charityVitals.officialContact.fullAddress;
                }
            }   
            else{
                System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
            }
        }
        catch(Exception e){
            System.debug('Standard Exception ------------------------'+e+ '___Final Exception DueDilEntitySearchServiceImpl searchCompanyByName MyMeThOd');
          //  ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('DueDilEntitySearchServiceImpl','searchCompanyByName',e,'ERROR');
            //throw new BulkAPICustomException.customExtendedException(e.getMessage());
        }
        
       //return results;
     return  results;
        
    }
    
    public ExternalEntitySearchService.GetIndividualDataResult getOfficerInformationByCompanyIdAndCountryCode(String pOfficerId, String pCountryCode){
		
		ExternalEntitySearchService.GetIndividualDataResult results = new ExternalEntitySearchService.GetIndividualDataResult();
		List<ExternalEntitySearchService.GetIndividualDataAppointmentResult> appointments = new List<ExternalEntitySearchService.GetIndividualDataAppointmentResult>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String accessToken = this.getAccessToken();
        
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();       
        System.debug('=======entitySearchSettings==='+entitySearchSettings);
        
                try{
			//https://api.101digital.io/company-information-service/v1.0/officers/917588417?listReturnFields=All
            request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c  +entitySearchSettings.OfficerSearchEndpointPath__c+'/'+pOfficerId);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('authorization', 'Bearer '+accessToken);   
            
            System.debug('accessToken >>>>'+accessToken);
            
            HttpResponse response = CalloutAttemptController.secureCallout(request,entitySearchSettings);      
            System.debug('-------------response.getStatusCode()-----------'+response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                DueDilGetOfficerDataResponse responseBody = DueDilGetOfficerDataResponse.parse(response.getBody());
                system.debug('-------responseBody.data------'+responseBody.data);
                for(DueDilGetOfficerDataResponse.Data data : responseBody.data.officerAppointment.data){
                    for (DueDilGetOfficerDataResponse.Appointments officerAppointment : data.appointments){
                        ExternalEntitySearchService.GetIndividualDataAppointmentResult appointment = new ExternalEntitySearchService.GetIndividualDataAppointmentResult();    
						
							appointment.companyName = data.name;
							appointment.companyId = data.companyId;
							appointment.companyCountryCode = data.countryCode;
							appointment.status = officerAppointment.status;
							appointment.startDate = officerAppointment.startDate;
							appointment.endDate = officerAppointment.endDate;
							appointment.officialRole = officerAppointment.officialRole;
							appointment.serviceAddress = officerAppointment.serviceAddress.fullAddress;
                            appointments.add(appointment);    
                    }
                    
                    
                }
                results.appointments = appointments;
              system.debug('¬¬¬¬¬¬¬¬¬results¬¬¬¬¬¬¬¬¬¬¬¬¬'+results);
            }   
            else{
                System.debug('ELSE -------------response.getStatusCode()-----------'+response.getStatusCode()+'get status '+response.getStatus());
            }
        }
        catch(Exception e){
            System.debug('Standard Exception ------------------------'+e+ '___Final Exception DueDilEntitySearchServiceImpl searchCompanyByName MyMeThOd');
          //  ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('DueDilEntitySearchServiceImpl','searchCompanyByName',e,'ERROR');
            //throw new BulkAPICustomException.customExtendedException(e.getMessage());
        }
        
       //return results;
     return  results;
        
    }
    
    
    // POST metod to get Access Token  getAccessToken RENAME   *****
	public  String getAccessToken(){
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();
        entitySearchSettings = EntitySearchSettingService.getCurrentEntitySearchSetting();
        
        HttpResponse response = new HttpResponse();
        String access_token;
        //try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();            
            AuthProvider authProv = [SELECT ConsumerKey,ConsumerSecret FROM AuthProvider where DeveloperName = 'EntitySearchApp' LIMIT 1];
            request.setEndpoint('callout:'+entitySearchSettings.NamedCredentialsAPIName__c+'/token?grant_type=client_credentials');  
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            NamedCredential nc = NamedCredentialService.getDueDilNamedCredential(entitySearchSettings.NamedCredentialsAPIName__c);
            request.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(nc.AuthProvider.ConsumerKey+':'+nc.AuthProvider.ConsumerSecret)));
            //request.setHeader('Authorization', 'Basic XZDJmWGJhVjg3Z2pyQmZXbGZzSTdJbUQ2eG5jYTpmWlFubGppZkNOSjVTWHZNZFhzQllMUWZ3SVlhXXX');   
            response = http.send(request); 
            System.debug('----response.getStatusCode() ---'+response.getStatusCode());
            System.debug('----response.getStatus() ---'+response.getStatus());
            // Parse the JSON response
            
            System.debug('----Final ---'+response.getBody());
            // Parse the JSON response
            if (response.getStatusCode() != 200) {  // 200 OK
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                throw new AccessTokenRetrievalException('Obtaining an access token was unsuccessful. Response code '+ response.getStatusCode() + ' was retrieved in the call to the token endpoint.');
            }else{
                
                System.debug('----Final ---'+response.getBody());
                Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                access_token = (String) results1.get('access_token');
                String token_type = (String) results1.get('token_type');
                System.debug('Received the  access_token:'+access_token+'---------token_type-----'+token_type);
            }         
        /*}catch(System.CalloutException ce){
            throw new 
            
        }catch(exception e){
            System.debug('----Exception ---'+e);
            System.debug('Standard Exception ------------------------'+e+ '___Final Exception DueDilEntitySearchServiceImpl searchCompanyByName MyMeThOd');
           // ExceptionLogService.insertExceptionLogRecordAndPrintDebugStatements('DueDilEntitySearchServiceImpl','searchCompanyByName',e,'ERROR');
           // 
        } */
       
        
        return access_token;
    }
    
    public class AccessTokenRetrievalException extends Exception{
        String Priority = 'FATAL';
    }
}