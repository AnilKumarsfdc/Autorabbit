/* --------------------------------------------------------------------------------------------------
     Name:            ReverseRelationshipHandlerTest.cls 
     Description:     Test Class for ReverseRelationshipHandler
    ------------------------------------------------------------------------------------------------ */
@isTest(SeeAllData = false)
private class ReverseRelationshipHandlerTest {

	/**
	 * @description Test for Reverse relation on insertion  . 
	 * 
	 **/
	@isTest private static void runPositiveTestsForInsert()
	{

		Relationship_Metadata__mdt role = [Select Relationship_Type__c, Relationship_Name__c, Reverse_Role__c from Relationship_Metadata__mdt WHERE Reverse_Role__c != null LIMIT 1];


		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'SAN Relationship Director' LIMIT 1];

		User usr = new User(LastName = 'Test',
		                    FirstName = 'User',
		                    Alias = 'utest',
		                    Email = 'santander@test.com',
		                    Username = 'santander@test.com',
		                    ProfileId = profileId.id,
		                    TimeZoneSidKey = 'GMT',
		                    LanguageLocaleKey = 'en_US',
		                    EmailEncodingKey = 'UTF-8',
		                    LocaleSidKey = 'en_US'
		);
		Database.insert(usr);

		List<Account> accountList = new List<Account> ();

		Account acc = PrepareTestData.getDefaultAccount();
        accountList.add(acc);
		Account acc1 = PrepareTestData.getDefaultAccount();
		accountList.add(acc1);
		Database.insert(accountList);

		Opportunity oppty = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'New Opportunity', CloseDate = system.today());
		Database.insert(oppty);

		// Account Team Member - Divya Gupta
		List<AccountTeamMember> membersList = new List<AccountTeamMember> ();
		AccountTeamMember member = new AccountTeamMember();
		member.AccountId = acc.Id;
		member.UserId = usr.Id;
		member.TeamMemberRole = 'Relationship Director';
		member.AccountAccessLevel = 'Read';
		member.OpportunityAccessLevel = 'Read';
		member.CaseAccessLevel = 'Edit';
		member.ContactAccessLevel = 'Edit';
		membersList.add(member);

		AccountTeamMember member1 = new AccountTeamMember();
		member1.AccountId = acc1.Id;
		member1.UserId = usr.Id;
		member1.TeamMemberRole = 'Relationship Director';
		member1.AccountAccessLevel = 'Edit';
		member1.OpportunityAccessLevel = 'Edit';
		member1.CaseAccessLevel = 'Edit';
		member1.ContactAccessLevel = 'Edit';
		membersList.add(member1);
		Database.insert(membersList);

		Relationship__c rel = new Relationship__c(Relationship_Type__c = role.Relationship_Type__c, Relationship_Name__c = role.Relationship_Name__c,
		                                          Company__c = acc.Id, Related_Company__c = acc1.Id);
		Database.insert(rel);

		Relationship__c rel1 = new Relationship__c(Relationship_Type__c = role.Relationship_Type__c, Relationship_Name__c = role.Relationship_Name__c,
		                                           Company__c = acc.Id, Related_Company__c = acc1.Id);
		Database.insert(rel1);

		List<Relationship__c> relList = new List<Relationship__c> { rel, rel1 };



		test.startTest();
		ReverseRelationshipHandler.processAfterInsert(relList);
		List<Relationship__c> revRelIns = [SELECT Id, Name, Reverse_Relationship__c FROM Relationship__c LIMIT 1000];


		ReverseRelationshipHandler.deleteReverseRelation(relList);
		List<Relationship__c> revRelDel = [SELECT Id, Name, Reverse_Relationship__c FROM Relationship__c LIMIT 1000];

		test.stopTest();
		system.assertEquals(2, revRelDel.size());
		system.assertEquals(3, revRelIns.size());

	}
}