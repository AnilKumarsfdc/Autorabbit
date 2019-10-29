/* --------------------------------------------------------------------------------------------------
Name:            ProductHoldingsTriggerHandler.cls 
Description:     Handler class for ProductHoldingsTrigger
Test class:      ProductHoldingsTriggerHandlerTest.cls 
------------------------------------------------------------------------------------------------ */
public without sharing class  ProductHoldingsTriggerHandler {
    
    /**
     * @description On before Insert/Update method which runs through the list of product holdings
     **/
    public static void onBeforeUpsert(List<Holding__c> newList){ 
        List<Holding__c> toBeUpdatedList = new List<Holding__c>();       
        Id recordTypeId = Schema.SObjectType.Holding__c.getRecordTypeInfosByName().get(GlobalConstants.PRODUCT_HOLDINGS_SANTANDER).getRecordTypeId();
        try{
            for(Holding__c hldg : newList){
                if(hldg.RecordTypeId == recordTypeId){
                    toBeUpdatedList.add(hldg);
                }
            }
            updateProductHoldings(toBeUpdatedList); 
        }catch(Exception ex){
            throw ex; 
        }
    }    
    /**
     * @description  method updates product holdings for company lookup field, product family and product name
     **/
    public static List<Holding__c> updateProductHoldings(List<Holding__c> prodHoldingList){
        List<Holding__c> holdingListToUpdate =  new List<Holding__c>();
        try{
            Map<String,Product_Holding_Family__c> productFamilyMap = new  Map<String,Product_Holding_Family__c>();
            
            for(Product_Holding_Family__c pfObj : Product_Holding_Family__c.getAll().values()){
                productFamilyMap.put(((pfObj.Type__c).trim()+GlobalConstants.DELIMITER+(pfObj.Sub_Type__c).trim()).toLowerCase(), pfObj );
            }
            
            Map<Id,Id> map_BdpCompany_AccountId = new Map<Id,Id>();
            Set<Id> bdpCompanyIds = new Set<Id>();
            
            for(Holding__c hldg : prodHoldingList){            
                bdpCompanyIds.add(hldg.BDPRecord__c);            
            }
            
            for(BDP_Company__c bcObj :[SELECT Id,Company__c FROM BDP_Company__c WHERE Id IN : bdpCompanyIds LIMIT 50000]){
                map_BdpCompany_AccountId.put(bcObj.Id,bcObj.Company__c);
            }
            
            for(Holding__c hldg : prodHoldingList){
                Product_Holding_Family__c pfObj = new Product_Holding_Family__c();
                if(!String.isBlank(hldg.Type__c) && !String.isBlank(hldg.Sub_Type__c)){               
                   pfObj = productFamilyMap.get(((hldg.Type__c).trim()+GlobalConstants.DELIMITER+(hldg.Sub_Type__c).trim()).toLowerCase());
                }
                if(pfObj != null){
                    hldg.Product_Family__c = pfObj.Product_Family__c;
                    hldg.Name = pfObj.Product_Name__c;
                    hldg.Third_Party_Product__c = pfObj.Is_Third_Party_Product__c;
                }
                if(!String.isBlank(hldg.BDPRecord__c)){
                    hldg.Company__c = map_BdpCompany_AccountId.get(hldg.BDPRecord__c);
                }
                holdingListToUpdate.add(hldg);
            }
        }catch(Exception ex){
            throw ex; 
        }
         return holdingListToUpdate;
    }
    
    /**
     * @description  method to get Product Holding having status Open and Closed
     **/
    public static void onAfterInsert(List<Holding__c> productHoldingList,Map<Id,Holding__c> productHoldingOldMap){
    	Set<String> companyIdsToActivate =  new Set<String>();
    	//Set<String> companyIdToCheckClose = new Set<String>();
    	
    	Id recordTypeId = Schema.SObjectType.Holding__c.getRecordTypeInfosByName().get(GlobalConstants.PRODUCT_HOLDINGS_SANTANDER).getRecordTypeId();
    	
    	try{
    		for(Holding__c HoldingObj:productHoldingList){
    			if(HoldingObj.RecordTypeId == recordTypeId ){
    				
    				if(HoldingObj.Status__c == GlobalConstants.PRODUCT_HOLDINGS_ACTIVE_STATUS){
    					companyIdsToActivate.add(HoldingObj.Company__c);
    				}
    				
    				/*if(productHoldingOldMap!=null && productHoldingOldMap.get(HoldingObj.id).Status__c != GlobalConstants.PRODUCT_HOLDINGS_CLOSED_STATUS){
						if(HoldingObj.Status__c == GlobalConstants.PRODUCT_HOLDINGS_CLOSED_STATUS){
	    					companyIdToCheckClose.add(HoldingObj.Company__c);        									
	    				}
    				}*/
    				
    			}
    		}
    		
    		/*if(companyIdToCheckClose.size()>0){
    			companyIdToCheckClose.removeAll(companyIdsToActivate);
    			updateCompanyStatus(companyIdsToActivate,companyIdToCheckClose);
    		}*/
    		
    		if(companyIdsToActivate.size()>0){
    			//updateCompanyStatus(companyIdsToActivate,companyIdToCheckClose);
    			updateCompanyStatus(companyIdsToActivate,null);
    		}
    		
    		
    	 }Catch(Exception e){ 	 
    	   throw e; 
    	 }
    }
    
     /**
     * @description  method to Update Company status to Active customer if any holding with open status
     * Update Company status to Former Customer if all holdings associated with company is having closed status
     **/
 //   @future
    public static void updateCompanyStatus(Set<String> companyIdsToActivate,Set<String> companyIdToCheckClose){
     	List<Account> accountList = [SELECT Id, Status__c 
                                     FROM Account 
                                     WHERE id IN :companyIdsToActivate 
                                     LIMIT :GlobalConstants.MAX_QUERY_LIMIT];
     	List<Account> accountListToUpdate = new List<Account>();
     	
     	for(Account accObj:accountList){
     		if(accObj.Status__c != GlobalConstants.COMPANY_STATUS_ACTIVECUSTOMER ||
     		   accObj.Status__c != GlobalConstants.COMPANY_STATUS_FORMERCUSTOMER ){
     			accObj.Status__c = GlobalConstants.COMPANY_STATUS_ACTIVECUSTOMER;
     			accObj.Sub_Status__c = GlobalConstants.COMPANY_SUB_STATUS_ACTIVECUSTOMER;
     			accountListToUpdate.add(accObj);
     		}
     	}     	
        if (accountListToUpdate.size() > 0) {
     		Database.update(accountListToUpdate, false);
        }
     	
     	/* TODO: uncomment and update logic once, it will be confirmed with business stakeholders
     	 * if(companyIdToCheckClose.size()>0){
     		
        	List<AggregateResult> results = [SELECT  Company__c FROM Holding__c WHERE  Company__c IN :companyIdToCheckClose AND Status__c IN ('NR', 'PR')AND Company__r.Status__c != 'Former Customer' GROUP BY Company__c]; 
        	
        	List<String> CompanyList = new List<String>();        	
        	for(AggregateResult AggObj:results){
        		 CompanyList.add(String.valueOf(AggObj.get('Company__c')));       	
        	}
        	
        	// Only companies which are having only closed holding
        	companyIdToCheckClose.removeAll(CompanyList);
        	List<Account> updateAccountList = new List<Account>();
        	if(companyIdToCheckClose.size()>0){
        		updateAccountList = [select Status__c from Account where id in :companyIdToCheckClose limit 50000];
        		for(Account accObj:updateAccountList){        			
        			accObj.Status__c = GlobalConstants.COMPANY_STATUS_FORMERCUSTOMER;
        			accObj.Sub_Status__c = GlobalConstants.COMPANY_SUB_STATUS_FORMERCUSTOMER;
        		}
        	}
			update updateAccountList;
     	}*/
     	  
    }
}