/************************************************
Name:TestDataFactoryUtility
Descritption:Utility class for the reusable test data.
Created By: Poonam Yadav 
Created Date: 26/08/2019
**************************************************/


public class TestDataFactoryUtility {
    
    
    /************************************************
    Method Name:createProductPackage
    Descritption:method to create Productpackage record to be used in testClasses.
    Input Parameters: noOfProductPackgs
    Output parameters: Product package list
    
    **************************************************/
        
        public static List<LLC_BI__Product_Package__c> createProductPackageswithAccount(Integer noOfProductPackgs , Id AccountId){
            
            List<LLC_BI__Product_Package__c> productpakgs= new List<LLC_BI__Product_Package__c>();
          
            if(noOfProductPackgs>0){
            for(Integer i=0;i<noOfProductPackgs;i++) {
            LLC_BI__Product_Package__c productpackageobj = new LLC_BI__Product_Package__c();
                productpackageobj.Name='Test Product Package'+ i;
                if(AccountId != null){
                    
                  productpackageobj.LLC_BI__Account__c=AccountId;
                }
                productpakgs.add(productpackageobj);
                
              }
            
           insert productpakgs;
           }
           return productpakgs;   
        }
    /************************************************
    Method Name:createLoan
    Descritption:method to createloan records
    Input Parameters:  noOfLoans, produckPackage Id
    Output parameters:Loan  
  
    **************************************************/
    
     public static List< LLC_BI__Loan__c> createLoanswithProductpackage(Integer noOfLoans, Id productpackageId){
            
           List<LLC_BI__Loan__c> loans =new List<LLC_BI__Loan__c>();
         
          if(noOfLoans>0 ){
            for(Integer i=0;i<noOfLoans;i++) {
            LLC_BI__Loan__c loanobj = new LLC_BI__Loan__c();
                loanobj.Name='Test Loan'+ i;
                loanobj.LLC_BI__Amount__c = 10000 + i;
                loanobj.LLC_BI__Status__c='Open';
                if(productpackageId!=null){
                loanobj.LLC_BI__Product_Package__c=productpackageId;
                }
                loans.add(loanobj);
              }
            
            insert loans;
           }
           return loans;
          
        }
    
    
     public static List< LLC_BI__Loan__c> createLoanswithRiskGroup(Integer noOfLoans, Id riskGroupId){
            
           List<LLC_BI__Loan__c> rgwithloans =new List<LLC_BI__Loan__c>();
         
          if(noOfLoans>0 ){
            for(Integer i=0;i<noOfLoans;i++) {
            LLC_BI__Loan__c rgloanobj = new LLC_BI__Loan__c();
                rgloanobj.Name='Test Loan'+ i;
                rgloanobj.LLC_BI__Amount__c = 10000 + i;
                rgloanobj.LLC_BI__Status__c='Open';
                if(riskGroupId!=null){
                rgloanobj.Risk_Group__c=riskGroupId;
                }
                rgwithloans.add(rgloanobj);
              }
            
            insert rgwithloans;
           }
           return rgwithloans;
          
        }
    
    
    
        public static LLC_BI__Loan__c createLoanWithApplicationStatus(){
            
           LLC_BI__Loan__c loan =new LLC_BI__Loan__c(LLC_BI__Stage__c = 'Application', PolicyAcknowledgement__c = true);
           loan.Name='loanName';
           loan.Passed_to_Credit__c = null;
            insert loan;
           //System.assertEquals(true,loan!=null);
         
           return loan;
        }
    
    /************************************************
    Method Name:createCollateralPledge
    Descritption:method to create collateral Pleadge Records
    Input Parameters: Collateral Pledge Name
    Output parameters:Collateral
    
    **************************************************/
    public static List<LLC_BI__Loan_Collateral2__c> createCollateralPledge( Integer noOfCollateralPledge,id loanId, Id CollateralId){
        
        List<LLC_BI__Loan_Collateral2__c> collateralPledges = new List< LLC_BI__Loan_Collateral2__c>();
        LLC_BI__Loan_Collateral_Aggregate__c loanCollateralaggobj=new LLC_BI__Loan_Collateral_Aggregate__c();
        insert loanCollateralaggobj;
        
        if(noOfCollateralPledge>0 ){
            for(Integer i=0;i<noOfCollateralPledge;i++) {
            LLC_BI__Loan_Collateral2__c collateralPledgeobj = new LLC_BI__Loan_Collateral2__c();
                if(loanId!=null){
                 collateralPledgeobj.LLC_BI__Loan__c = loanId;
                }
                if(CollateralId!=null){
                 collateralPledgeobj.LLC_BI__Collateral__c=CollateralId;
                }
                collateralPledgeobj.LLC_BI__Loan_Collateral_Aggregate__c=loanCollateralaggobj.Id;
                collateralPledges.add(collateralPledgeobj);
              }
            
            insert collateralPledges;
           }
           return collateralPledges;
        
        
       
    }    
    
