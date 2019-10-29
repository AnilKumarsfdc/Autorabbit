/************************************************
Name:LoanTrigger1HandlerTest
Descritption: This is the test class for "LoanTrigger1Handler" class.
Created By: Poonam Yadav 
Created Date: 26/08/2019
**************************************************/
@isTest(SeeAllData = false)
private class LoanTrigger1HandlerTest {
    
    @TestSetup static void setup(){
        // Create Opportunity 
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Trade Finance').getRecordTypeId();
        Opportunity newOpp = TestDataFactoryUtility.createOpportunity(recordTypeId,'ClassTestOpportunity','0019E00000yS9kKQAS',system.today(),'New Opportunity');
        newOpp.Confidential_Deal__c = true;
        newOpp.LLC_BI__Product_Line__c = 'SB';
        newOpp.LLC_BI__Product_Type__c = 'Trade Finance';
        newOpp.LLC_BI__Product__c = 'Trade Loans';
        newOpp.Structured_Finance__c = 'SF Sponsors';
        update newOpp;  
        
        // Create Opportunity Product
        Opportunity_Product__c newOppPro = TestDataFactoryUtility.createOpportunityProduct('Trade Finance Test',newOpp.Id, '0129E000000bCuvQAE');
        newOppPro.Facility_Amount__c = 1000;
        newOppPro.TP_Rate__c = 2;
        newOppPro.Gross_Margin__c = 2;
        newOppPro.Term_In_Months__c = 60;
        update newOppPro;
        
        // Create Opportunity Team
        OpportunityTeamMember newOppTeam = TestDataFactoryUtility.createOpportunityTeam(newOpp.Id, 'FX Partner','0059E00000728WSQAY');
    }
    @isTest static void updateField1Test(){
                
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='ClassTestOpportunity' LIMIT 1];
        LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(Name = 'TestPTC');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        PageReference pageRef = Page.LLC_BI__ComplexLifeCycleConverter;     // VF Page
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        insert newLoan;
              
        opp.LLC_BI__Loan__c = newLoan.id;
        update opp;
        
        newLoan.LLC_BI__Stage__c = 'Application';
        newLoan.LLC_BI__CloseDate__c = system.today() + 10;
        newLoan.PolicyAcknowledgement__c = true;
        update newLoan;
        
        opp.Pricing_Approval_Route__c = 'Core Asset/RoREG';
        opp.Pricing_Expiry_Date__c = system.today() + 10;
        update opp;
        
