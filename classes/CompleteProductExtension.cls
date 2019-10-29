/* ----------------------------------------------------------------------------------------------------
   Name:            CompleteProductExtension.cls 
   Description:     Visualforce controller class for page CompleteProduct.page
   Test class:      CompleteProductTest.cls 

   Date                Version      Author                      Summary of Changes 
  ------------          -------     -----------------          -------------------------------------------
  21-Feb-2017            0.1        Accenture-Ujjwala Gavhane    This Class will be used for Change the
                                                                  record type of of Project to record type.        
  ------------------------------------------------------------------------------------------------ ------*/

     /** 
	 * @description : Visualforce controller class for page CompleteProduct.page
	 **/
	Public with sharing Class CompleteProductExtension {
    Public String accountid;
    Public String RCT {get;set;}
    Public String DunsNo {get;set;}
        
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
     /** 
	 * @description : const
	 **/   
    public CompleteProductExtension(ApexPages.StandardController controller) {
        
        DunsNo='';
        accountid=controller.getid();
        
        
    }
	 /** 
	 * @description : getRCT
	 **/
    public List<SelectOption> getRCT() {
        try{
        
      	  
        }   catch (Exception e) 
        {        
            system.debug('Error: '+ e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        List<SelectOption> recordOptions= new List<SelectOption>();
        recordOptions.add(new SelectOption('Customer','Customer'));
        recordOptions.add(new SelectOption('Prospect','Prospect'));
        return recordOptions;
            
       
    }
   
        
    /** 
	 * @description : save
	 **/
    public PageReference save() {
        Account acc=[select ID, Name, RecordTypeId,DunsNumber from Account where id =:accountid LIMIT 1];
        if ( RCT.equals('Prospect'))  {
          acc.RecordTypeId = prospectRecordTypeId;
        } 
        else if (RCT.equals('Customer')) {
            acc.RecordTypeId = customerRecordTypeId;
        }else{
            System.debug('for novasuite');
        }
        if (DunsNo.equals('')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please enter D-U-N-S Number'));
            return null;
        }
        try{
            acc.DunsNumber = DunsNo;
            update acc; 
        } catch (Exception ex) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'D-U-N-S Number already used for other record'+DunsNo));
              return null;
        }

     PageReference pageref = new PageReference('/' +  acc.ID);
     pageref.setRedirect(true);
     return pageref;  


    }

}