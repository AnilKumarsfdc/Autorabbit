public class NamedCredentialService {
    public static NamedCredential getDueDilNamedCredential(String namedCredentialName){
        return NamedCredentialSelectorWS.getNamedCredentialByName(namedCredentialName);
    }
}