@isTest
public with sharing class TestEcmOffloadCriteriaFlowLoan {

    @isTest
    static void ecmOffloadCriteriaFlowLoanImplementsCreate() {
        EcmOffloadCriteriaFlow criteriaFlow = new EcmOffloadCriteriaFlow();
        Map<String,Object> inputs = new Map<String,Object>();
        Test.startTest();
        Flow.Interview result = criteriaFlow.create(inputs);
        EcmOffloadCriteriaFlow.register();
        EcmOffloadCriteriaFlow.deregister();  
        EcmOffloadCriteriaFlow.scheduleNow();        
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}