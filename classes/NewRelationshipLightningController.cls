public class NewRelationshipLightningController {
    
    @AuraEnabled
    public static List<String> getRelationshipType(){
        Set<String> contrSet = new Set<String>();
        List<String> contrList = new List<String>();
        
        for (Relationship_Metadata__mdt rel : [Select Relationship_Type__c from Relationship_Metadata__mdt]) {
            contrSet.add(rel.Relationship_Type__c);
        }
        for(String str : contrSet )
        {
            contrList.add(str);
        }
        
        return contrList;
    }
    
    @AuraEnabled
    public static List<String> getRelationshipName(string contrfieldValue){
        List<String> options = new List<String>();
        for (Relationship_Metadata__mdt rel : [Select Relationship_Name__c from Relationship_Metadata__mdt where Relationship_Type__c = :contrfieldValue]) 
        {
            options.add(rel.Relationship_Name__c);
        }
        
        return options;
    } 
    
    @AuraEnabled
    public static void insertRelationship(string relationship){
        system.debug('Inside Save method'+ relationship);
        List<Relationship__c> records = null;
     	records = (List<Relationship__c>) JSON.deserialize(relationship, 
                                List<Relationship__c>.class);
        system.debug('@@@@records'+records);

        insert records;
    }
}