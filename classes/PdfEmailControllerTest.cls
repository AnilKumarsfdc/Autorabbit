@isTest (SeeAllData=false)
private class PdfEmailControllerTest {/*
    
    static testmethod void runPositiveTests(){
        
        List<Meeting__c> meeting;
        Map<Id, List<String>> meetingMap;
        List<String> emailList;
        String email;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        Account Acc = new Account(Name='testAccount', RecordTypeId=AccountRecordTypeInfo.get('Project').getRecordTypeId());
        insert Acc;
        
        //Set up user
        User user = [SELECT Id FROM User WHERE Alias='skash'];
        System.RunAs(user){
        
        email = 'sheshant.kashyap@accenture.com';
        meeting = new List<Meeting__c>();
        for(integer i=0; i<3; i++) {
            meeting.add( new Meeting__c(Account__c= Acc.Id));
        }
        insert meeting;
       
        for(Meeting__c m:[SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
            WHERE CreatedDate = TODAY
            and CreatedById = :user.Id LIMIT 1]) {
                if (emailList == null) {
                emailList = new List<String>();
                }
                emailList.add(m.CreatedBy.Email);

                System.assertEquals(email, emailList[0]);
                
                meetingMap = new Map<Id,List<String>>();
                meetingMap.put(m.Id,emailList);
                
                Attachment attach = new Attachment(); 
        		attach.Name = 'Unit Test Attachment';
        		Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        		attach.body = bodyBlob;
        		attach.parentId = m.Id;
        		insert attach;
                
                PageReference pref = Page.PdfEmailer;
                pref.getParameters().put('id',m.id);
                Test.setCurrentPage(pref);
                
                ApexPages.StandardController sc = new ApexPages.StandardController(m);
                PdfEmailController con = new PdfEmailController(sc); 

                Test.startTest();
                con.meetingId = m.Id;
                con.email = 'sheshant.kashyap@accenture.com';
                con.sendEmailFromPage();
                Test.stopTest();
            }
        }
    }
    
    static testmethod void runNegativeTests(){
        
        List<Meeting__c> meeting;
        Map<Id, List<String>> meetingMap;
        List<String> emailList;
        String email;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        Account Acc = new Account(Name='testAccount', RecordTypeId=AccountRecordTypeInfo.get('Project').getRecordTypeId());
        insert Acc;
        
        //Set up user
        User user = [SELECT Id FROM User WHERE Alias='skash'];
        System.RunAs(user){
        
        email = 'sheshant.kashyap@accenture.com';
        meeting = new List<Meeting__c>();
        for(integer i=0; i<3; i++) {
            meeting.add( new Meeting__c(Account__c= Acc.Id));
        }
        insert meeting;
       
        for(Meeting__c m:[SELECT Id, Name, CreatedBy.Email, CreatedById FROM Meeting__c
            WHERE CreatedDate = TODAY
            and CreatedById = :user.Id LIMIT 1]) {
                if (emailList == null) {
                emailList = new List<String>();
                }
                emailList.add(m.CreatedBy.Email);

                System.assertEquals(email, emailList[0]);
                
                meetingMap = new Map<Id,List<String>>();
                meetingMap.put(m.Id,emailList);
                
                PageReference pref = Page.PdfEmailer;
                pref.getParameters().put('id',m.id);
                Test.setCurrentPage(pref);
                
                ApexPages.StandardController sc = new ApexPages.StandardController(m);
                PdfEmailController con = new PdfEmailController(sc); 

                Test.startTest();
                con.meetingId = m.Id;
                con.email = 'sheshantkashyap';
                try{
                    con.sendEmailFromPage();
                }
                
                catch(Exception e){
                    String expectedEmail = 'sheshantkashyap';
                    System.assertEquals(expectedEmail, con.email);
                }
                
                Test.stopTest();
            }
        }
    }
*/
}