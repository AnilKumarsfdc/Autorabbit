/****************************************************************
* ClassName: LTVWrapper
* Description: LTVWrapper encapsulate the data sent to Lightning Component
* Date: 14/9/2019
* Functionality: LTV
* *************************************************************/
public  without sharing class LTVWrapper {
    
    /*****************************************************/
	@AuraEnabled public List<Account> relRelationshipList;
    @AuraEnabled public List<LLC_BI__Loan__c> relLoanList;  
    @AuraEnabled public List<LLC_BI__Collateral__c> relCollateralList;  
    @AuraEnabled public  String profileName {get;set;}
    @AuraEnabled public List<loanWrapper> selectedloanslist;
    @AuraEnabled public List<CollateralWrapper> selectedCollateralslist;
    @AuraEnabled public List<realtionshipWrapper> selectedRealtionshipslist;
    @AuraEnabled public List<Risk_Group__c> riskGrpList {get;set;}
    @AuraEnabled public List<riskGroupWrapper> riskGroupLst {get;set;}
    /*****************************************************/
    @AuraEnabled public List<LLC_BI__Loan__c> listLoan;
    @AuraEnabled public List<LLC_BI__Collateral__c> listCollateral;
    @AuraEnabled public List<Account> listAccount;
    @AuraEnabled public Risk_Group__c riskGrp;
    
    @AuraEnabled public boolean isCreateAllowed;
    @AuraEnabled public boolean isReadAllowed;
    @AuraEnabled public boolean isUpdateAllowed;
    @AuraEnabled public boolean isDeleteAllowed;
    @AuraEnabled public string errorMessage;
    
    public String duplicateCheck='false';
    public Id riskGroupId;
    public Id prodpageId;
    
    public LTVWrapper(){
        riskGrpList = new List<Risk_Group__c>();
    }    
    
    public class loanWrapper{
        
        @AuraEnabled
        public String loanId{get;set;} 
        @AuraEnabled
        public String Name{get;set;} 
        @AuraEnabled
        public String Stage{get;set;} 
        @AuraEnabled
        public Decimal Amount{get;set;} 
        @AuraEnabled
        public Boolean loanCheck{get;set;}
        @AuraEnabled
        public string loanStatus{get;set;}
    } 
    
    public  class CollateralWrapper{
        
        @AuraEnabled
        public String collateralId{get;set;} 
        @AuraEnabled
        public String collateralNumber{get;set;} 
        @AuraEnabled
        public String Name{get;set;} 
        @AuraEnabled
        public String Type{get;set;} 
        @AuraEnabled
        public Boolean collateralCheck{get;set;}
        @AuraEnabled
        public string collStatus{get;set;}
    }
    
    public  class realtionshipWrapper{
        
        @AuraEnabled
        public String relatinshipId{get;set;} 
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Type{get;set;}
        @AuraEnabled 
        public String JFNumber{get;set;}
        @AuraEnabled 
        public Boolean accountcheck{get;set;}
        @AuraEnabled
        public string relStatus{get;set;}
    }
    
    public  class riskGroupWrapper{
        
        @AuraEnabled
        public Risk_Group__c riskGroupRec{get;set;} 
        @AuraEnabled
        public Boolean inactiveLoan {get;set;}
        @AuraEnabled
        public Boolean inactiveCollateral {get;set;}
        @AuraEnabled
        public Boolean inactiveRelationship {get;set;}
        @AuraEnabled
        public Boolean noLoan {get;set;}
        @AuraEnabled
        public Boolean noCollateral {get;set;}
    }
    
}