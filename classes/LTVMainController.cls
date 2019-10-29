/****************************************************************
* ClassName: LTVMainController
* Description: Main Class for LTV Functionality, invoked from LTVMainScreen lightning Component
* Date: 14/9/2019
* Functionality: LTV
* *************************************************************/

public   without sharing class LTVMainController {
    
    @AuraEnabled public static LTVWrapper wrapperObj {get;set;}
    @AuraEnabled public static String Result {get;set;}  
    private static List<Risk_Group__c> riskgrouprecordsList = new List<Risk_Group__c>();
    private static String outputResult;
    private static String duplicatecheck;
    private static Id riskGroupId;
    private static Id prodpageId;
    private static List<LTVWrapper.realtionshipWrapper> relationshipList = new  List<LTVWrapper.realtionshipWrapper>();
    private static List<LTVWrapper.loanWrapper> loanList = new  List<LTVWrapper.loanWrapper>();
    private static List<LTVWrapper.CollateralWrapper> collateralList = new  List<LTVWrapper.CollateralWrapper>();
    
    /****************************************************************
* Method: getRiskGroups
* Description: To Fetch Risk Group List to display on Lightning Component "LTVMainScreen"
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    @AuraEnabled
    Public static LTVWrapper getRiskGroups(String prodPackgeID){
        try{
            wrapperObj = new LTVWrapper();
            
            List<ObjectPermissions> lstPermission = SOQLUtility.checkObjectPermission();   
            if (lstPermission == null || lstPermission.size() == 0) {
                wrapperObj.isCreateAllowed = false;
                wrapperObj.isReadAllowed = false;
                wrapperObj.isUpdateAllowed = false;
                wrapperObj.isDeleteAllowed = false;
            }
            else if (lstPermission.size() == 1) {
                wrapperObj.isCreateAllowed = lstPermission[0].PermissionsCreate;
                wrapperObj.isReadAllowed = lstPermission[0].PermissionsRead;
                wrapperObj.isUpdateAllowed = lstPermission[0].PermissionsEdit;
                wrapperObj.isDeleteAllowed = lstPermission[0].PermissionsDelete;
            }
            if (wrapperObj.isReadAllowed) {
                //wrapperObj.riskGrpList = SOQLUtility.getRiskGroupList(prodPackgeID); //
                wrapperObj.riskGroupLst = getRiskGroupWrap(prodPackgeID,wrapperObj);
                if (wrapperObj.riskGroupLst.size() == 0) {
                    wrapperObj.errorMessage = System.Label.LTVRGNotAvailablePP;
                }
            }
            else {
                wrapperObj.errorMessage =System.Label.LTVNoPermissionRiskGroup;
             }
            
            return wrapperObj;
        }catch(exception e){
            return null;
        }
        
    }
    
     /****************************************************************
* Method: getRiskGroupRelatedObjects
* Description: To Fetch Risk Group Related Records for Loan, Collateral and Relationship
in wrapper to display on Lightning Component "LTVAddScreen"
* Input Parameters: Product Package ID, RiskGroup ID
* OutPut Parameters: LTVWrapperObject
* *************************************************************/
    @AuraEnabled
    Public static List<LTVWrapper.riskGroupWrapper> getRiskGroupWrap(String prodPackgeID,LTVWrapper wrapperObj){ // added name
        //System.debug('inside getRiskGroupRelatedObjects');
      
            List<LTVWrapper.riskGroupWrapper> allRisk = new List<LTVWrapper.riskGroupWrapper>();
            List<Risk_Group__c> rskgrpList= SOQLUtility.getRiskGroupList(prodPackgeID);
            LTVWrapper.riskGroupWrapper rskGroupObj;
            System.debug('rskGroupObj-- new list'+rskgrpList);
            
            Map<String, LTVWrapper.riskGroupWrapper> mapRG = new Map<String, LTVWrapper.riskGroupWrapper>();
            if(rskgrpList != null){
                System.debug('!rskgrpList.isEmpty()');
                for(Risk_Group__c rec:rskgrpList){
                    rskGroupObj= new LTVWrapper.riskGroupWrapper();
                    rskGroupObj.riskGroupRec= rec;
                    System.debug('rec.Loans__r'+rec.Loans__r);
                    System.debug('rec.Collateral_Mgmt__r'+rec.Collateral_Mgmt__r);
                    
                    if(rec.Loans__r.size() == 0){
                        rskGroupObj.noLoan = true; 
                    }
                    else{
                        rskGroupObj.noLoan = false; 
                    }
                    if(rec.Collateral_Mgmt__r.size() == 0){
                        rskGroupObj.noCollateral = true; 
                    }
                    else{
                        rskGroupObj.noCollateral = false;
                    }
                    
                    mapRG.put(rec.Id, rskGroupObj);
                }
                List<Risk_Group__c> rskInactiveList= SOQLUtility.getRiskGroupInactive(prodPackgeID);
                if(rskInactiveList != null){
                    for(Risk_Group__c rec:rskInactiveList){
                        rskGroupObj= mapRG.get(rec.Id);
                        
                        System.debug('rec.Loans__r'+rec.Loans__r);
                        System.debug('rec.Collateral_Mgmt__r'+rec.Collateral_Mgmt__r);
                        
                        if(!rskGroupObj.noLoan){
                            rskGroupObj.noLoan = !rec.Loans__r.isEmpty(); 
                        }
                        if(!rskGroupObj.noCollateral){
                            rskGroupObj.noCollateral = !rec.Collateral_Mgmt__r.isEmpty(); 
                        }
                        allRisk.add(rskGroupObj);
                    }
                }
                System.debug('allRisk'+allRisk);
                
            }
            else{
                allRisk = null;
            }
            
            return allRisk;
    
    }
    /****************************************************************
* Method: getRiskGroupRelatedObjects
* Description: To Fetch Risk Group Related Records for Loan, Collateral and Relationship
in wrapper to display on Lightning Component "LTVAddScreen"
* Input Parameters: Product Package ID, RiskGroup ID
* OutPut Parameters: LTVWrapperObject
* *************************************************************/
    @AuraEnabled
    Public static LTVWrapper getRiskGroupRelatedObjects(String prodPackgeID,String riskGroupId){ // added name
        //System.debug('inside getRiskGroupRelatedObjects');
        try{
            wrapperObj = new LTVWrapper();
            wrapperObj = fetchRelatedRecords(prodPackgeID,riskGroupId, wrapperObj);
            System.debug('wrapperObj'+wrapperObj);
            return wrapperObj;
        }catch(exception e){
            return null;
        }
    }
    
    /****************************************************************
* Method: fetchRelatedRecord
* Description: To Fetch Risk Group Related Records for Loan, Collateral and Relationship
in wrapper to display on Lightning Component "LTVAddScreen"
* Input Parameters: Product Package ID, RiskGroup ID
* OutPut Parameters: LTVWrapperObject
* *************************************************************/
    Public static LTVWrapper fetchRelatedRecords(String prodPackgeID, String riskGroupId,LTVWrapper wrapObj){
        
        //System.debug('inside fetchRelatedRecords');
        
        //Get Available records - check for null
        try{
            
            system.debug('fetchRelatedRecords prodPackgeID'+prodPackgeID);
            if(String.isnotBlank(prodPackgeID)){
                wrapObj.selectedloanslist = getLoan(prodPackgeID);
                wrapObj.selectedCollateralslist = getCollaterals(prodPackgeID);
                wrapObj.selectedRealtionshipslist = getRelationships(prodPackgeID);
                
            }
            
            
            system.debug('wrapObj.selectedCollateralslist'+wrapObj.selectedCollateralslist);
            //Get Associated records - Call this on Edit lightning component - check for null
            if(String.isnotBlank(riskGroupId)){
                wrapObj.relRelationshipList = getRGSRelationships(riskGroupId);
                wrapObj.relLoanList= getRGloans(riskGroupId); 
                wrapObj.relCollateralList= getRGcollaterals(riskGroupId);
            }
            return wrapObj;
        }catch(exception e){
            return null;
        }
    }
    
    
    
    /****************************************************************
* Method: createRiskGrouprelationships
* Description: To "SAVE" the Risk Group from Lightning Component "LTVAddScreen"
* Input Parameters: Product Package ID, RiskGroup ID,RiskGroupName,Relationships,Loan,Collaterals,RiskGroupList
* OutPut Parameters: RiskGroupID
* *************************************************************/    
    @AuraEnabled
    Public static String createRiskGrouprelationships(String prodPackgeID,String ltvName,String relationshipRecords,String loanRecords, String collaretalsRecords,String riskGroupList){
        
        
        //system.debug('Checked Accounts--'+ relationshipRecords );
        //system.debug('LTV name--'+ ltvName );
        //system.debug('checked loans'+ loanRecords);
        //system.debug('checked collaterals'+ collaretalsRecords);
        //system.debug('RiskGrpList'+ riskGroupList);
        try{ 
            Result= saveRiskGroup(prodPackgeID,ltvName,relationshipRecords,loanRecords,collaretalsRecords,riskGroupList);
            system.debug('Result'+ Result);
            return Result;
        }catch(exception e){
            return null;
        }
    }
    
    /****************************************************************
* Method: saveRiskGroup
* Description: To "SAVE" RiskGroup
* Input Parameters: prodPackgeID,ltvName,relationshipRecords,loanRecords,collaretalsRecords
* OutPut Parameters: isSuccess
* *************************************************************/ 
    public static String saveRiskGroup(String prodPackgeID, String ltvName, String relationshipRecords, String loanRecords, String collaretalsRecords, String riskGroupList){
        //Create a savepoint while inserting Risk group and related records
        Savepoint sp = Database.setSavepoint();
        try {
            Risk_Group__c riskobj = new Risk_Group__c();
            Boolean isRiskGroupCreated;
            Boolean isJunctionCreated;
            Id riskGroupId;
            
            system.debug('relationship record Ids--'+ relationshipRecords );
            system.debug('ltvNames--'+ ltvName );
            system.debug('prodpageId--'+ prodPackgeID );
            
            //validate if Risk Group Name is duplicate
            if(validateDuplicateCheck(ltvName,riskGroupList,prodPackgeID)){
                outputResult = ConstantUtility.LTV_DUPLICATE;//use labels
                return outputResult;
            }
            else if(string.isNotBlank(ltvName)){
                
                riskGroupId = insertRiskGroupRecord(riskobj,ltvName,prodPackgeID);
                if(riskGroupId != null){
                    
                    isJunctionCreated = updateRelatedRecords(riskGroupId,relationshipRecords,loanRecords,collaretalsRecords,riskGroupList);
                    if(isJunctionCreated){
                        outputResult = riskGroupId;
                    }
                    else{
                        outputResult = ConstantUtility.LTV_ERROR;
                    }
                }
                else{
                    outputResult = ConstantUtility.LTV_ERROR;
                }
            } 
            return  outputResult;  
        } catch (Exception ex) {
            //Rollback to the previous state while any error occurs
            Database.rollback(sp);
            outputResult = ConstantUtility.LTV_ERROR;
            return  outputResult;
        }       
    }
    
    /****************************************************************
* Method: createRelatedRecords
* Description: To "UPDATE" the Risk Group from Lightning Component "LTVEditScreen"
* Input Parameters: RiskGroup ID,Relationships,Loan,Collaterals,RiskGroupList
* OutPut Parameters: RiskGroupID
* *************************************************************/
    @AuraEnabled
    Public static Boolean createRelatedRecords(String riskGroupId,String relationshipRecords, String loanRecords, String collaretalsRecords, String riskGroupList){
        boolean isSuccess = false;
        //Create a savepoint while editing Risk group
        Savepoint sp = Database.setSavepoint();
        try {
            isSuccess = updateRelatedRecords(riskGroupId,relationshipRecords,loanRecords,collaretalsRecords,riskGroupList);
            return isSuccess;
        } catch (Exception ex) {
            //Rollback to the previous state while any error occurs
            Database.rollback(sp);
            return isSuccess;
        }
    }
    
    /****************************************************************
* Method: riskGroupLTVCalculation
* Description: To RGLTV% on RiskGroupList on "LTVMainScreen"
* Input Parameters: ProductPackageID
* OutPut Parameters: isSuccess
* *************************************************************/    
    
    @AuraEnabled
    Public static Boolean riskGroupLTVCalculation(String PPID){
        try{
            Boolean isSuccess;
            System.debug('riskGroupLTVCalculation'+PPID); 
            isSuccess = LTVPPCalculation.LTVCalculation(PPID);     
            return isSuccess;
        }catch(exception e){
            return null;
        }
    }
    
    /****************************************************************
* Method: riskGroupDelete
* Description: To Delete RiskGroup from List from "LTVMainScreen"
* Input Parameters: risk Group Id
* OutPut Parameters: isSuccess
* *************************************************************/  
    @AuraEnabled
    Public static Boolean riskGroupDelete(String riskGroupId){
        Boolean isSuccessdelete;
        try{
            system.debug('#######TEST - Delete method called ' + riskGroupId);
            List<Risk_Group__c> riskToBeDeleted =SOQLUtility.getRiskgrpsDeleted(riskGroupId);
            if(!riskToBeDeleted.isEmpty()) {
                
                delete riskToBeDeleted; 
                isSuccessdelete=true;
            }else {
                //TODO throw exception?
            }
        }catch(exception e){
            
             isSuccessdelete=false;
        }
       return  isSuccessdelete; 
    }
    
    /****************************************************************
* Method: validateDuplicateCheck
* Description: validation: 
* Input Parameters: risk Group Id
* OutPut Parameters: isSuccess
* *************************************************************/  
    Public static Boolean validateDuplicateCheck(String ltvName,String riskGroupList, string ppID){
        
        
            Boolean isDuplicate = False;
            //Query for duplicate check with all linked Risk Group records at PP level
            List<Risk_Group__c> lstRG = SOQLUtility.duplicatenamesRiskGroups(ltvName, ppID);
            if (lstRG.size() > 0) isDuplicate = true;
            return isDuplicate;
        
         
       
    }
    /****************************************************************
* Method: insertRiskGroupRecord
* Description: To "SAVE" RiskGroup
* Input Parameters: riskobj,ltvName,prodPackgeID
* OutPut Parameters: Id
* *************************************************************/ 
    Public static Id insertRiskGroupRecord(Risk_Group__c riskobj, String ltvName,String prodPackgeID){
        
      
            riskobj.Name__c=ltvName;
            riskobj.Product_Package__c= prodPackgeID;
            insert riskobj;
            system.debug('Inserted RiskGroup Details-->'+ riskobj);
            
            riskGroupId=[Select id from Risk_Group__c where id=:riskobj.id LIMIT 1].id;
            system.debug('Risk Group Id to be inserted for related objts-->'+ riskGroupId);
            return riskGroupId;

    }
    /****************************************************************
* Method: updateRelatedRecords
* Description: To "SAVE" Junction Records
* Input Parameters: riskGroupId,relationshipRecords,loanRecords,collaretalsRecords,riskGroupList
* OutPut Parameters: Boolean
* *************************************************************/ 
    Public static Boolean updateRelatedRecords(String riskGroupId,String relationshipRecords, String loanRecords, String collaretalsRecords, String riskGroupList){
        RecursiveTriggerHandler.RiskGroupUpdate = true;
        Boolean isSuccess = false;
        Set<Id> relId = new Set<Id>();
        Set<Id> collId = new Set<Id>();
        Set<Id> loanId = new Set<Id>();
        System.debug('relationshipRecords'+relationshipRecords);
        System.debug('loanRecords'+loanRecords);
        System.debug('collaretalsRecords'+collaretalsRecords);
        if(!string.isBlank(riskGroupId)){
            
            if(!string.isBlank(relationshipRecords)){
                relationshipList =(List<LTVWrapper.realtionshipWrapper>)System.JSON.deserialize(relationshipRecords,List<LTVWrapper.realtionshipWrapper>.class);
                system.debug('relationshipList-' + relationshipList);
                for(LTVWrapper.realtionshipWrapper a:relationshipList){
                    if(a.accountcheck == true){
                        relId.add(a.relatinshipId);
                    }
                    
                }  
                
                List<Account> listAccount =SOQLUtility.updateAccountonRiskGroups(relId); 
                system.debug('Relationships to be updated'+ listAccount);
                if(!listAccount.isEmpty()){
                    for(Account accrec:listAccount){
                        accrec.Risk_Group__c = riskGroupId;
                    }
                    update listAccount;
                } 
            } 
            
            if(!string.isBlank(loanRecords)){
                loanList = (List<LTVWrapper.loanWrapper>)System.JSON.deserialize(loanRecords,List<LTVWrapper.loanWrapper>.class);
                system.debug('loanList-' + loanList);
                for(LTVWrapper.loanWrapper lw:loanList){
                    if(lw.loanCheck == true){
                        loanId.add(lw.loanId);
                    }
                    
                }
                
                
                List<LLC_BI__Loan__c> loanList =SOQLUtility.updateLoansOnRiskGroups(loanId);
                system.debug('Loans to be updated-->'+ loanList);
                if(!loanList.isEmpty()){
                    for(LLC_BI__Loan__c loanrec:loanList){
                        loanrec.Risk_Group__c = riskGroupId;
                    }
                    system.debug('updated Loans to be updated-->'+ loanList);
                    //update loanList;
                    List<Database.SaveResult> SR = Database.update(loanList);
                    System.debug('SaveResult SR'+SR);
                }
            } 
            
            if(!string.isBlank(collaretalsRecords)){
                system.debug('inside collateral records');
                collateralList = (List<LTVWrapper.CollateralWrapper>)System.JSON.deserialize(collaretalsRecords,List<LTVWrapper.CollateralWrapper>.class);
                system.debug('collateralList-' + collateralList);
                
                for(LTVWrapper.CollateralWrapper col:collateralList){
                    if(col.collateralCheck == true){
                        collId.add(col.collateralId);
                    }   
                }
                
                
                List<LLC_BI__Collateral__c> relatedCollList=SOQLUtility.updateCollateralsOnRiskGroups(collId);
                system.debug('Collaterals to be updated -->'+ relatedCollList) ;
                if(!relatedCollList.isEmpty()){
                    for(LLC_BI__Collateral__c colrec:relatedCollList){
                        colrec.Risk_Group__c = riskGroupId;
                    }
                    update  relatedCollList;
                }
            }
            isSuccess = true;           
        }// End of riskgrpid check
        RecursiveTriggerHandler.RiskGroupUpdate = false;
        return isSuccess;
        
        
    }
    
    
    /****************************************************************
* Method: deleteAssociatedRecordRef
* Description: To RGLTV% on RiskGroupList on "LTVMainScreen"
* Input Parameters: ProductPackageID
* OutPut Parameters: isSuccess
* *************************************************************/    
    
    @AuraEnabled
    Public static Boolean deleteAssociatedRecordRef(String operation,String recordID){
        Boolean isSuccess = false;
        RecursiveTriggerHandler.RiskGroupUpdate = true;
        try {
            System.debug('operation'+operation+'recordID'+recordID);
            if(operation.equals(ConstantUtility.LTV_DELETE_LOAN)){
                if(!String.isBlank(recordID)){
                    
                    List<LLC_BI__Loan__c> loanRecList=SOQLUtility.deleteLoanOnRiskGroups(recordID);
                    if(!loanRecList.isEmpty()){
                        for(LLC_BI__Loan__c rec:loanRecList){
                            rec.Risk_Group__c = null;
                        }
                        System.debug('loanRecList in delete'+loanRecList);
                        update loanRecList;
                        isSuccess = true;
                    }
                    
                }
                
            }
            else if(operation.equals(ConstantUtility.LTV_DELETE_COLLATERAL)){
                if(!String.isBlank(recordID)){
                    
                    List<LLC_BI__Collateral__c> relatedCollList = SOQLUtility.deleteCollateralsOnRiskGroups(recordID);
                    if(!relatedCollList.isEmpty()){
                        for(LLC_BI__Collateral__c rec:relatedCollList){
                            rec.Risk_Group__c = null;
                        }
                        System.debug('relatedCollList in delete'+relatedCollList);
                        update relatedCollList;
                        isSuccess = true;
                    }
                }
                
            }
            else if(operation.equals(ConstantUtility.LTV_DELETE_RELATIONSHIP)){
                if(!String.isBlank(recordID)){
                    
                    List<Account> listAccount=SOQLUtility.deleteRelationshipOnRiskGroups(recordID);
                    if(!listAccount.isEmpty()){
                        for(Account rec:listAccount){
                            rec.Risk_Group__c = null;
                        }
                        System.debug('listAccount in delete'+listAccount);
                        update listAccount;
                        isSuccess = true;
                    }
                }
                
            }
            
        } catch (Exception ex) {
            
            RecursiveTriggerHandler.RiskGroupUpdate = false;
            return isSuccess;
        }
        RecursiveTriggerHandler.RiskGroupUpdate = false;
        return isSuccess;
    }
    
    /****************************************************************
* Method: getLoan
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    Public static List<LTVWrapper.loanWrapper> getLoan(String prodPackgeID){
        
      
            List<LTVWrapper.loanWrapper> allLoans=new List<LTVWrapper.loanWrapper>();
            List<LLC_BI__Loan__c> loanList= SOQLUtility.getLoanRecords(prodPackgeID);
            LTVWrapper.loanWrapper loanobj;
            System.debug('loanList-- new list'+loanList);
            if(!loanList.isEmpty()){
                for(LLC_BI__Loan__c l:loanList){
                    loanobj= new LTVWrapper.loanWrapper();
                    loanobj.loanId=l.Id;
                    loanobj.Name=l.Name;
                    loanobj.Stage=l.LLC_BI__Stage__c;
                    loanobj.Amount=l.LLC_BI__Amount__c;
                    loanobj.Amount=l.LLC_BI__Amount__c;
                    loanobj.loanCheck=false;
                    loanobj.loanStatus=l.LLC_BI__Status__c;
                    allLoans.add(loanobj);
                }
            }
            else{
                allLoans = null;
            }
            
            return allLoans; 
    }
    
    
    /****************************************************************
* Method: getCollaterals
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    public static List<LTVWrapper.CollateralWrapper> getCollaterals(String prodPackgeID){
        Set<Id> collListIds =new Set<Id>();
        List<LTVWrapper.CollateralWrapper> allcollaterals=new List<LTVWrapper.CollateralWrapper>();
      //  List<LLC_BI__Loan_Collateral2__c> colpledgeList= SOQLUtility.getcollateralpledgeRecords(prodPackgeID);
        LTVWrapper.CollateralWrapper colobj;
        
    
            
            //for(LLC_BI__Loan_Collateral2__c c: colpledgeList){
            for(LLC_BI__Loan_Collateral2__c c:SOQLUtility.getcollateralpledgeRecords(prodPackgeID)){
                
                collListIds.add(c.LLC_BI__Collateral__c);
            }
                
            
            
            
            List<LLC_BI__Collateral__c> relatedCollList = SOQLUtility.getcollateraleRecords(collListIds);
            if(!relatedCollList.isEmpty()){
                for(LLC_BI__Collateral__c c:relatedCollList){
                    colobj=new LTVWrapper.CollateralWrapper();
                    colobj.collateralId=c.Id;
                    colobj.collateralNumber=c.Name;
                    colobj.Name=c.LLC_BI__Collateral_Name__c;
                    colobj.Type=c.Collateral_Type_Formula__c;
                    colobj.collateralCheck=false;
                    colobj.collStatus=c.LLC_BI__Status__c;
                    allcollaterals.add(colobj);
                }
            }
            else{
                
                allcollaterals = null;
            }  
       
        return allcollaterals; 
    }
    /****************************************************************
* Method: getRiskGroupList
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/ 
    public static List<LTVWrapper.realtionshipWrapper> getRelationships(String prodPackgeID){
        
        
    
            Set<Id> uniqueAccounts =new Set<Id>();
            LTVWrapper.realtionshipWrapper relobj;
            List<LTVWrapper.realtionshipWrapper> allaccounts=new List<LTVWrapper.realtionshipWrapper>();
            List<LLC_BI__Legal_Entities__c> relatedAccounts = SOQLUtility.getEntitiesRecords(prodPackgeID);
            for(LLC_BI__Legal_Entities__c e:relatedAccounts){
                if(e.LLC_BI__Borrower_Type__c==ConstantUtility.LTV_BORROWER||e.LLC_BI__Borrower_Type__c==ConstantUtility.LTV_CO_BORROWER){
                    
                    uniqueAccounts.add(e.LLC_BI__Account__c);
                }
            }
            
            List<Account> listAccount=SOQLUtility.getAccountRecords(uniqueAccounts);
            if(!listAccount.isEmpty()){
                for (Account a:listAccount){
                    
                    relobj= new LTVWrapper.realtionshipWrapper();
                    relobj.relatinshipId=a.Id;
                    relobj.Name=a.Name;
                    relobj.Type=a.Type;
                    relobj.JFNumber=a.JFNumber__c;
                    relobj.accountcheck=false;
                    relobj.relStatus=a.Status__c;
                    allaccounts.add(relobj);
                }
            }
            else{
                allaccounts = null;
            }
            
            return allaccounts;

    }
    
    
    /****************************************************************
* Method: getRGSRelationships
* Description: To Fetch Risk Group List
* Input Parameters: Product Package ID
* OutPut Parameters: List Of Risk Group
* *************************************************************/
    public static List<Account> getRGSRelationships(String riskGroupId){
        
      
            
            List<Account> listAccount= SOQLUtility.getRiskGroupAssociatedAccounts(riskGroupId);
            system.debug('Available relationships---> '+listAccount);
            if(listAccount.isEmpty()){
                listAccount = null;
            }
            return listAccount;
       
    }
    
    /****************************************************************
* Method: getRGloans
* Description: To Fetch Risk Group Loan List
* Input Parameters: RiskGroup ID
* OutPut Parameters: List Of Loans
* *************************************************************/
    public static List<LLC_BI__Loan__c> getRGloans(String riskGroupId){
      
            List<LLC_BI__Loan__c> loanList =SOQLUtility.getRiskGroupAssociatedLoans(riskGroupId);
            system.debug('Available loans---> '+loanList);
            if(loanList.isEmpty()){
                loanList = null;
            }
            return loanList;
      
    }
    
    /****************************************************************
* Method: getRGcollaterals
* Description: To Fetch Risk Group associated Collaterals
* Input Parameters: RiskGroup Id
* OutPut Parameters: List Of collaterals
* *************************************************************/
    public static List<LLC_BI__Collateral__c>  getRGcollaterals(String riskGroupId){ 
        
      
            List<LLC_BI__Collateral__c> relatedCollList = SOQLUtility.getRGcollateralsRecords(riskGroupId);
            system.debug('Available collateral---> '+relatedCollList); 
            if(relatedCollList.isEmpty()){
                relatedCollList = null;
            }
            return relatedCollList;
      
        
        
        
    }
    
}