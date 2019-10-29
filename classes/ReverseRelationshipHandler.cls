/* --------------------------------------------------------------------------------------------------
     Name:            ReverseRelationshipHandler.cls 
     Description:     Handler class for ReverseRelationshipTrigger
  Test class:      ReverseRelationshipHandlerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public without sharing class ReverseRelationshipHandler {

	private static boolean run = true;
	private static boolean runForDelete = true;
	private static final String RECORD_TYPE = 'Confidential Project';
	private static final String ERROR_MESSAGE = 'You are not allowed to Setup Relationship for this Company';

	/**
	 * @description TO check recurssion  .
	 * 
	 **/
	public static boolean runOnce() {
		try {
			if (run) {
				run = false;
				return true;
			} else {
				return run;
			}
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description TO check recurssion  .
	 * 
	 **/
	public static boolean runOnceForDelete() {
		try {
			if (runForDelete) {
				runForDelete = false;
				return true;
			} else {
				return runForDelete;
			}
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description This method checks Account Access Level.
	 * 
	 **/
	public static void processBeforeInsert(List<Relationship__c> relList) {
		try {
			for (Relationship__c relation : relList) {
				for (UserRecordAccess accountAccess :[SELECT RecordId, HasEditAccess, HasReadAccess FROM UserRecordAccess
				     WHERE UserId = :UserInfo.getUserId() AND RecordId = :relation.Company__c LIMIT 10000]) {
					if (accountAccess.HasEditAccess != true && relation.Reverse_Relationship__c == null) {
						relation.addError(ERROR_MESSAGE);
					}
				}
			}
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description This method creates Reverse relationship  .
	 * 
	 **/
	public static void processAfterInsert(List<Relationship__c> relList) {
		try {
			Id projectCompany = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECORD_TYPE).getRecordTypeId();
			List<Relationship__c> relationObjList = new List<Relationship__c> ();
			Set<Id> relationshipIds = new Set<Id> ();

			for (Relationship__c relationship : relList) {
				relationshipIds.add(relationship.Id);
			}

			for (Relationship__c relation :[SELECT Company__c, Company__r.RecordTypeId, Relationship_Type__c,
			     Relationship_Name__c, Related_Company__c, Reverse_Relationship__c
			     FROM Relationship__c WHERE Id IN :relationshipIds LIMIT 10000]) {
				if (relation.Company__r.RecordTypeId != projectCompany ) {
					relationObjList.add(relation);
				}
			}
			if (relationObjList.size() > 0) {
				insertReverseRelation(relationObjList);
			}
		}
		catch(Exception e) {
			throw e;
		}
	}

	/**
	 * @description Insert a record for reverse relation of already inserted record.
	 * 
	 **/
	private static void insertReverseRelation(List<Relationship__c> relList) {
		if (runOnce()) {
			Relationship__c revr = new Relationship__c();
			List<Relationship__c> revRelList = new List<Relationship__c> ();
			Map<String, String> ma = new Map<String, String> ();
			for (Relationship_Metadata__mdt role :[SELECT Relationship_Type__c, Relationship_Name__c, Reverse_Role__c
			     FROM Relationship_Metadata__mdt WHERE Reverse_Role__c != null
			     LIMIT 10000]) {
				ma.put(role.Relationship_Name__c, role.Reverse_Role__c);
			}

			for (Relationship__c rel : relList) {
               String relationshipName = ma.get(rel.Relationship_Name__c);
                if(!String.isBlank(relationshipName)){
                    revr.Company__c = rel.Related_Company__c;
                    revr.Relationship_Type__c = rel.Relationship_Type__c;
                    revr.Relationship_Name__c = ma.get(rel.Relationship_Name__c);
                    revr.Related_Company__c = rel.Company__c;
                    revr.Reverse_Relationship__c = rel.Id;
                    revRelList.add(revr);
                }
			}
           
			try {
				Database.insert(revRelList);
			}
			catch(exception e) {
				throw e;
			}
		}
	}

	/**
	 * @description Delete a record for reverse relation when we try to delete a relationship record.
	 * 
	 **/
	public static void deleteReverseRelation(List<Relationship__c> relList)
	{
		if (runOnceForDelete()) {
			Set<Id> rNotNull = new Set<Id> ();
			Set<Id> rNull = new Set<Id> ();
			List<Relationship__c> deleteList = new List<Relationship__c> ();
			for (Relationship__c rel : relList) {
				if (rel.Reverse_Relationship__c != null) {
					rNotNull.add(rel.Reverse_Relationship__c);
				}
				else {
					rNull.add(rel.Id);
				}
			}
			for (Relationship__c rel :[Select Name from Relationship__c where Id IN :rNotNull LIMIT 10000]) {
				if (rel != null) {
					deleteList.add(rel);
				}
			}
			for (Relationship__c rel :[Select Name from Relationship__c where Reverse_Relationship__c IN :rNull
			     LIMIT 10000]) {
				if (rel != null) {
					deleteList.add(rel);
				}
			}
			if (deleteList != null) {
				try {
					Database.delete(deleteList);
				}
				catch(exception e) {
					throw e;
				}
			}
		}
	}
}