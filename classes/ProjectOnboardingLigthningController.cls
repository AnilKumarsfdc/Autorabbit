/* --------------------------------------------------------------------------------------------------
   Name:            ProjectOnboardingLigthningController.cls 
   Description:     Aura controller of Lightning component which is used to setup Confidential Project
				    Onboarding Process
   Test class:      ProjectOnboardingLigthningControllerTest.cls 

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   24-Apr-2017          0.1         Iegor Nechyporenko   Prototype Demo Version
   25-Apr-2017          1.0         Iegor Nechyporenko   Final version after bug fixes
  ------------------------------------------------------------------------------------------------ */
public with sharing class  ProjectOnboardingLigthningController {
    private static final String PROSPECT_RECORD_TYPE_NAME = 'Prospect';
    private static final String ONBOARDING_RECORD_TYPE_NAME = 'Onboarding';
    private static final String LEGAL_ENTITY_PICKLIST_VALUE = 'Legal Entity';
    private static final String SPV_PICKLIST_VALUE = 'Project';

     private static final String NEW_CASE_SUB = 'Onboarding';
    @testVisible private static final String prospectRecordTypeId;
    @testVisible private static final String oboardingRecordTypeId;
    
    /*Static constructor to initialize Prospect Record Type
    **Created By iegor Nechyporenko*/
    static {
    	Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
		prospectRecordTypeId = recordTypeInfoMap.get(PROSPECT_RECORD_TYPE_NAME).getRecordTypeId();   
        
        recordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        oboardingRecordTypeId = recordTypeInfoMap.get(ONBOARDING_RECORD_TYPE_NAME).getRecordTypeId(); 
    }
    
    
    /** 
	 * @description : Setup onboarding Process for the Project Created By: Iegor Nechyporenko
	 **/
    @AuraEnabled
    public static Case onboardProject(String projectId, Boolean isNewEntity, String existingCompanyId,
                                      String newCompanyName, Boolean keepConfidential){ 
                                          try{   
                                          
                                      
        //Change account recordType to prospect
        if (!keepConfidential) {
            updateProjectInfo(projectId, isNewEntity ? newCompanyName : null);
        }
                                              
    }  catch (Exception e) 
        {        
            system.debug('Error: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
                                          
                                          
        //Create new legal entity relationship
        if (keepConfidential || !isNewEntity) {
            if (isNewEntity) {
                existingCompanyId = createNewProspect(newCompanyName);
            }            
           createLegalEntityRelationship(projectId, existingCompanyId);
        }
                        
        //Return predefined Case data
        return new Case(
        	AccountId = (isNewEntity && !keepConfidential) ? projectId : existingCompanyId,
            Subject = NEW_CASE_SUB,
            RecordTypeId = oboardingRecordTypeId
        );
    }

    /** 
	* @description : Creates new prospect with a specific name  Created By: Iegor Nechyporenko
	**/
    private static Id createNewProspect(String prospectName){
        Account prospectToInsert = new Account(
            Name = prospectName,
            RecordTypeId = prospectRecordTypeId
        );
        Database.insert(prospectToInsert);
        return prospectToInsert.Id;        
    }    
    

    /** 
	* @description : Change existing project Record Type and rename it when needed  Created By: Iegor Nechyporenko
	**/
    private static void updateProjectInfo(String projectId, String newName){
        Account projectToUpdate = new Account(
            Id = projectId,
            RecordTypeId = prospectRecordTypeId
        );
        if (newName != null) {
            projectToUpdate.Name = newName; //Rename existing project
        }
        Database.update(projectToUpdate);        
    }
    
    /** 
	* @description : Create new Legal Entity Relationship between Project and RAPPort record Created By: Iegor Nechyporenko
	**/  
    private static void createLegalEntityRelationship(String projectId, String relatedCompanyId){
        Database.insert( new Relationship__c(
            Company__c = projectId,
            Related_Company__c = relatedCompanyId,
            Relationship_Name__c = LEGAL_ENTITY_PICKLIST_VALUE,
            Relationship_Type__c = SPV_PICKLIST_VALUE
        ) );        
    }
}