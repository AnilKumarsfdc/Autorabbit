/* --------------------------------------------------------------------------------------------------
   Name:            GlobalConstants.cls 
   Description:     Class containing useful constants overall project

   Date                 Version     Author               Summary of Changes 
   -----------          -------     ------------------   -------------------------------------------
   15-May-2017          0.1         Iegor Nechyporenko   Initial creation
  ------------------------------------------------------------------------------------------------ */
public with sharing class GlobalConstants {
   
    public static final String PROFILE_API = 'API User'; 
    public static final String PROFILE_STANDARD_USER = 'Standard User';
    public static final String PROFILE_SYSTEM_ADMIN = 'System Administrator';
   
    public static final String PROSPECT_RECORD_TYPE = 'Prospect';
    public static final String CUSTOMER_RECORD_TYPE = 'Customer';
	public static final String RTBF_RECORD_TYPE = 'Right to be Forgotten';
	public static final String REFWRIT_RECORD_TYPE = 'Servicing Request';
	public static final String REFWRIT_EMAIL_REPLY_APP = 'Approved';
	public static final String REFWRIT_EMAIL_REPLY_REJ = 'Rejected';
	public static final String REFWRIT_CASE_STATUS_APP	= 'Approved by SGO';
	public static final String REFWRIT_CASE_STATUS_REJ	= 'Rejected by SGO';
    public static final String RTDP_RECORD_TYPE = 'Data Portability';
    public static final String SAR_RECORD_TYPE = 'Subject Access Request';
    public static final String RTBF_CLOSED_UPHELD = 'Closed(Upheld)';
    public static final String RTBF_CLOSED_DECLINED = 'Closed(Declined)';
    public static final String RTDP_CLOSED_CLOSED = 'Closed(Closed)';
	public static final String RTBF_CLOSED_UPHELD_STATUS = 'Closed (Upheld)';   
    public static final String RTBF_CLOSED_DECLINED_STATUS = 'Closed (Declined)';
    public static final String RTDP_CLOSED_CLOSED_STATUS = 'Closed';    
    public static final String ACCOUNT_SECTOR = 'Digital';    
    public static final String ACCOUNT_STATUS_GENERAL_PROSPECT = 'General Prospect';
    public static final String ACCOUNT_SOURCE_DATA_COM = 'Data.com';    
    public static final Integer MAX_QUERY_LIMIT = 10000;   
    public static final Integer SOQL_QUERY_LIMIT = 50000;
	public static final String OPPORTUNITY_VALUE = 'Opportunity';
	public static final String OPPORTUNITY_PRODUCT_VALUE = 'Opportunity Product';	
	public static final String OPP_PRODUCT_FEE_RECORD_TYPE = 'Related Product';
    public static final Integer MIN_JNUMBER = 10000000;
    public static final Integer MAX_JNUMBER = 80000000;
    public static final Integer MIN_TRIGGER_BULK_ITERATION = 400;
    public static final Integer TEST_ITERATION = 10;
    public static final String BDP_TYPE_J = 'J';
    public static final String BDP_TYPE_F = 'F';
    public static final String REPORTING_CONTROLS_FLUSH_BATCH_CLASS = 'ReportingControlsIntegrationFlushBatch';
    public static final Integer REPORTING_CONTROLS_FLUSH_DAYS_SINCE = 8; 
    
    public static final String PRODUCT_HOLDINGS_SANTANDER = 'Santander';
    public static final String PRODUCT_HOLDINGS_COMPETITOR = 'Competitor';  
    public static final String COMPANY_STATUS_ACTIVECUSTOMER = 'Active Customer'; 
    public static final String COMPANY_STATUS_FORMERCUSTOMER = 'Former Customer'; 
    public static final String COMPANY_STATUS_INACTIVECUSTOMER = 'Inactive Customer'; 
    public static final String COMPANY_SUB_STATUS_ACTIVECUSTOMER = 'Maintain'; 
    public static final String COMPANY_SUB_STATUS_FORMERCUSTOMER = 'Due To Price'; 
    
    public static final String ACCOUNT_CUSTOMER = 'Customer';
    public static final String TEST_ACCOUNT_NUMBER = '12345';
    public static final Decimal TEST_BUDGET = 1234;
    public static final String TEST_PRODUCT_FAMILY1 = 'Liabilities';
    public static final String TEST_PRODUCT_FAMILY2 = 'Banking Products';
    public static final String OPPORTUNITY_LENDING = 'Lending';
    public static final Integer DEFAULT_MAX_INT = 1000;
    public final static Integer DEFAULT_BATCH_SIZE = 200;
    @Testvisible public static boolean IGNORE_OPPORTUNITY_TRIGGER = false;
    @Testvisible public static boolean IGNORE_TRADING_SETTING_TRIGGER = false;
   
    public static final String TEST_CUSTOM_SETTING_NAME = 'TestCustomSetting';   
    public static final String TEST_PRODUCT_NAME = 'ProductName';    
    public static final String TEST_TYPE = '123';
    public static final String TEST_SUB_TYPE = '123';
    
    public final static String PRODUCT_HOLDINGS_ACTIVE_STATUS = 'NR';
    public final static String PRODUCT_HOLDINGS_CLOSED_STATUS = 'CA';
    public final static String PRODUCT_HODINGS_SOBJECT = 'Holding__c';
    public final static String RECORD_TYPE_ID = 'RecordTypeId';
    public final static String PRODUCT_FAMILY = 'Product_Family__c';
    public final static String EXPR0 = 'expr0';
    public final static String EXPR1 = 'expr1';    
    
    public final static string DEFAULT_EVENT_STATUS = 'Nominated';
    public final static string TEST_EVENT = 'Test Event';  
	public static final String PERMISSION_SET_NAME = 'Central_Marketing_Team';    
    public static final String AUTHORISE_PERMISSION_NAME = 'Authorise_Marketing_Event_Members';
	@TestVisible
	public static final String AUTHORISED_MEMBER_STATUS = 'Authorised';
	@TestVisible
	public static final String NOT_AUTHORISED_MEMBER_STATUS = 'Not authorised';
	public static final String NO_PERMISSION_TO_AUTHORISE_ERROR_MESSAGE = 
						'You don\'t have permission to Authorise Marketing Event Member. '
					    + 'Please contact Central Marketing Team. ';	
    public final static string TEST_NAME = 'test';
    public final static string EVENT_TYPE = 'Meeting';
    public final static string NEW_OPPORTUNITY_RECORD_TYPE = 'New Opportunity';
    public final static string EMAIL = '@noreply.test.com';
    public final static string TIMEZONE_SID_KEY = 'America/Los_Angeles';
    public final static string EMAIL_ENCODING_KEY = 'UTF-8';
    public final static string LANGUAGE_KEY = 'en_US';
    public final static string MOBILE_PREFIX = '+44';
    public final static Integer MIN_RANGE = 100000000;
    public final static Integer MAX_RANGE = 999999999;
    public final static Integer TEST_NUMBER = 100;
    public final static Integer MIN_RANGE_SMALL = 1;
    public final static Integer MAX_RANGE_SMALL = 10;
    public final static string MEETING_DEFAULT_RECORD_TYPE = 'General Call';
    public final static string SYSTEM_DEFAULT_RECORD_TYPE = 'Master';
    public final static string ADDRESS_NOT_FOUND = 'No Address available';
    
    public final static string INPUT_TYPE_CHECKBOX = 'Checkbox';
    public final static string INPUT_TYPE_TEXT = 'String';   
    public final static string INPUT_TYPE_TEXTAREA = 'TextArea';
    public final static string INPUT_TYPE_RICHTEXT = 'RichText';
    public final static string SOBJECT_FIELD_NAME = 'Name';
    public final static string SOBJECT_FIELD_ID = 'Id';
    public static final String SOJBECT_ACCOUNT = 'Account';
    public static final String SOJBECT_CONTACT = 'Contact';
    public static final String UNLISTED_TYPE = 'UnlistedAttendee';
    public static final String SOJBECT_USER = 'User'; 
    public static final String SUCCESS = 'SUCCESS'; 
    public static final String ERROR = 'ERROR';
    public static final String DATE_FORMAT = 'dd MMM yyyy';
    
    public final static string SOQL_QUERY_SELECT = 'SELECT ';
    public final static string SOQL_QUERY_FROM = ' FROM ';
    public final static string SOQL_QUERY_WHERE = ' WHERE ';
    public final static string SOQL_QUERY_EQUAL = ' = ';   
    public static final String DELIMITER = ':';
    public static final String DELIMITER_COMMA = ', ';
    public static final String DELIMITER_DASH = ' – ';
    public static final String BLANK_SPACE = '';
    public static final String SIC_CODE1 = '123456';
    public static final String SIC_CODE2 = '654321';
    public static final String SECTOR_POLICY = 'Test123';
    public static final String BRAG_STATUS1 = 'Red';
    public static final String BRAG_STATUS2 = 'Green';
    
    public static final String ANNUAL_REVIEW_TASK_REC_TYPE = 'Annual Review Task';
    public static final String ANNUAL_REVIEW_TASK_TYPE = 'Other';
    public static final String ANNUAL_REVIEW_TASK_OPEN = 'Open';
    public static final String ANNUAL_REVIEW_TASK_REJECTED = 'Rejected';
    public static final String ANNUAL_REVIEW_TASK_PRIORITY = 'High';
    public static final String ANNUAL_REVIEW_CRITERIA_YES = 'Yes';
    public static final String ANNUAL_REVIEW_CRITERIA_NO = 'No';
    public static final String ANNUAL_REVIEW_PLAN_IMMEDIATE = 'Immediately';
    public static final String ANNUAL_REVIEW_PLAN_SHORT = 'ShortCriteria';
    public static final String ANNUAL_REVIEW_PLAN_LONG = 'LongCriteria';
    public static final String ANNUAL_REVIEW_PLAN_BOTH = 'BothCriterias';
    
    public static final String ANNUAL_REVIEW = 'Annual_Review__c';
    public static final String ANNUAL_REVIEW_TASK_COMPLETED = 'Completed';
    public static final String TASK_WHATID = 'whatId';
    
}