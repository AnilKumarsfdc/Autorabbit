/********************************************************
* @Author: Alagar Raja
* @Class: GeWS_PCSMautoDecision
* @Description: This prepares the payload rerquire for PCSM and 
                invokes their service to get a decision on 
                loan application
*********************************************************/
public class GeWS_PCSMautoDecision {

    public static List<Results> resList { get; set; }
    
    public static Results getDecision(Id productPackageId,List<Id> loanIds, String expectedResult){
        
        Savepoint sp = Database.setSavepoint();
        Boolean anyError = false;
        
        String tempResult = expectedResult;
        String packageStatus;
        Integer i = 0;
        
        List<loanResults> resList = new List<loanResults>();
        
        List<LLC_BI__Loan__c> updateList = new List<LLC_BI__Loan__c>();
        Map<Id,String> autodecisionresult = new Map<Id,String>();
        
        for(LLC_BI__Loan__c loan: [Select Id,System_Decision__c,System_Decision_Description__c,Decision_Group__c,Reason_Code__c,
                                          Reason_Code_Description__c,scorecardLDM_Score__c,scorecardLDM_ScorecardName__c,
                                          scorecardLDM__c,backgroundScorecardLDM_Score__c,backgroundScorecardLDM_ScoreCardName__c,
                                          backgroundScorecardLDM_ScoreCardID__c,Error_Message__c,Error_Code__c from LLC_BI__Loan__c 
                                          where Id IN:loanIds AND LLC_BI__Product_Package__c =:productPackageId ]){
            
            if(expectedresult == 'Approve/Reject'){
                
                packageStatus = 'Reject';
                if(i == 0){
                    tempResult = 'Approve';
                }else{
                    tempResult = 'Reject';
                }
            }else if(expectedresult == 'Approve/Refer'){
                
                packageStatus = 'Refer';
                if(i == 0){
                    tempResult = 'Approve';
                }else{
                    tempResult = 'Refer';
                }
                
            }else if(expectedresult == 'Reject/refer'){
                
                packageStatus = 'Refer';
                if(i == 0){
                    tempResult = 'Reject';
                }else{
                    tempResult = 'Refer';
                }
            }else if(expectedresult == 'Approve/Reject/refer'){
            
                if(i == 0){
                    tempResult = 'Approve';
                }else if(i == 1){
                    tempResult = 'Reject';
                }else{
                    tempResult = 'Refer';
                }
                packageStatus = 'Refer';
            }else{
               packageStatus = expectedResult;
            }
            
            i++;
            
            autodecisionresult.put(loan.id,tempResult);
            
            if(tempResult == 'Approve'){
                
                //APPROVE result
                loan.Reason_Code__c = 'GDS55';
                loan.Reason_Code_Description__c = 'Good Score';
                
                loan.System_Decision__c = 'Approve';
                loan.System_Decision_Description__c = 'Good credit, hence loan approved';
                loan.Decision_Group__c = 'APRV';
                //loan.reasons = reasonList;
                
                loan.scorecardLDM_Score__c = 8;
                loan.scorecardLDM_ScorecardName__c = 'APPROVECARD';
                loan.scorecardLDM__c = 'A0000001';
                
                loan.backgroundscorecardLDM_Score__c = 8.1;
                loan.backgroundscorecardLDM_ScorecardName__c = 'APPROVECARD';
                loan.backgroundScorecardLDM_ScoreCardID__c = 'A0000001';
                                
            }else if(tempResult == 'Reject'){
                
                //REJECT result
                
                loan.Reason_Code__c = 'BDS77';
                loan.Reason_Code_Description__c = 'Bad Credit Score';
                
                loan.System_Decision__c = 'Reject';
                loan.System_Decision_Description__c = 'Bad credit, hence loan rejected';
                loan.Decision_Group__c = 'RJT';
                
                loan.scorecardLDM_Score__c = 5;
                loan.scorecardLDM_ScorecardName__c = 'REJECTCARD';
                loan.scorecardLDM__c = 'RJ000001';
                
                loan.backgroundscorecardLDM_Score__c = 4.8;
                loan.backgroundscorecardLDM_ScorecardName__c = 'REJECTCARD';
                loan.backgroundScorecardLDM_ScoreCardID__c = 'RJ000001';
                                
            }else if(tempResult == 'Refer'){
                
                //REJECT result
                loan.Reason_Code__c = 'FCS762';
                loan.Reason_Code_Description__c = 'Fair Credit Score';
                
            
                loan.System_Decision__c = 'Refer';
                loan.System_Decision_Description__c = 'Not enough info, hence loan referred';
                loan.Decision_Group__c = 'RFR';
                
                loan.scorecardLDM_Score__c = 6.5;
                loan.scorecardLDM_ScorecardName__c = 'REFERCARD';
                loan.scorecardLDM__c = 'RFR00001';
                
                loan.backgroundscorecardLDM_Score__c = 6.55;
                loan.backgroundscorecardLDM_ScorecardName__c = 'REFERCARD';
                loan.backgroundScorecardLDM_ScoreCardID__c = 'RFR00001';
                
                
            }if(expectedResult == 'ERROR'){
                loan.Error_Message__c = 'Insufficient Data';
                loan.Error_Code__c = 'ERR0123';
            }
            
            
            //System.debug('$$$$$ '+ loan);
            updateList.add(loan);
            
        }
        
        if(updateList.size() > 0){
            Database.SaveResult[] srList = Database.update(updateList, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    
                    loanResults rst = new loanResults();
                    rst.loanId = sr.getId();
                    rst.AutoDecisionResults = autodecisionresult.get(sr.getId());
                    rst.nCinoUpdateResults = 'SUCCESS';
                    resList.add(rst);
                    
                }else {
                    
                    loanResults rst = new loanResults();
                    rst.loanId = sr.getId();
                    rst.AutoDecisionResults = autodecisionresult.get(sr.getId());
                    
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        rst.nCinoUpdateResults = 'ERROR: '+ err.getMessage();
                        anyError = TRUE;
                    }
                    resList.add(rst);
                }
            }
        }
        
        //Update product package
        LLC_BI__Product_Package__c pkg = new LLC_BI__Product_Package__c();
        pkg.Id = productPackageId;
        pkg.Auto_Decision_Status__c = packageStatus;
        
        Database.SaveResult[] packageList = Database.update(new List<LLC_BI__Product_Package__c> { pkg } , false);
        
        packageResults pr = new packageResults();
        pr.packageId = pkg.Id;
        pr.packageStatus = packageStatus;
        
        for (Database.SaveResult sr : packageList) {
            if (sr.isSuccess()) {
                pr.nCinoUpdateResults = 'SUCCESS';
                
            }else{
                for(Database.Error err : sr.getErrors()) {
                    pr.nCinoUpdateResults = 'ERROR: '+ err.getMessage();
                    anyError = TRUE;
                }
            }
        }
        
        if(anyError){
            Database.rollback( sp );
        }
        
        Results rlts = new Results();
        rlts.ProductPackage = pr;
        rlts.loan = resList;
        
        return rlts;
    }
    
    public class Results {
        public packageResults ProductPackage { get; set;}
        public List<loanResults> Loan { get; set;}
    }
    
    public class packageResults {
        public Id packageId { get; set; }
        public string packageStatus { get; set; }
        public string nCinoUpdateResults { get; set; }
    }
    public class loanResults {
        public Id loanId { get; set; }
        public string AutoDecisionResults { get; set; }
        public string nCinoUpdateResults { get; set; }
    }
        
}