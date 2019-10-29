/* --------------------------------------------------------------------------------------------------
   Name:            MeetingPdfTemplateExtension.cls 
   Description:     Extension for Visualforce MeetingRecordTemplate1.Page
   Test class:      MeetingPdfTemplateTest.cls 
  ------------------------------------------------------------------------------------------------ */
public with sharing class MeetingPdfTemplateExtension{
    static public Map<Id, Meeting__c> meetingCache;
    public Meeting__c meetingRecord {get; set;}
    public String fieldsetName {get; set;}
    public String cachedMeetingId;
    public final Date NEW_MEETING_VIEW_DATE = Date.newInstance(2018,9,21);
    private static final String FLD_SET_NAME= 'Review_Fields';
    private static final String ADD_DELIMA = ', ';
     /** 
     * @description : MeetingPdfTemplateExtension init
     **/
    public MeetingPdfTemplateExtension(Apexpages.StandardController controller){
       cachedMeetingId = controller.getId();
       fieldsetName = FLD_SET_NAME;
       if (meetingCache != null && meetingCache.containsKey(cachedMeetingId)){
           meetingRecord = meetingCache.get(cachedMeetingId);
       } else if (cachedMeetingId != null) {
           meetingRecord = [SELECT Id, Name, Account__r.Name, Meeting_Type__c, Relationship_Type__c, Next_Steps_Actions__c,
                    Start_DateTime__c, End_DateTime__c, Other_Attendees__c, Decline_Appeal__c, Meeting_Address__c,
                    Meeting_Agenda__c, Requirements__c, Structure__c, Strategy__c, Financials__c, Fraud_Protection_Discussed__c,
                    Products_And_Services__c, Customers_And_Suppliers__c, International_Operations__c,
                    Needs_Changed__c, Needs_Changed_Detail__c, Customers_Changed__c, Documents_Detailed__c,
                    Customers_Changed_Detail__c, Nature_Changed__c, Nature_Change_Detail__c,
                    Business_Operating_Expectations__c, Business_Operating_Detail__c, Observations__c,
                    Validated_Nature_Of_Business__c, Reason_Nature_Not_Validated__c, Outcome__c,
                    Credit_Decline_Notification__c, Credit_Decline_Detail__c, Documents_Attached__c,
                    PreCredit_Decline_Notification__c, PreCredit_Decline_Detail__c,Cancel_Reason__c,
                    Meeting_Note__c,Preferences_Discussed__c,Fraud_Protection_Detail__c,Pricing_Desc__c,Pricing__c,
                    Incomplete__c,Is_Cancelled__c,Meeting_Address_Type__c,Meeting_Date__c,CreatedDate,
                    (SELECT Id, User__r.Name FROM User_Attendees__r),
                    (SELECT Id, Contact__r.Name FROM Contact_Attendees__r)
                    FROM Meeting__c 
                    WHERE Id = :controller.getId() LIMIT 1000];
       } else{}
    }
    
    public Boolean getShouldShowHistoricalData() {
    	return meetingRecord.CreatedDate < NEW_MEETING_VIEW_DATE;
    }

     /** 
     * @description : get Attendees
     **/
    public String getSantanderAttendees(){
        List<String> santanderAttendees = new List<String>();
        String attendeesString = null;
        try{
           if (meetingRecord != null){
               for (User_Attendee__c attendee : meetingRecord.User_Attendees__r){
                  santanderAttendees.add(attendee.User__r.Name);
               }
           }
        } catch(Exception e){
            System.debug('Exception has been throw'+e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        } finally{
           attendeesString = String.join(santanderAttendees, ADD_DELIMA);
        }
        return attendeesString;
    }
    
    /** 
     * @description : get Related Companies
     **/
    public String getRelatedCompanies(){
        List<String> relatedCompanies = new List<String>();
        String relatedCompaniesStr = null;
        try{
           if (meetingRecord != null){
               for (Meeting_Company_Relation__c relatedCompany : [SELECT ID, Name, Company__r.Name 
                                                                    FROM Meeting_Company_Relation__c 
                                                                    WHERE Meeting__c =: meetingRecord.Id LIMIT 10000]){
                  relatedCompanies.add(relatedCompany.Company__r.Name);
               }
           }
        } catch(Exception e){
            System.debug('Exception has been throw'+e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        } finally{
           relatedCompaniesStr = String.join(relatedCompanies, ADD_DELIMA);
        }
        return relatedCompaniesStr;
    }
    
    
     /** 
     * @description : get contact attendees
     **/ 
    public String getContactAttendees(){
        List<String> contactAttendees = new List<String>();
        String attendeesString = null;
        try{
           if (meetingRecord != null){
               for (Contact_Attendee__c attendee : meetingRecord.Contact_Attendees__r){
                  contactAttendees.add(attendee.Contact__r.Name);
               }
           }
        } catch(Exception e){
            System.debug('Exception has been throw'+e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        } finally {
           attendeesString = String.join(contactAttendees, ADD_DELIMA);
        }
        return attendeesString;
    }
}