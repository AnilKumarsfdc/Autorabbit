/* --------------------------------------------------------------------------------------------------
   Name:            NewProductLightningControllerTest.cls 
   Description:     Test Class for Aura controller NewProductLightningController

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   01-March-2017          0.1       Ujjwala Gavhane    
  ------------------------------------------------------------------------------------------------ */
@isTest (SeeAllData=false)
private  class NewProductLightningControllerTest {
    
    private static testmethod void runPositiveTests() {
               
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> opportunityRecordTypeInfo = oppSchema.getRecordTypeInfosByName();
        
        Schema.DescribeSObjectResult oppProdSchema = Schema.SObjectType.Opportunity_Product__c; 
        Map<String,Schema.RecordTypeInfo> opportunityProductRecordTypeInfo = oppProdSchema.getRecordTypeInfosByName();
        
        Account acct = PrepareTestData.getDefaultAccount();
        Database.insert(acct);
        
        Opportunity oppty = new Opportunity(Name='testLendingOpportunity', RecordTypeId= opportunityRecordTypeInfo.get('Lending').getRecordTypeId(), AccountId = acct.Id, StageName ='New Opportunity', CloseDate = System.today());
        Database.insert(oppty);
         
        Product2 prod1 = new Product2(Name ='Lending',Sales_Process__c= 'Lending',Reporting_Group__c='Lending',
        							  Primary__c = true, Family=oppty.RecordType.Name, IsActive = true);
        Product2 prod2 = new Product2(Name = 'Lending', Sales_Process__c= 'Lending',Reporting_Group__c='Lending',
        							  Primary__c = False, Family=oppty.RecordType.Name, IsActive = true);
        Database.insert(new List<Product2>{prod1, prod2});
        
        Opportunity_Product__c opptyProd = new Opportunity_Product__c(Name='Test',
            Product__c=prod2.Id,Facility_Amount__c = 1000, Loan_Type_Percentage_New_Money__c = 1,
            Net_Margin_Percentage__c = 2, Opportunity__c = oppty.Id, Gross_Margin__c=5, 
            RecordTypeId= opportunityProductRecordTypeInfo.get('Lending').getRecordTypeId(), Term_In_Months__c = 2);
                
        List<Opportunity_Product__c> oppPrimaryProducts = [SELECT Id FROM Opportunity_Product__c 
                                                           WHERE Product__r.Primary__c = true
                                                           AND   Opportunity__c = :oppty.Id
                                                           LIMIT 1];
             
        Test.startTest();
        
        NewProductLightningController.getListOfProducts(oppty.Id);
        NewProductLightningController.getOpportunityProductRecord(oppty.Id,prod2.Id);
        NewProductLightningController.getListOfRelatedProducts(prod2.Id);
        
        Opportunity_Product__c[] oppProdList = new Opportunity_Product__c[]{opptyProd};
            
        String opportunityProductString = JSON.serialize(opptyProd);
        String relatedProductsString = JSON.serialize(oppProdList);
        NewProductLightningController.createOpportunityProducts(opportunityProductString,relatedProductsString);
        
        Test.stopTest();
    }
}