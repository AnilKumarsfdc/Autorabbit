/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityOwnerChangeTest.cls 
   Description:     Test Class which tests both Batch Job and Scheduled job for below batch execution
					1.OpportunityOwnerChangeBatch					
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   07-Feb-2018         0.1         Vijay Sonawane       Intial
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
public class OpportunityOwnerChangeTest {
     /**
   * @description Checks Batch Job execution for all existing Opportunity records owner updated to company owner 
   * when owner not equal to Integration user  
    **/
   @isTest  private static void runPositiveTests() {        
       
        List<User> userList = PrepareTestData.prepareUser(1,true,'SAN Relationship Director');
        List<Account> accountList = PrepareTestData.PrepareAccounts(1, true, 'Customer');
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp1 = PrepareTestData.getOpportunityData('Repayment', accountList[0].Id);
        opp1.OwnerId=userList[0].id;
        opportunityList.add(opp1);
        Opportunity opp2 = PrepareTestData.getOpportunityData('Lending', accountList[0].Id);
        opp2.OwnerId=userList[0].id;
        opportunityList.add(opp2);
        Database.insert(opportunityList) ;  
        List<Opportunity> opportunityList2=[select id,Is_Owner_Does_not_Match__c from Opportunity];
       
       
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  OpportunityOwnerChangeBatch batchObj = new OpportunityOwnerChangeBatch();
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Opportunity> resultList = [
            SELECT id,OwnerId,Account.OwnerId
            FROM Opportunity
          ];
          System.assertEquals(resultList[0].ownerId,resultList[0].Account.OwnerId);
		  System.assertEquals(resultList[1].ownerId,resultList[0].Account.OwnerId);        
    } 
    
    /**
   * @description Checks Batch Job execution for all existing Opportunity records where 
   * owner equal to Integration user  
    **/
   @isTest  private static void runNegativeTests() {        
       
        List<User> userList = PrepareTestData.prepareUser(1,true,'SAN Relationship Director');
        userList[0].FirstName=null;
        userList[0].LastName='integration';
        Database.update(userList);
        List<Account> accountList = PrepareTestData.PrepareAccounts(1, true, 'Customer');
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp1 = PrepareTestData.getOpportunityData('Repayment', accountList[0].Id);
        opp1.OwnerId=userList[0].id;
        opportunityList.add(opp1);
        Opportunity opp2 = PrepareTestData.getOpportunityData('Lending', accountList[0].Id);
        opp2.OwnerId=userList[0].id;
        opportunityList.add(opp2);
        Database.insert(opportunityList);
        List<Opportunity> opportunityList2=[select id,Is_Owner_Does_not_Match__c from Opportunity];
       
       
         Test.startTest();
       		System.runAs(new User(Id = UserInfo.getUserId())){
         	  OpportunityOwnerChangeBatch batchObj = new OpportunityOwnerChangeBatch();
              database.executeBatch(batchObj);
            }
          Test.stopTest();
          
          List<Opportunity> resultList = [
            SELECT id,OwnerId,Account.OwnerId
            FROM Opportunity
          ];
          System.assertNotEquals(resultList[0].ownerId,resultList[0].Account.OwnerId);
		  System.assertNotEquals(resultList[1].ownerId,resultList[0].Account.OwnerId);        
    } 
    
    /**
   * @description Checks  Batch Job execution started by one Scheduled Job
   * 
   **/
    @isTest  private static void testScheduledJobExecution() { 
          Test.startTest();
        	System.runAs(new User(Id = UserInfo.getUserId())){
            	String scheduleId = OpportunityOwnerChangeSchedule.setupSheduleJob();
        	}
          Test.stopTest();        
          Integer batchCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'OpportunityOwnerChangeBatch' LIMIT 1];
          System.assert(batchCount > 0);        
    }
}