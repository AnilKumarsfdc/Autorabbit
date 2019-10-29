/* --------------------------------------------------------------------------------------------------
  Name:            SendStrategyLightningController.cls 
  Description:     Aura controller of Lightning component which is used to Send 
                   Relationship Plan / Strategy Plan as a PDF
  Test class:      SendStrategyLightningControllerTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class SendStrategyLightningController {
    private static final string APPLICATION_TYPE = 'application/pdf';
    private static final string FILE_NAME = 'Relationship Plan / Strategy Plan.pdf';
    private static final string EMAIL_SUBJECT = 'Relationship Plan / Strategy Plan Report';
    private static final string EMAIL_BODY = 'Please find attached the Relationship Plan / Strategy Plan you requested. '
                                           + 'Kindly check the attachment.';
    
    /**
     * @description Sends Strategy Plan related to selected company and sends it as PDF to list of users from emailList
     * @return Boolean 
     **/
    @AuraEnabled
    public static Boolean sendEmailFromPage(ID companyId, List<String> emailList) {
        try {
            Account company = [SELECT Id, name, Relationship_Plan__c
                               FROM Account
                               WHERE Id = :companyId
                               LIMIT 1];
            OrgWideEmailAddress[] oWaList = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false);
            if (oWaList.size() > 0) {
                    mail.setOrgWideEmailAddressId(oWaList.get(0).Id);
            }
            mail.setToAddresses(emailList);
            mail.setSubject('Relationship Plan - '+ company.name);
            mail.setHtmlBody(EMAIL_BODY);
            mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                getPdfReportAttachment(company.Relationship_Plan__c)
            });
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            return true;

        }
        catch(Exception e) {
            throw e;
        }
    }    
    
    /**
     * @description Generates PDF or Relationship plan and wraps it into Email File Attachment
     * @return Messaging.EmailFileAttachment 
     **/
    private static Messaging.EmailFileAttachment getPdfReportAttachment(Id planId) {
        PageReference pdf = Page.RelationshipPlanTemplate;
        pdf.getParameters().put(GlobalConstants.SOBJECT_FIELD_ID, planId);
        
        Blob body = null;
        // the contents of the attachment from the pdf
        if (Test.IsRunningTest()) {
            body = Blob.valueOf(GlobalConstants.TEST_NAME);
        } else {
            body = pdf.getContent();
        }   
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType(APPLICATION_TYPE);
        attachment.setFileName(FILE_NAME);
        attachment.setInline(false);
        attachment.Body = body;
        return attachment;  
    }
}