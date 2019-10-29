public class SpringCM_DocumentDetails{
 
 //@InvocableMethod
    public static  void CreateSpringCMDetail(List<Id> LoanID){
        
     //     SELECT id,  SpringCM_Doc_Name__c FROM LLC_BI__Loan__c where id = 'a3Z9E0000002oez'
     //id1,val1,id2,val2,id3,val3,id4,val4
     
     
     if(!LoanID.isEmpty())
     {
        LLC_BI__Loan__c loanrec =[ SELECT id,  SpringCM_Doc_Name__c FROM LLC_BI__Loan__c where id =: LoanID[0] ];
        if(loanrec.SpringCM_Doc_Name__c != null) 
        {
            system.debug('----LoanID---'+LoanID);
            String str = loanrec.SpringCM_Doc_Name__c; //'id1,val1,id2,val2,id3,val3';
            List<String> lstAlpha = str.split(',');
            Map<string,String> Mapstr = new Map<string,String>();
            integer i=0;
            List<SpringCM_Document_Detail__c> SpringDocList = new List<SpringCM_Document_Detail__c>();
            
            system.debug('======'+lstAlpha);
            string tempKeyVal;
            for(string st:lstAlpha)
            {
                    // ODD Even logic
                   if(math.mod(i, 2) == 0){
                        Mapstr.put(st,'');
                        tempKeyVal = st;                  
                    }
                    else{                
                            Mapstr.put(tempKeyVal,st);
                            tempKeyVal = '';                 
                    }
                system.debug('---tempKeyVal--'+tempKeyVal);      
                i++;
            }           
             system.debug('---Mapstr--'+Mapstr);
            
            for(String  maptemp : Mapstr.keyset()) {
            SpringCM_Document_Detail__c spDocDetailVar = new SpringCM_Document_Detail__c();
                if(mapstr.containskey( maptemp)){
                    spDocDetailVar.Document_Name__c  = mapstr.get( maptemp);
                    spDocDetailVar.Document_Id__c = maptemp; 
                    spDocDetailVar.Loan__c = LoanID[0];
                    spDocDetailVar.ParentID__c = LoanID[0];
                //spDocDetailVar.IsUploaded__c              
                }
                SpringDocList.add(spDocDetailVar);            
            }
            
            system.debug('---SpringDocList---'+SpringDocList);
            
            if(!SpringDocList.isEmpty())
                insert SpringDocList;
        }
     }
        
    }
}