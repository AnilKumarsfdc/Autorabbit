/* ----------------------------------------------------------------------------------------------------
   Name:            CompleteProductTest.cls 
   Description:     Testclass for CompleteProductExtension.cls 

   Date                Version      Author                      Summary of Changes 
  ------------          -------     -----------------          -------------------------------------------
  10-Feb-2017            0.1        Accenture-Ujjwala Gavhane     This Class will be used for Change the
                                                                  record type of Project to record type.        
  ------------------------------------------------------------------------------------------------ ------*/

@isTest (seeAllData=false)

Private class CompleteProductTest {
    
  private static testmethod void runPositiveTests() {
      System.runAs(PrepareTestData.getRunningUser()) {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
      
        Account Acc = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Confidential Project').getRecordTypeId());
        insert Acc;
      
        ApexPages.StandardController sc = new ApexPages.StandardController(Acc);
        CompleteProductExtension testAccPlan = new CompleteProductExtension(sc);
      
        PageReference pageRef = page.CompleteProduct;
        pageRef.getParameters().put('Id', String.valueOf(Acc.Id));
        Test.setCurrentPage(pageRef);  
      
        Test.startTest();
        testAccPlan.accountid = Acc.Id;
        testAccPlan.getRCT();
        testAccPlan.RCT = 'Customer';
        testAccPlan.DunsNo = 'uytr';
        testAccPlan.save();
        Test.stopTest();
     }
  }
    
  private static testmethod void runNegativeTests() {
        System.runAs(PrepareTestData.getRunningUser()) {
	        System.Exception  ex;
	        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
	        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
	      
	        Account Acc = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Confidential Project').getRecordTypeId());
	        insert Acc;
	      
	        ApexPages.StandardController sc = new ApexPages.StandardController(Acc);
	        CompleteProductExtension testAccPlan = new CompleteProductExtension(sc);
	      
	        PageReference pageRef = page.CompleteProduct;
	        pageRef.getParameters().put('Id', String.valueOf(Acc.Id));
	        Test.setCurrentPage(pageRef);  
	       
	        Test.startTest();
	        testAccPlan.accountid = Acc.Id;
	        testAccPlan.getRCT();
	        testAccPlan.RCT = 'Prospect';
	        testAccPlan.DunsNo = '';
	        testAccPlan.save();
	        Test.stopTest();  
        }
   }
}