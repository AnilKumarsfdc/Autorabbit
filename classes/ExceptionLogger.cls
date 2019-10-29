/* --------------------------------------------------------------------------------------------------
   Name:            ExceptionLogger.cls 
   Description:     ExceptionLogger Class is used to log exception in Exception Log Object 
   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   13-August-2018         0.1         Anjali Nigam           Initial
  ------------------------------------------------------------------------------------------------ */ 
public class ExceptionLogger {
    private static ExceptionLogger exceptionLoggerObj;
    public static String INFO = 'INFO';
    public static String DEBUG = 'DEBUG';
    public static String WARNING = 'WARNING';
    public static String ERROR = 'ERROR';
    public static String FATAL = 'FATAL';
    
    /** 
     * @description : Static method that returns the instance of ExceptionLogger Object
     **/
    public static ExceptionLogger getInstance(){
        if(exceptionLoggerObj == null){           
            exceptionLoggerObj = new ExceptionLogger();
        }       
        return exceptionLoggerObj;
    }
    
    /** 
     * @description : This method insert Exception Log based on exception object
     **/
    public void logException(String className, String methodName, Exception e){
    	String message = 'Error: ' + e.getMessage() + '; Stack Trace:' + e.getStackTraceString();
    	logException(className, methodName, message, FATAL);
    }
    
    /** 
     * @description : This method insert Exception Log object whenever exception occurs
     **/
    public  void logException(String className, String methodName, String message, String Priority){
        Config_Settings__c configObj =  Config_Settings__c.getOrgDefaults();
        if(configObj!= null && configObj.Logging_Enabled__c){
            Exception_Log__c exceptionObj = new Exception_Log__c();
            exceptionObj.Class__c = className;
            exceptionObj.Method__c = methodName;
            exceptionObj.Message__c = message;
            exceptionObj.Priority__c = Priority;
            exceptionObj.Running_User__c = UserInfo.getUserName();
            try{
                Database.insert(exceptionObj);
            }catch(Exception e){
                System.debug('Failed to Insert the Exception Logger Record' +'Error: ' + e.getMessage());              
            }
        }
    }

}