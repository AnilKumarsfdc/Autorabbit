/* -------------------------------------------------------------------------------------------------- 
Description	:       Test Class which checks functionality of NewMeetingLightningController.
Test Class	:       NewMeetingLightningControllerTest.cls
Date             	Version     Author               Summary of Changes 
-----------      	-------     -------------------  -------------------------------------------
06-August-2018      0.1         Vijay R. Sonawane    Initial
------------------------------------------------------------------------------------------------  */
@isTest(SeeAllData = false)
private class NewMeetingLightningControllerTest {     
    /*
    * @describe : tests the getMeetingInfo method by accountId
    */
    @isTest private static void testGetMeetingInfoByCompanyId() { 
            System.runAs(PrepareTestData.getRunningUser()) {
                Account accObj = PrepareTestData.getDefaultAccount();
                accObj.BillingStreet=GlobalConstants.TEST_NAME;
                accObj.BillingCity=GlobalConstants.TEST_NAME;
                accObj.BillingState=GlobalConstants.TEST_NAME;
                accObj.BillingCountry=GlobalConstants.TEST_NAME;
                accObj.BillingPostalCode=String.valueOf(GlobalConstants.TEST_NUMBER);
                
                accObj.ShippingStreet=GlobalConstants.TEST_NAME;
                accObj.ShippingCity=GlobalConstants.TEST_NAME;
                accObj.ShippingState=GlobalConstants.TEST_NAME;
                accObj.ShippingCountry=GlobalConstants.TEST_NAME;
                accObj.ShippingPostalCode=String.valueOf(GlobalConstants.TEST_NUMBER);
                
                Database.insert(accObj);
                Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(true,accObj.Id);
                
                Test.startTest();                
                  NewMeetingLightningController.MeetingWrapper meetingWrpObj = NewMeetingLightningController.getMeetingInfo(accObj.Id);
                Test.stopTest();   
                system.assertNotEquals(GlobalConstants.ADDRESS_NOT_FOUND, meetingWrpObj.billingAddress);
                system.assertNotEquals(GlobalConstants.ADDRESS_NOT_FOUND, meetingWrpObj.shippingAddress);
            } 
    }  
    
	/*
    * @describe : tests the getMeetingInfo method by meeting Id 
    */
    @isTest private static void testGetMeetingInfoByMeetingId() { 
            System.runAs(PrepareTestData.getRunningUser()) {
                Account accObj = PrepareTestData.getDefaultAccount();
                accObj.BillingStreet=GlobalConstants.TEST_NAME;
                accObj.BillingCity=GlobalConstants.TEST_NAME;
                accObj.BillingState=GlobalConstants.TEST_NAME;
                accObj.BillingCountry=GlobalConstants.TEST_NAME;
                accObj.BillingPostalCode=String.valueOf(GlobalConstants.TEST_NUMBER);
                
                accObj.ShippingStreet=GlobalConstants.TEST_NAME;
                accObj.ShippingCity=GlobalConstants.TEST_NAME;
                accObj.ShippingState=GlobalConstants.TEST_NAME;
                accObj.ShippingCountry=GlobalConstants.TEST_NAME;
                accObj.ShippingPostalCode=String.valueOf(GlobalConstants.TEST_NUMBER);
                
                Database.insert(accObj);
                Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(true,accObj.Id);
                
                Test.startTest();                
                  NewMeetingLightningController.MeetingWrapper meetingWrpObj = NewMeetingLightningController.getMeetingInfo(meetingObj.Id);
                Test.stopTest();   
                system.assertNotEquals(GlobalConstants.ADDRESS_NOT_FOUND, meetingWrpObj.billingAddress);
                system.assertNotEquals(GlobalConstants.ADDRESS_NOT_FOUND, meetingWrpObj.shippingAddress);
            } 
    }      
    /*
    * @describe : tests saveNewMeetingAction method
    */
    @isTest private static void testSaveNewMeetingAction() {
       
            System.runAs(PrepareTestData.getRunningUser()) {
                Account accObj = PrepareTestData.getDefaultAccount(); 
                Database.insert(accObj);
                Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(false,accObj.Id);
                String meetingJSON = JSON.serialize(meetingObj);
                
                Test.startTest();                
                  String meetingId =NewMeetingLightningController.saveNewMeetingAction(
                          				meetingJSON,GlobalConstants.MEETING_DEFAULT_RECORD_TYPE
                  					);
                Test.stopTest();   
                system.assertNotEquals(null, meetingId);
            }  
    }  
    
