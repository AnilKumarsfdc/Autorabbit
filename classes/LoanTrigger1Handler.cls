/************************************************
Name:LoanTrigger1Handler
Descritption: This is a trigger handler class on Loan object as a part of process builder refactoring.
Created By: Poonam Yadav 
Created Date: 26/08/2019
Version:1.0
**************************************************/
public class LoanTrigger1Handler {
    
    private Set<Id> loanIds= new Set<Id>();
    
    
    /************************************************
Method Name: Update Product Package LTV
Descritption:This method will trigger the LTV calculations whenever a new loan is inserted or updated which will affect LTV 
Input Parameters: Trigger.new,Trigger.old,isUpdate,isInsert
Output Parameters:None
**************************************************/ 
    public void updateProductPackageforLTV(List<LLC_BI__Loan__c> loanListsnew,Map<Id,LLC_BI__Loan__c> loanlistsOld,Boolean isupdate,Boolean isinsert){ 
        boolean isSuccessForLTV = false;
        try{  
            List<string> ppIds = new List<string>();
            if(isinsert){
                if(!loanListsnew.isEmpty()){
                    for(LLC_BI__Loan__c loan :loanListsnew){
                        if((loan.LLC_BI__Product_Package__c != null) && (loan.Active_Loan_LTV__c)){
                            ppIds.add(loan.LLC_BI__Product_Package__c);
                        }
                    }
                }
            }
            if(isupdate){
                for(LLC_BI__Loan__c loan :loanListsnew){
                    LLC_BI__Loan__c oldLoan = loanlistsOld.get(loan.id);
                    if(((oldLoan.LLC_BI__Status__c == ConstantUtility.LTV_OPEN || oldLoan.LLC_BI__Status__c == ConstantUtility.LTV_HOLD || oldLoan.LLC_BI__Status__c == ConstantUtility.LTV_INREVIEW) &&  
                        (loan.LLC_BI__Status__c != ConstantUtility.LTV_OPEN && loan.LLC_BI__Status__c != ConstantUtility.LTV_HOLD && loan.LLC_BI__Status__c != ConstantUtility.LTV_INREVIEW)) ||     
                       ((oldLoan.LLC_BI__Status__c != ConstantUtility.LTV_OPEN && oldLoan.LLC_BI__Status__c !=ConstantUtility.LTV_HOLD && oldLoan.LLC_BI__Status__c != ConstantUtility.LTV_INREVIEW) &&  
                        (loan.LLC_BI__Status__c == ConstantUtility.LTV_OPEN || loan.LLC_BI__Status__c == ConstantUtility.LTV_HOLD || loan.LLC_BI__Status__c == ConstantUtility.LTV_INREVIEW)) ||
                       (oldLoan.LLC_BI__Amount__c != loan.LLC_BI__Amount__c) || 
                       (loan.LLC_BI__Product_Package__c != oldLoan.LLC_BI__Product_Package__c))
                    {
                        ppIds.add(loan.LLC_BI__Product_Package__c!=null?loan.LLC_BI__Product_Package__c:oldLoan.LLC_BI__Product_Package__c);
                    }
                } 
            }
            if (ppIds.size() > 0) {
                LTVPPCalculation.calculateLTVForPP(ppIds, false);
            }
            isSuccessForLTV = true;
        }
        catch(exception e){
            isSuccessForLTV = false;
        }
    }
    
    
    /************************************************
Method Name:setPurposeOfBorrowingOnLoan
Descritption: This methos is used for Set Purpose of Borrowing on Loan process builder logic
Input Parameters:List of Loans
Output Parameters:None
**************************************************/ 
    public boolean setPurposeOfBorrowingOnLoan(List<LLC_BI__Loan__c> Loanlists){
        try {
            
            for (LLC_BI__Loan__c lval :[Select id, Name, LLC_BI__Product__c,Purpose_of_Borrowing__c from LLC_BI__Loan__c where ID IN:Loanlists LIMIT 1000]){
                if(lval.LLC_BI__Product__c== ConstantUtility.OVERDRAFT|| lval.LLC_BI__Product__c== ConstantUtility.CC_OVERDRAFT || lval.LLC_BI__Product__c== ConstantUtility.INVOICE_DISCOUNTING||lval.LLC_BI__Product__c== ConstantUtility.OPEN_ITEM_LEDGER||lval.LLC_BI__Product__c== ConstantUtility.INVENTORY||lval.LLC_BI__Product__c== ConstantUtility.PLANT_AND_MACHINERY_LOAN||lval.LLC_BI__Product__c== ConstantUtility.BUSINESS_CREDIT_CARD||lval.LLC_BI__Product__c== ConstantUtility.SYNDICATIONS){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.WORKING_CAPITAL_BORROWER;
                }
                else if(lval.LLC_BI__Product__c== ConstantUtility.POOLING_SWEEPING){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.LIQUIDITY_MANAGEMENT;
                }
                else if(lval.LLC_BI__Product__c==ConstantUtility.HEDGING_PRODUCTS){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.RISK_HEDGING;
                    
                }
                
                else if(lval.LLC_BI__Product__c==ConstantUtility.FX_PFE){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.FOREIGN_EXCHANGE;
                }
                else if(lval.LLC_BI__Product__c==ConstantUtility.DD_ORIGINATIONS){
                    
                    lval.Purpose_of_Borrowing__c=ConstantUtility.DD_CLEARING_SETTLEMENT;
                }
                else if(lval.LLC_BI__Product__c== ConstantUtility.FX_DSL || lval.LLC_BI__Product__c==ConstantUtility.DAILY_SETTLEMENT_LIMITS){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.PB_DAILY_SETTLEMENT_LIMITS ;
                }
                else if(lval.LLC_BI__Product__c==ConstantUtility.BACS_CREDIT_PAYMENT){
                    
                    lval.Purpose_of_Borrowing__c= ConstantUtility.CP_CLEARING_SETTLEMENT;
                }
                else {
                    string setBlankStr = '';
                    lval.Purpose_of_Borrowing__c = setBlankStr;
                }
            }
            return true;
        } catch(Exception ex) {
            return false;
        }
        
    }
    
    
    /************************************************
Method Name:updateFXDSLDoneOnPP
Descritption:This method is used for the Update FX-DSL Done on PP process builder logic.
Input Parameters:List of Loans
Output Parameters:None
**************************************************/ 
    public boolean updateFXDSLDoneOnPP(List<LLC_BI__Loan__c> Loanlists){
        try {
            for(LLC_BI__Loan__c l:[Select id,LLC_BI__Product_Package__c,LLC_BI__Product__c,LLC_BI__Product_Package__r.FX_DSL_Done__c from LLC_BI__Loan__c where ID IN:Loanlists LIMIT 1000]){
                if(l.LLC_BI__Product__c==ConstantUtility.FX_DSL){
                    l.LLC_BI__Product_Package__r.FX_DSL_Done__c=true;
                }
            }
            return true;
        } catch(Exception ex) {
            return false;
        }
    }   
    
    
    /************************************************
Method Name:updateOpportunity
Descritption:This method is used to update Opportunity records field to be in sync with related Loan records fields.
Input Parameters:List of Loans
Output Parameters:None
**************************************************/
    Public void updateOpportunity(List<LLC_BI__Loan__c> LoanLists, Map<Id, LLC_BI__Loan__c> mapnewLoans, Map<Id, LLC_BI__Loan__c> mapoldLoans){
        Map<String, String> mapLoanStageByOppStage = new Map<String, String>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity_Product__c> lstOppProduct = new List<Opportunity_Product__c>();
        Set<Id> loanIds = new Set<Id>();
        try {
            for(Id loanId: mapnewLoans.keyset()){
                if  ((mapoldLoans.get(loanId).Lost_Reason__c != mapnewLoans.get(loanId).Lost_Reason__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Lost_Detail__c != mapnewLoans.get(loanId).LLC_BI__Lost_Detail__c) ||
                     (mapoldLoans.get(loanId).Appeal_Rights__c != mapnewLoans.get(loanId).Appeal_Rights__c) ||
                     (mapoldLoans.get(loanId).Appeal_Rights_Mandatory__c != mapnewLoans.get(loanId).Appeal_Rights_Mandatory__c) ||
                     (mapoldLoans.get(loanId).Passed_to_Credit__c != mapnewLoans.get(loanId).Passed_to_Credit__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__CloseDate__c != mapnewLoans.get(loanId).LLC_BI__CloseDate__c) ||
                     (mapoldLoans.get(loanId).Confidential_Deal__c != mapnewLoans.get(loanId).Confidential_Deal__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Credit_Approval_Date__c != mapnewLoans.get(loanId).LLC_BI__Credit_Approval_Date__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Stage__c != mapnewLoans.get(loanId).LLC_BI__Stage__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Amount__c != mapnewLoans.get(loanId).LLC_BI__Amount__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Term_Months__c != mapnewLoans.get(loanId).LLC_BI__Term_Months__c) ||
                     (mapoldLoans.get(loanId).TP_Rate__c != mapnewLoans.get(loanId).TP_Rate__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Spread__c != mapnewLoans.get(loanId).LLC_BI__Spread__c) ||
                     (mapoldLoans.get(loanId).LLC_BI__Total_Disbursed__c != mapnewLoans.get(loanId).LLC_BI__Total_Disbursed__c))
                {
                    loanIds.add(loanId);
                    
                } //if-end              
            } //For-end
            
            
            for(Loan_To_Opportunity_Stage_Mapping__mdt oppOppLoanStageMtd:[SELECT Id, MasterLabel, Opportunity_Stage__c FROM Loan_To_Opportunity_Stage_Mapping__mdt LIMIT 1000]){
                mapLoanStageByOppStage.put(oppOppLoanStageMtd.MasterLabel, oppOppLoanStageMtd.Opportunity_Stage__c);
            }
            oppList = [SELECT Id, Name,Lost_Reason__c,Lost_Comments__c,Appeal_Rights__c, Appeal_Rights_Mandatory__c, Passed_to_Credit__c,CloseDate,Confidential_Deal__c, LLC_BI__Loan__c, StageName, (SELECT Id, Name, Facility_Amount__c, Term_In_Months__c, TP_Rate__c, Gross_Margin__c,nCino_Lending_Amount__c FROM Opportunity_Products__r) FROM Opportunity WHERE LLC_BI__Loan__c IN :loanIds LIMIT 1000];        
            
            
            Opportunity_Product__c objOppProduct;
            LLC_BI__Loan__c objTempLoan;
            if(oppList.size() >0){
                for (Opportunity Opp: oppList){
                    objTempLoan = mapnewLoans.get(Opp.LLC_BI__Loan__c);
                    if(objTempLoan != null){
                        Opp.Lost_Reason__c = objTempLoan.Lost_Reason__c;
                        Opp.Lost_Comments__c = objTempLoan.LLC_BI__Lost_Detail__c;
                        Opp.Appeal_Rights__c = objTempLoan.Appeal_Rights__c;
                        Opp.Appeal_Rights_Mandatory__c = objTempLoan.Appeal_Rights_Mandatory__c;
                        Opp.Passed_to_Credit__c = objTempLoan.Passed_to_Credit__c;
                        Opp.CloseDate = objTempLoan.LLC_BI__CloseDate__c;
                        Opp.Confidential_Deal__c = objTempLoan.Confidential_Deal__c;
                        Opp.Credit_Approved__c = objTempLoan.LLC_BI__Credit_Approval_Date__c;
                        
                        if (mapLoanStageByOppStage.get(objTempLoan.LLC_BI__Stage__c) != null) {
                            if(!objTempLoan.LLC_BI__Stage__c.equalsIgnoreCase(ConstantUtility.TRIGGER_LOAN_STAGE_COMPLETE) || (objTempLoan.LLC_BI__Stage__c.equalsIgnoreCase(ConstantUtility.TRIGGER_LOAN_STAGE_COMPLETE) && objTempLoan.LLC_BI__Status__c.equalsIgnoreCase(ConstantUtility.TRIGGER_LOAN_STAGE_LOST))) {
                                Opp.StageName = mapLoanStageByOppStage.get(objTempLoan.LLC_BI__Stage__c);             
                            }                       
                        }
                        if (Opp.Opportunity_Products__r != null && Opp.Opportunity_Products__r.size() > 0) {
                            objOppProduct = new Opportunity_Product__c(Id=Opp.Opportunity_Products__r[0].Id);
                            objOppProduct.Facility_Amount__c = objTempLoan.LLC_BI__Amount__c;
                            objOppProduct.Term_In_Months__c = objTempLoan.LLC_BI__Term_Months__c;
                            objOppProduct.TP_Rate__c = objTempLoan.TP_Rate__c;
                            objOppProduct.Gross_Margin__c = objTempLoan.LLC_BI__Spread__c;
                            objOppProduct.nCino_Lending_Amount__c = objTempLoan.LLC_BI__Total_Disbursed__c;
                            lstOppProduct.add(objOppProduct);
                        }
                    }
                }
            } 
            if (oppList.size() > 0) {    
                Database.update(oppList);
            }
            if (lstOppProduct.size() > 0) {    
                Database.update(lstOppProduct);
            } 
            
        } 
        catch(DmlException e){   
            Trigger.New[0].addError(e.getDmlMessage(0));  
        }
    } 
    /************************************************
Method Name:updateLoanTeamFromOppTeam
Descritption:This method is used to insert Laon Team records from related Opportnity Team records
Input Parameters:List of Loans
Output Parameters:None
**************************************************/
    public boolean updateLoanTeamFromOppTeam(List<LLC_BI__Loan__c> LoanLists){
        try {
            if (ApexPages.currentPage() == null) {
                return false;
            }
            string oppId = ApexPages.currentPage().getParameters().get(ConstantUtility.idFieldAPI);
            if (oppId == null) {
                return false;
            }
            Map<string, string> mapRole = new Map<string, string>();
            for (LLC_BI__Role__c objRole:[SELECT Id, Name FROM LLC_BI__Role__c LIMIT 1000]) {
                mapRole.put(objRole.Name, objRole.Id);
            }
            
            //Role mapping query
            Map<String, String> mapLoanRoleByOppRole = new Map<String, String>();
            for(Oppoutunity_Loan_Role_Mapping__mdt objOppLoanMtd:[SELECT Id, MasterLabel, Opp_Team_Role__c FROM Oppoutunity_Loan_Role_Mapping__mdt LIMIT 1000]){
                mapLoanRoleByOppRole.put(objOppLoanMtd.Opp_Team_Role__c, objOppLoanMtd.MasterLabel);
            }
            
            list<LLC_BI__LoanTeam__c> loanTeamList = new List<LLC_BI__LoanTeam__c>(); // New List to capture Loan team
            LLC_BI__LoanTeam__c objLoanTeam;
            List<Opportunity> lstOpp = [Select id, Name,LLC_BI__Loan__c, LLC_BI__Loan__r.ID, (SELECT id, Name,TeamMemberRole,UserId FROM OpportunityTeamMembers) from Opportunity where Id = :oppId LIMIT 1];
            if (lstOpp.size() > 0) {
                for(OpportunityTeamMember objOppTeam: lstOpp[0].OpportunityTeamMembers){
                    objLoanTeam = new LLC_BI__LoanTeam__c();
                    objLoanTeam.LLC_BI__Loan__c = LoanLists[0].Id; // To link Loan Team to a Loan
                    objLoanTeam.LLC_BI__User__c =  objOppTeam.UserId;
                    string oppTeamRole = mapLoanRoleByOppRole.get(objOppTeam.TeamMemberRole);
                    if (oppTeamRole != null) {
                        objLoanTeam.LLC_BI__Assigned_Role__c = mapRole.get(oppTeamRole);
                    }               
                    loanTeamList.add(objLoanTeam);
                }
            }
            Database.Insert(loanTeamList);
            return true;
        } catch(Exception ex) {
            return false;
        }
    }
    
