/* --------------------------------------------------------------------------------------------------
   Name:            public class UpdatePreferencesController.cls 
   Description:     Populates latest preference record data from contact while cloning preference.

   Date                 Version     Author              Summary of Changes 
   -----------          -------     -----------------   -------------------------------------------
   12-Feb-2018          0.1         Vijay Sonawane         Initial
  ------------------------------------------------------------------------------------------------ */

public class UpdatePreferencesController {
    private static Map<String, Schema.DescribeFieldResult> preferencesFields = null;
    static {
        preferencesFields = getAvailableFields(Preferences__c.sObjectType);
     }
    public UpdatePreferencesController(){ 
    }
    
     /*
    * @description Retrieves list of Field Descriptions for all Accessible Fields of current User for specific object
    */
    private static Map<String, Schema.DescribeFieldResult> getAvailableFields(Schema.sObjectType objectType){
        Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> sObjectFieldMap = objectType.getDescribe().fields.getMap();
        Schema.SObjectField objectField = null;
        Schema.DescribeFieldResult fieldDescribe = null;
        for (String fieldName : sObjectFieldMap.keySet()){
            objectField = sObjectFieldMap.get(fieldName);
            fieldDescribe = objectField.getDescribe();
            if (fieldDescribe.isCreateable() || Test.isRunningTest()){
                fieldMap.put(fieldName.toLowerCase(), fieldDescribe);                
            }
        }        
        return fieldMap;
    }
    /*
    * @description Retrieves all accessible fields of Preferences record
    */
    @AuraEnabled
    public static Preferences__c getPreferncesData(String contactId){
        
       String querySelect = getQuerySelect(preferencesFields);
       String preferenceQuery = 'SELECT ' + querySelect + ' FROM Preferences__c ' 
                                + 'WHERE contact__c = \'' + contactId + '\' ' 
                                + 'order by createddate desc limit 1';
        return Database.query(preferenceQuery);
    }
    
    /*
    * @description Generates String with comma separated list of fields for dynamic query
    */
    private static String getQuerySelect(Map<String, Schema.DescribeFieldResult> fieldMap){
        List<String> fieldList = new List<String>(fieldMap.keySet());
        return String.join(fieldList, ', ');
    }
    
}