    /*
    * @describe : tests getNameById for account method
    */
    @isTest private static void testGetNameByIdForAccount() { 
      
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.insert(accObj);          
            PrepareTestData.getTestMeetingRecord(false,accObj.Id);          
          
            Test.startTest();                
            NewMeetingLightningController.PillWrapper pillWrapperObj =
                NewMeetingLightningController.getNameById(accObj.Id);
            Test.stopTest();   
            system.assertEquals(pillWrapperObj.sObjType,GlobalConstants.SOJBECT_ACCOUNT);
    } 
    
    /*
    * @describe : tests getNameById method for company attendee 
    */
    @isTest private static void testGetNameByIdForContact() { 
      
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.insert(accObj);
            Contact conObj = PrepareTestData.getTestContact(accObj.Id);
            Database.insert(conObj);           
            PrepareTestData.getTestMeetingRecord(false,accObj.Id); 
            Test.startTest();                
            NewMeetingLightningController.PillWrapper pillWrapperObj =
                NewMeetingLightningController.getNameById(conObj.Id);
            Test.stopTest();   
            system.assertEquals(pillWrapperObj.sObjType,GlobalConstants.SOJBECT_CONTACT);
    }  
    
    /*
    * @describe : tests getNameById method for santander attendee 
    */
    @isTest private static void testGetNameByIdForUser() {  
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.insert(accObj);
            User usrObj = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
            Database.insert(usrObj);
            PrepareTestData.getTestMeetingRecord(false,accObj.Id);  
            Test.startTest();                
            NewMeetingLightningController.PillWrapper pillWrapperObj =
                NewMeetingLightningController.getNameById(usrObj.Id);
            Test.stopTest();   
            system.assertEquals(pillWrapperObj.sObjType,GlobalConstants.SOJBECT_USER);
    }  
       
   /*
    * @describe : tests saveRelatedEnititiesAction method for added entities
    */
    @isTest private static void testSaveRelatedEnititiesActionToAdd() {  
       
            List<NewMeetingLightningController.PillWrapper> pillWrapperAdditionList = 
                new List<NewMeetingLightningController.PillWrapper>();
            List<NewMeetingLightningController.PillWrapper> pillWrapperDeletionList = 
                new List<NewMeetingLightningController.PillWrapper>();
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.SaveResult accSR = Database.insert(accObj);
            pillWrapperAdditionList.add(new NewMeetingLightningController.PillWrapper
                                (accObj.Name,accObj.Name,String.valueOf(accObj.getSObjectType()),
                                 String.valueOf(accSR.getId()),'')); 
            Contact conObj = PrepareTestData.getTestContact(accObj.Id);
            Database.SaveResult conSR = Database.insert(conObj);
            pillWrapperAdditionList.add(new NewMeetingLightningController.PillWrapper
                                (conObj.LastName,conObj.LastName,String.valueOf(conObj.getSObjectType()),
                                 String.valueOf(conSR.getId()),''));
            User usrObj = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
            Database.SaveResult usrSR = Database.insert(usrObj);
            pillWrapperAdditionList.add(new NewMeetingLightningController.PillWrapper
                                (usrObj.LastName,usrObj.LastName,String.valueOf(usrObj.getSObjectType()),
                                 String.valueOf(usrSR.getId()),''));
            
            //for unlisted atendees
            pillWrapperAdditionList.add(new NewMeetingLightningController.PillWrapper
                                (GlobalConstants.TEST_NAME,GlobalConstants.TEST_NAME,
                                 GlobalConstants.UNLISTED_TYPE,'',''));
            
            Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(true,accObj.Id);
            
            String result = null;
            Test.startTest();
           	 result =NewMeetingLightningController.saveRelatedEnititiesAction(JSON.serialize(pillWrapperAdditionList),
                                                                              JSON.serialize(pillWrapperDeletionList),
                                                                              meetingObj.Id);
            Test.stopTest();   
            system.assertEquals(GlobalConstants.SUCCESS,result);
    }  


