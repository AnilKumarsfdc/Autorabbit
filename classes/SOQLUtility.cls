/************************************************
Name:SOQLUtility
Descritption:Common utility class to manage all the SOQL queries used across Apex classes
Created By: Poonam Yadav 
Created Date: 26/08/2019
**************************************************/
public without sharing class SOQLUtility {
    public static boolean atRGLevel {get; set;}

    public static List<LLC_BI__Loan__c> fetchLoans(string ppID){
        List<LLC_BI__Loan__c> ppList;
        //if (atRGLevel == null || !atRGLevel) {
            ppList = [Select id,LLC_BI__Product_Package__c, LLC_BI__Amount__c 
                      from LLC_BI__Loan__c 
                      where LLC_BI__Product_Package__c =:ppID and LLC_BI__Status__c IN ('Open','Hold','In Review')];
                     //and Active_Loan_LTV__c = true];
        
        system.debug('ppList-->' +ppList);
        return ppList;
    }
     // needs to be deleted
   /* public static List<Related_Loan__c> fetchLTVLoans(string ltvID){
        List<Related_Loan__c> relatedLoans = [Select Id,Loan__c,Loan__r.LLC_BI__Product_Package__c,Loan__r.LLC_BI__Amount__c from Related_Loan__c WHERE Risk_Group__c =: ltvID];
        return relatedLoans;
    }
    
    public static List<Related_Collateral__c> fetchLTVCol(string ltvID){
        List<Related_Collateral__c> relatedCol = [Select Id from Related_Collateral__c WHERE Risk_Group__c =: ltvID];
        return relatedCol;
    }*/
    
    
    
     public static List<LLC_BI__Loan_Collateral2__c> sumofCollateral(set<id> loanId){
         system.debug('coll query ' + 'select LLC_BI__Collateral__c,LLC_BI__Collateral__r.Collateral_Valuation_Value__c,LLC_BI__Collateral__r.Direct_Third_Party_Charge__c,LLC_BI__Collateral__r.Further_Advance_with_no_DoP__c,LLC_BI__Collateral__r.Ranking__c,LLC_BI__Collateral__r.Collateral_Type_Formula__c,LLC_BI__Collateral__r.Santander_Value__c,LLC_BI__Collateral__r.Lendable_Value_WDV__c from LLC_BI__Loan_Collateral2__c where LLC_BI__Loan__c IN ' + loanId);
        List<LLC_BI__Loan_Collateral2__c> collateralList = [select LLC_BI__Collateral__c,
                                                            LLC_BI__Collateral__r.Collateral_Valuation_Value__c,
                                                            LLC_BI__Collateral__r.Direct_Third_Party_Charge__c,
                                                            LLC_BI__Collateral__r.Further_Advance_with_no_DoP__c,
                                                            LLC_BI__Collateral__r.Ranking__c,
                                                            LLC_BI__Collateral__r.Collateral_Type_Formula__c,
                                                            LLC_BI__Collateral__r.Santander_Value__c,
                                                            LLC_BI__Collateral__r.Lendable_Value_WDV__c, 
                                                            LLC_BI__Loan__r.LLC_BI__Product_Package__c, 
                                                            LLC_BI__Loan__r.LLC_BI__Amount__c
                                                            from LLC_BI__Loan_Collateral2__c 
                                                            where LLC_BI__Loan__c IN :loanId AND LLC_BI__Collateral__r.LLC_BI__Status__c != 'Released' ORDER BY LLC_BI__Collateral__r.Santander_Value__c DESC NULLS LAST];        
        return collateralList;
                                                       
    }

    public static List<LLC_BI__Collateral__c> getCollateralsForRG(set<string> rgIds){
        List<LLC_BI__Collateral__c> collateralList = [select Id,
                                                            Collateral_Valuation_Value__c,
                                                            Direct_Third_Party_Charge__c,
                                                            Further_Advance_with_no_DoP__c,
                                                            Ranking__c,
                                                            Collateral_Type_Formula__c,
                                                            Santander_Value__c,
                                                            Lendable_Value_WDV__c, 
                                                            Risk_Group__c
                                                            from LLC_BI__Collateral__c 
                                                            where Risk_Group__c IN :rgIds AND LLC_BI__Status__c != 'Released' ORDER BY Santander_Value__c DESC NULLS LAST];        
        return collateralList;
                                                       
    }
    
    public static List<LLC_BI__Collateral_Valuation__c> collValuation(set<id> collID){
        List<LLC_BI__Collateral_Valuation__c> valuationRec = [select id, LLC_BI__Value__c,LLC_BI__Collateral__c from LLC_BI__Collateral_Valuation__c where LLC_BI__Collateral__c =:collID and LLC_BI__Primary__c = true and LLC_BI__Active__c = true order by LLC_BI__Value__c DESC];
        system.debug('Highest value of collateral-->' +valuationRec[0].LLC_BI__Value__c);
         return valuationRec;
    }
    
   
   /****************************************************************
* Method: getRiskGroupList
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    Public static List<Risk_Group__c> getRiskGroupList(String prodPackgeID){
        
        List<Risk_Group__c> riskGrpList = [SELECT Id,Name__c,Name,Product_Package__c,Total_Santander_Value__c,Total_Loan_Value__c,Total_Lendable_Value__c,RGLTV__c, (Select id,LLC_BI__Status__c,Active_Loan_LTV__c from Loans__r), (Select id,LLC_BI__Status__c,Active_Collateral_LTV__c from Collateral_Mgmt__r), (Select id,Status__c,Active_Account_LTV__c from Companies__r) FROM Risk_Group__c where Product_Package__c=: prodPackgeID];
        System.debug('query again'+riskGrpList);
        return riskGrpList;
    }
    
       /****************************************************************
* Method: getRiskGroupList
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    Public static List<Risk_Group__c> getRiskGroupInactive(String prodPackgeID){
        
       List<Risk_Group__c> riskGrpList = [SELECT Id,Name__c,Name,Product_Package__c,Total_Santander_Value__c,Total_Loan_Value__c,Total_Lendable_Value__c,RGLTV__c, (Select id from Loans__r WHERE LLC_BI__Status__c NOT IN ('Open', 'Hold', 'In Review')), (Select id from Collateral_Mgmt__r WHERE LLC_BI__Status__c  IN ('Released')), (Select id from Companies__r WHERE Status__c  NOT IN ('Active Customer')) FROM Risk_Group__c where Product_Package__c=: prodPackgeID];
       System.debug('query again'+riskGrpList);
        
        return riskGrpList;
    }
    
 /****************************************************************
* Method: getProfile
* Description: To Fetch Profile Details
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/ 
    public static List<ObjectPermissions> checkObjectPermission(){
     return [select Id, Parent.Profile.Name, SobjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords 
     from ObjectPermissions 
     WHERE SobjectType = 'Risk_Group__c' 
     and parent.profileid =: userinfo.getProfileId()];
    }
    
  /****************************************************************
* Method: getLoanRecords
* Description: To Fetch loans for getLoan method in LTVMainController
* Input Parameters: Product Package ID
* OutPut Parameters: List of Loans
* *************************************************************/   
    public static List<LLC_BI__Loan__c> getLoanRecords(String prodPackgeID){
        
      List<LLC_BI__Loan__c> loanRecords=   [SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Status__c,LLC_BI__Amount__c,Active_Loan_LTV__c,Risk_Group__c FROM LLC_BI__Loan__c where Risk_Group__c  = null and LLC_BI__Product_Package__c=: prodPackgeID AND Active_Loan_LTV__c=true];
        return loanRecords; 
    }
    
  /****************************************************************
* Method: getcollateralpledgeRecords
* Description: To Fetch collateralPledge for getCollaterals method in LTVMainController
* Input Parameters: Product Package ID
* OutPut Parameters: List of collateralPledges
* *************************************************************/     

 public static List<LLC_BI__Loan_Collateral2__c> getcollateralpledgeRecords(String prodPackgeID){
     
    List<LLC_BI__Loan_Collateral2__c> colpledgerecords=[select Id,LLC_BI__Collateral__c,LLC_BI__Loan__c,LLC_BI__Loan__r.LLC_BI__Product_Package__c from LLC_BI__Loan_Collateral2__c where LLC_BI__Loan__r.LLC_BI__Product_Package__c =:prodPackgeID];  
     
     return colpledgerecords;
 }
    
/****************************************************************
* Method: getcollateraleRecords
* Description: To Fetch collateral based on collateralpledge for getCollaterals method in LTVMainController
* Input Parameters: Product Package ID
* OutPut Parameters: List of collaterals
* *************************************************************/  
    
 public static List<LLC_BI__Collateral__c> getcollateraleRecords(Set<Id> collListIds){
    
     List<LLC_BI__Collateral__c> relatedCollrecords = [SELECT Id, Name, LLC_BI__Collateral_Name__c,LLC_BI__Status__c,Collateral_Type_Formula__c,Active_Collateral_LTV__c FROM LLC_BI__Collateral__c where Risk_Group__c = null AND ID IN:collListIds AND Active_Collateral_LTV__c=true limit 10];
    
     return relatedCollrecords;
 }
    
/****************************************************************
* Method: getEntitiesRecords
* Description: To Fetch relationships associated to ProductPackage
* Input Parameters: Product Package ID
* OutPut Parameters: List Of relationships
* *************************************************************/   
     public static List<LLC_BI__Legal_Entities__c> getEntitiesRecords(String prodPackgeID){
       
          List<LLC_BI__Legal_Entities__c> relatedentities = [select LLC_BI__Account__c,LLC_BI__Account__r.Name,LLC_BI__Account__r.JFNumber__c,LLC_BI__Product_Package__c,LLC_BI__Borrower_Type__c from LLC_BI__Legal_Entities__c where LLC_BI__Account__r.Risk_Group__c =null AND LLC_BI__Product_Package__c=:prodPackgeID];
         
          return relatedentities;
     }
    
    
    /****************************************************************
* Method: getAccountRecords
* Description: To Fetch relationships based on the Legal Entities 
* Input Parameters: Set of Account ids
* OutPut Parameters: List Of relationships
* *************************************************************/   
     public static List<Account> getAccountRecords(Set<Id> uniqueAccounts){
       
          List<Account> accountRecords=[Select Id,Type,Name,Status__c,JFNumber__c,Active_Account_LTV__c from Account where Id IN:uniqueAccounts AND Active_Account_LTV__c=true];
         
          return accountRecords;
     }
    
/****************************************************************
* Method: getRGSRelationshipRecords
* Description: To Fetch Risk Group associated accounts
* Input Parameters: Riskgroup Id
* OutPut Parameters: List Of Accounts
* *************************************************************/
       public static List<Account> getRiskGroupAssociatedAccounts(String riskGroupId){
           
           List<Account> riskGroupAccounts=[Select Id,Type,Name,Status__c,JFNumber__c,Active_Account_LTV__c from Account where Risk_Group__c=:riskGroupId];
           return riskGroupAccounts;
       }
    
/****************************************************************
* Method: getRGloanRecords
* Description: To Fetch Risk Group Loan List
* Input Parameters: RiskGroup ID
* OutPut Parameters: List Of Loans
* *************************************************************/
      public static List<LLC_BI__Loan__c> getRiskGroupAssociatedLoans(String riskGroupId){
          
             List<LLC_BI__Loan__c> loanRecords = [SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Status__c,LLC_BI__Amount__c,Active_Loan_LTV__c FROM LLC_BI__Loan__c where  Risk_Group__c=:riskGroupId];
          return loanRecords;
      }
    
/****************************************************************
* Method: getRGcollateralsRecords
* Description: To Fetch Risk Group associated Collaterals
* Input Parameters: RiskGroup Id
* OutPut Parameters: List Of collaterals
* *************************************************************/
    public static List<LLC_BI__Collateral__c>  getRGcollateralsRecords(String riskGroupId){ 
        
        
          List<LLC_BI__Collateral__c> relatedCollRecords = [SELECT Id, Name,LLC_BI__Status__c, LLC_BI__Collateral_Name__c,Collateral_Type_Formula__c,Active_Collateral_LTV__c FROM LLC_BI__Collateral__c where Risk_Group__c=:riskGroupId];
        
        return relatedCollRecords;
    }
    
   /****************************************************************
* Method: getRiskgrpsDeleted
* Description: To Fetch Risk Group Ids to be deleted
* Input Parameters: RiskGroup Id
* OutPut Parameters:ids
* *************************************************************/ 
       public static List<Risk_Group__c>  getRiskgrpsDeleted(String riskGroupId){
           
            List<Risk_Group__c> riskgrpIds = [select id from Risk_Group__c where id = :riskGroupId];
            return riskgrpIds;
       }
      /****************************************************************
* Method: duplicatenamesRiskGroups
* Description: to get duplicate rosk group names 
* Input Parameters: risk Group Id
* OutPut Parameters: Risk Groups
* *************************************************************/ 
    public static List<Risk_Group__c>  duplicatenamesRiskGroups(String ltvName,string ppID){
        List<Risk_Group__c> riskgrprecords = [SELECT Id FROM Risk_Group__c WHERE Product_Package__c = :ppID AND Name__c = :ltvName];
        return riskgrprecords; 
    }
    
         /****************************************************************
* Method: updateAccountonRiskGroups
* Description: to get accounts that needs to be updated on RG 
* Input Parameters: Account Ids
* OutPut Parameters: Account Records
* *************************************************************/  
    
    public static List<Account>  updateAccountonRiskGroups(Set<Id> relId){
        
     List<Account> updateAccount = [Select Id,Type,Name,Risk_Group__c,JFNumber__c,Active_Account_LTV__c from Account where Id IN:relId]; 
      return  updateAccount; 
    }
    
/****************************************************************
* Method: updateLoansOnRiskGroups
* Description: to get accounts that needs to be updated on RG 
* Input Parameters: loan Ids
* OutPut Parameters: Loan Records
* *************************************************************/  
      public static List<LLC_BI__Loan__c>  updateLoansOnRiskGroups(Set<Id> loanId){
          
          List<LLC_BI__Loan__c> loanrecords = [SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Status__c,LLC_BI__Amount__c,Active_Loan_LTV__c,Risk_Group__c FROM LLC_BI__Loan__c where Id IN:loanId];
          return loanrecords;
      }
    
/****************************************************************
* Method: updateCollateralsOnRiskGroups
* Description: to get collaterals that needs to be updated on RG 
* Input Parameters: Collateral Ids
* OutPut Parameters: Collateral Records
* *************************************************************/  
     public static List<LLC_BI__Collateral__c>  updateCollateralsOnRiskGroups(Set<Id> collId){
         
         List<LLC_BI__Collateral__c> Collrecords = [SELECT Id, Name,LLC_BI__Collateral_Name__c,LLC_BI__Status__c,Risk_Group__c,Collateral_Type_Formula__c,Active_Collateral_LTV__c FROM LLC_BI__Collateral__c where ID IN:collId];
         return Collrecords;
     }
    
       
/****************************************************************
* Method: deleteLoanOnRiskGroups
* Description: to get loans that needs to be deleted on RG 
* Input Parameters: Loan Ids
* OutPut Parameters: Loan Records
* *************************************************************/   
     public static List<LLC_BI__Loan__c>  deleteLoanOnRiskGroups(String recordID){
         
          List<LLC_BI__Loan__c> deleteloanRecList = [SELECT Id, Name,LLC_BI__Stage__c,LLC_BI__Amount__c,Active_Loan_LTV__c,Risk_Group__c FROM LLC_BI__Loan__c where id =: recordID];
         return deleteloanRecList;
     }
         
/****************************************************************
* Method: deleteCollateralsOnRiskGroups
* Description: to get collaterals that needs to be deleted on RG 
* Input Parameters: Collateral Id
* OutPut Parameters: Collateral Records
* *************************************************************/   
     public static List<LLC_BI__Collateral__c>  deleteCollateralsOnRiskGroups(String recordID){
         
         List<LLC_BI__Collateral__c> deleteCollList = [SELECT Id, Name, LLC_BI__Collateral_Name__c,Collateral_Type_Formula__c,Active_Collateral_LTV__c,Risk_Group__c FROM LLC_BI__Collateral__c where  id =: recordID];
         return deleteCollList;
     }
  /****************************************************************
* Method: deleteRelationshipOnRiskGroups
* Description: to get accounts that needs to be deleted on RG 
* Input Parameters: Account Id
* OutPut Parameters: Account Records
* *************************************************************/   
     public static List<Account>  deleteRelationshipOnRiskGroups(String recordID){
         
         List<Account> deletelistAccount=[Select Id,Type,Name,JFNumber__c,Active_Account_LTV__c from Account where  id =: recordID];
         return deletelistAccount;
     }  
     /****************************************************************
* Method: getloanrecordsatPPlevel
* Description: to get loans that are associated to PP 
* Input Parameters: PPId
* OutPut Parameters: loan Records
* *************************************************************/   
    
    public static list<LLC_BI__Loan__c> getloanrecordsatPPlevel(list<string> ppIds){
        List<LLC_BI__Loan__c> loanList = [SELECT Id, LLC_BI__Product_Package__c, LLC_BI__Amount__c FROM LLC_BI__Loan__c 
                      WHERE LLC_BI__Product_Package__c in :ppIds AND LLC_BI__Status__c IN ('Open','Hold','In Review') LIMIT 500];
        return loanList;
    }
         /****************************************************************
* Method: getRGrecordsfromPP
* Description: to get RG that are associated to PP 
* Input Parameters: PPId
* OutPut Parameters: Risk Group Records
* *************************************************************/ 
    
    public static list<Risk_Group__c> getRGrecordsfromPP(list<string> ppIds){
        List<Risk_Group__c> riskGroupList = [SELECT Id FROM Risk_Group__c WHERE Product_Package__c IN :ppIds LIMIT 500];
        return riskGroupList;
    }
             /****************************************************************
* Method: getloanrecordsfromPP
* Description: to get loans that are associated to PP 
* Input Parameters: PPId
* OutPut Parameters: Loan Records
* *************************************************************/ 
    
    public static list<LLC_BI__Loan__c> getloanrecordsfromPP(list<string> ppIds){
        List<LLC_BI__Loan__c> loanList = [SELECT Id, LLC_BI__Product_Package__c, LLC_BI__Amount__c, Risk_Group__c, LLC_BI__Status__c FROM LLC_BI__Loan__c WHERE LLC_BI__Product_Package__c in :ppIds AND Risk_Group__c != null ORDER BY Risk_Group__c LIMIT 15000];
        return loanList;
    }
    /****************************************************************
* Method: getPPrecordsforLTV
* Description: to get pp for LTV calcualtion 
* Input Parameters: PPId
* OutPut Parameters: pp Records
* *************************************************************/ 
    public static list<LLC_BI__Product_Package__c> getPPrecordsforLTV(string ppId) {
      list<LLC_BI__Product_Package__c>  ppList = [SELECT Id, Total_Loan_Value__c, Total_Lendable_value__c, Total_Santander_Value__c, LTV__c FROM LLC_BI__Product_Package__c WHERE Id = :ppID LIMIT 1];
        return ppList;
    }
 /****************************************************************
* Method: getPPFields
* Description: to get pp 
* Input Parameters: PPId
* OutPut Parameters: pp Records
* *************************************************************/
    public static list<LLC_BI__Product_Package__c> getPPFields (string ppId) {
      list<LLC_BI__Product_Package__c>  ppList = [SELECT Id,Name,Requires_Manual_Approval__c,Purpose__c 
                                                     FROM LLC_BI__Product_Package__c WHERE Id=:ppID LIMIT 1];
        return ppList;
    }
    
/****************************************************************
* Method: getLoanFieldsPCSM
* Description: to get Loan List
* Input Parameters: PPId
* OutPut Parameters: Loan Records
* *************************************************************/
    public static list<LLC_BI__Loan__c> getLoanFieldsPCSM (string ppId) { 
      list<LLC_BI__Loan__c>  loanList = [SELECT Id, Name,LLC_BI__Stage__c,PolicyAcknowledgement__c FROM LLC_BI__Loan__c 
                                           WHERE LLC_BI__Product_Package__c =: ppID and LLC_BI__Is_Review_Ready__c=true 
                                           and LLC_BI__Stage__c In('Application','Final Review') LIMIT 1000];
        return loanList;
    }
    
    
/****************************************************************
* Method: getLoanFieldsPCSMCall
* Description: to get Loan List
* Input Parameters: PPId
* OutPut Parameters: Loan Records
* *************************************************************/
    public static list<LLC_BI__Loan__c> getLoanFieldsPCSMCall (Set<Id> LoanResultId) {
        list<LLC_BI__Loan__c>  loanList = [SELECT Id,Name,System_Decision__c,System_Decision_Description__c,Decision_Group__c,
                                           Reason_Code__c,Reason_Code_Description__c,scorecardLDM_Score__c,scorecardLDM__c,
                                           scorecardLDM_ScorecardName__c,backgroundScorecardLDM_Score__c,
                                           backgroundScorecardLDM_ScoreCardID__c,backgroundScorecardLDM_ScoreCardName__c,
                                           Error_Code__c,Error_Message__c,Decision_Reason__c,Manual_Decision__c,LLC_BI__Description__c,
                                           LLC_BI__Product_Package__c,LLC_BI__Product_Package__r.Requires_Manual_Approval__c,LLC_BI__Stage__c
                                           FROM LLC_BI__Loan__c WHERE Id IN:LoanResultId LIMIT 1000];
        return loanList;
    }
    
   /****************************************************************
* Method: getcollateralpledgeforCollaterals
* Description: To Fetch collateralPledge based on the collaterls for the collateral trigger handler
* Input Parameters: List of collaterals
* OutPut Parameters: List of collateralPledges
* *************************************************************/     

 public static List<LLC_BI__Loan_Collateral2__c> getcollateralpledgeforCollaterals(List<Id> updatedCollaterals){
     
    List<LLC_BI__Loan_Collateral2__c> relatedCollateralPledge =[select Id,LLC_BI__Collateral__c,LLC_BI__Loan__c,LLC_BI__Loan__r.LLC_BI__Product_Package__c from LLC_BI__Loan_Collateral2__c where LLC_BI__Collateral__c IN:updatedCollaterals];
     
     return relatedCollateralPledge;
 }   
    
   /****************************************************************
* Method: getnewcollateralpledge
* Description: To Fetch collateralPledge  for the collateralpledge trigger handler
* Input Parameters: List of collateralspledgeIds
* OutPut Parameters: List of collateralPledgesIds
* *************************************************************/     

 public static List<LLC_BI__Loan_Collateral2__c> getnewcollateralpledge(List<Id> newCollateralpledgeIds){
     
     List<LLC_BI__Loan_Collateral2__c> colpledgeIdList=[select Id,LLC_BI__Collateral__c,LLC_BI__Loan__c,LLC_BI__Loan__r.LLC_BI__Product_Package__c from LLC_BI__Loan_Collateral2__c where ID IN:newCollateralpledgeIds LIMIT 1000 ALL ROWS];
     
     return colpledgeIdList;
 } 
    
  /****************************************************************
* Method: pCSMApprovalProcessCall
* Description: To active approval processes
* Input Parameters: Object Name
* OutPut Parameters: Approval Process Name
* *************************************************************/ 

public static String pCSMApprovalProcessCall(String objName){
   
    String NameP;
    List<ProcessDefinition> processName=[SELECT Id,DeveloperName,TableEnumOrId,Name,State,Type FROM ProcessDefinition where TableEnumOrId =: objName and State='Active']; 
    if(processName.size()>0){
        NameP = processName[0].DeveloperName;
    }
    return NameP;
}
    
    /****************************************************************
* Method: getCreditApprovalRecords
* Description: To get Credit Approval History Record
* Input Parameters: Object Name
* OutPut Parameters: record of Credit Approval history
* *************************************************************/ 

public static List<Credit_Approval_History__c> getCreditApprovalRecords(List<LLC_BI__Loan__c> loanList){
   
    List<Credit_Approval_History__c> creditList = new List<Credit_Approval_History__c>();
     creditList = [Select id,Loan__c,Decision_Reason__c,Manual_Decision__c,Comments_CAH__c, Product_Package__c 
                                 from Credit_Approval_History__c where  Loan__c IN : loanList 
                                 ORDER BY CreatedDate ASC NULLS LAST limit 1000];
    return creditList; 
}

     /****************************************************************
* Method: getProductPackageList
* Description: To get rec of Product Package
* Input Parameters: List of Product Package Ids
* OutPut Parameters: Product Package Details
* *************************************************************/ 
  public static List<LLC_BI__Product_Package__c> getProductPackageList(Set<Id> ppIds){
   
      List<LLC_BI__Product_Package__c>  productPackageList = [SELECT Id,Name,Requires_Manual_Approval__c,Purpose__c,Reason_for_Manual_Review__c,Comments__c 
                              FROM LLC_BI__Product_Package__c WHERE Id=:ppIds LIMIT 1];
    return productPackageList; 
}  
    
}