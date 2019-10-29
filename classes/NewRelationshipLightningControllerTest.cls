@isTest (SeeAllData=false)
public class NewRelationshipLightningControllerTest
{ 
    static testmethod void runPositiveTests()
    {
        String relType='Source';
        Account acc1 = PrepareTestData.getDefaultAccount();
        insert acc1;
        Account acc2 = PrepareTestData.getDefaultAccount();
        insert acc2;
       	Opportunity opp = new Opportunity(Name='testOpp1', AccountId = acc1.Id, StageName ='New Opportunity', CloseDate = System.today());
        insert opp;
        
        Relationship_Metadata__mdt role =  [Select Relationship_Type__c, Relationship_Name__c, Reverse_Role__c from Relationship_Metadata__mdt WHERE Reverse_Role__c != null LIMIT 1];            

        Relationship__c rel= new Relationship__c(
            Relationship_Type__c= role.Relationship_Type__c, 
            Relationship_Name__c= role.Relationship_Name__c, 
            Company__c= acc1.Id, 
            Related_Company__c= acc2.Id
        );
        List<Relationship__c> relList=new list<Relationship__c>{rel};
        String relString= JSON.serialize(relList);
        
        Test.startTest();
        NewRelationshipLightningController.getRelationshipType();
        NewRelationshipLightningController.getRelationshipName(relType);
        NewRelationshipLightningController.insertRelationship(relString);
        Test.stopTest();
    }
}