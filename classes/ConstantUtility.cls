/************************************************
Name:ConstantUtility
Descritption:Common utility class to define constants used accross Apex classes
Created By: Poonam Yadav 
Created Date: 26/08/2019
**************************************************/
public  class  ConstantUtility {
 
   public static final String OVERDRAFT='Overdraft';
   public static final String CC_OVERDRAFT='Cross Currency Overdraft';
   public static final String INVOICE_DISCOUNTING='Invoice Discounting';
   public static final String OPEN_ITEM_LEDGER='Open Item Ledger';
   public static final String INVENTORY='Inventory';
   public static final String PLANT_AND_MACHINERY_LOAN='Plant & Machinery Loan';
   public static final String BUSINESS_CREDIT_CARD='Business Credit Card';
   public static final String SYNDICATIONS='Syndications';
   public static final String WORKING_CAPITAL_BORROWER='Working capital for the Borrower';
   public static final String POOLING_SWEEPING='Pooling and Sweeping';
   public static final String LIQUIDITY_MANAGEMENT='Working capital and liquidity management for the Borrower';
   public static final String HEDGING_PRODUCTS='Interest Rate Hedging Products';
   public static final String RISK_HEDGING='Interest rate risk hedging';
   public static final String FX_PFE='FX-PFE';
   public static final String DD_ORIGINATIONS='Direct Debit Originations';
   public static final String DD_CLEARING_SETTLEMENT='Direct debit clearing and settlement';
   public static final String FX_DSL='FX-DSL';
   public static final String DAILY_SETTLEMENT_LIMITS='Daily Settlement Limits';// This picklist value is from the Product field.
   public static final String PB_DAILY_SETTLEMENT_LIMITS='Daily settlement limit';// This picklist is from Purpose of Borrowing field.
   public static final String BACS_CREDIT_PAYMENT='BACS Credit Payments';
   public static final String FOREIGN_EXCHANGE ='Foreign exchange risk hedging';
   public static final String CP_CLEARING_SETTLEMENT ='Credit payments clearing and settlement';
   public static final String SYSTEM_DECISION_Reject ='Reject';
   public static final String LTV_DUPLICATE='Duplicate';
   public static final String LTV_ERROR='Error';
   public static final String LTV_BORROWER='Borrower';
   public static final String LTV_CO_BORROWER='Co-Borrower';
   public static final String LTV_OPEN = 'open';
   public static final String LTV_HOLD = 'Hold';
   public static final String LTV_INREVIEW = 'In Review';
   public static final String LTV_DELETE_LOAN='DeleteLoan';
   public static final String LTV_DELETE_COLLATERAL='DeleteCollateral';
   public static final String LTV_DELETE_RELATIONSHIP='DeleteRelationship';
   public static final string LTV_RESIDENTIAL_PROPERTY = 'Residential Property';
   public static final string LTV_SOCIAL_HOUSING = 'Social Housing';
   public static final string LTV_COMMERCIAL_PROPERTY  = 'Commercial Property';  
   public static final string LTV_LARGE_PROPERTY_PORTFOLIO = 'Large Property Portfolio'; 
   public static final string LTV_RANKING = '1st'; 
   public static final boolean LTV_FURTHER_ADVANCE_WITH_NO_DOP = False;  
   public static final string LTV_DIRECT_THIRD_PARTY_CHARGE = 'Direct';
   public static final String PCSM_APPLICATION_STAGE ='Application';
   public static final String PCSM_FINAL_REVIEW_STAGE ='Final Review';
   public static final String PCSM_REQUIRES_MANUAL_APPROVAL ='Yes';
   public static final string PCSM_PRODUCT_PACKAGE = 'LLC_BI__Product_Package__c';
   public static final string PCSM_LOAN = 'LLC_BI__Loan__c'; 
   public static final string LTV_RISK_GROUP = 'Risk_Group__c'; 
   public static final string LTV_LENDABLE_VALUE_WDV = 'Lendable_Value_WDV__c'; 
   public static final string LTV_SANTANDER_VALUE = 'Santander_Value__c'; 
   public static final string LTV_LOAN = 'LLC_BI__Loan__r';
   public static final string LTV_PRODUCT_PACKAGE = 'LLC_BI__Product_Package__c';   
   public static final string LTV_Collateral = 'LLC_BI__Collateral__r'; 
   public static final string TRIGGER_LOAN_STAGE_COMPLETE = 'Complete';
   public static final string TRIGGER_LOAN_STAGE_LOST = 'Lost';
   public static final string idFieldAPI = 'id';
   

}