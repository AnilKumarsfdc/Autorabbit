/* --------------------------------------------------------------------------------------------------
  Name:            ProjectOnboardingLigthningControllerTest.cls 
  Description:     Test class for ProjectOnboardingLigthningController class
 
  Date                 Version     Author              Summary of Changes 
  -----------          -------     -----------------   -------------------------------------------
  26-Apr-2017          1.0         Iegor Nechyporenko   Final Version
  ------------------------------------------------------------------------------------------------ */
@isTest
private class ProjectOnboardingLightningControllerTest {
	private static final String PROSPECT_RECORD_TYPE_NAME = 'Prospect';
	private static final String PROJECT_NAME = 'Test Project';
	private static final String LEGAL_ENTITY_NAME = 'Legal Entity';
	private static final String NEW_ENTITY_NAME = 'New Entity';
	private static final String PROJECT_DEVELOPER_NAME = 'ConfidentialProject';


	/** 
	 * @description : Test Setup Method to create Project Account and Related Prospect Account Created By: Iegor Nechyporenko
	 **/
	@testSetup public static void setupTestData() {
		try {
			System.runAs(PrepareTestData.getRunningUser()) {
				RecordType projectRecordType = [SELECT Id FROM RecordType
				                                WHERE DeveloperName = :PROJECT_DEVELOPER_NAME
				                                LIMIT 1];

				Database.insert(new List<Account> {
					               new Account(
					                           Name = PROJECT_NAME,
					                           RecordTypeId = projectRecordType.Id
					), new Account(
					               Name = LEGAL_ENTITY_NAME,
					               RecordTypeId = ProjectOnboardingLigthningController.prospectRecordTypeId
					)
				                });

			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}


	}



	/** 
	 * @description : Test method to check logic, when new Legal Entity is created for a Project chosen to become public Created By: Iegor Nechyporenko
	 **/
	public static testMethod void makeProjectPublicWithNewEntityTest() {
		try {
			System.runAs(PrepareTestData.getRunningUser()) {

				Account projectAccount = [SELECT Id FROM Account WHERE Name = :PROJECT_NAME LIMIT 1];
				Test.startTest();
				Case newCaseInfo = ProjectOnboardingLigthningController.onboardProject(
				                                                                       projectAccount.Id /*projectId*/,
				                                                                       true /*isNewEntity*/,
				                                                                       null /*existingCompanyId*/,
				                                                                       LEGAL_ENTITY_NAME /*newCompanyName*/,
				                                                                       false /*keepConfidential*/
				);
				Test.stopTest();
				Account resultAccount = [SELECT Id, RecordTypeId, Name FROM Account
				                         WHERE Id = :projectAccount.Id
				                         LIMIT 1];
				System.assertEquals(projectAccount.Id, newCaseInfo.AccountId);
				System.assertEquals(ProjectOnboardingLigthningController.prospectRecordTypeId,
				                    resultAccount.RecordTypeId);
				System.assertEquals(LEGAL_ENTITY_NAME, resultAccount.Name);
			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}

	}


	/** 
	 * @description : Test method to check logic, when new Legal Entity is created for a Project chosen to remain confidential Created By: Iegor Nechyporenko
	 **/
	public static testMethod void keepProjectConfidentialWithNewEntityTest() {

		try {
			System.runAs(PrepareTestData.getRunningUser()) {


				Account projectAccount = [SELECT Id FROM Account WHERE Name = :PROJECT_NAME LIMIT 1];
				Test.startTest();
				Case newCaseInfo = ProjectOnboardingLigthningController.onboardProject(
				                                                                       projectAccount.Id /*projectId*/,
				                                                                       true /*isNewEntity*/,
				                                                                       null /*existingCompanyId*/,
				                                                                       LEGAL_ENTITY_NAME /*newCompanyName*/,
				                                                                       true /*keepConfidential*/
				);
				Test.stopTest();
				Relationship__c newRelationship = [SELECT Id, Company__c, Related_Company__c, Related_Company__r.Name
				                                   FROM Relationship__c
				                                   WHERE Company__c = :projectAccount.Id LIMIT 1000];
				System.assertEquals(newRelationship.Related_Company__c, newCaseInfo.AccountId);
				System.assertEquals(LEGAL_ENTITY_NAME, newRelationship.Related_Company__r.Name);
			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}



	}



	/** 
	 * @description : Test method to check logic, when existing Legal Entity is created for a Project , chosen to become public Created By: Iegor Nechyporenko
	 **/
	public static testMethod void makeProjectPublicWithExistingEntityTest() {
		try {
			System.runAs(PrepareTestData.getRunningUser()) {

				Account projectAccount = [SELECT Id FROM Account WHERE Name = :PROJECT_NAME LIMIT 1];
				Account prospectEntity = [SELECT Id FROM Account WHERE Name = :LEGAL_ENTITY_NAME LIMIT 1];
				Test.startTest();
				Case newCaseInfo = ProjectOnboardingLigthningController.onboardProject(
				                                                                       projectAccount.Id /*projectId*/,
				                                                                       false /*isNewEntity*/,
				                                                                       prospectEntity.Id /*existingCompanyId*/,
				                                                                       null /*newCompanyName*/,
				                                                                       false /*keepConfidential*/
				);
				Test.stopTest();
				Relationship__c newRelationship = [SELECT Id, Company__c, Related_Company__c,
				                                   Company__r.RecordTypeId, Related_Company__r.Name
				                                   FROM Relationship__c
				                                   WHERE Company__c = :projectAccount.Id LIMIT 1];
				System.assertEquals(prospectEntity.Id, newCaseInfo.AccountId);
				System.assertEquals(ProjectOnboardingLigthningController.prospectRecordTypeId,
				                    newRelationship.Company__r.RecordTypeId);
				System.assertEquals(prospectEntity.Id, newRelationship.Related_Company__c);

			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}
	}


	/** 
	 * @description :  Test method to check logic, when existing Legal Entity is created for a Project.  Project chosen to remain confidential Created By: Iegor Nechyporenko
	 **/
	public static testMethod void keepProjectConfidentialWithExistingEntityTest() {
		try {
			System.runAs(PrepareTestData.getRunningUser()) {
				Account projectAccount = [SELECT Id FROM Account WHERE Name = :PROJECT_NAME LIMIT 1];
				Account prospectEntity = [SELECT Id FROM Account WHERE Name = :LEGAL_ENTITY_NAME LIMIT 1];
				Test.startTest();
				Case newCaseInfo = ProjectOnboardingLigthningController.onboardProject(
				                                                                       projectAccount.Id /*projectId*/,
				                                                                       false /*isNewEntity*/,
				                                                                       prospectEntity.Id /*existingCompanyId*/,
				                                                                       null /*newCompanyName*/,
				                                                                       true /*keepConfidential*/
				);
				Test.stopTest();
				Relationship__c newRelationship = [SELECT Id, Company__c, Related_Company__c, Related_Company__r.Name
				                                   FROM Relationship__c
				                                   WHERE Company__c = :projectAccount.Id LIMIT 1000];
				System.assertEquals(prospectEntity.Id, newCaseInfo.AccountId);
				System.assertEquals(prospectEntity.Id, newRelationship.Related_Company__c);
			}
		} catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}

	}

}