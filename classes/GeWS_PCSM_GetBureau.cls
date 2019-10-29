/****************************************************************
* @Author: Alagar Raja
* @Class: GeWS_PCSMautoDecision
* @Description: This prepares the payload rerquire for PCSM and 
                invokes their service to get a decision on 
                loan application
*****************************************************************/
public class GeWS_PCSM_GetBureau {
    
    @AuraEnabled
    public static string generatePDF(String recordId){
        
        System.debug('PDF service called--> ');
        
        //use the relative url of your page
        PageReference pf = new PageReference('/apex/PCSM_BureauPDF?Id='+recordId);
        pf.getParameters().put('id', recordId);
        Blob bdata = pf.getContent();
                        
        //save the PDF in content version 
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient = 'Bureau_v2.pdf';
        conVer.Title = 'Bureau_v2'; 
        conVer.VersionData = bData; //PDF file data
        insert conVer;
        System.debug('COntent version Id:::: '+ conVer.id);
        
        
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
         
        Id placeholderId = [Select Id from LLC_BI__AccountDocument__c where LLC_BI__Account__c =:recordId AND Name='Bureau' Limit 1].Id;
        
        //nCino service to store the document in placeholder
        nDOC.DocmanService dms = new nDOC.DocmanService();
        dms.linkContentWithPlaceholder(conVer.Id, placeholderId);
            
        /*
        //save the PDF as an attachment on the record
        Attachment att =  new Attachment(
                                    Name = 'Bureau.pdf',
                                    Body = data,
                                    ParentId = recordId
                                );
                                
        insert att;*/
        
        
        return conVer.Id;
    }
    
    public static void createJSON(String apiGroup){
        
        Map<String, List<String>> jsonKeyMap = new Map<String, List<String>>();
        
        for(GeWS_PCSM_JSONspec__mdt spec: [Select id,API_group__c,JSON_Header_Name__c,Object_API_Name__c,
                                                  Field_Map_Definition__c from GeWS_PCSM_JSONspec__mdt 
                                                  where API_group__c=:apiGroup] ){
            System.debug( ' #### '+ spec.Field_Map_Definition__c );
            
        }
        
    }
    
}