        newLoan.LLC_BI__Stage__c = 'Final Review';
        Test.startTest();        
        Update newLoan;
        Test.stopTest();
        //System.assertEquals(system.Today(),newLoan.Passed_to_Credit__c); 
    }
    @isTest static void updateField2Test(){
                
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='ClassTestOpportunity' LIMIT 1];
        LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(Name = 'TestCAD');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        PageReference pageRef = Page.LLC_BI__ComplexLifeCycleConverter;     // VF Page
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        insert newLoan;
              
        opp.LLC_BI__Loan__c = newLoan.id;
        update opp;
        
        newLoan.LLC_BI__Stage__c = 'Application';
        newLoan.LLC_BI__CloseDate__c = system.today() + 10;
        newLoan.PolicyAcknowledgement__c = true;
        update newLoan;
        
        opp.Pricing_Approval_Route__c = 'Core Asset/RoREG';
        opp.Pricing_Expiry_Date__c = system.today() + 10;
        update opp;
        
        newLoan.LLC_BI__Stage__c = 'Final Review';
        Update newLoan;
        
        newLoan.LLC_BI__Stage__c = 'Credit Sanctioning';
        Update newLoan;
        
        newLoan.LLC_BI__Stage__c = 'Acceptance';
                
        Test.startTest();        
        Update newLoan;
        Test.stopTest();
        //System.assertEquals(system.Today(),newLoan.LLC_BI__Credit_Approval_Date__c); 
    }
   /*@isTest static void updateLoanTeamFromOppTeamTest(){
        
    }*/
    
    @isTest static void updateLoanWithOppProductTest(){
        
        // Create Loan
        LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(Name = 'Test45654');    
         
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='ClassTestOpportunity' LIMIT 1];
        //Opportunity_Product__c oppPro = [SELECT Id,Facility_Amount__c FROM Opportunity_Product__c WHERE Name='Trade Finance Test' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        //myControllerExtension testAccPlan = new myControllerExtension(sc);
        PageReference pageRef = Page.LLC_BI__ComplexLifeCycleConverter;     // VF Page
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        
        //LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(Name = 'ClassTestLoan');
        //system.debug('id found ' + opp.Id);
       // ApexPages.currentPage().getParameters().put('id', opp.Id);
       // Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        insert newLoan;
        Test.StopTest();
        
        //system.debug('New Loan Id - >' + newLoan.Id + 'Name -> ' + newLoan.Name + 'Amount ->' + newLoan.LLC_BI__Amount__c );
        //system.debug('Opp Id - >' + opp.Id );
        //system.debug('Opp Product Id - >' + oppPro.Id + 'Amount -> ' + oppPro.Facility_Amount__c);
        
        //System.assertEquals(oppPro.Facility_Amount__c,newLoan.LLC_BI__Amount__c); 
        //System.assertEquals(newOppPro.Term_In_Months__c,newLoan.LLC_BI__Term_Months__c);
        //System.assertEquals(newOppPro.TP_Rate__c,newLoan.TP_Rate__c);
        //System.assertEquals(newOppPro.Gross_Margin__c,newLoan.LLC_BI__Spread__c);
        
        //System.assertEquals(oppPro.Facility_Amount__c,newLoan.LLC_BI__Amount__c);
        //System.assertEquals(oppPro.Term_In_Months__c,newLoan.LLC_BI__Term_Months__c);
        //System.assertEquals(oppPro.TP_Rate__c,newLoan.TP_Rate__c);
        //System.assertEquals(oppPro.Gross_Margin__c,newLoan.LLC_BI__Spread__c);
        
        
    }
    @isTest static void updateOpportunityTest(){
        Opportunity opp = [SELECT Id,StageName,Appeal_Rights__c,Appeal_Rights_Mandatory__c,Confidential_Deal__c,CloseDate FROM Opportunity WHERE Name='ClassTestOpportunity' LIMIT 1];
        Opportunity_Product__c oppPro = [SELECT Id,Facility_Amount__c,Term_In_Months__c,TP_Rate__c,Gross_Margin__c,nCino_Lending_Amount__c FROM Opportunity_Product__c WHERE Name='Trade Finance Test' LIMIT 1];
        LLC_BI__Loan__c newLoan = new LLC_BI__Loan__c(Name = 'ClassTestLoan');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        PageReference pageRef = Page.LLC_BI__ComplexLifeCycleConverter;  
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        insert newLoan;
        
        opp.LLC_BI__Loan__c = newLoan.id;
        update opp;
        
        newLoan.LLC_BI__Stage__c = 'Application';        
        newLoan.Appeal_Rights__c = True;
        newLoan.Appeal_Rights_Mandatory__c = True;
        newLoan.Confidential_Deal__c = True;
        newLoan.LLC_BI__CloseDate__c = system.today() + 10;
        newLoan.LLC_BI__Amount__c = 12000;
        newLoan.LLC_BI__Term_Months__c= 80;
        newLoan.TP_Rate__c = 5;
        newLoan.LLC_BI__Spread__c = 5;
        newLoan.LLC_BI__Total_Disbursed__c = 5000;
        Test.StartTest();
        update newLoan; 
        Test.StopTest();
        
        /*System.assertEquals('Sighting Paper',opp.StageName); 
        System.assertEquals(newLoan.Appeal_Rights__c,opp.Appeal_Rights__c); 
        System.assertEquals(newLoan.Appeal_Rights_Mandatory__c,opp.Appeal_Rights_Mandatory__c); 
        System.assertEquals(newLoan.Confidential_Deal__c,opp.Confidential_Deal__c); 
        System.assertEquals(newLoan.LLC_BI__CloseDate__c,opp.CloseDate); 
        System.assertEquals(newLoan.LLC_BI__Amount__c,oppPro.Facility_Amount__c); 
        System.assertEquals(newLoan.LLC_BI__Term_Months__c,oppPro.Term_In_Months__c);
        System.assertEquals(newLoan.TP_Rate__c,oppPro.TP_Rate__c);
        System.assertEquals(newLoan.LLC_BI__Spread__c ,oppPro.Gross_Margin__c);
        System.assertEquals(newLoan.LLC_BI__Total_Disbursed__c,oppPro.nCino_Lending_Amount__c);
        
        newLoan.PolicyAcknowledgement__c = true;
        newLoan.LLC_BI__Stage__c = 'Final Review';
        update newLoan;     
        System.assertEquals(newLoan.Passed_to_Credit__c,newOpp.Passed_to_Credit__c); 
        
        newLoan.LLC_BI__Credit_Approval_Date__c = system.today() + 10;      
        update newLoan; 
        System.assertEquals(newLoan.LLC_BI__Credit_Approval_Date__c,newOpp.Credit_Approved__c); 

        newLoan.LLC_BI__Status__c = 'Lost'
        newLoan.LLC_BI__Stage__c = 'Complete';
        newLoan.Lost_Reason__c = 'Created in Error';
        newLoan.LLC_BI__Lost_Detail__c = 'Test Lost Comments';
        update newLoan;
        System.assertEquals(newLoan.Lost_Reason__c,newOpp.Lost_Reason__c); 
        System.assertEquals(newLoan.LLC_BI__Lost_Detail__c,newOpp.Lost_Comments__c);    
		*/
    }
}