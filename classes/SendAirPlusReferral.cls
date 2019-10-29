public with sharing class SendAirPlusReferral {

	private static final String DISPLAY_NAME = 'Rapport CRM';
	private static final String TEMPLATE_NAME = 'Air Plus Referral Info';
    private static final String CORPORATE_CARD_PRODUCT = 'Airplus Corporate Card';

	/**
	* @description Retrieve informaiton if Referral data for this opportunity has been already sent and when
	*/
    @AuraEnabled
    public static DateTime getReferralSentDate(Id opportunityId){
        DateTime referralSentDate = null;
        try {
            return [SELECT Referral_Sent_Date__c
                    FROM Opportunity 
                    WHERE Id = :opportunityId 
                    LIMIT 1].Referral_Sent_Date__c;
        } catch (Exception e) {
            referralSentDate = null;
        }
        
        return referralSentDate;
    }

	/**
	* @description: Send the email referral or return error details, while sent process has failed
	* 
	**/
    @AuraEnabled
    public static ReferralActionResult sendOppEmail(Id opportunityId){
    	ReferralActionResult result = new ReferralActionResult();
        try {
            Opportunity oppObj = [SELECT Id, AccountId, RecordTypeId, OwnerId,
                                  Annual_Spend__c,Reason_for_Enquiry__c,Number_of_cards_required__c,
                                  Opportunity_New_Custom_Field_Help_for__c,
                                  How_do_they_currently_pay_for_travel__c,
                                  Lodge_Central_Travel_Account_Provider__c,
                                  Current_Corporate_Card_provider__c,
                                  Primary_Product_Lookup__r.Name
                            FROM Opportunity
                            WHERE Id=: opportunityId];
            
            List<String> fieldsNotPopulated = getOpportunityMissingFields(oppObj);
            
            if (fieldsNotPopulated.size() > 0) {
                result.isPositive = false;
                result.errorMessage = 'Please populate all required fields before sending email: ' +
                    String.join(fieldsNotPopulated, ', ');
            } else {
	            Messaging.SingleEmailMessage mail = getReferralEmailMessage(oppObj);
                Messaging.SendEmailResult[] emailResultList = Messaging.sendEmail(
                    new Messaging.SingleEmailMessage[] { mail }
                );
                
                Messaging.SendEmailResult emailResult = emailResultList.get(0);
                result.isPositive = emailResult.isSuccess();
                Messaging.SendEmailError[] errorList = emailResult.getErrors();
                if (errorList != null && errorList.size() > 0) {
                    result.errorMessage = 'Email sent has failed. Error details: ' + errorList.get(0).getMessage();        
                }
            }
            
            if (result.isPositive) {
                result.referralSentDate = DateTime.now();
                Database.update(new Opportunity(
                    Id = opportunityId, 
                    Referral_Sent_Date__c = result.referralSentDate
                ));
            }
        } catch (Exception e) {
            result.isPositive = false;
            result.errorMessage = 'Operation failed. Please share with administator error details: ' + e.getMessage();
        }
        
        return result;
	}   
    
    /*
     * @description Validates opportunity record and return list of fields, which should be filled before sending
     */
    private static List<String> getOpportunityMissingFields(Opportunity oppObj) {
        List<String> fieldsNotPopulated = new List<String>();
        List<Schema.DescribeFieldResult> requiredFieldList = new List<Schema.DescribeFieldResult>{
            Opportunity.Annual_Spend__c.getDescribe()
        };
                    
        if (oppObj.Primary_Product_Lookup__r.Name == CORPORATE_CARD_PRODUCT) {
        	requiredFieldList.addAll(new List<Schema.DescribeFieldResult>{
            	Opportunity.Reason_for_Enquiry__c.getDescribe(),
                Opportunity.Number_of_cards_required__c.getDescribe(),
                Opportunity.Current_Corporate_Card_provider__c.getDescribe()
            });      
        }
        
        for (Schema.DescribeFieldResult fieldDescribe : requiredFieldList) {
            if (oppObj.get(fieldDescribe.getName()) == null || oppObj.get(fieldDescribe.getName()) == 0) {
                fieldsNotPopulated.add(fieldDescribe.getLabel());
            }
        }
        
        if (oppObj.Lodge_Central_Travel_Account_Provider__c != null && 
            oppObj.How_do_they_currently_pay_for_travel__c == null) {
                fieldsNotPopulated.add(
                    Opportunity.How_do_they_currently_pay_for_travel__c.getDescribe().getLabel()
                );
        }
        
        return fieldsNotPopulated;  
    }
    
    /*
     * @description Returns Email Message generated from email template, which should be sent to AirPlus referral email
     */
    private static Messaging.SingleEmailMessage getReferralEmailMessage(Opportunity oppObj){
		List<String> refToAddresses = new List<String> (); 
        Config_Settings__c configSettings = Config_Settings__c.getInstance();

		OrgWideEmailAddress oWA = [SELECT Id, Address, DisplayName 
								   FROM OrgWideEmailAddress
								   WHERE DisplayName = :DISPLAY_NAME
								   LIMIT 1];

		EmailTemplate emailTemp = [SELECT Id, Subject, Body, HtmlValue 
								   FROM EmailTemplate 
								   WHERE Name = :TEMPLATE_NAME 
								   LIMIT 1];

        refToAddresses.add(configSettings.Airplus_Referral_Email__c);

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp.Id, oppObj.OwnerId, oppObj.Id);
		mail.setToAddresses(refToAddresses);
        mail.setOrgWideEmailAddressId(oWA.Id);
        mail.setTemplateId(emailTemp.Id);
        mail.setTargetObjectId(oppObj.OwnerId);
        mail.setsaveAsActivity(False);
		return mail;        
    }

	public class ReferralActionResult{
		@AuraEnabled
		public Boolean isPositive = true;
		@AuraEnabled
		public String errorMessage;
        @AuraEnabled
        public DateTime referralSentDate = null;
	}
}