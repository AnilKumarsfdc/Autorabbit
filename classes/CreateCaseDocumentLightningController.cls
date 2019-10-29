/* --------------------------------------------------------------------------------------------------
     Name:            CreateCaseDocumentLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  for Creating Case Documents.
	 Test class:      CreateCaseDocumentLightningCntlTest.cls 
    ------------------------------------------------------------------------------------------------ */

public class CreateCaseDocumentLightningController {
	        
	/**
	* @description: This method gets the Type and Data Type from Metadata
	* 
	**/
    @AuraEnabled
	public static Map<String, List<String>> getDocumentTypes(){

		Map<String, List<String>> docMap = new Map<String, List<String>> ();

		for (Case_Document_Metadata__mdt docMdt : [SELECT Type__c, Data_Type__c
												   FROM Case_Document_Metadata__mdt LIMIT 10000]) {
			if (docMap.get(docMdt.Type__c) != null) {
			List<String> dataTypeList = docMap.get(docMdt.Type__c);
			dataTypeList.add(docMdt.Data_Type__c);
			docMap.put(docMdt.Type__c, dataTypeList);
			} else {
				docMap.put(docMdt.Type__c, new List<String> { docMdt.Data_Type__c });
			}
		}

		return docMap;
	}

    
    /**
	* @description : This method gets List of Case Contact from Case.
	* 
	**/   
    @AuraEnabled
    public static List<Case_Contact__c> getCaseContactList(Id caseId){
        
        List<Case_Contact__c> caseContactList = new List<Case_Contact__c>();
        
        for (Case_Contact__c caseContact : [SELECT Id, Name, Case__c, Contact__c, Contact__r.Name, BDP_Contact__c, BDP_Contact__r.F_Number__c,
                                            BDP_Contact__r.First_Name__c, BDP_Contact__r.Last_Name__c
                                       		FROM Case_Contact__c 
                                            WHERE Case__c =:caseId]) {
                                                caseContactList.add(caseContact);
                                            }
        
        return caseContactList;
    }

    
    /**
	* @description: This method inserts Case Documents
	* 
	**/
    @AuraEnabled
    public static void saveCaseDocuments(string insertCaseDocumentsString) {
        List<Missing_Information__c> caseDocumentsToInsert = null;
        
        if (insertCaseDocumentsString != null) {
            caseDocumentsToInsert = (List<Missing_Information__c>) JSON.deserialize(insertCaseDocumentsString,
                                                                            List<Missing_Information__c>.class);
        }
        
        if (caseDocumentsToInsert != null && caseDocumentsToInsert.size() > 0) {
            try{
                Database.insert(caseDocumentsToInsert);
            }
            catch (AuraHandledException e){
                throw e;
            }
        }
    }
}