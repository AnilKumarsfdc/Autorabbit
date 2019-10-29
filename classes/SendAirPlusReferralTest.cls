@isTest
public class SendAirPlusReferralTest {
    
    private static final String SYS_ADMIN_PROFILE = 'System Administrator';
    private static final String CUSTOMER_COMPANY_RECORD_TYPE = 'Customer';
    private static final String OPP_RECORD_TYPE = 'Transactional Banking';
    
  
   @isTest private static void testWithoutRequiredField() {
        
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        system.runAs(user) {
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Schema.DescribeSObjectResult cfrOpportunitySchema = Schema.SObjectType.Opportunity;
            List<Opportunity> opportunityList = new List<Opportunity> ();
            List<Account> accList = new List<Account> ();
            
            Account acct = new Account(Name = 'Air Plus Refferal Test',
            RecordTypeId = accountRecordTypeInfo.get(CUSTOMER_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(acct);
            Database.insert(accList);
            
            Product2 product = new Product2(name = 'Airplus Corporate Card',Family = OPP_RECORD_TYPE,IsActive = true,Primary__c = true);
            insert product;
            
            Map<String, Schema.RecordTypeInfo> oppRecordTypeInfo = cfrOpportunitySchema.getRecordTypeInfosByName();        
            String oppRecordTypeId = oppRecordTypeInfo.get(OPP_RECORD_TYPE).getRecordTypeId();
            Opportunity tranOpportunity1 = new Opportunity(RecordTypeId = oppRecordTypeId,AccountId = acct.Id, Name='Testing AirPlus Referral 3', StageName = 'New Opportunity', CloseDate = Date.newInstance(2018, 11, 9), Reason_for_Enquiry__c = 'Testing Referrral 8', Number_of_cards_required__c =2, Current_Corporate_Card_provider__c = 'Refferal 5', Referral_Sent_Date__c = DateTime.now());
            opportunityList.add(tranOpportunity1);
            Database.insert(opportunityList);
            
            Schema.DescribeSObjectResult oppProdfrSchema = Schema.SObjectType.Opportunity_Product__c;
            Map<String, Schema.RecordTypeInfo> oppProdRecordTypeInfo = oppProdfrSchema.getRecordTypeInfosByName();
            
            
            String oppProdRecordTypeId = oppProdRecordTypeInfo.get(OPP_RECORD_TYPE).getRecordTypeId();
            
            Opportunity_Product__c oppProduct=  new Opportunity_Product__c(Facility_Amount__c = 22.5,Opportunity__c =  tranOpportunity1.id,RecordTypeId = oppProdRecordTypeId,name = 'Airplus Corporate Card',Product__c = product.id);
            insert oppProduct;
            
            
            Test.startTest();
            try{
                SendAirPlusReferral.sendOppEmail(tranOpportunity1.Id);
                SendAirPlusReferral.getReferralSentDate(tranOpportunity1.Id);
            } catch(Exception e) {

            }
            
            Test.stopTest();
        }
        
    }
    
    @isTest private static void testWithRequiredField() {
        
        User user = PrepareTestData.getRunningUser(SYS_ADMIN_PROFILE);
        system.runAs(user) {
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Schema.DescribeSObjectResult cfrOpportunitySchema = Schema.SObjectType.Opportunity;
            List<Opportunity> opportunityList = new List<Opportunity> ();
            List<Account> accList = new List<Account> ();
            
            Account acct = new Account(Name = 'Air Plus Refferal Test',
            RecordTypeId = accountRecordTypeInfo.get(CUSTOMER_COMPANY_RECORD_TYPE).getRecordTypeId());
            accList.add(acct);
            Database.insert(accList);
            
            Product2 product = new Product2(name = 'Airplus Corporate Card',Family = OPP_RECORD_TYPE,IsActive = true,Primary__c = true);
            insert product;
            
            Map<String, Schema.RecordTypeInfo> oppRecordTypeInfo = cfrOpportunitySchema.getRecordTypeInfosByName();        
            String oppRecordTypeId = oppRecordTypeInfo.get(OPP_RECORD_TYPE).getRecordTypeId();
            Opportunity tranOpportunity1 = new Opportunity(RecordTypeId = oppRecordTypeId,AccountId = acct.Id, Name='Testing AirPlus Referral 3', StageName = 'New Opportunity', CloseDate = Date.newInstance(2018, 11, 9), Reason_for_Enquiry__c = 'Testing Referrral 8', Number_of_cards_required__c =2, Current_Corporate_Card_provider__c = 'Refferal 5', Referral_Sent_Date__c = DateTime.now());
            opportunityList.add(tranOpportunity1);
            Database.insert(opportunityList);
            
            Schema.DescribeSObjectResult oppProdfrSchema = Schema.SObjectType.Opportunity_Product__c;
            Map<String, Schema.RecordTypeInfo> oppProdRecordTypeInfo = oppProdfrSchema.getRecordTypeInfosByName();
            
            
            String oppProdRecordTypeId = oppProdRecordTypeInfo.get(OPP_RECORD_TYPE).getRecordTypeId();

            
            Opportunity_Product__c oppProduct=  new Opportunity_Product__c(Facility_Amount__c = 22.5,Opportunity__c =  tranOpportunity1.id,RecordTypeId = oppProdRecordTypeId,name = 'Airplus Corporate Card',Product__c = product.id,Estimated_Annual_Spend__c=22);
            insert oppProduct;
            
            
            Test.startTest();
            try{
                SendAirPlusReferral.sendOppEmail(tranOpportunity1.Id);
                SendAirPlusReferral.getReferralSentDate(tranOpportunity1.Id);
            } catch(Exception e) {

            }
            
            Test.stopTest();
        }
        
    }
}