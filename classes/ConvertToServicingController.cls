public class ConvertToServicingController {

    private static final String RECORD_TYPE = 'Servicing Request';
    public String cachedCaseId;
    public Case objCase1{get;set;}
    public static Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RECORD_TYPE).getRecordTypeId();
	public static final Set<String> profiles = new Set<String> { 'System Administrator' , 'SAN 5' , 'SAN System Admin' };
    public static final Set<String> recordTypes = new Set<String> { 'Refunds / Write Offs' }; 
     /** 
     * @description : ConvertToServicingRequestController init.
     **/
    public ConvertToServicingController(Apexpages.StandardController controller){       
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
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Record already converted to Servicing Request'));
            return null;
        }
        try{
            Database.update(objCase1);
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Could not convert to Servicing Request'));
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
        Case caseObj = [SELECT Id, RecordTypeId, Formerly_Query__c,Amount_Requested__c,Value__c,Redress_Goodwill__c,SGO_RCA__c
                        FROM Case WHERE Id =:recordId LIMIT 1];
                            
        if (caseObj.RecordTypeId != complaintRecordTypeId){
            caseObj.RecordTypeId = complaintRecordTypeId;
            caseObj.Formerly_Query__c = true;
			System.debug(caseObj.Amount_Requested__c);
			caseObj.Value__c = caseObj.Amount_Requested__c;

            
	        Database.DMLOptions dmo = new Database.DMLOptions();
	        dmo.assignmentRuleHeader.useDefaultRule= true;
	        caseObj.setOptions(dmo);                  
        }
    
        Database.update(caseObj);      
    }
}