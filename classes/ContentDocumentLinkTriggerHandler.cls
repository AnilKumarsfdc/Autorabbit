/* --------------------------------------------------------------------------------------------------
Name:            ContentDocumentLinkTriggerHandler.cls 
Description:     Handler Class for ContentDocumentLinkTrigger.Trigger
Test class:      ContentDocumentLinkTriggerHandlerTest.cls 
------------------------------------------------------------------------------------------------ */
public without sharing class ContentDocumentLinkTriggerHandler {    
    @TestVisible
    private static final String SHARE_TYPE = 'I';
    private static final String FOLDER_NAME = 'KYC, AML and FinCrime Documentation';
    private static Boolean ignoreTriggerExecution = false;
    
    /** 
	* @description : This method processes after insert functionalities.
	**/    
    public static void processAfterInsert(List<ContentDocumentLink> conDocList) {
        try {
        	if (!ignoreTriggerExecution) {
	            contentCheck(conDocList);
	            contentDocsInsert(conDocList);
	            contentDocAttchmentCount(conDocList);
        	}
        }
        catch(Exception e) {
            throw e;
        }
    }
    public static void processAfterDelete(List<ContentDocumentLink> conDocList){
        try{
            contentDocAttchmentCount(conDocList);
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /**
	* @description : This methord will check if Files were uploaded to Meeting Record Object
	* 
	**/
    public static void contentCheck(List<ContentDocumentLink> cdlList) {
        try {
            Set<Id> mIds = new Set<Id> ();
            for (ContentDocumentLink contentDocLink : cdlList) {
                if (contentDocLink.LinkedEntityId != null &&
                    contentDocLink.LinkedEntityId.getSObjectType() == Meeting__c.sObjecTtype) {
                        mIds.add(contentDocLink.LinkedEntityId);
                    }
            }
            if (mIds.size() > 0) {
                updateMeeting(mIds);
            }
        }
        catch(Exception e) {
            throw e;
        }
    }
    
    /**
	* @description : Update checkbox on Meeting Record
	* 
	**/
    public static void updateMeeting(Set<Id> mIds) {
        List<Meeting__c> meetingList = [SELECT Id, Attachment_Added__c
                                        FROM Meeting__c
                                        WHERE Id IN :mIds LIMIT 10000];
        if (meetingList != null && meetingList.size() > 0) {
            for (Meeting__c meeting : meetingList) {
                meeting.Attachment_Added__c = true;
            }
            try {
                Database.update(meetingList);
            }
            catch(Exception e) {
                throw e;
            }
        }
    }
    
    /**
	* @description : This method shares attachment with Case and KYC Company Folder.
	* 
	**/   
    private static Void contentDocsInsert(List <ContentDocumentLink> conDocList){
        Map<Id,Id> conDocLinkMap = new Map<Id,Id>();
        Set<Id> accIds= new Set<Id>();
        List<ContentDocumentLink> conList = new List<ContentDocumentLink>();
        for(ContentDocumentLink contentDocL : conDocList)
        {
            if (contentDocL.LinkedEntityId != null &&
                contentDocL.LinkedEntityId.getSObjectType() == Missing_Information__C.sObjecTtype) {
                    conDocLinkMap.put(contentDocL.LinkedEntityId, contentDocL.ContentDocumentId);
            }
        }  
        
        for(Id conDocId : conDocLinkMap.keyset()){            
            for(Missing_Information__c caseDoc: [SELECT Id, Case__c, Case__r.AccountId 
                                                 FROM Missing_Information__c 
                                                 WHERE Id=:conDocLinkMap.keyset()]) { 
                 accIds.add(caseDoc.Case__r.AccountId);
                 conList.add(new ContentDocumentLink(                                     
                 	ContentDocumentId = conDocLinkMap.get(conDocId),
                 	LinkedEntityId = caseDoc.Case__c,
                 	ShareType = SHARE_TYPE
                 ));                    
            } 
            
            for(Company_Folder__c comFol: [SELECT Id, Name 
                                           FROM Company_Folder__c
                                           WHERE Name=:FOLDER_NAME 
                                           AND company__c IN :accIds]){
                   conList.add(new ContentDocumentLink(
                       ContentDocumentId = conDocLinkMap.get(conDocId),
                       LinkedEntityId = comFol.Id,
                       ShareType = SHARE_TYPE
                   ));                         
            }
            
            if(!conList.isEmpty()){
                Database.insert(conList);
            }
        } 
    } 
    
    /**
	* @description : This method Counts number of Attachments in Case Document and Company Folder.
	*  Jira Story Number : SR-397
	**/   
    private static void contentDocAttchmentCount(List <contentDocumentLink> contentCountList){        
        Set<id> countId = new Set<id>();
       	List<sObject> objectsToUpdate = new List<sObject>();      
        for(contentDocumentLink cdl1 : ContentCountList){
            if(cdl1.LinkedEntityId.getSObjectType() == Missing_Information__C.sObjecTtype 
               || cdl1.LinkedEntityId.getSObjectType() == Company_Folder__c.sObjecTtype){
                   //Creating List of LinkedEntityId for both the Objects.
                  countId.add(cdl1.LinkedEntityId);
               }
        }
        //Map to store LinkEntityId and Attachment count.
        
        map<Id,Integer> countMap = new Map<Id,Integer>();
        if(countId.size()>0){
            AggregateResult[] curProdCount = [SELECT LinkedEntityId LkId, COUNT(Id) cnt 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId IN: countId
                                              group by LinkedEntityId];
            if(curProdCount.size()>0){
                for(AggregateResult ar : curProdCount ){
                    countMap.put((Id)ar.get('LkId'), (Integer)ar.get('cnt'));
                } 
            }
        }  
        if(countMap.size()>0){
            for(Id attachmentCount : countMap.keySet()){
                if(attachmentCount.getSObjectType() == Missing_Information__C.sObjecTtype){
                    objectsToUpdate.add(new Missing_Information__C(
											Number_of_Attached_Documents__c = countMap.get(attachmentCount),
											Id = attachmentCount ));
                }
                else if(attachmentCount.getSObjectType() == Company_Folder__c.sObjecTtype){
                    objectsToUpdate.add(new Company_Folder__c(
											Number_of_Attached_Documents__c = countMap.get(attachmentCount),
											Id = attachmentCount));
                  }
            }
        }
        if(objectsToUpdate.size()>0){
            Database.update(objectsToUpdate);
        }
    }
}