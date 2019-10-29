/* --------------------------------------------------------------------------------------------------
   Name:            AssignBDPContactsController.cls 
   Description:     This class assigns multiple bdp contacts to selected contact
   Test class:      AssignBDPContactsControllerTest.cls 
 ------------------------------------------------------------------------------------------------ */  
public without sharing class AssignBDPContactsController  {
	private static final Integer MAX_RELATIONSHIP_LIMIT = 100;
    private static final Integer PAGE_SIZE = 10;

	/** 
	* @description : Get BDP Contact details from BDP Contact Relationship Object based on Contact
	**/
    @AuraEnabled
    public static OuterWrapper getContactList(String contactId, Integer pageIndex) {
        OuterWrapper wrapperObj =  new OuterWrapper();
        try{
            pageIndex = Integer.valueOf(pageIndex);

            Set<Id> relatedAccountIdSet = new Set<Id>();
            
            for (AccountContactRelation rel : [SELECT Id, AccountId
                               FROM AccountContactRelation
                               WHERE ContactId =:contactId
                               ORDER BY IsDirect DESC
                               LIMIT :MAX_RELATIONSHIP_LIMIT]) {
                relatedAccountIdSet.add(rel.AccountId);
            }
        
            List<wrapperClass> bdpRelWrapper = new List<wrapperClass>();
            // create a instance of wrapper class.
            
          
            Integer pageOffset = (pageIndex - 1) * PAGE_SIZE;
           
            Map<id,Set<id>> uniqueCompanyToContactMap = new Map<id,Set<id>>();
            BDP_Contact_Relationship__c previousValue = null;
            Integer realPageSize = 0;
           
            for (BDP_Contact_Relationship__c bdpRel : [SELECT Id,BDP_Contact__c,BDP_Contact__r.Id, BDP_Contact__r.First_Name__c, 
            										   BDP_Company__r.Id, BDP_Contact__r.Last_Name__c, BDP_Contact__r.Name, 
            										   BDP_Contact__r.F_Number__c, BDP_Company__c,
            										   BDP_Company__r.BDP_Customer_Number__c, BDP_Company__r.Company__r.Name
                                                       FROM BDP_Contact_Relationship__c 
                                                       WHERE BDP_Company__r.Company__c IN :relatedAccountIdSet
                                                         AND BDP_Contact__r.Salesforce_Contact__c = NULL 
                                                        ORDER BY BDP_Contact__c, BDP_Company__c
                                                        LIMIT :PAGE_SIZE OFFSET :pageOffset]) {
                If(previousValue == null || (bdpRel.BDP_Contact__c != previousValue.BDP_Contact__c ||
                                             bdpRel.BDP_Company__c != previousValue.BDP_Company__c)) {
                    bdpRelWrapper.add(new WrapperClass(bdpRel,false));                                           
                }                                                           
                previousValue = bdpRel;               
                realPageSize++;
            }           
            
            wrapperObj.canLoadMoreItems = (realPageSize < PAGE_SIZE) ? false : true;
            wrapperObj.wrapperList = bdpRelWrapper;
    
           
        }catch(Exception e){
            throw e;
        }
     return wrapperObj;
    }

	/** 
	* @description : Wrapper class with AuraEnabled properties
	**/    
    public with sharing class OuterWrapper {        
        @AuraEnabled public boolean canLoadMoreItems {get;set;}
        @AuraEnabled public List<WrapperClass> wrapperList {get;set;}
        
        /**
        * @description: constructor
        * 
        **/
        public OuterWrapper(){
            wrapperList=new List<wrapperClass>();
        }
    }

	/**
	* @description: Wrapper Class and its constructor
	* 
	**/
    public with sharing class WrapperClass{
        @AuraEnabled public BDP_Contact_Relationship__c bdpContactRelObj {get; set;}
        @AuraEnabled public Boolean checked {get; set;}
        
        /**
        * @description: constructor
        * 
        **/
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
    public static void saveBDPContacts(string updateBDPContactsString) {
        List<BDP_Contact__c> bdpContactsToUpdate = null;
        
        if (updateBDPContactsString != null) {
            bdpContactsToUpdate = (List<BDP_Contact__c>) JSON.deserialize(updateBDPContactsString,
                                                                            List<BDP_Contact__c>.class);
        }
        
        if (bdpContactsToUpdate != null && bdpContactsToUpdate.size() > 0) {
            try{
            	BdpContactUpdater utilityObject = new BdpContactUpdater();
                utilityObject.updateBDPContacts(bdpContactsToUpdate);
            }
            catch (AuraHandledException e){
                throw e;
            }
        }
    }
    
    public without sharing class BdpContactUpdater {
    	public void updateBDPContacts(List<BDP_Contact__c> contactList) {
    		Database.update(contactList);
    	}
    }
    
}