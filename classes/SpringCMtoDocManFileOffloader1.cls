public class SpringCMtoDocManFileOffloader1 {
        
       @future(callout=true)
        public static  void  attachmentLoader(set<Id> newDocumentDetailIdSet,set<Id> newLoanIdSet){
            
             List<blob> data = new List<blob>();
             List<LLC_BI__Document_Store__c> docStoreList = new List<LLC_BI__Document_Store__c>();
             List<ContentVersion> cvList =new  List<ContentVersion>();
             List<LLC_BI__Document_Store_Index__c> docStInList =new List<LLC_BI__Document_Store_Index__c>();
             List<LLC_BI__Document_Store_Index__c> docStInListFinal =new List<LLC_BI__Document_Store_Index__c>();
             List<ContentDocumentLink> cdlList =new  List<ContentDocumentLink>();
             List<LLC_BI__LLC_LoanDocument__c> LLCLoanDocList =new List<LLC_BI__LLC_LoanDocument__c>();
             List<LLC_BI__LLC_LoanDocument__c> LLCLoanDocUpdateList =new List<LLC_BI__LLC_LoanDocument__c>();
             List<LLC_BI__LLC_LoanDocument__c> LLCLoanDocWithLookupUpdateList =new List<LLC_BI__LLC_LoanDocument__c>();
             
             List<LLC_BI__LLC_LoanDocument__c> LoanDocumentList =new List<LLC_BI__LLC_LoanDocument__c>();
             List<LLC_BI__LLC_LoanDocument__c> LoanDocumentList2 =new List<LLC_BI__LLC_LoanDocument__c>();
             Set<ID> ContentVersionID =new Set<ID>();
             Set<Id> docStoreIDSet = new Set<Id>(); 
             Set<Id> loanIDSet = new Set<Id>(); 
             Set<ID> DocumentStoreIndexIDs = new Set<ID>(); 
             Map<String,ContentVersion> SpringCMDocIDMAPtoCOntentVersion = new Map<String,ContentVersion>();
             integer i=0;
             
        
        
        List<SpringCMTempMapToPlaceHolder__mdt> PlaceHolderMDT = [select id,DeveloperName,PlaceHolderName__c,MasterLabel from SpringCMTempMapToPlaceHolder__mdt];
 System.debug('*************** PlaceHolderMDT: ' + PlaceHolderMDT); 

       if(!newLoanIdSet.isEmpty())
             LLCLoanDocList = [SELECT Id, Name FROM LLC_BI__LLC_LoanDocument__c WHERE LLC_BI__Loan__c in : newLoanIdSet] ;
                  

        
        
        
            MAP<ID,SpringCM_Document_Detail__c> mapDocumentDetail = new MAP<Id,SpringCM_Document_Detail__c>([Select ID,Document_Id__c,Document_Name__c,IsUploaded__c,Loan__c,ParentID__c  from SpringCM_Document_Detail__c where id in :  newDocumentDetailIdSet]);
        
          // System.debug('*************** values: ' + mapDocumentDetail.values()); 
        for(SpringCM_Document_Detail__c mapvar : mapDocumentDetail.values()) {
                System.debug('*************** Current Document_Id__c: ' + mapvar.Document_Id__c); 
             
            loanIDSet.add(mapvar.Loan__c);
            
            
            
// iterating   LLC_BI__LLC_LoanDocument__c   LLC LoanDocument StartDocument

    

  for(LLC_BI__LLC_LoanDocument__c LLCLoanDocVar : LLCLoanDocList){
      system.debug('LLLLLLLLLLLLLLLLL'+LLCLoanDocVar.Name);
      
            System.debug('DDDDDDDD varMDT: ' + LLCLoanDocVar.Name +'DDDDDDDD mapvar: ' + mapvar.Document_Name__c); 
            if(LLCLoanDocVar.Name.containsOnly(mapvar.Document_Name__c)){
                
                System.debug('BBBBBBBBBBB varMDT: ' + LLCLoanDocVar.Name +'CCCCCCCCCCCCCCCCC mapvar: ' + mapvar.Document_Name__c); 
                LLC_BI__LLC_LoanDocument__c llcvar = new  LLC_BI__LLC_LoanDocument__c();
                llcvar.LookupKey__c = mapvar.Document_Id__c;
                llcvar.id = LLCLoanDocVar.id;
                LLCLoanDocUpdateList.add(llcvar);
                
                break;
            }
      
     // break;
      
  }
// iterating   LLC_BI__LLC_LoanDocument__c   LLC LoanDocument End           
            
//custom Metadata Searching     
            /*
            for(SpringCMTempMapToPlaceHolder__mdt  varMDT : PlaceHolderMDT) {   
            System.debug('DDDDDDDDDDDDDDD varMDT: ' + varMDT.MasterLabel+'DDDDDDDDDDD mapvar: ' + mapvar.Document_Name__c); 
                if(varMDT.MasterLabel.containsOnly(mapvar.Document_Name__c)) {
                

                }
            } */
            
            
            //Callout for Blob       

            GeWS_SpringCMService_WS api = new GeWS_SpringCMService_WS();
            blob singleData ;
            singleData = api.getSpringCMDocumentById(mapvar.Document_Id__c); 
            data.add(singleData);

            //Creating a DocStor
            LLC_BI__Document_Store__c docStore = new LLC_BI__Document_Store__c();
            docStore.LLC_BI__lookupKey__c = mapvar.Document_Id__c;  
            docStoreList.add(docStore);
            
            LLC_BI__Document_Store_Index__c docStIn = new LLC_BI__Document_Store_Index__c();    
            docStIn.LLC_BI__lookupKey__c =  mapvar.Document_Id__c;  
           docStInList.add(docStIn);            

            // Create COntent Version 
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';           
            cv.VersionData = singleData;
            cv.LookupKey__c = mapvar.Document_Id__c;  
            cv.Title = mapvar.Document_Name__c; //+'.docx';
            cv.PathOnClient =  cv.Title;  
            cvList.add(cv); 
            
        SpringCMDocIDMAPtoCOntentVersion.put( mapvar.Document_Id__c,cv);
        
           // Creating LoanDocument
            LLC_BI__LLC_LoanDocument__c loanDoc = new LLC_BI__LLC_LoanDocument__c();
            loanDoc.Name = mapvar.Document_Name__c;//'3_SpringCM-Overdraft_SF';
            loanDoc.LLC_BI__Loan__c =  mapvar.Loan__c; //'a3Z9E0000002pc2';  
            loanDoc.LLC_BI__reviewStatus__c = 'In-File'; 
            loanDoc.LLC_BI__Approval_Roles__c  = 'SAN 14;SAN System Admin'; 
            LoanDocumentList.add(loanDoc);
            //   LoanDocumentList2.addall(LoanDocumentList);

        }
        
        insert docStoreList;
         insert cvList;
        
        
       //#  // insert LoanDocumentList;
       update  LLCLoanDocUpdateList;
      
        
        //system.debug('Blob Data==========='+data);
        system.debug('LLC_BI__Document_Store__c docStoreList ==========='+docStoreList);
        system.debug(' ContentVersion ==========='+cvList);
        system.debug(' LoanDocumentList ==========='+LoanDocumentList);
        system.debug(' LLCLoanDocUpdateList ==========='+LLCLoanDocUpdateList);
        system.debug(' docStInList ==========='+docStInList);
        
        
        
        

        
//update Lookup value in the Document Store Index       


        for(LLC_BI__Document_Store__c docStoreID :docStoreList){
            for(LLC_BI__Document_Store_Index__c docStoreIndexID :docStInList){
            LLC_BI__Document_Store_Index__c docStIn = new LLC_BI__Document_Store_Index__c();  
            
            
            system.debug(' LLC_BI__Document_Store_Index__c =========='+docStoreIndexID.LLC_BI__lookupKey__c+' LLC_BI__Document_Store__c ========='+docStoreID.LLC_BI__lookupKey__c);
                if(docStoreIndexID.LLC_BI__lookupKey__c == docStoreID.LLC_BI__lookupKey__c) {
                docStIn.LLC_BI__Document_Store__c = docStoreID.Id;
                docStIn.LLC_BI__lookupKey__c = docStoreID.LLC_BI__lookupKey__c;
                docStInListFinal.add(docStIn);
                }
            }

        }

system.debug(' docStInList before insert ========== ='+docStInListFinal);

       insert docStInListFinal;
        
        system.debug(' docStInList AFTER insert ========== ='+docStInListFinal);
        
        
        // Fetch all ContentVersion IDs
        for(ContentVersion cvVar: cvList){
                ContentVersionID.add(cvVar.id);
        }
        
        //Content Document Link  logic
           
           for(ContentVersion conVerId : [SELECT Id, ContentDocumentId,LookupKey__c FROM ContentVersion WHERE Id in : ContentVersionID]){
               ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = conVerId.ContentDocumentId;
               for(LLC_BI__Document_Store__c docStoreID :docStoreList){
                   docStoreIDSet.add(docStoreID.id);
                    LLC_BI__Document_Store_Index__c docStIn = new LLC_BI__Document_Store_Index__c(); 
                    
                //  if(SpringCMDocIDMAPtoCOntentVersion.containsKey(docStoreID.LLC_BI__lookupKey__c)){
                  if( conVerId.LookupKey__c == docStoreID.LLC_BI__lookupKey__c){
                            cdl.LinkedEntityId = docStoreID.id;
                            system.debug(' docStoreID.LLC_BI__lookupKey__c individual   ========== ='+docStoreID.LLC_BI__lookupKey__c);
                       
                    }
                }
                                         
                
                
                 cdl.ShareType = 'I';                 
                 cdlList.add(cdl);
           }
           insert cdlList;
          
             
    system.debug(' cdlList full  ========== ='+cdlList);

  //  system.debug(' docStInList ========== ='+docStInList);


    

    //    for(LLC_BI__Document_Store_Index__c cvVar: docStInList){
        
        for(LLC_BI__Document_Store_Index__c cvVar: docStInListFinal){
                DocumentStoreIndexIDs.add(cvVar.id);
                
                for(LLC_BI__LLC_LoanDocument__c llcLoanDocVar: LLCLoanDocUpdateList){
                    if (llcLoanDocVar.LookupKey__c == cvVar.LLC_BI__lookupKey__c){
                        LLC_BI__LLC_LoanDocument__c llcvar = new  LLC_BI__LLC_LoanDocument__c();
                        llcvar.LLC_BI__Document_Store_Index__c = cvVar.id;
                        llcvar.id = LLCLoanDocVar.id;
                        LLCLoanDocWithLookupUpdateList.add(llcvar);
                    }
                }
        }       
        
        update LLCLoanDocWithLookupUpdateList;
        
        system.debug('jjjjjjjjjjjjjjjjjjjjjjjjj='+LLCLoanDocWithLookupUpdateList);
        
        Id DocManagerID = [SELECT Id,LLC_BI__lookupKey__c,LLC_BI__Type__c,Name FROM LLC_BI__DocManager__c  where LLC_BI__lookupKey__c  =: Label.SpringCMDocManger].id;
        Id DocTypeID = [SELECT Id,LLC_BI__docManager__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c FROM LLC_BI__DocType__c where LLC_BI__lookupId__c =: Label.SPringCMDocType].id;
        Id DocClassID = [SELECT Id,LLC_BI__Description__c,LLC_BI__docManager__c,LLC_BI__DocType__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c,Name FROM LLC_BI__DocClass__c where LLC_BI__lookupId__c =: Label.SpringCMDocClass].id;



            //Update LLC_BI__LLC_LoanDocument__c NEW
            
            
            //Update LLC_BI__LLC_LoanDocument__c

           for(LLC_BI__Document_Store_Index__c conVarDSI : [SELECT Id,LLC_BI__Document_Store__c,LLC_BI__lookupKey__c,Name ,LLC_BI__Document_Store__r.LLC_BI__lookupKey__c   FROM LLC_BI__Document_Store_Index__c  WHERE LLC_BI__Document_Store__c in : docStoreIDSet]){               
               
              // Iterate SpringCM_Document_Detail__c Map 
              for(SpringCM_Document_Detail__c mapvar : mapDocumentDetail.values()) {
                            system.debug('YYYYYYYYYYY  mapvar.Document_Id__c '+mapvar.Document_Id__c +'YYYYYYYYYYY LLC_BI__Document_Store_Index__c Soql conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c '+conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c +'YYYYYYYYYYY conVarDSI.LLC_BI__lookupKey__c'+conVarDSI.LLC_BI__lookupKey__c);                 
                 if(mapvar.Document_Id__c ==  conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c  && conVarDSI.LLC_BI__lookupKey__c == conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c)  {
                     for(LLC_BI__LLC_LoanDocument__c varLD: LoanDocumentList) {                     
                            system.debug('iiiiiiiiiiiiiiiiiiii  mapvar.Document_Name__c'+mapvar.Document_Name__c+'iiiiiiiiiii LoanDocumentList varLD.Name'+varLD.Name);
                         if(mapvar.Document_Name__c  == varLD.Name) {                           
                            LLC_BI__LLC_LoanDocument__c loanDoc = new LLC_BI__LLC_LoanDocument__c();
                            varLD.LLC_BI__Document_Store_Index__c = conVarDSI.Id;   
                            varLD.LLC_BI__docManager__c = DocManagerID;
                            varLD.LLC_BI__docClass__c  = DocClassID; 
                        //    varLD.LLC_BI__docType__c = mapvar.DocTypePlaceHolder__c; //DocTypeID; 
                            
                            ////
                            
                              varLD.Name = varLD.Name;//'3_SpringCM-Overdraft_SF';
         //   varLD.LLC_BI__Loan__c =  varLD.LLC_BI__Loan__c; //'a3Z9E0000002pc2';  
            varLD.LLC_BI__reviewStatus__c = 'In-File'; 
         //~~   varLD.LLC_BI__Approval_Roles__c  = 'SAN 14;SAN System Admin'; 
                            LoanDocumentList2.add(varLD);
                            break;
                         }
                     }
break;                 
                 }
              }
           }
           
           system.debug('fffffffffffffffffffffffffffffffffff LoanDocumentList2'+LoanDocumentList2);
           system.debug('fffffffffffffffffffffffffffffffffff LoanDocumentList '+LoanDocumentList);
           
     ///###     update LoanDocumentList;
           
                      system.debug('gggggggggggg LoanDocumentList2'+LoanDocumentList2);
           system.debug('ggggggggggggggggggg LoanDocumentList '+LoanDocumentList);

 
        
        }
        
    
        
/*      
         @future(callout=true)
        public static  void  attachmentLoader1(set<Id> newDocumentDetailIdSet){
            
             List<blob> data = new List<blob>();
             List<LLC_BI__Document_Store__c> docStoreList = new List<LLC_BI__Document_Store__c>();
             List<ContentVersion> cvList =new  List<ContentVersion>();
             List<LLC_BI__Document_Store_Index__c> docStInList =new List<LLC_BI__Document_Store_Index__c>();
             List<ContentDocumentLink> cdlList =new  List<ContentDocumentLink>();
             List<LLC_BI__LLC_LoanDocument__c> LoanDocumentList =new List<LLC_BI__LLC_LoanDocument__c>();
             List<LLC_BI__LLC_LoanDocument__c> LoanDocumentList2 =new List<LLC_BI__LLC_LoanDocument__c>();
             Set<ID> ContentVersionID =new Set<ID>();
             Set<Id> docStoreIDSet = new Set<Id>(); 
             Set<ID> DocumentStoreIndexIDs = new Set<ID>(); 
             integer i=0;
             
        
            MAP<ID,SpringCM_Document_Detail__c> mapDocumentDetail = new MAP<Id,SpringCM_Document_Detail__c>([Select ID,Document_Id__c,Document_Name__c,IsUploaded__c,Loan__c,ParentID__c from SpringCM_Document_Detail__c where id in :  newDocumentDetailIdSet]);
        
           System.debug('*************** values: ' + mapDocumentDetail.values()); 
        for(SpringCM_Document_Detail__c mapvar : mapDocumentDetail.values()) {
                System.debug('*************** Current Document_Id__c: ' + mapvar.Document_Id__c); 
             

            //Callout for Blob       

            GeWS_SpringCMService_WS api = new GeWS_SpringCMService_WS();
            blob singleData ;
            singleData = api.getSpringCMDocumentById(mapvar.Document_Id__c); 
            data.add(singleData);

            //Creating a DocStor
            LLC_BI__Document_Store__c docStore = new LLC_BI__Document_Store__c();
            docStore.LLC_BI__lookupKey__c = mapvar.Document_Id__c;  
            docStoreList.add(docStore);

            // Create COntent Version 
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';           
            cv.VersionData = singleData;
            cv.Title = mapvar.Document_Name__c; //+'.docx';
            cv.PathOnClient =  cv.Title;  
            cvList.add(cv); 
         
           // Creating LoanDocument
            LLC_BI__LLC_LoanDocument__c loanDoc = new LLC_BI__LLC_LoanDocument__c();
            loanDoc.Name = mapvar.Document_Name__c;//'3_SpringCM-Overdraft_SF';
            loanDoc.LLC_BI__Loan__c =  mapvar.Loan__c; //'a3Z9E0000002pc2';  
            loanDoc.LLC_BI__reviewStatus__c = 'In-File'; 
            loanDoc.LLC_BI__Approval_Roles__c  = 'SAN 14;SAN System Admin'; 
            LoanDocumentList.add(loanDoc);
            //   LoanDocumentList2.addall(LoanDocumentList);

        }
        
        insert docStoreList;
        insert cvList;
        insert LoanDocumentList;
        
        //system.debug('Blob Data==========='+data);
        system.debug('LLC_BI__Document_Store__c docStoreList ========== ='+docStoreList);
        system.debug(' ContentVersion ========== ='+cvList);
        system.debug(' LoanDocumentList ========== ='+LoanDocumentList);
        
        // Fetch all ContentVersion IDs
        for(ContentVersion cvVar: cvList){
                ContentVersionID.add(cvVar.id);
        }
        
        //Content Document Link  logic
           
           for(ContentVersion conVerId : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id in : ContentVersionID]){
               ContentDocumentLink cdl = new ContentDocumentLink();
               cdl.ContentDocumentId = conVerId.ContentDocumentId;
               for(LLC_BI__Document_Store__c docStoreID :docStoreList){
                    LLC_BI__Document_Store_Index__c docStIn = new LLC_BI__Document_Store_Index__c();        
                    if(i==0) {
                            cdl.LinkedEntityId = docStoreID.id;
                            docStoreIDSet.add(docStoreID.id);
                            docStIn.LLC_BI__Document_Store__c = docStoreID.Id;
                            docStInList.add(docStIn);
                            i++;
                    system.debug(' docStoreIDSet individual iffff  ========== ='+docStoreIDSet);
                        break;
                    }
                    else if(!docStoreIDSet.contains(docStoreID.id))
                    {                     
                        cdl.LinkedEntityId = docStoreID.id;
                        docStoreIDSet.add(docStoreID.id);
                        // insert   LLC_BI__Document_Store_Index__c logic
                        docStIn.LLC_BI__Document_Store__c = docStoreID.Id;
                        docStInList.add(docStIn);
                        i++;
                        system.debug(' docStoreIDSet individual  ELSSSSSS ========== ='+docStoreIDSet);
                        break;
                    }
                                         
                }
                
                 cdl.ShareType = 'I';                 
                 cdlList.add(cdl);
           } 
             insert cdlList;
             insert docStInList;
             
    system.debug(' cdlList full  ========== ='+cdlList);
    system.debug(' docStoreIDSet full  ========== ='+docStoreIDSet);
    system.debug(' docStInList ========== ='+docStInList);


    

        for(LLC_BI__Document_Store_Index__c cvVar: docStInList){
                DocumentStoreIndexIDs.add(cvVar.id);
        }       
        
        Id DocManagerID = [SELECT Id,LLC_BI__lookupKey__c,LLC_BI__Type__c,Name FROM LLC_BI__DocManager__c  where LLC_BI__lookupKey__c  =: Label.SpringCMDocManger].id;
        Id DocTypeID = [SELECT Id,LLC_BI__docManager__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c FROM LLC_BI__DocType__c where LLC_BI__lookupId__c =: Label.SPringCMDocType].id;
        Id DocClassID = [SELECT Id,LLC_BI__Description__c,LLC_BI__docManager__c,LLC_BI__DocType__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c,Name FROM LLC_BI__DocClass__c where LLC_BI__lookupId__c =: Label.SpringCMDocClass].id;


            //Update LLC_BI__LLC_LoanDocument__c

           for(LLC_BI__Document_Store_Index__c conVarDSI : [SELECT Id,LLC_BI__Document_Store__c,LLC_BI__lookupKey__c,Name ,LLC_BI__Document_Store__r.LLC_BI__lookupKey__c   FROM LLC_BI__Document_Store_Index__c  WHERE LLC_BI__Document_Store__c in : docStoreIDSet]){               
               
              // Iterate SpringCM_Document_Detail__c Map 
              for(SpringCM_Document_Detail__c mapvar : mapDocumentDetail.values()) {
                            system.debug('iiiiiiiiiiiiiiiiiiii  mapvar.Document_Id__c '+mapvar.Document_Id__c +'iiiiiiiiiii LLC_BI__Document_Store_Index__c Soql conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c '+conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c );                 
                  if(mapvar.Document_Id__c ==  conVarDSI.LLC_BI__Document_Store__r.LLC_BI__lookupKey__c)  {
                     for(LLC_BI__LLC_LoanDocument__c varLD: LoanDocumentList) {                     
                            system.debug('iiiiiiiiiiiiiiiiiiii  mapvar.Document_Name__c'+mapvar.Document_Name__c+'iiiiiiiiiii LoanDocumentList varLD.Name'+varLD.Name);
                         if(mapvar.Document_Name__c  == varLD.Name) {                           
                            LLC_BI__LLC_LoanDocument__c loanDoc = new LLC_BI__LLC_LoanDocument__c();
                            varLD.LLC_BI__Document_Store_Index__c = conVarDSI.Id;   
                            varLD.LLC_BI__docManager__c = DocManagerID;
                            varLD.LLC_BI__docClass__c  = DocClassID; 
                            varLD.LLC_BI__docType__c = DocTypeID; 
                            LoanDocumentList2.add(varLD);
                         }
                     }
                  }
              }
           }
           
           system.debug('fffffffffffffffffffffffffffffffffff LoanDocumentList2'+LoanDocumentList2);
           system.debug('fffffffffffffffffffffffffffffffffff LoanDocumentList '+LoanDocumentList);
           
          update LoanDocumentList;
           
                      system.debug('gggggggggggg LoanDocumentList2'+LoanDocumentList2);
           system.debug('ggggggggggggggggggg LoanDocumentList '+LoanDocumentList);

 
        
        }
        
    // ====    
        
         @future(callout=true)
        public static  void  attachmentLoader(String SpringDocIdvar, String LoanDocName,String LoandSFID){
            
         GeWS_SpringCMService_WS api = new GeWS_SpringCMService_WS();
         blob data = api.getSpringCMDocumentById(SpringDocIdvar); 
         system.debug('Blob Data='+data);
              
        //Creating a DocStore
        string springDocId = SpringDocIdvar; // '3_1be03af9-19b2-e911-9c27-30e17155e337__3';
        LLC_BI__Document_Store__c docStore = new LLC_BI__Document_Store__c();
        docStore.LLC_BI__lookupKey__c = springDocId;
        insert docStore;
        Id docStoreId = docStore.Id;
        system.debug('docStoreId='+docStoreId);
        

        //SELECT id,contentDocumentId,ContentLocation ,VersionData ,PathOnClient, Title,FirstPublishLocationId ,FirstPublishLocation.Name FROM ContentVersion limit 30
        
        //String  base64Data = EncodingUtil.urlDecode(getResponse.getBodyAsBlob(), 'UTF-8');
                
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
        //  cv.ContentDocumentId = contentDocumentId;  (Create contentDocument)
            cv.VersionData = data;
            cv.Title = LoanDocName; //+'.docx';
            cv.PathOnClient =  cv.Title;        
            insert cv;
        system.debug('@@=='+cv.Id); 
        system.debug('@@== cv'+cv); 
            


        // Creating DocumentStoreIndex
        LLC_BI__Document_Store_Index__c docStIn = new LLC_BI__Document_Store_Index__c();
        docStIn.LLC_BI__Document_Store__c = docStore.Id;
        insert docStIn;
        
        //Content Document Link 
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        //cdl.ContentDocumentId = contentDocumentId;
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = docStore.Id;
        cdl.ShareType = 'I';
        insert cdl;


        System.debug('-------------ContentDocumentLink----------------'+cdl);


        Id DocManagerID = [SELECT Id,LLC_BI__lookupKey__c,LLC_BI__Type__c,Name FROM LLC_BI__DocManager__c  where LLC_BI__lookupKey__c  =: Label.SpringCMDocManger].id;
        Id DocTypeID = [SELECT Id,LLC_BI__docManager__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c FROM LLC_BI__DocType__c where LLC_BI__lookupId__c =: Label.SPringCMDocType].id;

        Id DocClassID = [SELECT Id,LLC_BI__Description__c,LLC_BI__docManager__c,LLC_BI__DocType__c,LLC_BI__lookupId__c,LLC_BI__lookupKey__c,Name FROM LLC_BI__DocClass__c where LLC_BI__lookupId__c =: Label.SpringCMDocClass].id;



        system.debug('----DocManagerID--'+DocManagerID+'----DocTypeID---'+DocTypeID+'++++DocClassID===='+DocClassID);


    // Creating LoanDocument
    LLC_BI__LLC_LoanDocument__c loanDoc = new LLC_BI__LLC_LoanDocument__c();
    loanDoc.Name = LoanDocName;//'3_SpringCM-Overdraft_SF';   /////####
    loanDoc.LLC_BI__Document_Store_Index__c = docStIn.Id;   
    loanDoc.LLC_BI__Loan__c =  LoandSFID; //'a3Z9E0000002pc2';   /////####
    loanDoc.LLC_BI__docManager__c = DocManagerID;
    loanDoc.LLC_BI__docClass__c  = DocClassID; 
    loanDoc.LLC_BI__docType__c       = DocTypeID; 
    loanDoc.LLC_BI__reviewStatus__c = 'In-File';    /////####
    loanDoc.LLC_BI__Approval_Roles__c  = 'SAN 14;SAN System Admin';  /////####

    insert loanDoc;

    system.debug('---------------------loanDoc---------------'+loanDoc);

     
        }
        
            */

    }