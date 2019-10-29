global with sharing class ECMTransactionLogTriggerHandler extends nFORCE.ATriggerHandler {
    List<LLC_BI__Document_Version__c> docVersionsToUpdate = new List<LLC_BI__Document_Version__c>();

    global ECMTransactionLogTriggerHandler() {}

    global override void afterUpdate(List<sObject> newObjs, List<sObject> oldObjs, Set<Id> objIds) {
        Map<Id,Map<String,Object>> recordDetailMap = getTransactionDetails(newObjs);
system.debug('+++++ AfterUpdate'+newObjs); 
        if (recordDetailMap.keySet().size() > 0){
            processTransactionDetails(recordDetailMap);
        }

    }

    private Map<Id,Map<String,Object>> getTransactionDetails(List<sObject> newObjs){
        Map<Id,Map<String,Object>> recordDetailMap = new Map<Id,Map<String,Object>>();
        for (sObject newObj : newObjs) {
            nFUSE__Transaction_Log__c tl = (nFUSE__Transaction_Log__c)newObj;

            if(tl.nFUSE__Transaction_Status__c == TRANSACTION_STATUS_COMPLETE &&
                tl.nFUSE__Vendor_Status__c == VENDOR_STATUS){
                recordDetailMap.put(tl.Id, (Map<String, Object>)JSON.deserializeUntyped(tl.nFUSE__Transaction_Detail__c));
            }
        }
        
        system.debug('-------------recordDetailMap-----------'+recordDetailMap);

        return recordDetailMap;
    }

    private void processTransactionDetails(Map<Id,Map<String,Object>> recordDetailMap){
        
        system.debug('-------------recordDetailMap-----------'+recordDetailMap);
        Set<Id> logIdSet = recordDetailMap.keySet();
        for (Id logId : logIdSet) {
            Map<String, Object> versionMap = recordDetailMap.get(logId);
            Set<String> versionIds = versionMap.keySet();

            Map<String, LLC_BI__Document_Version__c> versionsToUpdateMap = getVersionsToUpdateMap(versionIds);

            for (String versionId : versionIds) {
                Object versionDetails = versionMap.get(versionId);
                Map<String, Object> versionDetailsMap = (Map<String, Object>)versionDetails;

                LLC_BI__Document_Version__c docVersion = versionsToUpdateMap.get(String.valueOf(versionId).substring(0, 15));

                for (String field : versionDetailsMap.keySet()){
                    if (field == 'LLC_BI__Published_Date__c'){
                        docVersion.put(field, DateTime.newInstance(Long.valueOf((String)versionDetailsMap.get(field))));
                    }
                    else{
                        docVersion.put(field, versionDetailsMap.get(field));
                    }
                }

                docVersionsToUpdate.add(docVersion);
            }
        }
        system.debug('-------------docVersionsToUpdate-----------'+docVersionsToUpdate);
        nFORCE.DMLUtility.updateObj(docVersionsToUpdate);
    }

    private Map<String, LLC_BI__Document_Version__c> getVersionsToUpdateMap(Set<String> versionIds){
        system.debug('-------------versionIds-----------'+versionIds);
        Map<String, LLC_BI__Document_Version__c> versionMap = new Map<String, LLC_BI__Document_Version__c>();

        List<LLC_BI__Document_Version__c> docVersionsToUpdate = [
            SELECT 
                Id, 
                LLC_BI__External_Download_URL__c, 
                LLC_BI__External_ID__c, 
                LLC_BI__External_Preview_URL__c, 
                LLC_BI__External_Thumbnail_URL__c,
                LLC_BI__Published_Date__c
            FROM 
                LLC_BI__Document_Version__c
            WHERE
                Id IN :versionIds];

        for(LLC_BI__Document_Version__c version : docVersionsToUpdate){
            versionMap.put(String.valueOf(version.Id).substring(0, 15), version);
        }
system.debug('-------------versionMap-----------'+versionMap);
        return versionMap;
    }

    public final String TRANSACTION_STATUS_COMPLETE = 'Complete';
    public final String VENDOR_STATUS = 'ECM_offload';

}