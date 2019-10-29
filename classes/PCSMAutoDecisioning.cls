/****************************************************************
* ClassName: PCSMAutoDecisioning
* Description: PCSMAutoDecisioning 
* Date: 
* Functionality: Credit Approval 
* *************************************************************/
public class PCSMAutoDecisioning {
    
    public static GeWS_PCSMautoDecision.Results Result = new GeWS_PCSMautoDecision.Results();
    public static PCSMDataWrapper pcsmWrapObject {get;set;}
    
    
    /****************************************************************
* Method: sendForAutoDecisiontoPCSM
* Description: 
* Input Parameters:Product Package_id
* OutPut Parameters: 
* *************************************************************/
    @AuraEnabled
    public static PCSMDataWrapper sendForAutoDecisiontoPCSM(string ppID) {
        
        pcsmWrapObject = new  PCSMDataWrapper();
        Boolean isSuccess = true;
        // Boolean isrequierdmanual = true;
        
        List<Credit_Approval_History__c> creditInsertList=new List<Credit_Approval_History__c>();
        List<Id> loanIds =new List<Id>();
        pcsmWrapObject.isError = false;
        pcsmWrapObject.isValidationError = false;
        pcsmWrapObject.isNoLoanError = false;
        pcsmWrapObject.isApprovalProcessError = false;
        List<PCSMDataWrapper.PCSMData> listdata = new List<PCSMDataWrapper.PCSMData>();
        List<LLC_BI__Loan__c> loansStageChange = new List<LLC_BI__Loan__c>();
        List <LLC_BI__Product_Package__c> FieldPP = SOQLUtility.getPPFields(ppID);
        List <LLC_BI__Product_Package__c> UpdateProductPackageField = new  List <LLC_BI__Product_Package__c>();
        //  List<LLC_BI_Loan__c> loanList = new List<LLC_BI_Loan__c>();
        
        if(!String.isBlank(ppID)){
            
            //get loan IDs
            loanIds=FetchLoanList(ppID);
            System.debug('FetchLoanList'+loanIds);
            if(!loanIds.isEmpty()){
                
                //check if both fields -"Purpose and Manual Review Required?" are not blank
                pcsmWrapObject.isValidationError = validatePPDetails(ppID);
                System.debug('isValidationError'+pcsmWrapObject.isValidationError);
                pcsmWrapObject.isPolicyExceptionError = validateLoanDetails(SOQLUtility.getLoanFieldsPCSM(ppID));
                //Check If Purpose and Manual Review Required are blank
                 System.debug('isPolicyExceptionError'+pcsmWrapObject.isPolicyExceptionError);
                if(pcsmWrapObject.isValidationError || pcsmWrapObject.isPolicyExceptionError){ 
                    return pcsmWrapObject;
                }
                else
                {
                    //Call Integration
                    Result = GeWS_PCSMautoDecision.getDecision(ppID,loanIds,'Approve');
                    List<GeWS_PCSMautoDecision.loanResults> LoanResult= Result.loan;
                    //fetch Loan Id from integration and assign to wrapper object
                    set<Id> LoanResultId = new set<Id>();
                    
                    for(GeWS_PCSMautoDecision.loanResults loan :LoanResult){
                        PCSMDataWrapper.PCSMData pscmrec = new PCSMDataWrapper.PCSMData();
                        pscmrec.loanId = loan.loanId;
                        pscmrec.AutoDecision = loan.AutoDecisionResults;
                        pscmrec.NcinoDecision = loan.nCinoUpdateResults;
                        LoanResultId.add(loan.loanId);
                        listdata.add(pscmrec);
                        
                    }// wrapper data from Gews for loop ends
                    
                    pcsmWrapObject.pcsmList = listdata;
                    
                    //query the Loan object for all fields needed to create Credit Approval Record
                    List<LLC_BI__Loan__c> ListOfloans =SOQLUtility.getLoanFieldsPCSMCall(LoanResultId);
                    
                    Credit_Approval_History__c creditObj ;
                    //iterate over "ListOfloans" and find if even one is rejected,then set isSuccess = False
                    for(LLC_BI__Loan__c  loanobjresult:ListOfloans){
                        
                        creditObj= new Credit_Approval_History__c();
                        creditObj.backgroundScorecardLDM_Score__c  = loanobjresult.backgroundScorecardLDM_Score__c;
                        creditObj.backgroundScorecardLDM_ScoreCardID__c = loanobjresult.backgroundScorecardLDM_ScoreCardID__c;
                        creditObj.backgroundScorecardLDM_ScoreCardName__c = loanobjresult.backgroundScorecardLDM_ScoreCardName__c;
                        creditObj.Decision_Group__c = loanobjresult.Decision_Group__c;
                        //creditObj.Decision_Reason__c = loanobjresult.Decision_Reason__c;
                        creditObj.Error_Code__c = loanobjresult.Error_Code__c;
                        creditObj.Error_Message__c = loanobjresult.Error_Message__c;
                        creditObj.Loan__c = loanobjresult.Id;
                        //creditObj.Manual_Decision__c = loanobjresult.Manual_Decision__c;
                        creditObj.Product_Package__c = loanobjresult.LLC_BI__Product_Package__c;
                        creditObj.Require_Manual_Approval__c = loanobjresult.LLC_BI__Product_Package__r.Requires_Manual_Approval__c;
                        creditObj.Purpose__c = loanobjresult.LLC_BI__Description__c;
                        creditObj.scorecardLDM_Score__c = loanobjresult.scorecardLDM_Score__c;
                        creditObj.scorecardLDM__c = loanobjresult.scorecardLDM__c;
                        creditObj.scorecardLDM_ScorecardName__c = loanobjresult.scorecardLDM_ScorecardName__c;
                        creditObj.System_Decision__c = loanobjresult.System_Decision__c;
                        creditObj.System_Decision_Description__c = loanobjresult.System_Decision_Description__c;
                        
                        for(PCSMDataWrapper.PCSMData rec: pcsmWrapObject.pcsmList){
                            if(rec.loanId == loanobjresult.Id){
                                rec.loanName = loanobjresult.Name;
                            }
                        }//for loop ends
                        
                        if(loanobjresult.System_Decision__c == ConstantUtility.SYSTEM_DECISION_Reject){
                            isSuccess = false;
                        }
                        creditInsertList.add(creditObj);
                        
                    }//for credit approval hitory loop ends
                    
                    if(creditInsertList.size()>0){
                        insert creditInsertList;
                    }
                    Boolean isrequierdmanual =  setLoanStageToFinalReview(ppID);
                    system.debug('isrequierdmanual====>'+isrequierdmanual);
                    
                    if(isrequierdmanual == true){  
                        system.debug('isrequierdmanual====> IF');
                        for(LLC_BI__Loan__c  loanobjresult:ListOfloans){
                            if(loanobjresult.LLC_BI__Stage__c==ConstantUtility.PCSM_APPLICATION_STAGE){
                                loanobjresult.LLC_BI__Stage__c=ConstantUtility.PCSM_FINAL_REVIEW_STAGE;
                            }
                            loansStageChange.add(loanobjresult);
                        }
                        if(loansStageChange.size()>0){
                            update loansStageChange;
                        }
                        //pcsmWrapObject.isError = true;
                        return pcsmWrapObject;
                    }//if isrequierdmanual = TRUE - Ends
                    else if(isrequierdmanual == false){      
                        
                        if(isSuccess == true){
                            Boolean productPackageApproval   =  invokeApprovalProcess(ppID,pcsmWrapObject);
                            Boolean loanlApproval  =  invokeLoanApprovalProcess(ListOfloans,pcsmWrapObject);
                            
                            if(productPackageApproval == true && loanlApproval == true){
                                
                                for (LLC_BI__Product_Package__c pp : FieldPP){
                                    pp.Requires_Manual_Approval__c='';
                                    pp.Reason_for_Manual_Review__c='';
                                    pp.Purpose__c='';
                                    pp.Comments__c='';
                                    UpdateProductPackageField.add(pp);  
                                }
                                if(UpdateProductPackageField.size()>0){
                                    update UpdateProductPackageField;
                                }
                                
                            }
                            else{
                                return pcsmWrapObject;
                            }
                            
                        }
                        return pcsmWrapObject;
                        
                    }//isrequierdmanual == false Ends
                    return pcsmWrapObject;
                }//main else ends
                
            }//LoanId empty if ends
            else
            {
                pcsmWrapObject.isNoLoanError = true;
                return pcsmWrapObject;
            }
        }//PPID blank If Ends 
        else
        {
            pcsmWrapObject.isError = true;
            return pcsmWrapObject;
        }
    }
    /****************************************************************
* Method: validatePPDetails
* Description:Fetch Requires_Manual_Approval__c,Purpose__c from Product Package for validating (Blank Or NotBlank)
* Input Parameters: Product_Package__Id
* OutPut Parameters: Bolean value
* *************************************************************/
    Public Static  Boolean  validateLoanDetails (List<LLC_BI__Loan__c> loanlist){
        
        Boolean isError = false;
        
        for(LLC_BI__Loan__c loanrec : loanlist){
            
            if(loanrec.PolicyAcknowledgement__c != true){ 
                isError = true;
            }    
        }
        return isError;   
    }
    /****************************************************************
* Method: validatePPDetails
* Description:Fetch Requires_Manual_Approval__c,Purpose__c from Product Package for validating (Blank Or NotBlank)
* Input Parameters: Product_Package__Id
* OutPut Parameters: Bolean value
* *************************************************************/
    Public Static  Boolean  validatePPDetails (String ppID){
        
        Boolean isError = false;
        List<LLC_BI__Product_Package__c> ProductPackage =SOQLUtility.getPPFields(ppID);
        for(LLC_BI__Product_Package__c ProductPkg : ProductPackage){
            
            if(String.isBlank(ProductPkg.Requires_Manual_Approval__c)  || String.isBlank(ProductPkg.Purpose__c)){
                isError = true;
            }    
        }
        return isError;   
    }
    /****************************************************************
* Method: FetchLoanList
* Description:Fetch Loan Related To Product Package
* Input Parameters: Product_Package__Id
* OutPut Parameters: List Of Loan
* *************************************************************/
    Public Static  List<Id>  FetchLoanList (String ppID){
        
        List<Id> LoanId =new List<Id>();
        List<LLC_BI__Loan__c> ListOfloan =SOQLUtility.getLoanFieldsPCSM(ppID);
        //(ConstantUtility.PCSM_APPLICATION_STAGE , ConstantUtility.PCSM_FINAL_REVIEW_STAGE)
        for (LLC_BI__Loan__c LBLC : ListOfloan){
            LoanId.add(LBLC.Id);
        }
        return LoanId;
    } 
    
    
    /****************************************************************
* Method: invokeApprovalProcess
* Description:invokinking product package approvel Process.
* Input Parameters: PPLoanList
* OutPut Parameters: 
* *************************************************************/
    Public Static Boolean invokeApprovalProcess (String ppID,PCSMDataWrapper pcsmWrapObjectPp){
        //create new pojo which contains 2 fields 1-boolean isApproved aand 2-description messaage
        Boolean result = false;
        string apname=SOQLUtility.pCSMApprovalProcessCall(ConstantUtility.PCSM_PRODUCT_PACKAGE);
        
        try{
            
            if(String.isBlank(apname)){
                pcsmWrapObjectPp.isApprovalProcessError = true;
                return   false ;
            }
            else{
                
                Approval.ProcessSubmitRequest reqPPID = new Approval.ProcessSubmitRequest();
                reqPPID.setComments('Apex Approval');
                reqPPID.setObjectId(ppID);
                reqPPID.setSubmitterId(userinfo.getuserId());
                reqPPID.setProcessDefinitionNameOrId(apname);
                Approval.ProcessResult resultreqPPID = Approval.process(reqPPID);
                //resultList.add(resultreqPPID); 
                if(resultreqPPID.isSuccess() == true){
                    result= true;
                }
                else{
                    result = false;
                }
                return result;
            }
            
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        } 
    }
    
