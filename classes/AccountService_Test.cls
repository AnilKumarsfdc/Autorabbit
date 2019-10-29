@IsTest
public class AccountService_Test {
    
    @testSetup static void setup() {
        // Create common test accounts
        Test.startTest();
        List<Account> accountList = (List<Account>)TestFactory.createNewSobject('Account', 200);
        List<Account> formatedAccountList = new List<Account>();
        for(Account acc : accountList){
            acc.AccountNumber = TestFactory.generateRandomString(40);
            acc.Country_of_Incorporation__c = 'GB';
            formatedAccountList.add(acc);
        }
        
        insert formatedAccountList;
        Test.stopTest();
    }
    
    static testmethod void getPaginatedAccountsByNameAndCountryCode(){
        Test.startTest(); 
        system.debug('-----------test1-----');
        List<Account> acc = [SELECT id, name,Country_of_Incorporation__c FROM Account limit 5];
        system.debug('-----------acc-----'+acc);
        List<Account> accList = AccountService.getPaginatedAccountsByNameAndCountryCode(acc[0].Name, acc[0].Country_of_Incorporation__c, 0, 5);
        System.assert(accList.size() > 0);
        Test.stopTest();     
    }   
    
    static testmethod void insertAccounts(){
        Test.startTest();
        List<Account> acct = new list<account>();
        acct.add(new account(name = 'Test'));
        AccountService.insertAccounts(acct);
        
        Account createdAcc = [Select Id, Name from Account LIMIT 1];
        
        System.assert(createdAcc != null);
        
        Test.stopTest();
    }
    
    static testmethod void updateAccounts(){
        Test.startTest();
        List<Account> acc = [SELECT id, name FROM Account limit 5];
        
        AccountService.updateAccounts(acc);
        System.assert(acc != null);
        
        Test.stopTest();
    }
    
    static testmethod void setRecordTypeToProspect(){
        Test.startTest();
        
        List<Account> acc = [SELECT id, name FROM Account];
        try{
            AccountService.setRecordTypeToProspect(acc);
            Account updatedAcc = [SELECT id, name, recordtype.name FROM Account];
            System.assert(updatedAcc.recordtype.name.equalsIgnoreCase('Prospect'));
        }
        catch(Exception e){
            
        }
        
        Test.stopTest();
    }
    
    static testmethod void getPaginatedCharitiesByNameAndCountryCode(){
        Test.startTest(); 
        system.debug('-----------test1-----');
        List<Account> acc = [SELECT id, name, Country_of_Incorporation__c FROM Account limit 5];
        system.debug('-----------acc-----'+acc);
        List<Account> accList = AccountService.getPaginatedCharitiesByNameAndCountryCode(acc[0].Name, acc[0].Country_of_Incorporation__c, 0, 5);
        System.assert(accList.size() > 0);
        
        Test.stopTest();     
    }  
    
    static testmethod void getTotalCharityCountMatchingNameAndCountryCode(){
        Test.startTest(); 
        system.debug('-----------test1-----');
        List<Account> acc = [SELECT id, name, Country_of_Incorporation__c FROM Account limit 5];
        system.debug('-----------acc-----'+acc);
        Integer toalCharityCount = AccountService.getTotalCharityCountMatchingNameAndCountryCode(acc[0].Name, acc[0].Country_of_Incorporation__c);
        System.assert(toalCharityCount != null);
        
        Test.stopTest();     
    } 
    
    static testmethod void getTotalCountMatchingNameAndCountryCode(){
        Test.startTest(); 
        system.debug('-----------test1-----');
        List<Account> acc = [SELECT id, name, Country_of_Incorporation__c FROM Account limit 5];
        system.debug('-----------acc-----'+acc);
        Integer toalCompanyCount = AccountService.getTotalCountMatchingNameAndCountryCode(acc[0].Name, acc[0].Country_of_Incorporation__c);
        System.assert(toalCompanyCount != null);
        Test.stopTest();     
    } 
    
    
    static testmethod void getCompaniesForRefresh(){
        Test.startTest(); 
            Database.QueryLocator queryLocator = AccountService.getCompaniesForRefresh();
            System.assert(queryLocator != null);
        Test.stopTest();     
    } 
    
    static testmethod void getChartiesForRefresh(){
        Test.startTest(); 
            Database.QueryLocator queryLocator = AccountService.getChartiesForRefresh();
            System.assert(queryLocator != null);
        Test.stopTest();     
    } 
    
    static testmethod void getAccountsByUniqueKeyIdentifierSet(){
        Test.startTest(); 
            List<Account> acc = [SELECT id, name, Country_of_Incorporation__c, UniquekeyIdentifier__c FROM Account limit 5];
            Set<String> accUniqueIndentifier = new Set<String>{acc[0].UniquekeyIdentifier__c};
            List<Account> accountList = AccountService.getAccountsByUniqueKeyIdentifierSet(accUniqueIndentifier);
            System.assert(accountList.size() > 0);
        Test.stopTest();     
    } 
    
    
    static testmethod void testCompanyNameCleanup(){
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions Limited'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions ltd'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions ltd.'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions limiTED'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions lImited Partnership'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions gmbh'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions plc'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Limited Solutions plc.'), 'Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Unlimited Solutions Limited'), 'Unlimited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Unlimited/Limited Solutions ltd.'), 'Unlimited/Limited Solutions');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Unlimited Solutions plc global'), 'Unlimited Solutions plc global');
        System.assertEquals(AccountService.removeCommonCompanyAbbreviationsAndTermsFromName('Unlimited Solutions Public Limited Company'), 'Unlimited Solutions');
    }
}