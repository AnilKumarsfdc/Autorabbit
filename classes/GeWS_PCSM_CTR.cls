public with sharing class GeWS_PCSM_CTR {
    
    public string str { get; set; }
    public GeWS_PCSM_CTR(){
        Id accId = '0019E000011gfDw';
        //str = GeWS_PCSM_BureauAPI.generatePayload(new List<Id> { accId }, TRUE);
        
        //Get decision call
        Id ppId = 'a449E000000OZzLQAW';
        List<Id> loanIds = new List<id>();
        
        for(LLC_BI__Loan__c  ll: [Select Id from LLC_BI__Loan__c where LLC_BI__Product_Package__c =:ppId]){
            loanIds.add(ll.Id);
        }
            
        str = GeWS_PCSM_GetDecisionAPI.generatePayload(ppId ,loanIds);
    }
}