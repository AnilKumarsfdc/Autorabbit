/* EcmOffloadCriteriaFlow
* 
 * The following class is used to register the flow criteria for 
 * the ECM Offloader / Document Transfer API.
* 
 */

global with sharing class EcmOffloadCriteriaFlow Extends nDOC.AEcmCriteriaFlow{
  
    global override Flow.Interview create(Map<String,Object> inputs) {
        return new Flow.Interview.EcmOffloadCriteriaFlow(inputs);
    }
  
    global static void register() {
        nDOC.AEcmCriteriaFlow.registerFlowClass(EcmOffloadCriteriaFlow.class);
    }
    
    global static void deregister() {
        nFORCE.BeanRegistry.getInstance().deregisterBean('EcmOffloadCriteriaFlow:EcmOffloadFlow');
    }

    global static void scheduleNow() {
        nDOC.BatchECMOffloaderScheduler b = new nDOC.BatchECMOffloaderScheduler();
                                         b.schedule();
    }
    
}