    /************************************************
Method Name:updateLoanWithOppProduct
Descritption:This method is used to update Loan records with Opportunity product field during convert to nCino
Input Parameters:List of Loans
Output Parameters:None
**************************************************/
    public boolean updateLoanWithOppProduct(List<LLC_BI__Loan__c> LoanLists){
        try {
            if (ApexPages.currentPage() == null) {
                return false;
            }
            string oppId = ApexPages.currentPage().getParameters().get(ConstantUtility.idFieldAPI);
            if (oppId == null) {
                return false; 
            }     
            List<Opportunity> oppList = [Select id, Name,LLC_BI__Loan__c, LLC_BI__Loan__r.ID,Primary_Product_Lookup__c, (select Id, Name, Facility_Amount__c, Term_In_Months__c, TP_Rate__c, Gross_Margin__c from Opportunity_Products__r) from Opportunity where Id = :oppId LIMIT 1];
            
            if (oppList.size() > 0) {
                LoanLists[0].LLC_BI__Amount__c = (Decimal)oppList[0].Opportunity_Products__r[0].Facility_Amount__c;
                LoanLists[0].LLC_BI__Term_Months__c = oppList[0].Opportunity_Products__r[0].Term_In_Months__c;
                LoanLists[0].TP_Rate__c = oppList[0].Opportunity_Products__r[0].TP_Rate__c;
                LoanLists[0].LLC_BI__Spread__c = oppList[0].Opportunity_Products__r[0].Gross_Margin__c;
                
            }
            return true;
        } catch(Exception ex) {
            return false;
        }
    }
    /************************************************
Method Name:updateField
Descritption:This method is used to update "Passed to Credit" and "Credit Approval Date" field on Loan records 
Input Parameters:List of Loans
Output Parameters:None
**************************************************/
    public boolean updateField(Map<Id,LLC_BI__Loan__c> OldMap,Map<Id,LLC_BI__Loan__c> NewMap){
        try {
            for(Id loanId: NewMap.keyset()){
                
                if(OldMap.get(loanId).LLC_BI__Stage__c.equalsIgnoreCase('Application') && NewMap.get(loanId).LLC_BI__Stage__c.equalsIgnoreCase('Final Review')){
                    if(NewMap.get(loanId).Passed_to_Credit__c == null) {
                        NewMap.get(loanId).Passed_to_Credit__c = System.Today();
                    }
                } 
                if (OldMap.get(loanId).LLC_BI__Stage__c.equalsIgnoreCase('Credit Sanctioning') && NewMap.get(loanId).LLC_BI__Stage__c.equalsIgnoreCase('Acceptance')){
                    if(NewMap.get(loanId).LLC_BI__Credit_Approval_Date__c == null){ 
                        NewMap.get(loanId).LLC_BI__Credit_Approval_Date__c = System.Today();            
                    }
                }
            }
            return true;
        } catch(Exception ex) {
            return false;
        }
    } 
    
    
    /************************************************
Method Name:updateCreditApprovalDecision
Descritption:This method is used to update Passed to Loan  field on Credit records 
Input Parameters:List of Loans
Output Parameters:None
*************************************************/
    public boolean updateCreditApprovalDecision(List<LLC_BI__Loan__c> newLoanLists,List<LLC_BI__Loan__c> oldLoanLists,Map<Id, LLC_BI__Loan__c> mapOldLoans){
        try {
            
            Boolean ManualReviewRequiredStaus =false;
            List<LLC_BI__Product_Package__c> PPList = new List<LLC_BI__Product_Package__c>();
            List <LLC_BI__Product_Package__c> UpdateProductPackageField = new  List <LLC_BI__Product_Package__c>();
            List<Credit_Approval_History__c> creditAppList = new List<Credit_Approval_History__c>();
            List<Credit_Approval_History__c> creditApprovalUpdate = new  List<Credit_Approval_History__c> ();
            List<Credit_Approval_History__c> ppcreditApprovalUpdate = new  List<Credit_Approval_History__c> ();
            List<LLC_BI__Loan__c> loanList = new List<LLC_BI__Loan__c>();
            Map<Id,List<Id>> sendPCSMDetailsId = new Map<Id,List<Id>>();
            
            Map<String, Credit_Approval_History__c> mapCAByPPId = new Map<String, Credit_Approval_History__c>();
            LLC_BI__Loan__c objOldLoan = new LLC_BI__Loan__c();
            Credit_Approval_History__c creditRec ;
            Credit_Approval_History__c creditPPRec ;
            string setBlankStr = '';
            Set<ID> ppId = new Set<ID>();
            
            //get Loans which satisfy our criteria and for which our code should be invoked
            for (LLC_BI__Loan__c newLoanRec : newLoanLists){
                objOldLoan = mapOldLoans.get(newLoanRec.Id);
                
             /* system.debug('objOldLoan-->' +objOldLoan);
                system.debug('new Manual_Review_Required__cc-->' +newLoanRec.Manual_Review_Required__c);
                system.debug('objOldLoan.Manual_Decision__c-->' +objOldLoan.Manual_Decision__c);
                system.debug('newrec.Manual_Decision__c-->' +newLoanRec.Manual_Decision__c);
              */  
                if(objOldLoan != null &&
                   (objOldLoan.Manual_Decision__c == null &&  (newLoanRec.Manual_Decision__c == 'Approved' || newLoanRec.Manual_Decision__c == 'Rejected'))
                   && newLoanRec.Manual_Review_Required__c == 'Yes' ){
                       loanList.add(newLoanRec);
                       ppId.add(newLoanRec.LLC_BI__Product_Package__c);
                   }
            }
            
            //if we have loans which satisfy our criteria, then fetch credit approvals for this loans
            
            //get Product Package data
            ppList = SOQLUtility.getProductPackageList(ppId);
            if(loanList != null && ppList != null)
            {
                
                creditAppList = SOQLUtility.getCreditApprovalRecords(loanList);
                //check if any credit approval history records present for loans
                //1. If credit approval history records are present update the credit approval history
                
                if(creditAppList.size() > 0)
                {
                    
                    for (Credit_Approval_History__c objCA:creditAppList){
                        mapCAByPPId.put(objCA.Loan__c, objCA);
                        // system.debug('mapCAByPPId-->' +mapCAByPPId);
                    }
                    
                    for(LLC_BI__Loan__c newrec: loanList ){
                        objOldLoan = mapOldLoans.get(newrec.Id);
                        
                        
                        creditRec = new Credit_Approval_History__c(Id=mapCAByPPId.get(newrec.Id).Id);
                        system.debug('creditRec -->' +creditRec);
                        creditRec.Decision_Reason__c = newrec.Decision_Reason__c;
                        creditRec.Comments_CAH__c    = newrec.Comments_CAH__c;
                        creditRec.Manual_Decision__c = newrec.Manual_Decision__c;
                        creditRec.Reason_for_Manual_Review__c = ppList[0].Reason_for_Manual_Review__c;
                        creditRec.Purpose__c= ppList[0].Purpose__c;
                        creditApprovalUpdate.add(creditRec);
                        system.debug('creditApprovalUpdate  ---> '+creditApprovalUpdate);
                        
                    }//for loop ends
                    callBacktoPCSMCheck(loanList);
                    
                }//if credit approval ends
                else{ 
                    
                    //if no credit approval records present,and decision is different then create a map and send loan/PPID to PCSM
                    callBacktoPCSMCheck(loanList);
                }
                //need to blank the product package 4 fields
                if(ppList.size() > 0){  
                    
                    //for(LLC_BI__Product_Package__c PPrec: ppList ){
                    
                    ppList[0].Requires_Manual_Approval__c=setBlankStr;
                    ppList[0].Reason_for_Manual_Review__c=setBlankStr;
                    ppList[0].Purpose__c=setBlankStr;
                    ppList[0].Comments__c=setBlankStr;
                    
                    //UpdateProductPackageField.add(PPrec); 
                    
                }
            }//if loanList ends
            
            system.debug('creditApprovalUpdate  ---> '+creditApprovalUpdate.size());
            if(creditApprovalUpdate.size() > 0){
                Database.update(creditApprovalUpdate);
            }
            if(ppList.size() > 0){
                update ppList;
            }
            RecursiveTriggerHandler.CreditApprovalCall = true;            
            return true;
            
        } catch(Exception ex) {
            return false;
        }
    } 
    
