public with sharing class PdfEmailController {
    /*

    public ID meetingId { get; set; }
    public String email { get; set; }
    public Meeting__c meeting;
    Map<Id, Meeting__c> meetingMap;
    public Boolean isSaveSuccessful { get; set; }
    
    public PdfEmailController(){
    }
    
    public PdfEmailController(ApexPages.StandardController stdController){
        meetingId = stdController.getId();
        isSaveSuccessful = true;
    }

    
    public void sendEmailFromPage(){
        List<String> emailList = new List<String>();
        if(email !=null){
            emailList = email.Split(',');
        }
        
        List<String> validEmailResults = new List<String>();
        List<String> invalidEmailResults = new List<String>();
        if(emailList.size() >0){
            for(String emailReg : emailList){
            if(Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', emailReg))
                {
                    validEmailResults.add(emailReg);
                    isSaveSuccessful = true;
                }
                else if(!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', emailReg))
                {
                    invalidEmailResults.add(emailReg);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please Enter Valid Email Id for:' +emailReg));
                    isSaveSuccessful = false;
                }
            }
        }
        
        map<Id, List<string>> mapMeetingIdEmailListFromPage = new map<Id, List<string>>();
        mapMeetingIdEmailListFromPage.put(meetingId,validEmailResults);
        sendPdf(mapMeetingIdEmailListFromPage);
    } 


    public void sendPdf(map<Id, List<string>> mapMeetingIdEmailList) {
      
        Messaging.SingleEmailMessage[] messageList = new list<Messaging.SingleEmailMessage>();
        
        meetingMap = new Map<Id, Meeting__c>(
            [SELECT Id, Name, Account__r.Name, Meeting_Type__c, Relationship_Type__c, 
                    Start_DateTime__c, End_DateTime__c, Other_Attendees__c, 
                    Meeting_Agenda__c, Requirements__c, Structure__c, Strategy__c, Financials__c,
                    Products_And_Services__c, Customers_And_Suppliers__c, International_Operations__c,
                    Needs_Changed__c, Needs_Changed_Detail__c, Customers_Changed__c, 
                    Customers_Changed_Detail__c, Nature_Changed__c, Nature_Change_Detail__c,
                    Business_Operating_Expectations__c, Business_Operating_Detail__c, Observations__c,
                    Validated_Nature_Of_Business__c, Reason_Nature_Not_Validated__c, Outcome__c,
                    Credit_Decline_Notification__c, Credit_Decline_Detail__c, Documents_Attached__c,
                    PreCredit_Decline_Notification__c, PreCredit_Decline_Detail__c,Cancel_Reason__c, 
                    (SELECT Id, User__r.Name FROM User_Attendees__r),
                    (SELECT Id, Contact__r.Name FROM Contact_Attendees__r)
             FROM Meeting__c 
             WHERE Id IN :mapMeetingIdEmailList.keySet()]
        );
        
        Map<Id,List<Messaging.EmailFileAttachment>> mapIdAndEmailAttachments = new Map<Id,List<Messaging.EmailFileAttachment>>();
        Messaging.EmailFileAttachment efa;
        for(Attachment att : [SELECT Id, Name, Body, ContentType,parentId FROM Attachment 
             WHERE ParentId IN :mapMeetingIdEmailList.keySet()]){
            
            efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            efa.setContentType(att.ContentType);
            
            if(mapIdAndEmailAttachments!= null && !mapIdAndEmailAttachments.containskey(att.parentId)){
                mapIdAndEmailAttachments.put(att.parentId,new List<Messaging.EmailFileAttachment>{efa});
            }else{
                mapIdAndEmailAttachments.get(att.parentId).add(efa);
            }
        }
        
        //Populate static Page Cache, what will give ability to reuse data within PDF document rather then making a separate queries
        MeetingPdfTemplateExtension.meetingCache = meetingMap;
        
        for(String mId : mapMeetingIdEmailList.keySet()){
            if(mapMeetingIdEmailList != null && mapMeetingIdEmailList.get(mId).size()>0){
                
                //PageReference pdf = Page.TemplateTest;
                PageReference pdf = Page.MeetingRecordTemplate1;
                pdf.getParameters().put('id', mId);
                Blob body;
                
                // the contents of the attachment from the pdf
                if(Test.IsRunningTest()){
                    body = Blob.valueOf('UNIT.TEST');
                }
                else
                {
                    body = pdf.getContent();
                }
                
                    
                // To send the PDF of Meeting record as an attachment
                efa = new Messaging.EmailFileAttachment(); 
                efa.setContentType('application/pdf');
                efa.setFileName('Meeting.pdf');
                efa.setInline(false);
                efa.Body = body;
                if(mapIdAndEmailAttachments!= null && !mapIdAndEmailAttachments.containskey(mId)){
                    mapIdAndEmailAttachments.put(mId,new List<Messaging.EmailFileAttachment>{efa});
                }else{
                    mapIdAndEmailAttachments.get(mId).add(efa);
                }
                
                  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setToAddresses(mapMeetingIdEmailList.get(mId));
                mail.setSubject('Meeting Report');
                mail.setHtmlBody('Below please find Meeting Report you requested. Kindly check the attachment.');
                mail.setFileAttachments(mapIdAndEmailAttachments.get(mId));
                
                // Adding Email Message to List
                messageList.add(mail);
               
            }
        }
            // Send the email
            Messaging.sendEmail(messageList);
    }
*/
}