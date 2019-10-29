public class EntitySearchSettingSelector {
    public static EntitySearchSettings__mdt getEntitySEarchSettingByAPIName(String pEntitySearchSettingAPIName){
        //TODO: perform query here
        EntitySearchSettings__mdt entitySearchSettings =  new EntitySearchSettings__mdt();	    
		try{
					
				if(pEntitySearchSettingAPIName != null){	
				for(EntitySearchSettings__mdt allAPIConnection : [SELECT ID,NamedCredentialsAPIName__c,QueryPageSize__c,SearchProvider__c,SearchRequestTimeout__c,NameParameter__c,PageNumber__c,PageSize__c  FROM EntitySearchSettings__mdt where NamedCredentialsAPIName__c =: pEntitySearchSettingAPIName]){	
				
				entitySearchSettings = allAPIConnection;
				}
			}
			
			system.debug('=======entitySearchSettings==='+entitySearchSettings);
			return entitySearchSettings; 
		}
		catch(Exception e){
			
			system.debug('-----Exception Class name EntitySearchSettingSelector '+e);
            return entitySearchSettings; 
          
		}
    }
}