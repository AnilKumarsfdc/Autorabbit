global with sharing class DueDilBatchUpdateRequestWrapper {
    
    global class CompanyMatchCriteriaWrapper{        
        global String countryCode;
        global String entityId;
        global CompanyMatchCriteriaWrapper(String companyRegistrationNumberArg, String operatingCountryCodeArg){
            this.entityId = companyRegistrationNumberArg;
            this.countryCode = operatingCountryCodeArg;
        }
    }
    global List<CompanyMatchCriteriaWrapper> listEntities = new List<CompanyMatchCriteriaWrapper>();
    global Boolean returnOfficers;
    global String entityType;
    global String endRefreshRequestId;

    global DueDilBatchUpdateRequestWrapper(List<CompanyMatchCriteriaWrapper> companyMatchKeyArg, Boolean returnOfficersArg, String entityTypeArg, String endRefreshRequestIdArg) {
        this.entityType = entityTypeArg;
        this.listEntities = companyMatchKeyArg;        
        this.returnOfficers = returnOfficersArg;
        this.endRefreshRequestId = endRefreshRequestIdArg;
    }
}