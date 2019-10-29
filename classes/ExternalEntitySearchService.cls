public with sharing class ExternalEntitySearchService {
    public class CompanySearchResult{
       public  List<CompanyResultListItem> searchResultListItems= new List<CompanyResultListItem> ();
       public  Integer totalResults; 
    }
    
    public class CharitySearchResult{
        public List<CharityResultListItem> searchResultListItems= new List<CharityResultListItem> ();
        public Integer totalResults;
    }
    
    public class IndividualSearchResult{
        public List<IndividualResultListItem> searchResultListItems= new List<IndividualResultListItem> ();
        public Integer totalResults;
    }
    
    public class GetCompanyDataResult{
        public Long turnover;
        public String currencyString;
    }
    
    public class GetCharityDataResult{
        public String officialContactName;
        public String officialContactEmail;
        public String officialContactPhone;
        public String officialContactFullAddress;
    }
    
    public class GetIndividualDataResult{
        public List<GetIndividualDataAppointmentResult> appointments;
    }
    
    public class GetIndividualDataAppointmentResult{
        public String companyName;
        public String companyId;
        public String companyCountryCode;
        public String status;
        public String startDate;
        public String endDate;
        public String officialRole;
        public String serviceAddress;//fullAddress
    }
    
    public interface Strategy{
        CompanySearchResult searchCompanyByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse);
        CharitySearchResult searchCharityByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse);
        IndividualSearchResult searchIndividualByName(String pQueryString, String pCountryCode, Integer pQueryOffsetToUse, Integer pQueryLimitToUse);
        GetCompanyDataResult getCompanyInformationByCompanyIdAndCountryCode(String pCompanyId, String pCountryCode);
        GetCharityDataResult getCharityInformationByCompanyIdAndCountryCode(String pCharityId, String pCountryCode);
        GetIndividualDataResult getOfficerInformationByCompanyIdAndCountryCode(String pOfficerId, String pCountryCode);
    }
    
    public class CompanyResultListItem{
        @AuraEnabled public Id SalesforceId;
        @AuraEnabled public String CountryName;
        @AuraEnabled public String CountryNameLowerCase;
        @AuraEnabled public String Name;
        @AuraEnabled public String CRN;
        @AuraEnabled public String SimplifiedStatus;
        @AuraEnabled public String Address;
        @AuraEnabled public String FormattedSICString;
        @AuraEnabled public String FormattedTurnover;
    }
    
    public class CharityResultListItem{
        @AuraEnabled public Id SalesforceId; 
        @AuraEnabled public String Name;
        @AuraEnabled public String CountryName;
        @AuraEnabled public String CountryNameLowerCase;
        @AuraEnabled public String CharityId;
        @AuraEnabled public String Address;
        @AuraEnabled public String CurrentStatus;        
    }
    
    public class IndividualResultListItem{
        @AuraEnabled public String IndividualId;
        @AuraEnabled public String Title;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String MiddleName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String Nationalities;
        @AuraEnabled public String MonthOfBirth;
        @AuraEnabled public String YearOfBirth;
        @AuraEnabled public String CompanyName;
        @AuraEnabled public Boolean IsDisqualified;
        @AuraEnabled public String DOB;
    }
}