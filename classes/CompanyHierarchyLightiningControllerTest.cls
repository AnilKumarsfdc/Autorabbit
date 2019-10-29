/* --------------------------------------------------------------------------------------------------
     Name:            CompanyHierarchyLightningControllerTest.cls 
     Description:     Apex test class for CompanyHierarchyLightningControllerTest
     Date                 Version     Author              Summary of Changes 
     -----------          -------     -----------------   -------------------------------------------
     25-Jul-2017          0.1         Iegor Nechyporenko  Final Pre-Demo version
    ------------------------------------------------------------------------------------------------ */
@isTest 
private with sharing class CompanyHierarchyLightiningControllerTest {
	/** 
	 * @description : Check that specific errow will be displayed when Account is not connected with Data.com
	 **/
	private static testMethod void checkNoDnbCompany() {		
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			Account testAccount = PrepareTestData.getDefaultAccount();
			insert testAccount;
			
			Test.startTest();
			CompanyHierarchyLightiningController.CompanyHierarchyResponse response = null;
			response = CompanyHierarchyLightiningController.getCompanyHierarchyData(testAccount.Id);
			Test.stopTest();
			
			System.assert(!response.isCorrect, 'Dnb company shouldn\'t be found for specific Account');
		}
	}    
	
	/** 
	 * @description : Checks getting children of specific DnB Node
	 **/
	private static testMethod void testQueryOfNewDnbCompany(){
		String testDunsNumber = '1231211';
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			CompanyHierarchyLightiningController.CompanyHierarchyNode[] responseArray;
			Test.startTest();
			responseArray = CompanyHierarchyLightiningController.getNodeChildren(testDunsNumber, null);
			Test.stopTest();
			System.assertEquals(1, responseArray.size());
		}		
	}
	
	/** 
	 * @description : Checks process of geting specific node details
	 **/
	private static testMethod void testGetNodeDetails(){
		String testDunsNumber = '1231211';
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			CompanyHierarchyLightiningController.CompanyHierarchyNode responseNode;
			Test.startTest();
			responseNode = CompanyHierarchyLightiningController.getNodeDetails(testDunsNumber);
			Test.stopTest();
			System.assert(!responseNode.hasSalesforceRecord);
			System.assertEquals(false, responseNode.expanded);
		}		
	}	
	
		
	/** 
	 * @description : Test creation of new Salesfroce Company
	 **/
	private static testMethod void testCreateSalesforceCompany(){
		String testDunsNumber = '1231211';
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			CompanyHierarchyLightiningController.SalesforceCompanyCreationResponse response;
			Test.startTest();
			response = CompanyHierarchyLightiningController.createSalesforceCompany(testDunsNumber);
			Test.stopTest();
			System.assertEquals(false, response.isCreated);
		}		
	}	
		
	/** 
	 * @description : Test creation of new Salesfroce Company
	 **/
	private static testMethod void testInitialnbCompanyCall(){
		String testDunsNumber = '1231211';
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			Account testAccount = PrepareTestData.getDefaultAccount();
			testAccount.DunsNumber = testDunsNumber;
			insert testAccount; 
			
			Test.startTest();
			CompanyHierarchyLightiningController.CompanyHierarchyResponse response = null;
			response = CompanyHierarchyLightiningController.getCompanyHierarchyData(testAccount.Id);
			Test.stopTest();
			
			System.assert(response.isCorrect);
			System.assertEquals(testAccount.Id, response.rootNode.sfCompanyId);
			System.assertEquals(1, response.rootNode.children.size());
		}		
	}	
		
	/** 
	 * @description : Test creation of new Salesfroce Company
	 **/
	private static testMethod void testUndefinedRootNodeCreation(){
		String testDunsNumber = '1231211';
		User testUser = new User(Id = UserInfo.getUserId());
		System.runAs(testUser) {
			CompanyHierarchyLightiningController.CompanyHierarchyNode responseNode;
			Test.startTest();
			responseNode = new CompanyHierarchyLightiningController.CompanyHierarchyNode(true, testDunsNumber);
			Test.stopTest();
			
			System.assertEquals(true, responseNode.isUndefinedParentNode);
			System.assertEquals(testDunsNumber, responseNode.dunsNumber);
		}		
	}		
}