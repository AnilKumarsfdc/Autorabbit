public with sharing class NamedCredentialSelectorWS {
    public static NamedCredential getNamedCredentialByName(String namedCredentialName){
        List<NamedCredential> dueDilNamedCredential = [SELECT DeveloperName,Endpoint,Id,MasterLabel,PrincipalType,AuthProvider.ConsumerKey,AuthProvider.ConsumerSecret FROM NamedCredential WHERE DeveloperName=:namedCredentialName];
		return dueDilNamedCredential[0];
    }
}