     /************************************************
    Method Name:createCollateral
    Descritption:method to create collateral records
    Input Parameters: Collateral Name
    Output parameters:Collateral
    
    **************************************************/
    
     public static List<LLC_BI__Collateral__c> createCollaterals(Integer noOfCollaterals){
            
          List< LLC_BI__Collateral__c> collaterals =new List<LLC_BI__Collateral__c>();
          LLC_BI__Collateral_Type__c collateralTypeobj =new LLC_BI__Collateral_Type__c();
          collateralTypeobj.LLC_BI__Type__c = 'Commercial Property';
          collateralTypeobj.LLC_BI__Subtype__c = 'Leisure Hotel';
          collateralTypeobj.Name='TestCollateralTypeName';
          collateralTypeobj.LLC_BI__Advance_Rate__c=20;
          insert collateralTypeobj;
         
         	if(noOfCollaterals>0 && collateralTypeobj!=null){
            	for(Integer i=0;i<noOfCollaterals;i++) {
           			 LLC_BI__Collateral__c collateralobj = new LLC_BI__Collateral__c();
                	collateralobj.LLC_BI__Status__c='Proposed';
                    collateralobj.Ranking__c = '1st';
                    collateralobj.Direct_Third_Party_Charge__c = 'Direct';
                    collateralobj.Further_Advance_with_no_DoP__c = False;
                    collateralobj.Advance_Rate__c=20;
                    collateralobj.LLC_BI__Value__c=60000;
                	collateralobj.LLC_BI__Collateral_Type__c=collateralTypeobj.Id;
                    collaterals.add(collateralobj);
              }
            
            insert collaterals;
          }
         
         return collaterals;
        }
    
    public static List<LLC_BI__Collateral__c> createCollateralsforRiskGroup(Integer noOfCollaterals, id riskGroupId){
            
           List<LLC_BI__Collateral__c> CollateralsforriskGroup =new List<LLC_BI__Collateral__c>();
        LLC_BI__Collateral_Type__c collateralTypeobj =new LLC_BI__Collateral_Type__c();
          collateralTypeobj.LLC_BI__Type__c = 'Commercial Property';
          collateralTypeobj.LLC_BI__Subtype__c = 'Leisure Hotel';
          collateralTypeobj.Name='TestCollateralTypeName';
          collateralTypeobj.LLC_BI__Advance_Rate__c=20;
          insert collateralTypeobj;
           
        if(noOfCollaterals>0){
            	for(Integer i=0;i<noOfCollaterals;i++) {
           		 LLC_BI__Collateral__c collobj = new LLC_BI__Collateral__c();
                    collobj.LLC_BI__Status__c='Proposed';
                    collobj.Ranking__c = '1st';
                    collobj.Direct_Third_Party_Charge__c = 'Direct';
                    collobj.Further_Advance_with_no_DoP__c = False;
                    collobj.Advance_Rate__c=20;
                    collobj.LLC_BI__Value__c=60000;
                	collobj.LLC_BI__Collateral_Type__c=collateralTypeobj.Id;
                    collobj.Risk_Group__c = riskGroupId;
               	// rjobj.Name='Test RG Name'+ i;
                 CollateralsforriskGroup.add(collobj);
              }
            
           insert CollateralsforriskGroup;
           }
           return CollateralsforriskGroup;  
        }   
    
    
    public static List<LLC_BI__Collateral_Valuation__c> createCollateralsValuation(Integer noOfCollaterals, id collateralmgmtid){
        
        List<LLC_BI__Collateral_Valuation__c> listofcollateralvaluation = new list<LLC_BI__Collateral_Valuation__c>();
        
        if(noOfCollaterals>0){
            	for(Integer i=0;i<noOfCollaterals;i++) {
           			LLC_BI__Collateral_Valuation__c collateralvaluation = new LLC_BI__Collateral_Valuation__c();
                    //collateralvaluation.Name = 'TestCollateral' + i;
                    collateralvaluation.LLC_BI__Valuation_Date__c = system.today();
                    collateralvaluation.LLC_BI__Active__c = True;
                    collateralvaluation.LLC_BI__Primary__c = True;
                    collateralvaluation.LLC_BI__Source__c = 'Astleys';
                    collateralvaluation.LLC_BI__Type__c = 'MV1';
                    collateralvaluation.MV1__c = 5000;
                    collateralvaluation.LLC_BI__Value__c = 5000;
                    collateralvaluation.VPV__c = 5000;
                    collateralvaluation.LLC_BI__Collateral__c = collateralmgmtid;
                    listofcollateralvaluation.add(collateralvaluation);
              }
            
            insert listofcollateralvaluation;
          }
        return listofcollateralvaluation;
    }
     
