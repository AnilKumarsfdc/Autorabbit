/* --------------------------------------------------------------------------------------------------
     Name:            LookupLightningController.cls 
     Description:     Lighting apex controller for the custom advanced lookup lightning component
	 Test class:      LookupLightningControllerTest.cls 
    ------------------------------------------------------------------------------------------------ */
public class LookupLightningController {
    public static final Integer DISPLAY_LOOKUP_LIMIT = 5;
        
	/** 
	 * @description : Retrieves list of objects, with name matching search Keywords for Lookup field.
	 * if Search Keyword is empty, retrieves, the most recent items.
	 **/
    @AuraEnabled
    public static List<sObject> fetchLookupValues(String objectApiName, String searchKeyword) { 
        String fieldsToFetch = 'Id, Name';
        if (objectApiName == 'User' || objectApiName == 'Contact') {
            fieldsToFetch += ', Email';
        }
        
        List<sObject> returnList = null;
        if (searchKeyword != null && searchKeyword.length() >= 2) {
            returnList = serchElementsByKeyword(objectApiName, fieldsToFetch, searchKeyword);
        } else {
            returnList = getMostRecentElements(objectApiName, fieldsToFetch, searchKeyword);
        }
        return returnList;
    }
    
	/** 
	 * @description : Retrieves list of the most recent items.
	 **/
    private static List<sObject> getMostRecentElements(String objectApiName, String fieldsToFetch, String searchKeyword) {
        String sQuery =  'SELECT ' + fieldsToFetch +' FROM ' + objectApiName + ' ';
        
        if (searchKeyword != null && searchKeyword != '') {
	        String searchKey = searchKeyword + '%';
            sQuery += 'WHERE Name LIKE :searchKey ';
        }         
        
        sQuery += 'ORDER BY LastViewedDate DESC ' + 
             	  'LIMIT :DISPLAY_LOOKUP_LIMIT';
        return Database.query(sQuery);
    }
    
	/** 
	 * @description : Use standard salesforce search to find all the items for a specific object, which match search keyword
	 **/
    private static List<sObject> serchElementsByKeyword(String objectApiName, String fieldsToFetch, String searchKeyword) {
        String soslQuery = 'FIND :searchKeyword IN NAME FIELDS RETURNING ' +
  							objectApiName + ' (' + fieldsToFetch + ')' + 
  							'LIMIT :DISPLAY_LOOKUP_LIMIT';
        
        List<List<sObject>> resultList = Search.query(soslQuery);
        return resultList.get(0);
    }
}