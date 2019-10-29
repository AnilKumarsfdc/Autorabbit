public class GeWS_RatingsCleanupUtility {
    
    public static void refreshRatingResponses(Id ratingRecordId){
        String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id = \''+ratingRecordId +'\'';
        Ratings_Model__c ratingRecord = (Ratings_Model__c)Database.query(ratingsRecordQuery)[0];

        ratingRecord.SME_Quantitative_Assessment__c = null;
	
		ratingRecord.SME_Qualitative_Overlay__c = null;
		ratingRecord.SME_Automatic_Assessment__c = null;
		
		ratingRecord.IPRE_Predictability_Grade__c = null;
		ratingRecord.IPRE_Key_Tenant_Grade__c = null;
		ratingRecord.IPRE_Lease_term_vs_loan_term_grade__c = null;
		
		ratingRecord.IPRE_Percentage_of_Capital_Repaid_Grade__c = null;
		ratingRecord.IPRE_Interest_Cover_Grade__c = null;
		ratingRecord.IPRE_Capital_and_Interest_Cover_Grade__c = null;
		ratingRecord.IPRE_Scenario_Stress_Analysis_Grade__c = null;
		ratingRecord.IPRE_Hedging_Arrangements_Grade__c = null;
		ratingRecord.IPRE_Rental_Assignment_Grade__c = null;
		ratingRecord.IPRE_Loan_to_value_now_grade__c = null;
		ratingRecord.IPRE_Loan_to_VP_Value_Forecast_Grade__c = null;
		ratingRecord.IPRE_Robustness_of_Financial_Cov_Grade__c = null;
		ratingRecord.IPRE_Structure_of_Transaction_Grade__c = null;
		
		ratingRecord.IPRE_Valuation_Date_Grade__c = null;
		ratingRecord.IPRE_Location_Design_and_Condition_Grade__c = null;
		ratingRecord.IPRE_Market_Demand_Grade__c = null;
		
		ratingRecord.IPRE_Obligation_to_support_Grade__c = null;
		ratingRecord.IPRE_Track_Record_Grade__c = null;
		ratingRecord.IPRE_Financial_Capacity_Grade__c = null;
		
		ratingRecord.IPRE_Overall_security_package_Grade__c = null;
		
		ratingRecord.IPRE_Total_Score__c = null;
        ratingRecord.IPRE_Slotting_Grade__c = null;
        
        update ratingRecord;
    }
    
    public static void simulateApproval(List<Id> ratingRecordIds){
        String ratingsRecordQuery = GeWS_ActicoUtils.composeQueryFields('Ratings_Model__c')+' where Id in :ratingRecordIds';
        list<Ratings_Model__c> ratingRecordList = (list<Ratings_Model__c>)Database.query(ratingsRecordQuery);
        
        for( Ratings_Model__c ratingRecord : ratingRecordList ){
            ratingRecord.Status__c = 'Approved';
        }
        
        update ratingRecordList;
    }
    

}