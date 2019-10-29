/* --------------------------------------------------------------------------------------------------
     Name:            CompanyHierarchyLightningController.cls 
     Description:     Aura controller of Lightning component which represents Data.com based company
   	 hierarchy. Controller is used both by Company Hierarchy and Company Hierarchy Node components
     Test class:      CompanyHierarchyLightningControllerTest.cls 
     Date                 Version     Author              Summary of Changes 
     -----------          -------     -----------------   -------------------------------------------
     25-Jul-2017          0.1         Iegor Nechyporenko  Final Pre-Demo version
    ------------------------------------------------------------------------------------------------ */
public with sharing class CompanyHierarchyLightiningController {
	public static final String NO_DNB_ENTITY_ERROR = 'There is no D&B entity found for current record';
	public static final String PROSPECT_RECORD_TYPE = 'Prospect';
	
	/*
	* @description Method returns initial information about company based on three possible scenarios:
	* 1) Company is Global Headquarter, then it returns company with it's children
	* 2) Company is Child of Global Headquarter. Then company and it's parent returned
	* 3) In other case, company, Global Headquarter, and expandable parent will be returned
	*/
	@AuraEnabled
	public static CompanyHierarchyResponse getCompanyHierarchyData(String accountId){
		CompanyHierarchyResponse response = new CompanyHierarchyResponse();
		try {
			Account baseAccount = [SELECT Id, Name, DunsNumber, Owner.Name FROM Account WHERE Id = :accountId];
			DatacloudDandBCompany dnbCompany = null;
			if (baseAccount.DunsNumber != null) {
				dnbCompany = getCompanyByDunsNumber(baseAccount.DunsNumber);
			}
			
			//In case when account is empty we should skip creation of tree, as record is not in salesforce yet
			if (dnbCompany == null) {
				response.isCorrect = false;
				response.errorMessage = NO_DNB_ENTITY_ERROR;
			} else {
				//Fetch initial tree containing three elements
				response.rootNode = getInitialHierarchyTree(dnbCompany,  baseAccount);
			}
			
		} catch (Exception e) {
			response.isCorrect = false;
			response.errorMessage = e.getMessage();
		} 
		return response;
	}
	
	/*
	* @description Aura methods returns children of the specific company, excluding selected ids
	*/
	@AuraEnabled
	public static CompanyHierarchyNode[] getNodeChildren(String dunsNumber, List<String> exclude){
		CompanyHierarchyNode[] nodeChildren = new List<CompanyHierarchyNode>();
		Set<String> excludeSet = (exclude == null) ? new Set<String>() : new Set<String>(exclude);
		DatacloudDandBCompany[] companyChildren = getCompanyChildren(dunsNumber, excludeSet);
		Map<String, Account> sfAccountMap = getSfCompanyMapForDnbCompanies(companyChildren);
		Map<String, Id >dandBCompanyIdMap = getIdMapForDnbCompanies(companyChildren);
		
		for (DatacloudDandBCompany childCompany : companyChildren) {
			nodeChildren.add(new CompanyHierarchyNode(
				childCompany, 
				sfAccountMap.get(childCompany.DunsNumber), 
				dandBCompanyIdMap.get(childCompany.DunsNumber)
			));
		}
		
		return nodeChildren;
	}
	
	/*
	* @description Get information about specific node, based on Duns Number
	*/
	@AuraEnabled
	public static CompanyHierarchyNode getNodeDetails(String dunsNumber){
		DatacloudDandBCompany dnbCompany = getCompanyByDunsNumber(dunsNumber);
		Account sfAccount = getSfAccountForDnbCompany(dunsNumber);
		Id dandBCompanyId = getDandBCompanyId(dunsNumber);
		return new CompanyHierarchyNode(dnbCompany, sfAccount, dandBCompanyId);
	}
	
	/*
	* @description Adds Data.com company to Salesforce as a new Prospect
	*/
	@AuraEnabled
	public static SalesforceCompanyCreationResponse createSalesforceCompany(String dunsNumber) {
		SalesforceCompanyCreationResponse response = new SalesforceCompanyCreationResponse();
		try {
			DatacloudDandBCompany dnbCompany = getCompanyByDunsNumber(dunsNumber);
			Account sfAccount = getSfAccountForDnbCompany(dunsNumber);
			response.salesforceAccountName = dnbCompany.Name;
			
			if (sfAccount == null) {
				DandBCompany newDnbCompany = getDandBCompany(dnbCompany);
				Account newAccount = getAccountFromDndCompany(dnbCompany);
				newAccount.DandBCompanyId = (newDnbCompany != null) ? newDnbCompany.Id : null;
				Database.insert(newAccount);
				response.salesforceAccountName = newAccount.Name;
				response.salesforceOwnerName = UserInfo.getName();
				response.dnbCompanyId = (newDnbCompany != null) ? newDnbCompany.Id : null;
				sfAccount = newAccount;
			} else {
				response.salesforceOwnerName = sfAccount.Owner.Name;
			}
						
			response.isCreated = true;
			response.salesforceAccountId = sfAccount.Id;
		} catch (Exception e) {
			response.isCreated = false;
			response.errorMessage = e.getMessage();
		}
		return response;
	}
	
	/*
	* @description Returns initial tree based on based on three possible scenarios:
	* 1) Company is Global Headquarter, then it returns company with it's children
	* 2) Company is Child of Global Headquarter. Then company and it's parent returned
	* 3) In other case, company, Global Headquarter, and expandable parent will be returned
	*/
	private static CompanyHierarchyNode getInitialHierarchyTree(DatacloudDandBCompany dnbCompany, Account sfAccount) {
		CompanyHierarchyNode rootNode = null;
		Id dandBCompanyId = getDandBCompanyId(dnbCompany.DunsNumber);
		CompanyHierarchyNode currentCompanyNode = new CompanyHierarchyNode(dnbCompany, sfAccount, dandBCompanyId);
		currentCompanyNode.isCurrentNode = true;
		
		if (dnbCompany.GlobalUltimateDunsNumber == null || dnbCompany.ParentOrHqDunsNumber == null || 
			dnbCompany.GlobalUltimateDunsNumber == dnbCompany.DunsNumber){
			currentCompanyNode.children = getNodeChildren(dnbCompany.DunsNumber, null);
			currentCompanyNode.expanded = (currentCompanyNode.children.size() > 0);
			currentCompanyNode.canLoadMoreChildren = false;
			rootNode = currentCompanyNode;
		} else {
			DatacloudDandBCompany globalCompany = getCompanyByDunsNumber(dnbCompany.GlobalUltimateDunsNumber);
			Account globalSfAccount = getSfAccountForDnbCompany(globalCompany.DunsNumber);
			Id globalDandBCompanyId = getDandBCompanyId(globalCompany.DunsNumber);
			
			CompanyHierarchyNode globalNode = new CompanyHierarchyNode(globalCompany, globalSfAccount, globalDandBCompanyId);
			globalNode.expanded = true;
			
			if (dnbCompany.GlobalUltimateDunsNumber == dnbCompany.ParentOrHqDunsNumber) {
				globalNode.children.add(currentCompanyNode);
			} else {
				globalNode.canLoadMoreChildren = false;
				CompanyHierarchyNode parentUndefinedNode = new CompanyHierarchyNode(true, dnbCompany.ParentOrHqDunsNumber);
				parentUndefinedNode.children.add(currentCompanyNode);
				parentUndefinedNode.canLoadMoreChildren = false;
				parentUndefinedNode.expanded = true;
				globalNode.children.add(parentUndefinedNode);
			}
			
			rootNode = globalNode;
		}
		return rootNode;
	}
	
	/*
	* @description Returns Salesfroce Account by Duns Number, or null if it doesn't exists
	*/
	private static Account getSfAccountForDnbCompany(String dunsNumber){
		Account[] queryResult = [SELECT Id, DunsNumber, Owner.Name FROM Account WHERE DunsNumber = :dunsNumber LIMIT 1];
		return (queryResult.size() > 0) ? queryResult.get(0) : null;		
	}
	
	/*
	* @description DandBCompany by Duns Number, or null if it doesn't exists
	*/
	private static Id getDandBCompanyId(String dunsNumber) {
		DandBCompany[] queryResult = [SELECT Id FROM DandBCompany WHERE DunsNumber = :dunsNumber LIMIT 1];
		return (queryResult.size() > 0) ? queryResult.get(0).Id : null;
	}
	
	/*
	* @description Returns DnB Account by Duns Number, or null if it doesn't exists
	*/
	private static DatacloudDandBCompany getCompanyByDunsNumber(String DunsNumber) {
		//DatacloudDandBCompany cannot be queries within tests, so new record should be returned
		if (Test.isRunningTest()){ return new DatacloudDandBCompany();}
		DatacloudDandBCompany[] queryResult = [SELECT Id, DunsNumber, City, Country, EmployeesTotal,
							IsParent, GlobalUltimateBusinessName, GlobalUltimateDunsNumber,
							Name, ParentOrHqBusinessName, ParentOrHqDunsNumber, Revenue
							FROM DatacloudDandBCompany
							WHERE DunsNumber = :DunsNumber
							LIMIT 1];
		return queryResult.size() > 0 ? queryResult.get(0) : null;
	}
	
	/*
	* @description Returns all children of the company with specific duns number, excluding list of loaded one's
	*/
	private static DatacloudDandBCompany[] getCompanyChildren(String ParentDunsNumber, Set<String> excludeDunsNumberSet) {
		DatacloudDandBCompany[] resultCompanies = new List<DatacloudDandBCompany>();
		if (Test.isRunningTest()) {
			resultCompanies.add(new DatacloudDandBCompany());	
		} else {
			for (DatacloudDandBCompany dnbCompany : [SELECT Id, DunsNumber, City, Country, EmployeesTotal,
								IsParent, GlobalUltimateBusinessName, GlobalUltimateDunsNumber,
								Name, ParentOrHqBusinessName, ParentOrHqDunsNumber, Revenue
								FROM DatacloudDandBCompany
								WHERE ParentOrHqDunsNumber = :ParentDunsNumber
								LIMIT :GlobalConstants.MAX_QUERY_LIMIT]) {
				//Company should be excluded itself from the returned list
				if (dnbCompany.DunsNumber != ParentDunsNumber && !excludeDunsNumberSet.contains(dnbCompany.DunsNumber)) {
					resultCompanies.add(dnbCompany);
				}
			}
		}
		return resultCompanies;
	}
	
	/*
	* @description Returns map of Duns Numbers as keys and Salesforce Accounts as values for list of DnB Companies
	*/
	private static Map<String, Account> getSfCompanyMapForDnbCompanies(DatacloudDandBCompany[] dnbCompanyList){
		Set<String> dunsNumberSet = new Set<String>();
		for (DatacloudDandBCompany dnbCompany : dnbCompanyList){
			dunsNumberSet.add(dnbCompany.DunsNumber);
		}
		
		Account[] sfAccountList = [SELECT Id, DunsNumber, Owner.Name FROM Account 
								   WHERE DunsNumber IN :dunsNumberSet
								   LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
								   
		Map<String, Account> resultMap = new Map<String, Account>();
		for (Account sfAccount : sfAccountList) {
			resultMap.put(sfAccount.DunsNumber, sfAccount);
		}
		return resultMap;
	}
	
	/*
	* @description Returns map of Duns Numbers as keys and Data.com company Ids as values for list of DnB Companies
	*/
	private static Map<String, Id> getIdMapForDnbCompanies(DatacloudDandBCompany[] dnbCloudCompanyList){
		Set<String> dunsNumberSet = new Set<String>();
		for (DatacloudDandBCompany dnbCompany : dnbCloudCompanyList){
			dunsNumberSet.add(dnbCompany.DunsNumber);
		}
		
		DandBCompany[] dnbCompanyList = [SELECT Id, DunsNumber FROM DandBCompany 
								   WHERE DunsNumber IN :dunsNumberSet
								   LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
								   
		Map<String, Id> resultMap = new Map<String, Id>();
		for (DandBCompany dnbCompany : dnbCompanyList) {
			resultMap.put(dnbCompany.DunsNumber, dnbCompany.Id);
		}
		return resultMap;
	}
	
	/*
	* @description Creates in Salesforce new DandBCompany company for it's cloud representation and returns new entity
	*/
	private static DandBCompany getDandBCompany(DatacloudDandBCompany dnbCompany) {
		DandBCompany newCompany = new DandBCompany(
			Name = dnbCompany.Name,
			DunsNumber = dnbCompany.DunsNumber
		);
		try {
			Database.insert(newCompany);
		} catch (Exception e) {
			newCompany = null;
		}
		return newCompany;
	}

	/*
	* @description Returns map of Duns Numbers as keys and Data.com company Ids as values for list of DnB Companies
	*/
	private static Account getAccountFromDndCompany(DatacloudDandBCompany dnbCompany) {
		RecordType prospectRecordType = [SELECT Id FROM RecordType 
										 WHERE SobjectType='Account' AND DeveloperName=:GlobalConstants.PROSPECT_RECORD_TYPE
										 LIMIT 1];
										 
		Account resultAccount = new Account(
			Name = dnbCompany.Name,
			DunsNumber = dnbCompany.DunsNumber,
			RecordTypeId = prospectRecordType.Id,
			Status__c = GlobalConstants.ACCOUNT_STATUS_GENERAL_PROSPECT,
			AccountSource = GlobalConstants.ACCOUNT_SOURCE_DATA_COM
		);
		return resultAccount;
	}
	
	/*
	* @description Aura Class, containing information about operaion of brining new D&B Company from Data.com to Salesforce
	*/
	public class SalesforceCompanyCreationResponse {
		@AuraEnabled public Boolean isCreated;
		@AuraEnabled public String errorMessage;
		@AuraEnabled public String salesforceAccountId;
		@AuraEnabled public String salesforceAccountName;
		@AuraEnabled public String salesforceOwnerName;
		@AuraEnabled public String dnbCompanyId;
	}
	
	/*
	* @description Class contains generic information about Company Hierarchy loading process
	*/
	public class CompanyHierarchyResponse {
		@AuraEnabled public Boolean isCorrect;
		@AuraEnabled public String errorMessage;
		@AuraEnabled public CompanyHierarchyNode rootNode;
		
		/*
		* @description Public consturctor
		*/
		public CompanyHierarchyResponse(){
			isCorrect = true;
			errorMessage = null;
		}
	}
	
	/*
	* @description Aura Class, containing full description of one single node within Company Hierarachy
	*/
	public class CompanyHierarchyNode {
		@AuraEnabled public List<CompanyHierarchyNode> children; 
		@AuraEnabled public Boolean hasSalesforceRecord;
		@AuraEnabled public Boolean isUndefinedParentNode;
		@AuraEnabled public Boolean isCurrentNode; 
		
		@AuraEnabled public String dunsNumber;
		
		@AuraEnabled public DatacloudDandBCompany dnbCompany;
		@AuraEnabled public Id sfCompanyId;
		@AuraEnabled public Id dnbCompanyId;
		@AuraEnabled public String sfCompanyOwnerName;
		
		@AuraEnabled public Boolean expanded;
		@AuraEnabled public Boolean canLoadMoreChildren;
		@AuraEnabled public Boolean hasChildren;
		
		/*
		* @description Base public constructor
		*/
		public CompanyHierarchyNode(DatacloudDandBCompany dnbCompanyRecord, Account sfAccount, Id datacloudCompanyId){
			children = new List<CompanyHierarchyNode>();
			hasSalesforceRecord = (sfAccount != null);
			isUndefinedParentNode = false;
			dunsNumber = dnbCompanyRecord.DunsNumber;
			dnbCompanyId = datacloudCompanyId;
			dnbCompany = dnbCompanyRecord;
			expanded = false;
			isCurrentNode = false;
			canLoadMoreChildren = hasChildren = dnbCompanyRecord.IsParent;
			if (sfAccount != null) {
				sfCompanyId = sfAccount.Id;
				sfCompanyOwnerName = sfAccount.Owner.Name;
			}
		}
		
		/*
		* @description Public constructor for undefined parent, which should be loaded by clicking "Load More" link
		*/
		public CompanyHierarchyNode(Boolean isUndefined, String dunsNumber){
			this.children = new List<CompanyHierarchyNode>();
			this.hasSalesforceRecord = false;
			this.isUndefinedParentNode = isUndefined;
			this.dunsNumber = dunsNumber;
			this.canLoadMoreChildren = false;
			this.hasChildren = true;
			this.expanded = true;
			this.isCurrentNode = false;
		}
	}    
}