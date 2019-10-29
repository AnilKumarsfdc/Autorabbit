/*
IMPORTANT CODE PLEASE DONT DELETE

5c3b79ae-5ce0-e911-9c2b-30e17155e337,Personal Guarantee_20190926_125349.docx,f913e79b-84db-e911-9c2b-30e17155e337,Test_20190920_085706.docx



*/


public class SpringCMtoDocManFileOffloader {
        
       @future(callout=true)
        public static  void  attachmentLoader(set<Id> newDocumentDetailIdSet,set<Id> newLoanIdSet){
            
            try{
            
            List<blob> data = new List<blob>();
            List<ContentVersion> cvList =new  List<ContentVersion>();
            List<LLC_BI__LLC_LoanDocument__c> LLCLoanDocList =new List<LLC_BI__LLC_LoanDocument__c>();
            List<LLC_BI__LLC_LoanDocument__c> LLCLoanDocUpdateList =new List<LLC_BI__LLC_LoanDocument__c>();
            Set<ID> ContentVersionID =new Set<ID>();
            Set<Id> loanIDSet = new Set<Id>();          
            nDOC.DocmanService dms = new nDOC.DocmanService();
            Map<id,id> ContentLoanDocIDMap = new Map<id,id>();
            Integer ContentVersionFlag =0;
         
        
        
        List<SpringCMTempMapToPlaceHolder__mdt> PlaceHolderMDT = [select id,DeveloperName,PlaceHolderName__c,MasterLabel from SpringCMTempMapToPlaceHolder__mdt];
 System.debug('*************** PlaceHolderMDT: ' + PlaceHolderMDT); 

       if(!newLoanIdSet.isEmpty())
             LLCLoanDocList = [SELECT Id, Name FROM LLC_BI__LLC_LoanDocument__c WHERE LLC_BI__Loan__c in : newLoanIdSet] ;
                  
     
        
            MAP<ID,SpringCM_Document_Detail__c> mapDocumentDetail = new MAP<Id,SpringCM_Document_Detail__c>([Select ID,Document_Id__c,Document_Name__c,IsUploaded__c,Loan__c,ParentID__c from SpringCM_Document_Detail__c where id in :  newDocumentDetailIdSet]);
        
          // System.debug('*************** values: ' + mapDocumentDetail.values()); 
        for(SpringCM_Document_Detail__c mapvar : mapDocumentDetail.values()) {
                System.debug('*************** Current Document_Id__c: ' + mapvar.Document_Id__c); 
                loanIDSet.add(mapvar.Loan__c);
                
            // iterating   LLC_BI__LLC_LoanDocument__c    LLC LoanDocument 
          for(LLC_BI__LLC_LoanDocument__c LLCLoanDocVar : LLCLoanDocList){
            
              System.debug('DDDDDDDD varMDT: ' + LLCLoanDocVar.Name +'DDDDDDDD mapvar: ' + mapvar.Document_Name__c); 
                    if(LLCLoanDocVar.Name.containsOnly(mapvar.Document_Name__c)){                       
                        System.debug('BBBBBBBBBBB varMDT: ' + LLCLoanDocVar.Name +'CCCCCCCCCCCCCCCCC mapvar: ' + mapvar.Document_Name__c); 
                        LLC_BI__LLC_LoanDocument__c llcvar = new  LLC_BI__LLC_LoanDocument__c();
                        llcvar.LookupKey__c = mapvar.Document_Id__c;
                        llcvar.id = LLCLoanDocVar.id;
                        llcvar.LLC_BI__reviewStatus__c = 'In-File';
                        LLCLoanDocUpdateList.add(llcvar);
                        
                        break;
                    }
            }           
            
            //Callout for Blob     
            GeWS_SpringCMService_WS api = new GeWS_SpringCMService_WS();
            blob singleData ;
            singleData = api.getSpringCMDocumentById(mapvar.Document_Id__c); 
            data.add(singleData);
           if(singleData != null) {
            // Create Content Version 
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';           
            cv.VersionData = singleData;
            cv.LookupKey__c = mapvar.Document_Id__c;  
            cv.Title = mapvar.Document_Name__c; //+'.docx';
            cv.PathOnClient =  cv.Title;  
            cvList.add(cv);   
            ContentVersionFlag =1;
           }            
    
        }
        system.debug('Blob Data==========='+data);   
        if(ContentVersionFlag ==1)
            insert cvList;
        update  LLCLoanDocUpdateList;
        
        system.debug('Blob Data==========='+data);    
        system.debug(' ContentVersion ==========='+cvList);     
        system.debug(' LLCLoanDocUpdateList ==========='+LLCLoanDocUpdateList);
            if(!cvList.isEmpty())
            {
                // Fetch all ContentVersion IDs
                for(ContentVersion cvVar: cvList){
                        ContentVersionID.add(cvVar.id);
                }               
        // Call Content Version : LookupKey__c , Placeholder Mapping  LookupKey__c                 
                   for(ContentVersion conVerId : [SELECT Id, ContentDocumentId,LookupKey__c FROM ContentVersion WHERE Id in : ContentVersionID]){
                        for(LLC_BI__LLC_LoanDocument__c LLCLoanDocVar : LLCLoanDocUpdateList){
                             system.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqq conVerId.id---'+conVerId.id+'qqqqqqqqqqqq LLCLoanDocVar.LookupKey__c'+LLCLoanDocVar.LookupKey__c);
                             if( conVerId.LookupKey__c == LLCLoanDocVar.LookupKey__c ){                     
                                // dms.linkContentWithPlaceholder(conVerId.id, LLCLoanDocVar.id);
                                ContentLoanDocIDMap.put( conVerId.id,LLCLoanDocVar.id);
                                 break;
                             }
                        }
                   }                   
                   system.debug('___ContentLoanDocIDMap---'+ContentLoanDocIDMap);
                   
                   for (Id key : ContentLoanDocIDMap.keySet()) {
                       //ContentLoanDocIDMap.get(key);
                       system.debug('++++++++ key ===== '+key+'ContentLoanDocIDMap.get(key)---'+ContentLoanDocIDMap.get(key));
                       dms.linkContentWithPlaceholder(key, ContentLoanDocIDMap.get(key));
                       
                   }
                }
            } catch (Exception e) {
              system.debug('___Exception'+e);
        }
        
        }
    }