    /****************************************************************
* Method: invokeLoanApprovalProcess
* Description:Fetch LoanId and if all loan status is approved condition then invoke below approvel Process.
* Input Parameters: PPLoanList
* OutPut Parameters: 
* *************************************************************/
    Public Static  Boolean invokeLoanApprovalProcess (List<LLC_BI__Loan__c> LoanList,PCSMDataWrapper pcsmWrapObjectLoan){
        
        //query approval process
        string apname=SOQLUtility.pCSMApprovalProcessCall(ConstantUtility.PCSM_LOAN); 
        
        try{
            Boolean status = false; 
            List<Approval.ProcessResult> resultList = new List<Approval.ProcessResult>();
            if(String.isBlank(apname)){
                pcsmWrapObjectLoan.isApprovalProcessError = true;
                return   false ;
            }
            else
            {
                for (LLC_BI__Loan__c loanrec: LoanList){
                    
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Apex Approval');
                    req.setObjectId(loanrec.id);
                    req.setSubmitterId(userinfo.getuserId());
                    req.setProcessDefinitionNameOrId(apname);
                    Approval.ProcessResult result = Approval.process(req);
                    resultList.add(result);
                    if(result.isSuccess() == true){
                        status= true;
                    }
                    else{
                        status= false;
                    }
                } 
                return status;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /****************************************************************
* Method: setLoanStageToFinalReview
* Description:Fetch LoanId and if all loan status is approved condition then invoke below approvel Process.
* Input Parameters: Product Package Id
* OutPut Parameters: 
* *************************************************************/ 
    Public static Boolean setLoanStageToFinalReview (String ppID){
        
        Boolean isrequierdmanual = false;
        List<LLC_BI__Product_Package__c> ProductPackage =SOQLUtility.getPPFields(ppID);
        for (LLC_BI__Product_Package__c PPList : ProductPackage){
            system.debug('isrequierdmanual====> '+PPList.Requires_Manual_Approval__c);
            if(PPList.Requires_Manual_Approval__c ==ConstantUtility.PCSM_REQUIRES_MANUAL_APPROVAL){
                isrequierdmanual = true;
            }
        }
        
        return isrequierdmanual;
    }
    
}