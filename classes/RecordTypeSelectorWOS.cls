public class RecordTypeSelectorWOS {
    public static Id getProspectRecordTypeId(){
        
        System.debug('record fetched: '+[Select Id from RecordType where sObjectType = 'Account' and DeveloperName = 'Prospect']);
        return [Select Id from RecordType where sObjectType = 'Account' and DeveloperName = 'Prospect'].Id;
    }
}