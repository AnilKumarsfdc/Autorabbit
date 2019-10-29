public class GeWS_Ratings_Wrapper {
    
    public class SME_Wrap{
        public string financial_statement_id;
        public Map<String,String> industry_code;
        public Map<String, Map<String,String>> subjectives;
        public Map<String,String> manual_rating;
        public string group_id;
        public string proposed_adjustment_comment;
        public string proposed_adjustment;
        public string final_rating;
        public string override_reason;
        
        public SME_Wrap( String financial_statement_idArg, 
                         Map<String,String> industry_codeArg, 
                         Map<String, Map<String,String>> subjectivesArg, 
                         Map<String,String> manual_ratingArg,
                         String group_idArg ){
                             
            this.financial_statement_id = financial_statement_idArg;
            this.industry_code = industry_codeArg;
            this.subjectives = subjectivesArg;
            this.manual_rating = manual_ratingArg;
            this.group_id = group_idArg;
        }
        
        public SME_Wrap( String proposed_adjustment_commentArg,
                         String proposed_adjustmentArg,
                         String final_ratingArg,
                         String override_reasonArg ){
            
            this.proposed_adjustment_comment = proposed_adjustment_commentArg;
            this.proposed_adjustment = proposed_adjustmentArg;
            this.final_rating = final_ratingArg;
            this.override_reason = override_reasonArg;
        }
    }
    
    public class IPRE_Wrap{
        public string financial_statement_id;
        public string group_id;
        public string krg_id;
        public string acm_customer_id;
        public Map<String, Map<String,String>> subjectives;
        public string proposed_adjustment;
        public string proposed_adjustment_comment;
        public string override_rating;
        public string override_comment;
        
        public IPRE_Wrap( String financial_statement_idArg, 
                          String group_idArg,
                          String krg_idArg,
                          String acm_customer_idArg,
                          Map<String, Map<String,String>> subjectivesArg ){
                             
            this.financial_statement_id = financial_statement_idArg;
            this.group_id = group_idArg;
            this.krg_id = krg_idArg;
            this.acm_customer_id = acm_customer_idArg;
            this.subjectives = subjectivesArg;
        }
        
        public IPRE_Wrap( String proposed_adjustmentArg,
                          String proposed_adjustment_commentArg,
                          String override_ratingArg,
                          String override_commentArg ){
        
            this.proposed_adjustment = proposed_adjustmentArg;
            this.proposed_adjustment_comment = proposed_adjustment_commentArg;
            this.override_rating = override_ratingArg;
            this.override_comment = override_commentArg;
        }
    }
    
    public class SHPD_Wrap{
        
        public string financial_statement_id;
        public string impersonal_or_indicative_pd;
        public string guarantor;
        public string direct_borrower;
        public string business_plan_approval;
        public string charity_status;
        public Map<String,String> area_and_interest_cover; 
        public Map<String,String> mgmt_info; 
        public Map<String,String> rev_and_lev; 
        public Map<String,String> voids_and_bad_debts; 
        public Map<String,String> assessment;
        
        public SHPD_Wrap( String financial_statement_idArg,
                          String impersonal_or_indicative_pdArg,
                          String guarantorArg,
                          String direct_borrowerArg,
                          String business_plan_approvalArg,
                          String charity_statusArg,
                          Map<String,String> area_and_interest_coverArg,
                          Map<String,String> mgmt_infoArg,
                          Map<String,String> rev_and_levArg,
                          Map<String,String> voids_and_bad_debtsArg,
                          Map<String,String> assessmentArg ){
                              
            this.financial_statement_id = financial_statement_idArg;
            this.impersonal_or_indicative_pd = impersonal_or_indicative_pdArg;
            this.guarantor = guarantorArg;
            this.direct_borrower = direct_borrowerArg;
            this.business_plan_approval = business_plan_approvalArg;
            this.charity_status = charity_statusArg;
            this.area_and_interest_cover = area_and_interest_coverArg;
            this.mgmt_info = mgmt_infoArg;
            this.rev_and_lev = rev_and_levArg;
            this.voids_and_bad_debts = voids_and_bad_debtsArg;
            this.assessment = assessmentArg;
        }
        
        public SHPD_Wrap( Map<String,String> assessmentArg ){
            this.assessment = assessmentArg;
        }
    }
    
    public class SHLGD_Wrap{
        
        public string financial_statement_id;
        public string counterparty_name;
        public string impersonal_or_indicativePD_or_personal;
        public string guarantor;
        public string business_plan_approval;
        public string charity_status;
        public Map<String,String> facility; 
        public Map<String,String> assessment;
        
        public SHLGD_Wrap( String financial_statement_idArg,
                          String counterparty_nameArg,  
                          String impersonal_or_indicativePD_or_personalArg,
                          String guarantorArg,
                          String business_plan_approvalArg,
                          String charity_statusArg,
                          Map<String,String> facilityArg,
                          Map<String,String> assessmentArg ){
                              
            this.financial_statement_id = financial_statement_idArg;
            this.counterparty_name = counterparty_nameArg;
            this.impersonal_or_indicativePD_or_personal = impersonal_or_indicativePD_or_personalArg;
            this.guarantor = guarantorArg;
            this.business_plan_approval = business_plan_approvalArg;
            this.charity_status = charity_statusArg;
            this.facility = facilityArg;
            this.assessment = assessmentArg;
        }
        
        public SHLGD_Wrap( Map<String,String> assessmentArg ){
            this.assessment = assessmentArg;
        }
    }
    
    public class cascade_bdp_element{
        public list<String> element;
        public cascade_bdp_element( list<string> elementArg ){
            this.element = elementArg;
        }
    }
    
    public class Request_Wrap{
        public string ncino_process_id;
        public string rule_model;
        public string action;
        public string rating_id;
        public string test_flag;
        public string bdp_id;
        public Map<String,String> rating_approver;
        public string approval_comment;
        public string cascade_to_group;
        public GeWS_Ratings_Wrapper.cascade_bdp_element cascade_to_bdp_ids;
        public Map<String,String> rating_conductor;
        public GeWS_Ratings_Wrapper.SME_Wrap SME;
        public GeWS_Ratings_Wrapper.IPRE_Wrap IPRE;
        public GeWS_Ratings_Wrapper.SHPD_Wrap SHPD;
        public GeWS_Ratings_Wrapper.SHLGD_Wrap SHLGD;
        
        public Request_Wrap( String ncino_process_idArg,
                             String rule_modelArg,
                             String actionArg,
                             String rating_idArg,
                             String test_flagArg,
                             String bdp_idArg,
                             Map<String,String> rating_approverArg,
                             String approval_commentArg,
                             String cascade_to_groupArg,
                             GeWS_Ratings_Wrapper.cascade_bdp_element cascade_to_bdp_idsArg,
                             Map<String,String> rating_conductorArg,
                             GeWS_Ratings_Wrapper.SME_Wrap SMEArg,
                             GeWS_Ratings_Wrapper.IPRE_Wrap IPREArg,
                             GeWS_Ratings_Wrapper.SHPD_Wrap SHPDArg,
                             GeWS_Ratings_Wrapper.SHLGD_Wrap SHLGDArg){
                                 
            this.ncino_process_id = ncino_process_idArg;
            this.rule_model = rule_modelArg;
            this.action = actionArg;
            this.rating_id = rating_idArg;
            this.test_flag = test_flagArg;
            this.bdp_id = bdp_idArg;
            this.rating_approver = rating_approverArg;
            this.cascade_to_group = cascade_to_groupArg;
            this.cascade_to_bdp_ids = cascade_to_bdp_idsArg;
            this.rating_conductor = rating_conductorArg;
            this.SME = SMEArg;
            this.IPRE = IPREArg;
            this.SHPD = SHPDArg;
            this.SHLGD = SHLGDArg;
         }
    }
    
    public class Request_Data_Wrap {
        public GeWS_Ratings_Wrapper.Request_Wrap request;
        
        public Request_Data_Wrap( GeWS_Ratings_Wrapper.Request_Wrap requestArg ){
            this.request = requestArg;
        }
    }
    
    public class Rating_Request {
        public string event;
        public string id;
        public string referenceId;
        public GeWS_Ratings_Wrapper.Request_Data_Wrap requestData;
        
        public Rating_Request( String eventArg, 
                               String idArg, 
                               String referenceIdArg, 
                               GeWS_Ratings_Wrapper.Request_Data_Wrap requestDataArg ){
                                   
            this.event = eventArg;
            this.id = idArg;
            this.referenceId = referenceIdArg;
            this.requestData = requestDataArg;
        }
    }
    
    public class Ratings_Request_Payload {
        public GeWS_Ratings_Wrapper.Rating_Request ratingRequest;
        public GeWS_Ratings_Wrapper.Rating_Request approvalRequest;
        
        public Ratings_Request_Payload( GeWS_Ratings_Wrapper.Rating_Request ratingRequestArg , 
                                        GeWS_Ratings_Wrapper.Rating_Request approvalRequestArg ){
                                            
            this.ratingRequest = ratingRequestArg;
            this.approvalRequest = approvalRequestArg;
        }
    }
    
}