/* --------------------------------------------------------------------------------------------------
Name:            BDPContactListController.cls 
Description:     Aura controller of Lightning component which represents user-friendly interface
of showing BDP Contacts as a Related List on Company. 
Test class:      BDPContactListControllerTest.cls 
------------------------------------------------------------------------------------------------ */
public with sharing class BDPContactListController {
    
    /** 
	* @description : Get BDP Contact details from BDP Contact Relationship Object based on Company
	**/
    @AuraEnabled
    public static BdpContactWrapper getContactList(String companyId, Decimal pageNumber ,Integer recordToDisply) {
	
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        // create a instance of wrapper class.
        BdpContactWrapper wrapperObj =  new BdpContactWrapper();  
        wrapperObj.pageSize = pageSize;
        wrapperObj.page = (Integer) pageNumber;
        wrapperObj.total = [SELECT count() FROM BDP_Contact_Relationship__c WHERE BDP_Company__r.Company__c = :companyId AND BDP_Contact__r.Active__c = TRUE LIMIT 1000];
        wrapperObj.bdpConRelList = [SELECT Role__c, BDP_Contact__r.Id, BDP_Contact__r.Job_Title__c, BDP_Contact__r.First_Name__c,
                                    BDP_Contact__r.Last_Name__c, BDP_Contact__r.Name, BDP_Contact__r.BDP_Last_Updated_Date__c,
                                    BDP_Contact__r.BDP_Email__c, BDP_Contact__r.BDP_Phone__c, BDP_Contact__r.CreatedDate,
                                    BDP_Contact__r.Active__c
                                    FROM BDP_Contact_Relationship__c 
                                    WHERE BDP_Company__r.Company__c = :companyId 
									AND BDP_Contact__r.Active__c = TRUE
                                    LIMIT :recordToDisply OFFSET :offset];
        // return the wrapper class instance .
        return wrapperObj;
    }
    
    /** 
	* @description : Wrapper class with AuraEnabled properties
	**/    
    public with sharing class BdpContactWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<BDP_Contact_Relationship__c> bdpConRelList {get;set;}
    }
}