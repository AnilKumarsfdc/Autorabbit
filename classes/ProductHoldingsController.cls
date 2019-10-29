/* --------------------------------------------------------------------------------------------------
Name:            ProductHoldingsController.cls 
Description:     Aura controller of Lightning component which represents user-friendly interface
				 of product holdings sorted by product family
Test class:      ProductHoldingsControllerTest.cls 
Date             Version     Author              Summary of Changes 
-----------      -------     -----------------   -------------------------------------------
09-May-2018      0.1         Vijay Sonawane      Prototype for product holding summary on company
---------------------------------------------------------------------------------------------------------- */
public with sharing class ProductHoldingsController {
	private final static String TOTAL_COUNT_KEY = 'totalCount';
	private final static String BUDGET_KEY = 'budget';
	private final static String ACTIVE_COUNT_KEY = 'activeCount';
	private final static String TRANSACTIONS_KEY = 'totalTransactions';
	private final static String INCOME_KEY = 'totalIncome';
	
    /**
    * @description Get the list of product holding summary data.
    * @returns ProductHoldingSummaryWrapper 
    **/
    @AuraEnabled
    public static ProductHoldingSummaryWrapper getProductHoldingSummary(String accountId) {
        
        ProductHoldingSummaryWrapper prodSummaryWrapper = new ProductHoldingSummaryWrapper();      
        try {           
    		Map<String, ProductHoldingSummary> totalProductSummary = getTotalProductFamilyInfo(accountId);
    		String aggregateKey = null;
    	 
        	for (AggregateResult ar : [SELECT RecordTypeId, Product_Family__c, SUM(Outstanding_Balance__c) budget, COUNT(Id) activeCount,
        								SUM(Transactions_Previous_Month__c) totalTransactions, SUM(Total_Income__c) totalIncome 
                                        FROM Holding__c
                                        WHERE Company__c = :accountId
                                        AND Status__c = :GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS
                                        AND Product_Family__c != NULL
                                        GROUP BY RecordTypeId, Product_Family__c 
                                        LIMIT :GlobalConstants.MAX_QUERY_LIMIT])  {
                                        	                                                    
                aggregateKey = getAggregateResultKey(ar);
                if (totalProductSummary.containsKey(aggregateKey)) {
                	totalProductSummary.get(aggregateKey).setActiveHoldingsAggregate(ar);
                }
        	}
        	
        	for (ProductHoldingSummary holdingSummary : totalProductSummary.values()) {
        		prodSummaryWrapper.addSummaryWrapper(holdingSummary);
        	}
        } catch(Exception e) {
            throw e;
        }
        
        return prodSummaryWrapper;
    }    
    
    /**
    * @description Get map of ProductHoldingSummary which contains information only about total holdings count
    * As this is preparation function it contains is only total, and all active data will be retrieved in different method.
    **/
    private static Map<String, ProductHoldingSummary> getTotalProductFamilyInfo(String accountId) {
    	Map<String, ProductHoldingSummary> resultMap = new Map<String, ProductHoldingSummary>();
 		Map<Id,RecordType> recordTypesMap = new Map<Id,RecordType>([
 											SELECT Id, Name FROM RecordType 
                                            WHERE sObjectType = :GlobalConstants.PRODUCT_HODINGS_SOBJECT 
                                            LIMIT :GlobalConstants.MAX_QUERY_LIMIT
                                          ]);
        String recordTypeId = null;
		
        for (AggregateResult ar : [SELECT RecordTypeId, Product_Family__c, COUNT(Id) totalCount
                                            FROM Holding__c
                                            WHERE Company__c = :accountId
                                            AND Product_Family__c != NULL
                                            GROUP BY RecordTypeId, Product_Family__c 
                                            LIMIT :GlobalConstants.MAX_QUERY_LIMIT])  {                                                
                recordTypeId = String.valueOf(ar.get(GlobalConstants.RECORD_TYPE_ID));
                resultMap.put(
                	getAggregateResultKey(ar),
                	new ProductHoldingSummary(
                		recordTypeId,
                		recordTypesMap.get(recordTypeId).Name,
                		String.valueOf(ar.get(GlobalConstants.PRODUCT_FAMILY)),
                		Integer.valueOf(ar.get(TOTAL_COUNT_KEY))
                	)
                );
		}
    	
    	return resultMap;
    }
    
    /**
    * @description Get groupping key of Aggregate result, which consists from Record Type Id and Product Family
    * @returns String 
    **/
    private static String getAggregateResultKey(AggregateResult aggregate) {
    	return String.valueOf(aggregate.get(GlobalConstants.RECORD_TYPE_ID)) + '_' +
    		   String.valueOf(aggregate.get(GlobalConstants.PRODUCT_FAMILY));
    }
        
   /**
    * @description: Gets the list of product holding details data in wrapper.
    * @returns ProductDetailPagerWrapper 
    **/
    @AuraEnabled
    public static ProductDetailPagerWrapper fetchProductHoldingsDetails(String accountId, String productFamily, Integer pgNumber, String recordType, Integer recordsToDisplay) {
        try {     
            Integer pageSize = Integer.valueOf(recordsToDisplay);
            Integer pageNumber = Integer.valueOf(pgNumber);
            Integer offset = (pageNumber - 1) * pageSize;        
            // create a instance of wrapper class.
            ProductDetailPagerWrapper obj =  new ProductDetailPagerWrapper();
            // set the pageSize,Page(Number), total records and products List(using OFFSET)   
            obj.pageSize = pageSize;
            obj.page = pageNumber;        
            obj.productFamily = productFamily;
            obj.products = [SELECT Id, Name, Budget__c, Interest_Rate__c, Product_Family__c, Status_Description__c, Term__c,Open_Date__c,
                           	Maturity_Date__c,Transactions_Previous_Month__c,CurrencyIsoCode, Account_Number__c,Competitor_Name__c,Outstanding_Balance__c
                            FROM Holding__c 
                            WHERE Company__c =: accountId 
                            AND Product_Family__c =: productFamily 
                            AND RecordTypeId = : recordType
                            LIMIT :pageSize 
                            OFFSET :offset];
            obj.total = [SELECT COUNT()
                         FROM Holding__c 
                         WHERE Company__c =: accountId 
                         AND Product_Family__c =: productFamily
                         AND RecordTypeId = : recordType];
            return obj;
        }catch(Exception e) {
            throw e;
        }    
    }
    
    /**
    * @description:Product Holdings Summary wrapper class with @AuraEnabled Properties.
    *  
    **/
    public with sharing class ProductHoldingSummary{
    	@AuraEnabled public String recordTypeId {get; set;}
        @AuraEnabled public String recordTypeName {get;set;}
        @AuraEnabled public String productFamily {get;set;}
        @AuraEnabled public Decimal summaryBudget {get;set;}
        @AuraEnabled public Integer numberOfAccounts {get;set;}  
        @AuraEnabled public Integer numberOfActiveAccounts {get;set;}
        @AuraEnabled public Integer numberOfTransactions {get;set;}
        @AuraEnabled public Decimal totalIncome {get;set;}
        
        /**
         *@description: constructor which gets number of Active accounts
         * */
        public ProductHoldingSummary(String recordTypeId, String recordTypeName,String productFamily,Integer numberOfAccounts){
            this.recordTypeId = recordTypeId;
            this.recordTypeName = recordTypeName;
            this.productFamily = productFamily;
            this.numberOfAccounts = numberOfAccounts;
            this.summaryBudget = 0;
            this.numberOfActiveAccounts = 0;
            this.numberOfTransactions = 0;
            this.totalIncome = 0;
        }
        
        /**
        * @description Specify aggregate result about active accounts
        **/
        public void setActiveHoldingsAggregate(AggregateResult activeAggregate) { 
        	this.summaryBudget = (Decimal) activeAggregate.get(BUDGET_KEY);
        	this.numberOfActiveAccounts = Integer.valueOf(activeAggregate.get(ACTIVE_COUNT_KEY));
        	this.numberOfTransactions = Integer.valueOf(activeAggregate.get(TRANSACTIONS_KEY));
        	this.totalIncome = (Decimal) activeAggregate.get(INCOME_KEY);
        }
    }
    /**
    * @description:Product Holdings Summary wrapper class with @AuraEnabled Properties.
    *  
    **/ 
    public with sharing class ProductHoldingSummaryWrapper{
        @AuraEnabled public Map<String,List<ProductHoldingSummary>> mapSummary {get;set;}
        @AuraEnabled public Boolean canCreateCompetitorHolding {get; set;}
        
        /*
        * @description Public constructor
        */
        public ProductHoldingSummaryWrapper(){
            mapSummary = new Map<String,List<ProductHoldingSummary>>(); 
            canCreateCompetitorHolding = Holding__c.sObjectType.getDescribe().isCreateable();           
        } 
        
        /*
        * @description Add ProductHoldingSummary to the total wrapper method
        */
        public void addSummaryWrapper(ProductHoldingSummary holdingSummary) {
        	String recordTypeName = holdingSummary.recordTypeName;
        	if (mapSummary.containsKey(recordTypeName)) {
        		mapSummary.get(recordTypeName).add(holdingSummary);
        	} else {
        		mapSummary.put(recordTypeName, new List<ProductHoldingSummary>{holdingSummary});
        	}
        }
    }
    /**
    * @description:Product Holdings Details wrapper class with @AuraEnabled Properties.
    *  
    **/  
    public with sharing class ProductDetailPagerWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public String productFamily {get;set;}
        @AuraEnabled public List<Holding__c> products {get;set;}
        /**
         * Description: constructor
         * */
        public ProductDetailPagerWrapper(){
            products = new List<Holding__c>();
            total = 0;
        }
    }
}