    /************************************************
Method Name:updateCreditApprovalDecision
Descritption:This method is used to update Passed to Loan  field on Credit records 
Input Parameters:List of Loans
Output Parameters:None
*************************************************/
    public static void callBacktoPCSMCheck(List<LLC_BI__Loan__c> loanList){
        List<Id> listLoanPassing = new List<Id>();
        Map<Id,List<Id>> sendPCSMDetailsId = new Map<Id,List<Id>>();
        for(LLC_BI__Loan__c newrec: loanList){
            
            if(newrec.System_Decision__c != newrec.Manual_Decision__c){
                
                listLoanPassing = sendPCSMDetailsId.get(newrec.LLC_BI__Product_Package__c);
                if(listLoanPassing == null){
                    listLoanPassing = new List<Id>();
                }
                listLoanPassing.add(newrec.Id);
                sendPCSMDetailsId.put(newrec.LLC_BI__Product_Package__c,listLoanPassing);
            }
        } 
        
        if(sendPCSMDetailsId.size() > 0){
            GeWS_PCSM_OverrideDecision.updateDecision(sendPCSMDetailsId);
        }
        
    }
    
    /***************************   
SpringCM_DocumentDetailsUpdate
*************************/
    public void SpringCM_DocumentDetailsUpdate(Map<Id,LLC_BI__Loan__c> oldMap,Map<Id,LLC_BI__Loan__c> newMap){
        List<ID> LoanIDs = new List<ID>();
        Integer i;
        system.debug('---LoanTrigger1Handler--- oldMap ---  '+oldMap+'----newMap---'+newMap);
        
        for(LLC_BI__Loan__c newRecord:NewMap.values())
        { 
            if(Oldmap != null  && !Oldmap.isEmpty()){
                if(Oldmap.get(newRecord.Id).SpringCM_Doc_Name__c!=Newmap.get(newRecord.Id).SpringCM_Doc_Name__c && Newmap.get(newRecord.Id).SpringCM_Doc_Name__c  != null)
                { 
                    LoanIDs.add(newRecord.Id);    
                    i=0;                 
                } 
            }
            else
                if(Newmap.get(newRecord.Id).SpringCM_Doc_Name__c  != null){
                    LoanIDs.add(newRecord.Id);    
                    i=0;             
                }
        }
        system.debug('---LoanTrigger1Handler--- SpringCM_DocumentDetailsUpdate ---  '+LoanIDs);
        if(i==0)
            SpringCM_DocumentDetails.CreateSpringCMDetail(LoanIDs);
        
        
    }
    /**********************
Method Name:relatedConditionstoLoan method
Descritption:This method is used to throw error when a user is trying to change the stage of a loan from Acceptance to Doc prep
when the related conditions are either in the Review Required, Satisfied(Pending Approval), NA the status will not change	
Input Parameters:List of Loans
Output Parameters:None
****************************/
    
