/* --------------------------------------------------------------------------------------------------
Name:            RefWritEmailHandler.cls 
Description:     RefWritEmailHandler Class for intercepting incoming email messages and routing them
to related case along with case status update
--------------------------------------------------------------------------------------------------*/
global with sharing class RefWritEmailHandler implements Messaging.InboundEmailHandler {
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
						if(keyword.equalsIgnoreCase(GlobalConstants.REFWRIT_EMAIL_REPLY_APP)){	
                            if(caseToProcess.RecordType.Name == GlobalConstants.REFWRIT_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.REFWRIT_CASE_STATUS_APP;
                                caseShouldBeProcessed = true;
                                        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId 
													   						      FROM ProcessInstanceWorkitem 
													  							  WHERE ProcessInstance.TargetObjectId = :caseList[0].Id];
										List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
										for(ProcessInstanceWorkitem workItem : workItems){
										  Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
										  req.setWorkitemId(workItem.Id);
										  req.setAction('Approve');
										  req.setComments('Case Approved !');
										  requests.add(req);
										}
										Approval.ProcessResult[] processResults = Approval.process(requests);
                            }
                        } else  if(keyword.equalsIgnoreCase(GlobalConstants.REFWRIT_EMAIL_REPLY_REJ)){
                            if(caseToProcess.RecordType.Name == GlobalConstants.REFWRIT_RECORD_TYPE){
                                caseToProcess.Status = GlobalConstants.REFWRIT_CASE_STATUS_REJ;
                                caseShouldBeProcessed = true;
									    List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId 
													   						      FROM ProcessInstanceWorkitem 
													  							  WHERE ProcessInstance.TargetObjectId = :caseList[0].Id];
										List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
										for(ProcessInstanceWorkitem workItem : workItems){
										  Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
										  req.setWorkitemId(workItem.Id);
										  req.setAction('Reject');
										  req.setComments('Case Rejected !');
										  requests.add(req);
										}
										Approval.ProcessResult[] processResults = Approval.process(requests);
						
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
            logger.logException('RefWritEmailHandler', 'handleInboundEmail', ex.getMessage(), ExceptionLogger.ERROR);           
        } 
        return result;
    }	
}