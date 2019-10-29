@isTest
public class UpdateCollateralPrimaryRecord_Test {
    
    @TestSetup
    private static void InsertCollateralmgmt(){
        //construct a test collateral mgmt record
        LLC_BI__Collateral__c comgmt = new LLC_BI__Collateral__c();
        comgmt.RecordTypeId ='0129E000000bA9PQAU';
        //comgmt.Collateral_Type_Formula__c = '';
        //comgmt.Collateral_Subtype_Formula__c = '';   
        comgmt.LLC_BI__Collateral_Name__c = 'Thomas Shelby';
        comgmt.LLC_BI__Status__c = 'Proposed';
        insert comgmt;
        
        ID comgmtID = comgmt.Id;
        
        //Insert a collateral type-subtype record associate to this ID
       // LLC_BI__Collateral_Type__c cType = new LLC_BI__Collateral_Type__c();
       // cType.Id = comgmt.Id;
        //ctype.LLC_BI__Type__c = ''
       // insert ctype;
       
        
        //create the collateral valution record associate to this ID
        LLC_BI__Collateral_Valuation__c cvaluation = new LLC_BI__Collateral_Valuation__c();
        cvaluation.LLC_BI__Collateral__c = comgmt.Id;
        cvaluation.LLC_BI__Source__c = 'Appraisal';
        cvaluation.LLC_BI__Value__c = 10000;
        cvaluation.LLC_BI__Valuation_Date__c = date.today();
        cvaluation.LLC_BI__Primary__c = False;
        insert cvaluation;
        
         //create the collateral valution record associate to this ID
        LLC_BI__Collateral_Valuation__c cvaluation1 = new LLC_BI__Collateral_Valuation__c();
        cvaluation1.LLC_BI__Collateral__c = comgmt.Id;
        cvaluation1.LLC_BI__Source__c = 'Credit Offer';
        cvaluation1.LLC_BI__Value__c = 11000;
        cvaluation1.LLC_BI__Valuation_Date__c = date.today();
        cvaluation1.LLC_BI__Primary__c = False;
        insert cvaluation1;
        
         //create the collateral valution record associate to this ID
        LLC_BI__Collateral_Valuation__c cvaluation2 = new LLC_BI__Collateral_Valuation__c();
        cvaluation2.LLC_BI__Collateral__c = comgmt.Id;
        cvaluation2.LLC_BI__Source__c = 'Insurance Agent';
        cvaluation2.LLC_BI__Value__c = 12000;
        cvaluation2.LLC_BI__Valuation_Date__c = date.today();
        cvaluation2.LLC_BI__Primary__c = False;
        insert cvaluation2;
    }
    
    @isTest
    private static void UpdateCollateralMgmt_ProcessFired() {
        
    // Load the Collateral Valuation Reord
     LLC_BI__Collateral_Valuation__c cvaluation3 = [SELECT LLC_BI__Primary__c
                             FROM LLC_BI__Collateral_Valuation__c];
        
    // Set the Tracked value to something else:
    cvaluation3.LLC_BI__Active__c = True;
        
    // Save it to the database, and fire the process builder
    test.startTest();
        update cvaluation3;
    test.stopTest();
        
      // Load the tracking record for this Opportunity
     // Tracking_Record__c trackingResult = [SELECT Opportunity_Value__cFROM Tracking_Record__c bWHERE Id = :loadedOpp.Id];
    // Check the tracked value is now 5
   // System.assertEquals(5, trackingResult.Opportunity_Value__c);
}

}