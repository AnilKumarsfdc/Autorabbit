public with sharing class GeWs_SecuritCredential_DAO{
    private static Map<String, GeWS_Security_Credential__c> secCreds;

    public GeWS_Security_Credential__c getSecurityCredentialByIdentifier(String identifierForCredential) {
        //if Sec Cruds are null
        if(secCreds == null){
            secCreds = new Map<String, GeWS_Security_Credential__c>();
                    List<GeWS_Security_Credential__c> listOfSecurityCreds= [SELECT GeWS_Credential_Identifier__c
                                                                            ,Name
                                                                , GeWS_Credential_Type__c
                                                                , GeWS_User_Agent__c
                                                                , GeWS_API_Key__c
                                                                , GeWS_API_Secret__c
                                                                , GeWS_Authentication_Endpoint__c
                                                                , GeWS_Grant_Type__c
                                                                FROM GeWS_Security_Credential__c 
                                                                LIMIT 2000];
            //Populate the map with the returned Creds
            for(GeWS_Security_Credential__c aCred : listOfSecurityCreds){
                secCreds.put(aCred.GeWS_Credential_Identifier__c,aCred);
            }
        }

        //Get Sec Cred if known
        if(secCreds.containsKey(identifierForCredential)){
            return secCreds.get(identifierForCredential);
        }
        return null;
    }
}