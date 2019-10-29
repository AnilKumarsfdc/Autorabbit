/* --------------------------------------------------------------------------------------------------
   Name:            NewProductLightningController.cls 
   Description:     Aura controller of Lightning component which represents user-friendly interface
                    of New Opportunity Product creation
   Test class:  NewProductLightningControllerTest.cls 

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   27-Feb-2017          0.1         Iegor Nechyporenko   Final Pre-Demo version
  ------------------------------------------------------------------------------------------------ */
public with sharing class NewProductLightningController {
    private static String RelatedRecordDeveloperName = 'Related_Product';
    
    //Retrieve private infromation about Opportunity based on Opportunity Record
    private static Opportunity getOpportunityRecord(Id OpportunityId){
        return [SELECT Id, Name, RecordTypeId, RecordType.Name FROM Opportunity WHERE Id = :OpportunityId];
    }
    
    //Get List of Products with the same Product Family as in related Opportunity
    @AuraEnabled 
    public static List<Product2> getListOfProducts(Id opportunityId){
        Opportunity opportunityRecord = getOpportunityRecord(opportunityId);
        
        List<Opportunity_Product__c> oppPrimaryProducts = [SELECT Id FROM Opportunity_Product__c 
                                                           WHERE Product__r.Primary__c = true
                                                           AND   Opportunity__c = :opportunityId
                                                           LIMIT 1];
        
        Boolean shouldBePrimary = (oppPrimaryProducts.size() == 0);
        return [SELECT Id, Name, Family 
        		FROM Product2 
        		WHERE Family = :opportunityRecord.RecordType.Name
        		AND Primary__c = :shouldBePrimary
        		AND IsActive = true
               	ORDER BY Name];
    }    
    
    
    //Generate and return Opportunity Product record based on selected Product Id
    @AuraEnabled
    public static Opportunity_Product__c getOpportunityProductRecord(Id opportunityId, Id productId){
        Opportunity opportunityInfo = getOpportunityRecord(opportunityId);
        Product2 productInformation = [SELECT Id, Name, Family, Primary__c FROM Product2 WHERE Id = :productId];
        
        Opportunity_Product__c newOppProduct = new Opportunity_Product__c();
        newOppProduct.Opportunity__c = opportunityInfo.Id;
        newOppProduct.Product__c = productInformation.Id;
        
        RecordType oppProductRecordType;
        if (productInformation.Primary__c){
            oppProductRecordType = [SELECT Id, Name FROM RecordType 
                                    WHERE SobjectType='Opportunity_Product__c' 
                                    AND Name = :productInformation.Family];
        } else {
            oppProductRecordType = [SELECT Id, Name FROM RecordType
                                    WHERE SobjectType='Opportunity_Product__c' 
                                    AND DeveloperName = :RelatedRecordDeveloperName];
        }
        newOppProduct.RecordType = oppProductRecordType;
        newOppProduct.Name = productInformation.Name;
        newOppProduct.RecordTypeId = oppProductRecordType.Id;
        newOppProduct.Estimated_Income__c = null;
        return newOppProduct;
    }
    
    //Retrieve list of all Product Relationships with selected Product
    @AuraEnabled 
    public static List<Product_Relationship__c> getListOfRelatedProducts(Id productId){
        return [SELECT Id, Is_Required__c, Related_Product__c,
                       Related_Product__r.Id, Related_Product__r.Name, Related_Product__r.Family
                       FROM Product_Relationship__c
                       WHERE Primary_Product__c = :productId
                       AND Related_Product__r.IsActive = true];
    } 
    
    //Create Opportunity Product records for selected Primary Product and list of Selected/Required Related Products
    @AuraEnabled
    public static Opportunity_Product__c createOpportunityProducts(String opportunityProductString, String relatedProductsString){
        Opportunity_Product__c opportunityProduct = (Opportunity_Product__c) JSON.deserialize(opportunityProductString, 
                                                                                              Opportunity_Product__c.class);
        Opportunity_Product__c[] relatedProducts = null;
        
        if (relatedProductsString != null && relatedProductsString != 'null' && relatedProductsString != '') {
            relatedProducts = (Opportunity_Product__c[])JSON.deserialize(relatedProductsString, List<Opportunity_Product__c>.class);
        }
        RecordType relatedRecordType = [SELECT Id FROM RecordType
                                        WHERE SobjectType='Opportunity_Product__c' 
                                        AND DeveloperName = :RelatedRecordDeveloperName];
        
        Database.insert(opportunityProduct);
        
        if (relatedProducts != null && relatedProducts.size() > 0) {
            for (Opportunity_Product__c relatedProduct : relatedProducts){
                relatedProduct.RecordTypeId = relatedRecordType.Id;
                relatedProduct.Opportunity__c = opportunityProduct.Opportunity__c;
            }
            
            Database.insert(relatedProducts);
        }
        return opportunityProduct;
    }
}