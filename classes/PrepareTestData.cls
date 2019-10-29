/* --------------------------------------------------------------------------------------------------
   Name:            PrepareTestData.cls 
   Description:     Test Data Class for Aura controller TradingSettingController

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   13-March-2017          0.1       Iegor Nechyporenko    
   24-July-2019            0.2       Anil Kumar           added lines 123, 124, 125 to satisfy validation rules in Campaign Member
  ------------------------------------------------------------------------------------------------ */

public with sharing class PrepareTestData {
    /**
     * Description: returns RecordtypeId
     * */
    public static Id getRecordTypeId(Schema.DescribeSObjectResult describeResult, String recordTypeName){
         Schema.RecordTypeInfo recordTypeInfo = describeResult.getRecordTypeInfosByName().get(recordTypeName);
         return (recordTypeInfo != null) ? recordTypeInfo.getRecordTypeId() : null;
    }
    
    /**
     * Description: returns random Integer number
     * */
    public static Integer randomInt(Integer maxInteger){
        return Math.round(Math.random() * maxInteger);
    }
    
    /**
     * Description: returns random Integer number within range
     * */    
    public static Integer randomInt(Integer minInteger, Integer maxInteger){
        return Math.round(Math.random() * (maxInteger - minInteger)) + minInteger;
    }
    
     /**
     * Description: returns User with profile
     * */
    public static User getRunningUser(){
        return getRunningUser(GlobalConstants.PROFILE_STANDARD_USER);
    }   
    
    /**
     * Description: returns User with profile
     * */
    public static User getRunningUser(String profileName){
        Profile p = [SELECT Id FROM Profile WHERE Name= :profileName LIMIT 1];      
        String testUserName = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.DEFAULT_MAX_INT) + GlobalConstants.EMAIL;
        return new User(Alias = GlobalConstants.TEST_NAME, 
                        Email=testUserName, 
                        EmailEncodingKey=GlobalConstants.EMAIL_ENCODING_KEY, 
                        LastName= GlobalConstants.TEST_NAME, 
                        LanguageLocaleKey=GlobalConstants.LANGUAGE_KEY, 
                        LocaleSidKey=GlobalConstants.LANGUAGE_KEY, 
                        ProfileId = p.Id, 
                        TimeZoneSidKey=GlobalConstants.TIMEZONE_SID_KEY, 
                        UserName=testUserName);
    }
    
    /**
     * Description: returns Test Account
     * */
    public static Account getDefaultAccount(){
        Account testAccount = new Account(
            Name = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.DEFAULT_MAX_INT),
            Sector__c = GlobalConstants.ACCOUNT_SECTOR,
            RecordTypeId = getRecordTypeId(Schema.SObjectType.Account, GlobalConstants.ACCOUNT_CUSTOMER)
        );
        return testAccount;
    }
    
    /**
     * Description:  returns Case with given ID
     * */
    public static Case getDefaultCase(Id accId){
        Case testCase = new Case(
            Subject = GlobalConstants.TEST_NAME,
            AccountId = accId
        );
        return testCase;
    }

    /**
     * Description: returns Test Event for given Account
     * */
    public static Event getDefaultEvent(Id accId){
        Time dummyTime = Time.newInstance(randomInt(GlobalConstants.MIN_RANGE_SMALL,GlobalConstants.MAX_RANGE_SMALL), randomInt(GlobalConstants.MAX_RANGE_SMALL),
                                          randomInt(GlobalConstants.MIN_RANGE_SMALL), randomInt(GlobalConstants.MIN_RANGE_SMALL));
        DateTime dummyStartDateTime = DateTime.newInstance(system.today(), dummyTime);
        DateTime dummyEndDateTime = DateTime.newInstance(system.today()+randomInt(GlobalConstants.MIN_RANGE_SMALL,GlobalConstants.MAX_RANGE_SMALL), dummyTime);

        Event testEvent = new Event(
            Subject = GlobalConstants.TEST_NAME,
            WhatId = accId,
            Type = GlobalConstants.EVENT_TYPE,
            StartDateTime = dummyStartDateTime,
            EndDateTime = dummyEndDateTime);
        return testEvent;
    }
    
    /**
     * Description: returns Test Campaign
     * */
    public static Campaign getTestCampaign(Boolean isInsert){
        
        Campaign testEvent = new Campaign(
            Name = GlobalConstants.TEST_EVENT,
            StartDate = System.today(),
            isActive = true
        );
        if(isInsert){
            Database.insert(testEvent);
        }
        return testEvent;
    }
    
    /**
     * Description: returns Test Campaign Member for given contact and event id
     * */
    public static CampaignMember getTestCampaignMember(Boolean isInsert,Id eventId,Id contactId){
        
        CampaignMember testEventMember = new CampaignMember(
            CampaignId = eventId,
            ContactId =contactId,
            Contract_or_Business_Negotiations__c='In the Last Three Months',
            Contract_or_Business_Negotiations_Info__c='testcampaignmember',
            Key_Decision_Maker__c='No',
            Status = GlobalConstants.DEFAULT_EVENT_STATUS
        );
        if(isInsert){
            Database.insert(testEventMember);
        }
        return testEventMember;
    }
    
    /**
     * Description: returns Test Product
     * */
    public static Product2 getProductData(String productFamily, Boolean isPrimary){
        return new Product2 (
            Name = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.DEFAULT_MAX_INT),
            Primary__c = isPrimary,
            Family = productFamily,
            IsActive = true
        );
    }
    
    /**
     * Description: returns Test Opportunity with given recordtype for given account
     * */
    public static Opportunity getOpportunityData(String recordTypeName, Id accountId){
        Account testAccount;
        if (AccountId == null) {
            testAccount = getDefaultAccount();
            Database.insert(testAccount);          
        }
        
        Opportunity testOpportunity = new Opportunity(
            Name = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.DEFAULT_MAX_INT),
            AccountId = accountId==null?testAccount.Id:accountId,
            RecordTypeId = getRecordTypeId(Schema.SObjectType.Opportunity, recordTypeName),
            CloseDate = Date.today().addDays(randomInt(GlobalConstants.TEST_NUMBER)),
            StageName = GlobalConstants.NEW_OPPORTUNITY_RECORD_TYPE
        );
        
        return testOpportunity;
    }
    
    /**
     * Description: returns Opportunity product(custom) with given recordtype for given opportunity
     * */
    public static Opportunity_Product__c getOpportunityProduct(Id opportunityId, String recordTypeName){
        Boolean isFee = (recordTypeName == GlobalConstants.OPP_PRODUCT_FEE_RECORD_TYPE);
        Product2 testProduct = getProductData(recordTypeName, !isFee);
        Database.insert(testProduct);
        
        Opportunity_Product__c opportunityProduct = new Opportunity_Product__c(
            Opportunity__c = opportunityId,
            Product__c = testProduct.Id,
            Name = testProduct.Name,
            RecordTypeId = getRecordTypeId(Schema.SObjectType.Opportunity_Product__c, recordTypeName),
            Facility_Amount__c = randomInt(GlobalConstants.TEST_NUMBER) * GlobalConstants.TEST_NUMBER
        );
        return opportunityProduct;
    }
    
    /**
     * Description: returns Test Contact for given account
     * */
    public static Contact getTestContact(Id accountId) {
        Contact testContact = new Contact(
            AccountId = accountId,
            FirstName = GlobalConstants.TEST_NAME,
            LastName = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.MAX_RANGE),
            Email = randomInt(GlobalConstants.MIN_RANGE) + GlobalConstants.EMAIL,
            MobilePhone = GlobalConstants.MOBILE_PREFIX + randomInt(GlobalConstants.MIN_RANGE, GlobalConstants.MAX_RANGE)
        );
        return testContact;
    }
    
    /**
     * Description: returns Test BDPContact for given contact
     * */
    public static BDP_Contact__c getTestBDPContact(Id contactId) {
        String fNumber = String.valueOf(randomInt(GlobalConstants.MIN_RANGE, GlobalConstants.MAX_RANGE));
        BDP_Contact__c testBDPContact = new BDP_Contact__c(
            Name = fNumber,
            F_Number__c = fNumber,
            First_Name__c = GlobalConstants.TEST_NAME,
            Last_Name__c = String.valueOf(randomInt(GlobalConstants.MIN_RANGE)),
            BDP_Email__c = randomInt(GlobalConstants.MIN_RANGE) + GlobalConstants.EMAIL,
            Mobile_Phone__c = GlobalConstants.MOBILE_PREFIX + randomInt(GlobalConstants.MIN_RANGE, GlobalConstants.MAX_RANGE),
            Salesforce_Contact__c = contactId
        );
        return testBDPContact;
    }
    
    /**
     * Description: returns Test BDPContact with given fNumber for given contact
     * */
    public static BDP_Contact__c getTestBDPContact(Boolean insertNow,Id contactId,String fNumber) {
        
        BDP_Contact__c testBDPContact = new BDP_Contact__c(
            Name = fNumber,
            F_Number__c = fNumber,
            First_Name__c = GlobalConstants.TEST_NAME,
            Last_Name__c = String.valueOf(randomInt(GlobalConstants.MIN_RANGE)),
            BDP_Email__c = randomInt(GlobalConstants.MIN_RANGE) + GlobalConstants.EMAIL,
            Mobile_Phone__c = GlobalConstants.MOBILE_PREFIX + randomInt(GlobalConstants.MIN_RANGE, GlobalConstants.MAX_RANGE),
            Salesforce_Contact__c = contactId
        );
        if(insertNow){
            Database.insert(testBDPContact);
        }
        return testBDPContact;
    }
    
    /**
     * Description: returns list of Accounts with given count and recordtype
     * */
    public static List<Account> PrepareAccounts(Integer numAccounts, Boolean insertNow, String recordTypeName){
        List<Account> retVal = new List<Account>();
        Id recordType =Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        for(Integer i=0; i<numAccounts; i++){
                
            Account a = new Account();
            a.Name = GlobalConstants.TEST_NAME + i;
            a.DunsNumber = String.valueOf( i + GlobalConstants.MIN_RANGE);           
            a.RecordTypeId = recordType;
            retVal.add(a);
        }
        if(insertNow){
            Database.insert( retVal );      
        }
        return retVal;   
    }
    
    /**
     * Description: returns Test BDPCompany with given count for given account
     * */
    public static List<BDP_Company__c> PrepareBDPcompanies(Integer num, Boolean insertNow, String accountId){
        List<BDP_Company__c> retVal = new List<BDP_Company__c>();
        
        for(Integer i=1; i<=num; i++){              
            BDP_Company__c bdpObj = new BDP_Company__c();            
            bdpObj.BDP_Customer_Number__c = String.valueOf(randomInt(GlobalConstants.MIN_JNUMBER,GlobalConstants.MAX_JNUMBER));
            bdpObj.Company__c = accountId;
            retVal.add(bdpObj);
        }
        if(insertNow){
            Database.insert( retVal );      
        }
        return retVal;   
    }
    
    /**
    * Description: creates record for BDP_Company__c 
    * */
    public static BDP_Company__c getTestBDPCompany(Boolean insertNow,Id accountId,String customerNumber) {        
      
        BDP_Company__c bdpObj = new BDP_Company__c( Name = customerNumber,
                                                    BDP_Customer_Number__c = customerNumber,
                                                    Company__c = accountId);
        if(insertNow){
            Database.insert( bdpObj );      
        }
        return bdpObj;
    }
    
     /**
     * Description: returns Test ProductHoldings with given count and given information
     * */
      public static List<Holding__c> PrepareProductHoldings(Integer numHoldings, Boolean insertNow, String recordTypeName,String bdpRecordId,String companyId,String productFamily,String status ){
        List<Holding__c> retVal = new List<Holding__c>();
        Id recordType = Schema.SObjectType.Holding__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        for(Integer i=0; i<numHoldings; i++){               
            Holding__c hldObj = new Holding__c();
            if(!String.isBlank(bdpRecordId)){
                hldObj.BDPRecord__c = bdpRecordId;
            }
            if(!String.isBlank(companyId)){
                hldObj.Company__c = companyId;
            }           
            hldObj.Budget__c = GlobalConstants.TEST_BUDGET;
            hldObj.Product_Family__c = productFamily;
            hldObj.Account_Number__c = String.valueOf(randomInt(GlobalConstants.TEST_NUMBER));
            hldObj.Name = GlobalConstants.TEST_NAME + i;
            hldObj.Type__c = String.valueOf(GlobalConstants.TEST_TYPE);
            hldObj.Sub_Type__c = String.valueOf(GlobalConstants.TEST_SUB_TYPE);
            hldObj.RecordTypeId = recordType; 
            hldObj.status__c  = status;
            retVal.add(hldObj);
        }
        if(insertNow){
            Database.insert( retVal );      
        }
        return retVal; 
    }
    
    /**
     * Description: returns Test List of Trading Setting with given count for given account
     * */
      public static List<Trading_Settings__c> PrepareTradingSettings(Integer numTradesettings, Boolean insertNow, Id accountId ){
        List<Trading_Settings__c> retVal = new List<Trading_Settings__c>();
        Schema.DescribeFieldResult fieldDescribe = Trading_Settings__c.Country__c.getDescribe();
        Schema.PicklistEntry[] picklistData = fieldDescribe.getPicklistValues(); 
        Integer maxItemIndex = picklistData.size() - GlobalConstants.MIN_RANGE_SMALL;
        
        for(Integer i=0; i<numTradesettings; i++){
            retVal.add(new Trading_Settings__c(
                Name = GlobalConstants.TEST_NAME + randomInt(GlobalConstants.DEFAULT_MAX_INT),
                Country__c = picklistData.get(randomInt(maxItemIndex)).getValue(),
                Company__c = accountId,
                Exporter__c = true
            ));
        }
        if(insertNow){
            Database.insert( retVal );      
        }
        return retVal;   
    }
    
    /**
    * Description: creates record for Reporting_Control_Integration__c 
    * */
    public static Reporting_Controls_Integration__c PrepareReportingControlIntegration(Boolean insertNow, String type,Integer bdpIdentifier){
        Reporting_Controls_Integration__c retVal = new Reporting_Controls_Integration__c();
        retVal=new Reporting_Controls_Integration__c( BDP_Identifier__c = Decimal.valueOf(bdpIdentifier),
                                                     BDP_Type__c = type,
                                                     Active__c = true           
                                                    );
        
        if(insertNow){
            Database.insert( retVal );      
        }
        return retVal;   
    }
    
   /**
     * Description: returns Test List of User with given count and with given profile name
     * */
    public static List<User> prepareUser(Integer numUsers, Boolean insertNow, String profileName){
        List<User> retVal = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = : profileName LIMIT 1].Id ;

        for(Integer i=0; i < numUsers; i++){
            User u = new User();
            u.FirstName = GlobalConstants.TEST_NAME + i;
            u.LastName  = GlobalConstants.TEST_NAME + i;
            u.Email     = GlobalConstants.TEST_NAME + i + GlobalConstants.EMAIL;
            u.Username  = GlobalConstants.TEST_NAME + i + GlobalConstants.EMAIL;
            u.Alias     = GlobalConstants.TEST_NAME + i;
            u.ProfileId = profileId;    
            u.TimeZoneSidKey    = GlobalConstants.TIMEZONE_SID_KEY;
            u.LocaleSidKey      = GlobalConstants.LANGUAGE_KEY;
            u.EmailEncodingKey  = GlobalConstants.EMAIL_ENCODING_KEY;
            u.LanguageLocaleKey = GlobalConstants.LANGUAGE_KEY;
            u.SAN_User_ID__c= String.valueof(i+randomInt(GlobalConstants.DEFAULT_MAX_INT)+randomInt(GlobalConstants.MAX_RANGE_SMALL));       
            retVal.add(u); 
        }
        if(insertNow){
            Database.insert( retVal );
        }
        return retVal;
    }
    
    /*
    * @description
    */
    public static Id createTestContentDocumnet() {
        String name = 'Test Attachment ' + randomInt(100000);
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('Test Data: ' + randomInt(1000000000));
        cv.Title = name;
        cv.PathOnClient = name;
        cv.Description = 'Test Description';
        Database.insert(cv);
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        return cv.ContentDocumentId;
    }
    
    /**
    * Description: creates record for Meeting__c 
    * */
    public static Meeting__c getTestMeetingRecord(Boolean insertNow,Id accountId) {        
       Id recordTypeId = Meeting__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get(GlobalConstants.MEETING_DEFAULT_RECORD_TYPE).getRecordTypeId();
        Meeting__c meetingObj = new Meeting__c( Account__c = accountId,
                                                    Start_DateTime__c = system.today(),
                                                    End_DateTime__c = system.today()+1,RecordTypeId = recordTypeId);
        if(insertNow){
            Database.insert( meetingObj );      
        }
        return meetingObj;
    }
    
    /**
     * Description: returns Test Annual Review
     * */
    public static Annual_Review__c getDefaultAnnualReview(Id companyId){
        Annual_Review__c testAnnualReview = new Annual_Review__c(Company__c = companyId,
                                                                Annual_Review_Date__c = System.today());
        return testAnnualReview;
    }
}