    public void relatedConditionstoLoan(List<LLC_BI__Loan__c> oldloanList,map<id,LLC_BI__Loan__c> newloanMap){
        
        list<LLC_BI__Loan__c> loanList = [select id, (select id, Status__c,Loan__c from Conditions__r where Loan__c =:oldloanList and Status__c IN('Review Required','Satisfied(Pending Approval)','NA')) from LLC_BI__Loan__c];
        set<id> loanid = new set<id>();
        
        for(LLC_BI__Loan__c loans :loanList){
            
            if(loans.Conditions__r.size()>0){
                loanid.add(loans.id);
            }
            
        }
        
        for(LLC_BI__Loan__c loan :oldloanList){
            LLC_BI__Loan__c newloan = newloanMap.get(loan.id);
            if(loan.LLC_BI__Stage__c == 'Acceptance' && newloan.LLC_BI__Stage__c == 'Doc Prep'){
                if(loanid.contains(loan.id)){
                    newloan.LLC_BI__Stage__c.addError('You can not change the stage of the loan, Please check the conditions');
                }
            } 
        }
    }
    
    /**********************
Method Name:changeConditionStatus
Descritption:This method is used to change the status of condition related to loan when the loan is in the approved stage.	
Input Parameters:List of Loans
Output Parameters:None
****************************/
    public void changeConditionStatus(map<id,LLC_BI__Loan__c> newloanMap){
        
        list<Condition__c> ConditionList = [select id, Status__c,Loan__c from Condition__c where Loan__c =:newloanMap.keyset() and Status__c IN('Review Required','NA')];
        set<id> loanid = new set<id>();
        LLC_BI__Loan__c newLoan;
        list<Condition__c> ConditionListUpdate = new list<Condition__c>();
        
        for(Condition__c conditions :ConditionList) {
             newLoan = newloanMap.get(conditions.Loan__c);
            
            if(newLoan != null && newLoan.LLC_BI__Stage__c == 'Acceptance' && newLoan.Id == conditions.Loan__c) {
            	conditions.Status__c = conditions.Status__c=='Review Required'?'Accepted':'NA - Accepted';
                ConditionListUpdate.add(conditions);
            }
        }
        update ConditionListUpdate;
        
           
        
        
    }
    
}