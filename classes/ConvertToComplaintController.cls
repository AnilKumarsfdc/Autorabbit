/* --------------------------------------------------------------------------------------------------
     Name:            ConvertToComplaintController.cls 
     Description:     Controller of Lightning component and Visualforce page to change
                      Case RecordType to Complaint
     Test class:      ConvertToComplaintControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public with sharing class ConvertToComplaintController {
    
    private static final String RECORD_TYPE = 'Complaint';
    public String cachedCaseId;
    public Case objCase1{get;set;}
    public static Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RECORD_TYPE).getRecordTypeId();
	public static final Set<String> profiles = new Set<String> { 'System Administrator' , 'SAN 5' , 'SAN System Admin' };
    public static final Set<String> recordTypes = new Set<String> { 'Servicing Request' }; 
     /** 
     * @description : ConvertToComplaintController init.
     **/
    public ConvertToComplaintController(Apexpages.StandardController controller){       
        cachedCaseId = controller.getId();
        objCase1 = new Case(Id=cachedCaseId);
    }
    
    /** 
     * @description : This method will check component access for current login user.
     **/
    @AuraEnabled
    public static boolean hasAccess(ID recordId){
        User userObj = [SELECT Id, Profile.Name 
                        FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        Case caseObj = [SELECT Id, RecordType.Name
                        FROM Case WHERE Id =:recordId LIMIT 1];
        if(profiles.contains(userObj.Profile.Name) && recordTypes.contains(caseObj.RecordType.Name)){
            return true;
        }else{
            return false;
        }
    }
    
     /** 
     * @description : This method is used by VF page to update the case record type.
     **/
    public PageReference save(){
        
        if (objCase1.RecordTypeId != complaintRecordTypeId){
            objCase1.RecordTypeId = complaintRecordTypeId;
            objCase1.Formerly_Query__c = true;
            objCase1.Convert_to_Complaint_Date__c = Date.today();
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Record already converted to Complaint'));
            return null;
        }
        try{
            Database.update(objCase1);
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Could not convert to complaint'));
            return null;
        }
        
        PageReference pageRef = new PageReference('/' +  objCase1.Id + '?param=' + Math.random());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /** 
     * @description : This method will get the Case record Id from Lightning component and change the record type.
     **/
    @AuraEnabled
    public static void changeRecordType(ID recordId){
        Case caseObj = [SELECT Id, RecordTypeId, Formerly_Query__c,Convert_to_Complaint_Date__c 
                        FROM Case WHERE Id =:recordId LIMIT 1];
                            
        if (caseObj.RecordTypeId != complaintRecordTypeId){
            caseObj.RecordTypeId = complaintRecordTypeId;
            caseObj.Formerly_Query__c = true;
            caseObj.Convert_to_Complaint_Date__c = Date.today();
            
	        Database.DMLOptions dmo = new Database.DMLOptions();
	        dmo.assignmentRuleHeader.useDefaultRule= true;
	        caseObj.setOptions(dmo);                  
        }
    
        Database.update(caseObj);      
    }
}