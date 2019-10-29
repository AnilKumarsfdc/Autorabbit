/******************************************************************************
 * Version: 1.0
 * Date: 28/10/2019
 * Author: Puneet Mehra (Accenture)
 * Description: To validate Rating inputs before making a callout to Actico 
 *****************************************************************************/
global with sharing class ValidateRatingInputsClass {
     
    @InvocableMethod(label='Validate Rating Inputs')
    global static List<ValidateRatingInputsResult> ValidateRatingInputsMethod(List<ValidateRatingInputsRequest> ratingsList) {
      List<ValidateRatingInputsResult> ratingResults = new List<ValidateRatingInputsResult>();
      ValidateRatingInputsResult result = new ValidateRatingInputsResult();
        if(ratingsList[0].recordTypeName == 'SME' ||
          ratingsList[0].recordTypeName == 'SME - MRO' ||
          ratingsList[0].recordTypeName == 'SME - CE') {
        	result.missingFields = ValidateRatingInputsClass.getMissingFieldsSME(ratingsList[0].rating);
        }
        
      ratingResults.add(result); 
      return ratingResults;  
    }
    
    //input variables consist of the Rating, the Section where the button was clicked (if applicable) and the Record Type
    global class ValidateRatingInputsRequest {
        @InvocableVariable(required = true)
        global Ratings_Model__c rating;
        
        @InvocableVariable
        global String sectionName;
        
        @InvocableVariable(required = true)
        global String recordTypeName;
    }
    
    //output variable is a string of missing fields, with each field separated by a newline
    global class ValidateRatingInputsResult {
        @InvocableVariable
        global String missingFields;
    }
    
    //helper method for SME
    private static String getMissingFieldsSME(Ratings_Model__c r) {
        String missingFieldsSME = '';
        //Product/Market/Demand section
        if(r.SME_Strength_of_Demand_Non_Cyclicaly__c == null ||
          r.SME_Available_product_substitutes__c == null ||
          r.SME_Stable_Regulation_Operating_Enviro__c == null ||
          r.SME_Barriers__c == null ||
          r.SME_Market_Position__c == null ||
          r.SME_Concentration_of_Suppliers__c == null ||
          r.SME_Outlook_for_turnover_and_order_book__c == null ||
           r.SME_Appropriateness_of_diversification__c == null) missingFieldsSME += 'Product/Market/Demand\n'.toUpperCase();
        if(r.SME_Strength_of_Demand_Non_Cyclicaly__c == null) missingFieldsSME+='Strength of Demand/Non-Cyclicaly\n';
        if(r.SME_Available_product_substitutes__c == null) missingFieldsSME+='Available product substitutes\n';
        if(r.SME_Stable_Regulation_Operating_Enviro__c == null) missingFieldsSME+='Stable Regulation/Operating Environment\n';
        if(r.SME_Barriers__c == null) missingFieldsSME+='Barriers\n';
        if(r.SME_Market_Position__c == null) missingFieldsSME+='Market Position\n';
        if(r.SME_Concentration_of_Suppliers__c == null) missingFieldsSME+='Concentration of Suppliers\n';
        if(r.SME_Concentration_of_Customers__c == null) missingFieldsSME+='Concentration of Customers\n';
        if(r.SME_Outlook_for_turnover_and_order_book__c == null) missingFieldsSME+='Outlook for turnover and order book\n';
        if(r.SME_Appropriateness_of_diversification__c == null) missingFieldsSME+='Appropriateness of diversification\n';
        //Shareholder/Management
        if(r.SME_Visibility_of_Company__c == null ||
          r.SME_MotivationCapacity_financial_support__c == null ||
          r.SME_Appropriatenes_Shareholder_Structure__c == null ||
          r.SME_Management_Experience_Depth_History__c == null ||
          r.SME_Appropriateness_Management_Structure__c == null ||
          r.SME_Historical_noticesfinancial_problems__c == null ||
          r.SME_Strategy_and_consistency__c == null ||
          r.SME_Audit_aptness_transparancy_of_FS__c == null) missingFieldsSME+= '\nShareholder/Management\n'.toUpperCase();
        if(r.SME_Visibility_of_Company__c == null) missingFieldsSME+='Visibility of Company\n';
        if(r.SME_MotivationCapacity_financial_support__c == null) missingFieldsSME+='Motivation Capacity of financial support\n';
        if(r.SME_Appropriatenes_Shareholder_Structure__c == null) missingFieldsSME+='Appropriateness of Shareholder Structure\n';
        if(r.SME_Management_Experience_Depth_History__c == null) missingFieldsSME+='Management Experience / Depth / History\n';
        if(r.SME_Appropriateness_Management_Structure__c == null) missingFieldsSME+='Appropriateness of Management Structure\n';
        if(r.SME_Historical_noticesfinancial_problems__c == null) missingFieldsSME+='Historical notices of financial problems\n';
        if(r.SME_Strategy_and_consistency__c == null) missingFieldsSME+='Strategy and consistency\n';
        if(r.SME_Audit_aptness_transparancy_of_FS__c == null) missingFieldsSME+='Audit aptness & transparancy of FS\'s\n';
        //Access to Credit
        if(r.SME_Financial_Flexibility_Refinance_Risk__c == null ||
           r.SME_Limitslevel_of_committed_headroom__c == null) missingFieldsSME+='\nAccess to Credit\n'.toUpperCase();
        if(r.SME_Financial_Flexibility_Refinance_Risk__c == null) missingFieldsSME+='Financial Flexibility and Refinance Risk\n';
        if(r.SME_Limitslevel_of_committed_headroom__c == null) missingFieldsSME+='Limits and level of committed headroom\n';
        //Profitability/Profits
        if(r.SME_Stability_and_recurrence_of_profits__c == null ||
           r.SME_Forecast_for_next_12_months__c == null ||
           r.SME_Cost_Structure__c == null) missingFieldsSME+= '\nProfitability/Profits\n'.toUpperCase();
        if(r.SME_Stability_and_recurrence_of_profits__c == null) missingFieldsSME+='Stability and recurrence of profits\n';
        if(r.SME_Forecast_for_next_12_months__c == null) missingFieldsSME+='Forecast for next 12 months\n';
        if(r.SME_Cost_Structure__c == null) missingFieldsSME+='Cost Structure\n';
        //Generation of Resources
        if(r.SME_Capacity_of_CF_to_service_debt__c == null ||
           r.SME_Capacity_to_self_financeinvestments__c == null ||
           r.SME_Capacity_to_finance_WC_Operating_CF__c == null) missingFieldsSME+= '\nGeneration of Resources\n'.toUpperCase();
        if(r.SME_Capacity_of_CF_to_service_debt__c == null) missingFieldsSME+='Capacity of cash flow to service debt\n';
        if(r.SME_Capacity_to_self_financeinvestments__c == null) missingFieldsSME+='Capacity to self-finance investments\n';
        if(r.SME_Capacity_to_finance_WC_Operating_CF__c == null) missingFieldsSME+='Capacity to finance WC from Operating CF\n';
        //Solvency
        if(r.SME_Noncore_tangible_asset_disposability__c == null ||
           r.SME_Quality_of_working_capital__c == null ||
           r.SME_Unrealised_cap_gains_losses_capacity__c == null ||
           r.SME_Off_BS_liabilities_and_commitments__c == null) missingFieldsSME+= '\nSolvency\n'.toUpperCase();
        if(r.SME_Noncore_tangible_asset_disposability__c == null) missingFieldsSME+='Non-core tangible asset disposability\n';
        if(r.SME_Quality_of_working_capital__c == null) missingFieldsSME+='Quality of working capital\n';
        if(r.SME_Unrealised_cap_gains_losses_capacity__c == null) missingFieldsSME+='Unrealised capital gains/losses capacity\n';
        if(r.SME_Off_BS_liabilities_and_commitments__c == null) missingFieldsSME+='Off BS liabilities and commitments\n';
        return missingFieldsSME; 
    }

}