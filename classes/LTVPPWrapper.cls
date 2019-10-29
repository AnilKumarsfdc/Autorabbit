public without sharing class LTVPPWrapper {
    
    @AuraEnabled Public Decimal totalFacilityAmt{get;set;}
    @AuraEnabled Public Decimal TotalLendableValue{get;set;}
    @AuraEnabled Public Decimal TotalSantanderValue{get;set;}
    @AuraEnabled Public Decimal LTV{get;set;}
    @AuraEnabled Public Boolean isError{get;set;}
    @AuraEnabled Public string errorMessage{get;set;}
    
    public LTVPPWrapper()
    {
        totalFacilityAmt = 0;
        TotalLendableValue = 0 ;
        TotalSantanderValue = 0;
        LTV = 0;
        isError = False;
        errorMessage = '';
    }

}