	/*
    * @describe : tests testSaveRelatedEnititiesAction for deleted entities
    */
    @isTest private static void testSaveRelatedEnititiesActionToDelete() { 
        	List<NewMeetingLightningController.PillWrapper> pillWrapperAdditionList = 
                new List<NewMeetingLightningController.PillWrapper>();
            List<NewMeetingLightningController.PillWrapper> pillWrapperDeletionList = 
                new List<NewMeetingLightningController.PillWrapper>();
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.SaveResult accSR = Database.insert(accObj);
      		Contact conObj = PrepareTestData.getTestContact(accObj.Id);
            Database.SaveResult conSR = Database.insert(conObj);
            User usrObj = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
            Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(false,accObj.Id);
        	meetingObj.Other_Attendees__c = GlobalConstants.TEST_NAME;
        	Database.insert(meetingObj); 
        
            
            User_Attendee__c usrAtt = 
                new User_Attendee__c(User__c = usrObj.Id, Meeting__c= meetingObj.Id);
            Database.SaveResult usrAttSR = Database.insert(usrAtt);
        	Contact_Attendee__c contAtt = 
                new Contact_Attendee__c(Contact__c = conObj.Id, Meeting__c= meetingObj.Id);
        	Database.SaveResult contAttSR = Database.insert(contAtt);
        	Meeting_Company_Relation__c compRel = 
                new Meeting_Company_Relation__c(Company__c = accObj.Id, Meeting__c= meetingObj.Id);
        	Database.SaveResult compRelSR = Database.insert(compRel);
          
            pillWrapperDeletionList.add(new NewMeetingLightningController.PillWrapper
                                (usrObj.Name,usrObj.Name,String.valueOf(usrObj.getSObjectType()),
                                 String.valueOf(usrObj.Id),String.valueOf(usrAttSR.getId()))); 
            pillWrapperDeletionList.add(new NewMeetingLightningController.PillWrapper
                                (conObj.Name,conObj.Name,String.valueOf(accObj.getSObjectType()),
                                 String.valueOf(conSR.getId()),String.valueOf(contAttSR.getId()))); 
            pillWrapperDeletionList.add(new NewMeetingLightningController.PillWrapper
                                (accObj.Name,accObj.Name,String.valueOf(accObj.getSObjectType()),
                                 String.valueOf(accSR.getId()),String.valueOf(compRelSR.getId()))); 
            pillWrapperDeletionList.add(new NewMeetingLightningController.PillWrapper
                                (GlobalConstants.TEST_NAME,GlobalConstants.TEST_NAME,
                                 GlobalConstants.UNLISTED_TYPE,GlobalConstants.TEST_NAME,NULL));
            
            
            String result = null;
            Test.startTest();
           	 result =NewMeetingLightningController.saveRelatedEnititiesAction(JSON.serialize(pillWrapperAdditionList),
                                                                              JSON.serialize(pillWrapperDeletionList),
                                                                              meetingObj.Id);
            Test.stopTest();   
            system.assertEquals(GlobalConstants.SUCCESS,result);
    }  
    
    /*
    * @describe : tests getMeetingRelatedEntities method
    */
    @isTest private static void testGetMeetingRelatedEntities() { 
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.SaveResult accSR = Database.insert(accObj);
      		Contact conObj = PrepareTestData.getTestContact(accObj.Id);
            Database.SaveResult conSR = Database.insert(conObj);
            User usrObj = PrepareTestData.getRunningUser(GlobalConstants.PROFILE_SYSTEM_ADMIN);
            Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(false,accObj.Id);
        	meetingObj.Other_Attendees__c = GlobalConstants.TEST_NAME;
        	Database.insert(meetingObj);
            
            List<sObject> relatedEntities = new List<sObject>();
            User_Attendee__c usrAtt = 
                new User_Attendee__c(User__c = usrObj.Id, Meeting__c= meetingObj.Id);
        	Contact_Attendee__c contAtt = 
                new Contact_Attendee__c(Contact__c = conObj.Id, Meeting__c= meetingObj.Id);
        	Meeting_Company_Relation__c compRel = 
                new Meeting_Company_Relation__c(Company__c = accObj.Id, Meeting__c= meetingObj.Id);
            relatedEntities.add(usrAtt);
            relatedEntities.add(contAtt);
        	relatedEntities.add(compRel);
        	Database.insert(relatedEntities);          
            Test.startTest();
           	 List<NewMeetingLightningController.PillWrapper> result =
                 NewMeetingLightningController.getMeetingRelatedEntities(meetingObj);
            Test.stopTest();   
            system.assertEquals(5,result.size());
    } 
    
   /*
    * @describe : tests populateDate method for EndDateTime 
    */
    @isTest private static void testPopulateDateForEndDateTime() { 
            Account accObj = PrepareTestData.getDefaultAccount(); 
            Database.insert(accObj);
            Meeting__c meetingObj = PrepareTestData.getTestMeetingRecord(false,accObj.Id);
            meetingObj.Name = accObj.Name;
            meetingObj.Start_DateTime__c = system.now();
            meetingObj.End_DateTime__c = null;
            String meetingJSONString = JSON.serialize(meetingObj);
            Meeting__c result= null;
            Test.startTest();                
            	result = NewMeetingLightningController.populateDateAction(meetingJSONString);
            Test.stopTest();   
            system.assertEquals(meetingObj.Start_DateTime__c.addhours(GlobalConstants.MIN_RANGE_SMALL),result.End_DateTime__c);
    } 
}