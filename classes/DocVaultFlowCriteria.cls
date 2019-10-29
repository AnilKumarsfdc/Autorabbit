global with sharing class DocVaultFlowCriteria {
    
    private static final Set<String> acctDocReviewStatus = new Set<String>{'Approved','Reviewed'};
    private static final Set<String> loanDocReviewStatus = new Set<String>{'Approved','Reviewed'};
            private static final Set<String> docPHDocReviewStatus = new Set<String>{'Approved','Reviewed'};
                
                private static final Set<String> loanVaultStages = new Set<String>{'Final Decision'};
                    
                    public class InputParameters {
                        @InvocableVariable(
                            label = 'Input Version Ids'
                            required = true
                            description = 'String Container of Version IDs to process in the GetVaultReadyDocuments Invocable Method'
                        )
                        public List<String> versionIdList;
                    }
    
    public class OutputParameters {
        @InvocableVariable(
            label = 'Vault Ready Version Ids'
            description = 'String Container of Version IDs ready to vault from the GetVaultReadyDocuments Invocable Method'
        )
        public List<String> updatedIdList;
    }
    
    
    
    @InvocableMethod(label='GetVaultReadyDocuments' description='Return a list of ids of Document Version records that are ready for vaulting.')
    public static List<OutputParameters> markReadyToVault(List<InputParameters> inParms) {
        Set<Id> docVersionIdInSet = new Set<Id>();
        for (InputParameters inParm : inParms) {     
            for(String versionId : inParm.versionIdList){
                docVersionIdInSet.add((Id) versionId);
            }
        }
        
        Set<Id> docVersionVaultIdSet = new Set<Id>();
        Set<Id> adAccountDocItemIdSet = new Set<Id>();
        Set<Id> adLoanDocItemIdSet = new Set<Id>();
        Set<Id> adDocPHDocItemIdSet = new Set<Id>();
        
        Map<Id, Set<Id>> phDVMap = new Map<Id, Set<Id>>();
        
        List<LLC_BI__Document_Version__c> dvList = new List<LLC_BI__Document_Version__c>(
            [
                SELECT 
                Id
                , LLC_BI__Placeholder_Id__c 
                FROM LLC_BI__Document_Version__c 
                WHERE Id IN :docVersionIdInSet
            ]
        );
        
        for(LLC_BI__Document_Version__c dvItem : dvList){
            if(dvItem.LLC_BI__Placeholder_Id__c != null) {
                String strObjAPIName = ((Id)dvItem.LLC_BI__Placeholder_Id__c).getSObjectType().getDescribe().getName();
                if(strObjAPIName == 'LLC_BI__AccountDocument__c') {
                    adAccountDocItemIdSet.add((Id)dvItem.LLC_BI__Placeholder_Id__c);
                } else if(strObjAPIName == 'LLC_BI__LLC_LoanDocument__c') {
                    adLoanDocItemIdSet.add((Id)dvItem.LLC_BI__Placeholder_Id__c);
                } else if(strObjAPIName == 'LLC_BI__Document_Placeholder__c') {
                    //adDocPHDocItemIdSet.add((Id)dvItem.LLC_BI__Placeholder_Id__c);
                }
            }
            set<Id> theseDVs;
            if(phDVMap.containskey(dvItem.LLC_BI__Placeholder_Id__c)){
                theseDVs = phDVMap.get(dvItem.LLC_BI__Placeholder_Id__c);
            } else{
                theseDVs = new Set<Id>();
            }
            theseDVs.add(dvItem.Id);
            phDVMap.put(dvItem.LLC_BI__Placeholder_Id__c,theseDVs);
        }
        
        if(adAccountDocItemIdSet.Size() > 0){
            List<LLC_BI__AccountDocument__c> acctDocList = new List<LLC_BI__AccountDocument__c>([
                SELECT 
                Id
                , LLC_BI__reviewStatus__c
                , LLC_BI__Account__r.LLC_BI__Tax_Identification_Number__c
                FROM LLC_BI__AccountDocument__c 
                WHERE Id IN :adAccountDocItemIdSet
                AND NDOC__isTrash__c = false
                AND LLC_BI__attachmentId__c != null
            ]); 
            for(LLC_BI__AccountDocument__c acctDocItem : acctDocList){
                /*if(acctDocReviewStatus.contains(acctDocItem.LLC_BI__reviewStatus__c) && acctDocItem.LLC_BI__Account__r.LLC_BI__Tax_Identification_Number__c != null ){
                    docVersionVaultIdSet.addAll(phDVMap.get(acctDocItem.Id));
                }*/
                docVersionVaultIdSet.addAll(phDVMap.get(acctDocItem.Id));
            }
        }
        
        if(adLoanDocItemIdSet.Size() > 0){
            List<LLC_BI__LLC_LoanDocument__c> loanDocList = new List<LLC_BI__LLC_LoanDocument__c>([
                SELECT 
                Id
                , LLC_BI__reviewStatus__c
                , LLC_BI__Loan__r.LLC_BI__Stage__c
                FROM LLC_BI__LLC_LoanDocument__c 
                WHERE Id IN :adLoanDocItemIdSet
                AND NDOC__isTrash__c = false
                AND LLC_BI__attachmentId__c != null
            ]);
            for(LLC_BI__LLC_LoanDocument__c loanDocItem : loanDocList){
                /*if(loanDocReviewStatus.contains(loanDocItem.LLC_BI__reviewStatus__c) && loanVaultStages.contains(loanDocItem.LLC_BI__Loan__r.LLC_BI__Stage__c)){
                    docVersionVaultIdSet.addAll(phDVMap.get(loanDocItem.Id));
                    }*/
                docVersionVaultIdSet.addAll(phDVMap.get(loanDocItem.Id));
            }
        }
        
        if(adDocPHDocItemIdSet.Size() > 0){
            List<LLC_BI__Document_Placeholder__c> docPHDocList = new List<LLC_BI__Document_Placeholder__c>([
                SELECT 
                Id
                , LLC_BI__External_Id__c
                , LLC_BI__Review_Status__c
                FROM LLC_BI__Document_Placeholder__c 
                WHERE Id IN :adDocPHDocItemIdSet
                AND LLC_BI__Is_Trash__c = false
                AND NDOC__Attachment_Id__c  != null
            ]
                                                                                                          );
            for(LLC_BI__Document_Placeholder__c docPHDocItem : docPHDocList){
                if(docPHDocReviewStatus.contains(docPHDocItem.LLC_BI__Review_Status__c)){
                    docVersionVaultIdSet.addAll(phDVMap.get(docPHDocItem.Id));
                }
            }             
        }
        
        List<OutputParameters> outputParams = new List<OutPutParameters>();
        OutputParameters outParm = new OutputParameters();
        outParm.updatedIdList = new List<String>();
        List<LLC_BI__Document_Version__c> docVerList = new List<LLC_BI__Document_Version__c>();
        for(Id dvItemId : docVersionVaultIdSet){
            outParm.updatedIdList.add((String)dvItemId);
        }
        outputParams.add(outParm);
        return outputParams;
        
        
        
    }
}