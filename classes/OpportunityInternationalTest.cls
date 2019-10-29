/* --------------------------------------------------------------------------------------------------
   Name:            OpportunityInternationalTest.class 
   Description:     Test class for TradingSettingTrigger,TradingSettingsTriggerHandler,OpportunityInternationalBatch    

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   14-Feb-2018          0.1         Vijay Sonawane      Initial 
  ------------------------------------------------------------------------------------------------  */
@isTest (SeeAllData=false)
private class OpportunityInternationalTest {   
   
     /**
	 * @description  This method tests creation of Opportunity Internation junction object records 
	 * Sequence: 1. Opportunity Insertion
	 * 			 2. Trading Setting Insertion	
	 **/
     private static testMethod void testOpportunityAndTradingSettingInsertion1() {
         GlobalConstants.IGNORE_OPPORTUNITY_TRIGGER=true;         
         Account acc = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
         opportunity opp =PrepareTestData.getOpportunityData(GlobalConstants.OPPORTUNITY_LENDING,acc.Id); 
         Database.insert(opp);
         Test.startTest();                 
         List<Trading_Settings__c> ts = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);
         Test.stopTest(); 
         List<Opportunity_International__c> oppInternationalList= [Select id,Opportunity__c,Trading_Settings__c from Opportunity_International__c where Opportunity__c=:opp.Id LIMIT 10000] ;         	
         System.assertEquals(oppInternationalList.size(),5);         
     }
    
    /**
	 * @description  This method tests creation of Opportunity Internation junction object records 
	 * Sequence: 1. Trading Setting Insertion
	 * 			 2. Opportunity Insertion	
	 **/
    private static testMethod void testOpportunityAndTradingSettingInsertion2() {
        GlobalConstants.IGNORE_TRADING_SETTING_TRIGGER=true;        
        Account acc = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
        List<Trading_Settings__c> ts = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);             
        Test.startTest();                 
        opportunity opp =PrepareTestData.getOpportunityData(GlobalConstants.OPPORTUNITY_LENDING,acc.Id); 
        Database.insert(opp);
        Test.stopTest(); 
        List<Opportunity_International__c> oppInternationalList= [Select id,Opportunity__c,Trading_Settings__c from Opportunity_International__c where Opportunity__c=:opp.Id LIMIT 10000] ;         	
        System.assertEquals(oppInternationalList.size(),5);
    }
    
	/**
	 * @description This method is for negative test for Trading settting insertion 
	 * without Opportunity on company 
	 **/
    private static testMethod void testTradingSettingInsertionWithoutOpportunity() {
        Test.startTest();
        Account acc = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
        List<Trading_Settings__c> ts = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);            
        Test.stopTest();
        List<Opportunity_International__c> oppInternationalList= [Select id from Opportunity_International__c LIMIT 10000] ;
        System.assertEquals(oppInternationalList.size(),0);
    }

	/**
	 * @description This method is for negative test for Opportunity insertion 
	 * without tradding Setting on company 
	 **/
    private static testMethod void testOpportunityInsertionWithoutTradingSetting() {
        Test.startTest();
        Account acc = PrepareTestData.PrepareAccounts(5, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
        opportunity opp =PrepareTestData.getOpportunityData(GlobalConstants.OPPORTUNITY_LENDING,acc.Id);
        Database.insert(opp);
        Test.stopTest();
        List<Opportunity_International__c> oppInternationalList= [Select id from Opportunity_International__c LIMIT 10000] ;         	
        System.assertEquals(oppInternationalList.size(),0);
    }
    
    /**
	 * @description  This method test batch OpportunityInternationBatch when opportunity records 
	 * are not found against existing Trading setting records on related account
	 * 			 	
	 **/
    private static testMethod void testNegativeTestCaseForOpportunityInternationalBatch() {
        Account acc = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
        List<Trading_Settings__c> ts = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);            
        Test.startTest();
        OpportunityInternationalBatch batchObject= new OpportunityInternationalBatch();
        database.executeBatch(batchObject, GlobalConstants.DEFAULT_BATCH_SIZE);            
        Test.stopTest(); 
        List<Opportunity_International__c> oppInternationalList= [Select id,Opportunity__c,Trading_Settings__c from Opportunity_International__c LIMIT 10000] ;         	
        
        System.assertEquals(oppInternationalList.size(),0);
    }
    
    /**
	 * @description  This method test batch OpportunityInternationBatch when opportunity records 
	 * are found against existing Trading setting records on related account
	 * 			 	
	 **/
    private static testMethod void testPositiveTestCaseForOpportunityInternationalBatch() {
        GlobalConstants.IGNORE_OPPORTUNITY_TRIGGER=true;//disable future method on opportunity inser
        GlobalConstants.IGNORE_TRADING_SETTING_TRIGGER=true;//disable future method on trading setting insert
        
        Account acc = PrepareTestData.PrepareAccounts(1, true, GlobalConstants.ACCOUNT_CUSTOMER)[0];
        List<Trading_Settings__c> ts = PrepareTestData.PrepareTradingSettings(5, true, acc.Id);            
        Test.startTest();
        opportunity opp =PrepareTestData.getOpportunityData(GlobalConstants.OPPORTUNITY_LENDING,acc.Id);
        Database.insert(opp);
        OpportunityInternationalBatch batchObject= new OpportunityInternationalBatch();
        database.executeBatch(batchObject, GlobalConstants.DEFAULT_BATCH_SIZE);            
        Test.stopTest(); 
        List<Opportunity_International__c> oppInternationalList= [Select id,Opportunity__c,Trading_Settings__c from Opportunity_International__c LIMIT 10000] ;         	
        
        System.assertEquals(oppInternationalList.size(),5);
    } 
}