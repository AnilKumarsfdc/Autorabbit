/* --------------------------------------------------------------------------------------------------
     Name:            CreateCaseContactLightningController.cls 
     Description:     Aura controller of Lightning component which represents user-friendly interface
					  for Creating Case Contacts.
	 Test class:      CreateCaseContactLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */

public class CreateCaseContactLightningController {
        
    
    /**
	* @description : This method gets List of BDP Contact based on J# from the Relationship object  .
	* 
	**/   
    @AuraEnabled
    public static List<wrapperClass> getContactList(Id bdpCaseId){
        
        List<wrapperClass> bdpContactWrapperList = new List<wrapperClass>();
        Map<Id, Id> caseConMap = new Map<Id,Id>();
        
        Case caseObj =[SELECT Id, Status, BDP_Company__c,
                       (SELECT Id, Name, Contact__c, BDP_Contact__c, BDP_Contact__r.Name FROM Case_Contacts__r)
                       FROM Case
                       WHERE Id =:bdpCaseId];
        
        for (Case_Contact__c caseContact : caseObj.Case_Contacts__r){
            
            caseConMap.put(caseContact.BDP_Contact__c,caseContact.Id) ;     
        }
        
        
        for (BDP_Contact_Relationship__c rel :[SELECT BDP_Company__r.Company__c, BDP_Company__r.Company__r.Name, BDP_Contact__c,
                                               BDP_Company__c, BDP_Contact__r.First_Name__c, BDP_Contact__r.Last_Name__c, BDP_Contact__r.BDP_Email__c,
                                               BDP_Contact__r.Salesforce_Contact__c, BDP_Contact__r.F_Number__c,
                                               BDP_Contact__r.Salesforce_Contact__r.Name
                                               FROM BDP_Contact_Relationship__c
                                               WHERE BDP_Company__c  = :caseObj.BDP_Company__c
                                               LIMIT 10000]) {
			if(caseConMap.get(rel.BDP_Contact__c) == NULL && rel.BDP_Contact__r.Salesforce_Contact__c!= NULL){
            	bdpContactWrapperList.add(new wrapperClass(rel,false));
            }
        } 
        return bdpContactWrapperList;
    }
    
    /**
	* @description: Wrapper Class and its constructor
	* 
	**/
    public class wrapperClass{
        @AuraEnabled public BDP_Contact_Relationship__c bdpContactRelObj {get; set;}
        @AuraEnabled public Boolean checked {get; set;}
        
        public wrapperClass(BDP_Contact_Relationship__c bdpContactRel, boolean isChecked){
            bdpContactRelObj = bdpContactRel;
            checked = isChecked;
        }  
    }
    
    /**
	* @description: This method inserts Case Contacts
	* 
	**/
    @AuraEnabled
    public static void saveCaseContacts(string insertCaseContactsString) {
        List<Case_Contact__c> caseContactsToInsert = null;
        
        if (insertCaseContactsString != null) {
            caseContactsToInsert = (List<Case_Contact__c>) JSON.deserialize(insertCaseContactsString,
                                                                            List<Case_Contact__c>.class);
        }
        
        if (caseContactsToInsert != null && caseContactsToInsert.size() > 0) {
            try{
                Database.insert(caseContactsToInsert);
            }
            catch (AuraHandledException e){
                throw e;
            }
        }
    }
}