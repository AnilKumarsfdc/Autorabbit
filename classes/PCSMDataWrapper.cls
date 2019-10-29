public class PCSMDataWrapper {
    
    @AuraEnabled
    public Boolean isValidationError{get;set;}
    @AuraEnabled
    public Boolean isPolicyExceptionError{get;set;}
    @AuraEnabled
    public Boolean isError{get;set;}
    @AuraEnabled
    public Boolean isNoLoanError{get;set;}
    @AuraEnabled 
    public List<PCSMData> pcsmList;
    @AuraEnabled
    public Boolean isApprovalProcessError{get;set;}
    

   
    
    public class PCSMData{
        
        @AuraEnabled
        public String loanId{get;set;} 
        @AuraEnabled
        public String loanName{get;set;} 
        @AuraEnabled
        public String AutoDecision{get;set;} 
        @AuraEnabled
        public String NcinoDecision{get;set;} 
         
        
    } 

}