   /************************************************
    Method Name:createAccounts
    Descritption:method to create Account records
    Input Parameters: noOfAccounts
    Output parameters:account list
    
    **************************************************/
    
     public static List<Account> createAccounts(Integer noOfAccounts){
            
           List<Account> accounts =new List<Account>();
           if(noOfAccounts>0){
            	for(Integer i=0;i<noOfAccounts;i++) {
           		 Account accountobj = new Account();
               	 accountobj.Name='Test Account Name'+ i;
                   accountobj.Status__c='Active Customer'; 
                 accounts.add(accountobj);
              }
            
           insert accounts;
           }
           return accounts;  
        }  
    
    /************************************************
    Method Name:createRiskGroup
    Descritption:method to create RiskGroup records
    Input Parameters: noOfRG
    Output parameters:RG list
    
    **************************************************/
    
     public static List<Risk_Group__c> createRiskGroup(Integer noOfRiskGroup, id productpackageId){
            
           List<Risk_Group__c> riskGroup =new List<Risk_Group__c>();
           if(noOfRiskGroup>0){
            	for(Integer i=0;i<noOfRiskGroup;i++) {
           		 Risk_Group__c rjobj = new Risk_Group__c();
                    rjobj.Product_Package__c = productpackageId;
               	// rjobj.Name='Test RG Name'+ i;
                 riskGroup.add(rjobj);
              }
            
           insert riskGroup;
           }
           return riskGroup;  
        }   
    
    
    
    
     /************************************************
    Method Name:createLegalEntities
    Descritption:method to create Legal Entities Records for LTV
    Input Parameters: noOfLegalEntities
    Output parameters:legalEntities list
    
    **************************************************/ 
     public static List<LLC_BI__Legal_Entities__c> createLegalEntities(Integer noOfLegalEntities, Id AccountId,Id ProductPackageId){
            
           List<LLC_BI__Legal_Entities__c> legalEntities =new List<LLC_BI__Legal_Entities__c>();
           if(noOfLegalEntities>0){
            	for(Integer i=0;i<noOfLegalEntities;i++) {
           		 LLC_BI__Legal_Entities__c legalEntityobj = new LLC_BI__Legal_Entities__c();
                    if(AccountId !=null){
               	 legalEntityobj.LLC_BI__Account__c= AccountId;
                    }
                    if(ProductPackageId != null){
                 legalEntityobj.LLC_BI__Product_Package__c=ProductPackageId;
                    }
                 legalEntities.add(legalEntityobj);
              }
            
           insert legalEntities;
           }
           return legalEntities;  
        } 
    
    
    
  /************************************************
    Method Name:createCovenant
    Descritption:method to create covenant records
    Input Parameters: Covenant Type,Test Date,Information Due in Days,Frequency
    Output parameters:Covenant
    
    **************************************************/
    
    public static LLC_BI__Covenant2__c createCovenant(String CovenantType, Date TestDate,String InformationDueinDays,String Frequency ){
        
      LLC_BI__Covenant2__c Comgmt=new LLC_BI__Covenant2__c(Covenant_Type2__c=CovenantType,Test_Date__c=TestDate,Information_Due_in_Days__c=InformationDueinDays,LLC_BI__Frequency__c=Frequency);
       insert Comgmt;
       return Comgmt;
         }
    
    /************************************************
    Method Name:createCompliance
    Descritption:method to create covenant Compliance records
    Input Parameters: Status,Covenant
    Output parameters:Covenant Compliance
    
    **************************************************/
    
     public static LLC_BI__Covenant_Compliance2__c createCompliance(String Status, Id Covenant){
        LLC_BI__Covenant_Compliance2__c CC=new  LLC_BI__Covenant_Compliance2__c(LLC_BI__Status__c=Status, LLC_BI__Covenant__c=Covenant);
         //RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'LLC_BI__Covenant_Compliance2__c' AND Name = 'Ratched'];
        // CC.RecordTypeId = rt.Id;
         insert CC;
         return CC;
         }
    
    /********************************************************
     * Method Name:createAccount
     * Decription:method to create Account record
     * Input Paramteres:
     * Output Parameters:
     * *****************************************************/
    
    public static Account createAccount(String Name,String RecordType){
        Account ac = new Account(Name=Name,RecordTypeId=RecordType);
        insert ac;
        return ac;
    }
    
    /*********************************************************
     * Method Name:createDocManager
     * Description:method to create DocManager record
     * Input Parameters:
     * Output Paramters:
     * *******************************************************/
    public static LLC_BI__DocManager__c createDocManager(Id Account,String namePrefix){
        LLC_BI__DocManager__c dm= new LLC_BI__DocManager__c(Name=Account,LLC_BI__namespacePrefix__c=namePrefix);
        insert dm;
        return dm;
    }
    
