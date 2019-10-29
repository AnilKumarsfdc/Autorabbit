/* --------------------------------------------------------------------------------------------------
Name:            EmailMessageHandler.cls 
Description:     EmailMessageHandler Class for intercepting incoming email messages and routing them
to related case along with case status update
--------------------------------------------------------------------------------------------------*/
global with sharing class EmailMessageHandler implements Messaging.InboundEmailHandler {
    private static final String COLON_DELIMETER = ':';
    private static final String BRACKET_DELIMETER = ')';
    private static final String DISCLAIMER_DELIMITER = '*';
    private static final String SPACE_DELIMETER = '[;,\\s\\.]+';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                           Messaging.Inboundenvelope envelope) 
    {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {        
            // Look for case whose caseNumber is matching with caseNumber in email subject
            Integer lastIndex = (email.subject).lastIndexOf(COLON_DELIMETER);
           
            String caseNumber = email.subject.substring(lastIndex+1,(email.subject).length()).trim();
                      
            List<case> caseList= [SELECT Id, Status, RecordType.Name
                                  FROM Case 
                                  WHERE CaseNumber =:caseNumber 
                                  LIMIT 1];
            
            if (caseList.size() > 0) {
                Case caseToProcess = caseList[0];
                Boolean caseShouldBeProcessed = false;
                
                String body= email.plainTextBody.trim();
                Integer firstDotIndex = body.IndexOf(DISCLAIMER_DELIMITER);
                if (firstDotIndex != -1) {
                    body=(email.plainTextBody).substring(0,firstDotIndex);
                }
                
                String[] bodyContent = body.split(SPACE_DELIMETER);
                
                if(! caseList.isEmpty()){        
                    for(String keyword : bodyContent){  
                        if(keyword.equalsIgnoreCase(GlobalConstants.RTBF_CLOSED_UPHELD)){           
                            if(caseToProcess.RecordType.Name == GlobalConstants.RTBF_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.RTBF_CLOSED_UPHELD_STATUS;
                                caseShouldBeProcessed = true;
                            }
                        } else if(keyword.equalsIgnoreCase(GlobalConstants.RTBF_CLOSED_DECLINED)){
                            if(caseToProcess.RecordType.Name == GlobalConstants.RTBF_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.RTBF_CLOSED_DECLINED_STATUS; 
                                caseShouldBeProcessed = true;
                            }
                        } else if(keyword.equalsIgnoreCase(GlobalConstants.RTDP_CLOSED_CLOSED)){
                            if(caseToProcess.RecordType.Name == GlobalConstants.RTDP_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.RTDP_CLOSED_CLOSED_STATUS;
                                caseShouldBeProcessed = true;
                            }
                        } else if(keyword.equalsIgnoreCase(GlobalConstants.RTDP_CLOSED_CLOSED_STATUS)){
                            if(caseToProcess.RecordType.Name == GlobalConstants.SAR_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.RTDP_CLOSED_CLOSED_STATUS;
                                caseShouldBeProcessed = true;
                            }
                        }
                    }                 
                    if (caseShouldBeProcessed) {
                        Database.update(caseToProcess);
                    }
                }
            }
        } catch (Exception ex) {
            ExceptionLogger logger = ExceptionLogger.getInstance();
            logger.logException('EmailMessageHandler', 'handleInboundEmail', ex.getMessage(), ExceptionLogger.ERROR);           
        } 
        return result;
    }
}