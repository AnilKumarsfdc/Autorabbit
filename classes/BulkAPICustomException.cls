public with sharing class BulkAPICustomException extends Exception {
    public class  customExtendedException  extends Exception{}
    public boolean addError(String errMsg, boolean escape){
        String errorMessage = errMsg;
        Boolean escapeFlag = escape;
        return true;
    }
}