    /*********************************************************
     * Method Name:createDocType
     * Description:method to create DocType record
     * Input Parameters:
     * Output Paramters:
     * *******************************************************/
    public static LLC_BI__DocType__c createDocType(String Name,Id DocMan){
        LLC_BI__DocType__c dt= new LLC_BI__DocType__c(Name=Name,LLC_BI__docManager__c=DocMan);
        insert dt;
        return dt;
    }
    /*********************************************************
     * Method Name:createAccountDocument
     * Description:method to create AccountDocument record
     * Input Parameters:
     * Output Paramters:
     * *******************************************************/
    public static LLC_BI__AccountDocument__c createAccountDocument(String Name,Id DocMan,Id DocType,String Status){
        LLC_BI__AccountDocument__c ad = new LLC_BI__AccountDocument__c(Name=Name,LLC_BI__docManager__c=DocMan,LLC_BI__docType__c=DocType,LLC_BI__reviewStatus__c=Status);
        insert ad;
        return ad;
    }
    /*********************************************************
     * Method Name:createOpportunity
     * Description:method to create Opportunity record
     * Input Parameters:
     * Output Paramters:
     *********************************************************/
        public static Opportunity createOpportunity(ID RecordType, String Name, Id AcctId, Date ClsDate, String Stage){
        Opportunity opp = new Opportunity(RecordTypeId = RecordType, Name=Name, AccountId = AcctId, CloseDate = ClsDate, StageName = Stage);
        insert opp;
        return opp;
    }
     /*********************************************************
     * Method Name:createOpportunityProduct
     * Description:method to create Opportunity Product record
     * Input Parameters:
     * Output Paramters:
     *********************************************************/
     public static Opportunity_Product__c createOpportunityProduct(string name, Id OppId, string oppRcdID){
        Opportunity_Product__c oppPro = new Opportunity_Product__c(Name = name,Opportunity__c = OppId, RecordTypeID = oppRcdID);
        
        insert oppPro;
        return oppPro;
    }
    /*********************************************************
     * Method Name:createOpportunityTeam
     * Description:method to create Opportunity Team record
     * Input Parameters: Opportunity Id,Member, User ID
     * Output Paramters:
     *********************************************************/
    public static OpportunityTeamMember createOpportunityTeam(Id OppID, string Role,Id User ){
        OpportunityTeamMember oppTeam = new OpportunityTeamMember(OpportunityId = OppID, TeamMemberRole = Role, UserId = User);
        insert oppTeam;
        return oppTeam;
    }
     /*********************************************************
     * Method Name:createProductPackages_PCSM
     * Description:method to create Opportunity Team record
     * Input Parameters: Opportunity Id,Member, User ID
     * Output Paramters:
     *********************************************************/
    public static List<LLC_BI__Product_Package__c> createProductPackage_PCSM(Integer noOfProductPackgs){
          List<LLC_BI__Product_Package__c> productpakgs= new List<LLC_BI__Product_Package__c>();
        if(noOfProductPackgs > 0){
            for(Integer i=0;i<noOfProductPackgs;i++) {
                LLC_BI__Product_Package__c PPInsert= new LLC_BI__Product_Package__c();
                PPInsert.Name='TestingPP';
                PPInsert.Requires_Manual_Approval__c='Yes';
                PPInsert.LLC_BI__Status__c='Open';
                PPInsert.Purpose__c='New Monies';
                productpakgs.add(PPInsert);
            }
            insert productpakgs;
        }
      		return  productpakgs;
    }
    
    
     public static List<LLC_BI__Loan__c> createLoanswithProductpackage_PCSM(Integer noOfLoan,Id ppId){
          List<LLC_BI__Loan__c> insertLoan= new List<LLC_BI__Loan__c>();
        if(noOfLoan > 0){
            for(Integer i=0;i<noOfLoan;i++) {
              LLC_BI__Loan__c loanList= new LLC_BI__Loan__c();
                loanList.Name='TestingLoan_'+i;
                loanList.LLC_BI__Product_Package__c=ppId;
                loanList.LLC_BI__Stage__c ='Application';
                loanList.LLC_BI__Is_Review_Ready__c=true;
                loanList.PolicyAcknowledgement__c=true;
                insertLoan.add(loanList);
            }
            insert insertLoan;
        }
      		return  insertLoan;
    }
  
    
     /************************************************
    Method Name:createUser
    Descritption:method to create user
    Input Parameters: NA
    Output parameters:user
    
    **************************************************/
    public static user createUser(String ProfilName){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name=:ProfilName LIMIT 1];
        
        User usr = new User();
        usr.LastName = 'Test';
        usr.FirstName='User';
        usr.Alias = 'testUser';
        usr.Email = 'testuser@test.com';
        usr.Username = 'testuser11@testtest.com';
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US' ;

       insert usr;
       return usr;
    }
        
    
}