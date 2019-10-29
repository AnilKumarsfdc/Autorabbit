public without sharing class LTVPPCalculation {
    
    //@AuraEnabled
    //public static LTVPPWrapper wrapperObj{get;set;}
    public static List<sobject> lstToUpdate;
    
/*Method to calculate Total Loan Amount, Total Lendable value, Total Santander Value and LTV at Product Package level
This method can be called when, 
    1. Loan amount is changed for associated loan 
    2. Lendable value OR santander value is changed for associated collateral
    3. A Collateral is linked/unlinked to/from product package
*/
    public static string calculateLTVForPP(List<string> recordIds, boolean atRGLevel) {
        //SELECT Id, LLC_BI__Product_Package__c, Sum(LLC_BI__Amount__c) TOTALLOANVALUE FROM LLC_BI__Loan__c WHERE LLC_BI__Product_Package__c in ('a449E000000BsFSQA0', 'a449E000000BsKEQA0', 'a449E000000BsLvQAK', 'a449E000000BsikQAC') AND LLC_BI__Status__c IN ('Open','Hold','In Review') GROUP BY Id, LLC_BI__Product_Package__c ORDER BY LLC_BI__Product_Package__c 

        try{
           // wrapperObj =  new LTVPPWrapper();
            List<LLC_BI__Loan__c> lstLoan;
            List<Risk_Group__c> lstRG;
            Set<Id> setRGIds = new Set<Id>();
            
            if (!atRGLevel) 
                lstLoan = SOQLUtility.getloanrecordsatPPlevel(recordIds);
            else {
                lstRG = SOQLUtility.getRGrecordsfromPP(recordIds);
                //lstLoan = SOQLUtility.getloanrecordsfromPP(recordIds);
                lstLoan = [SELECT Id, LLC_BI__Product_Package__c, LLC_BI__Amount__c, Risk_Group__c, LLC_BI__Status__c FROM LLC_BI__Loan__c WHERE LLC_BI__Product_Package__c in :recordIds AND Risk_Group__c != null AND LLC_BI__Status__c IN ('Open','Hold','In Review') ORDER BY Risk_Group__c LIMIT 15000];
                recordIds = new List<String>();
                for (Risk_Group__c objRG:lstRG) {
                    recordIds.add(objRG.Id);
                }
            }
            Set<Id> setIds = new Set<Id>(); 
            Map<String, List<Decimal>> mapValuesByPP = new Map<String, List<Decimal>>();
            
            //Calculate total loan value of each active loan per product package
            for (LLC_BI__Loan__c objLoan:lstLoan) {
                setIds.add(objLoan.Id);
                string mapKey = atRGLevel?objLoan.Risk_Group__c:objLoan.LLC_BI__Product_Package__c;
                List<Decimal> lstValues = mapValuesByPP.get(mapKey);
                if (lstValues == null) 
                    lstValues = new List<Decimal>{0,0,0,0};
                if (objLoan.LLC_BI__Amount__c != null) {
                    lstValues[0] = lstValues[0] + objLoan.LLC_BI__Amount__c;
                }
                mapValuesByPP.put(mapKey, lstValues);
            }
            //Set 0 as total loan value if no active loan found for product package OR risk group
            for (String recordId:recordIds) {
                List<Decimal> lstValues = mapValuesByPP.get(recordId);
                if (lstValues == null) {
                    lstValues = new List<Decimal>{0,0,0,0};
                    mapValuesByPP.put(recordId, lstValues);
                }
            }

            List<sobject> lstLoanColl;
            
            if (!atRGLevel)
                lstLoanColl = SOQLUtility.sumofCollateral(setIds);
            else
                lstLoanColl = SOQLUtility.getCollateralsForRG(new Set<String>(recordIds));
                
            Map<String, List<sobject>> mapCollaterals = new Map<String, List<sobject>>();
            set<string> setUniqueCallIds = new set<string>();
            //Calculate total lendable and santander values for each product package
            //Also prepare a list of collateral pledged records for each product package which will be used in calculating LTV
            decimal totalLValue, totalSanValue;
            string mapKey='';
            List<Decimal> lstValues;
            List<sobject> lstPledged;
            for(sobject objLoanColl :lstLoanColl){
                mapKey='';
                totalLValue = 0;
                totalSanValue = 0;
                if (atRGLevel) {
                    mapKey = (string)objLoanColl.get(ConstantUtility.LTV_RISK_GROUP);
                    totalLValue = (Decimal)(objLoanColl.get(ConstantUtility.LTV_LENDABLE_VALUE_WDV));
                    totalSanValue = (Decimal)(objLoanColl.get(ConstantUtility.LTV_SANTANDER_VALUE));
                }
                else {
                    mapKey = (string)(objLoanColl.getSobject(ConstantUtility.LTV_LOAN).get(ConstantUtility.LTV_PRODUCT_PACKAGE));
                    if (setUniqueCallIds.contains(mapKey + '-' + objLoanColl.get('LLC_BI__Collateral__c'))) {
                        continue;
                    }
                    totalLValue = (Decimal)(objLoanColl.getSobject(ConstantUtility.LTV_Collateral).get(ConstantUtility.LTV_LENDABLE_VALUE_WDV));
                    totalSanValue = (Decimal)(objLoanColl.getSobject(ConstantUtility.LTV_Collateral).get(ConstantUtility.LTV_SANTANDER_VALUE));
                    setUniqueCallIds.add(mapKey + '-' + objLoanColl.get('LLC_BI__Collateral__c'));
                }
                
                lstValues = mapValuesByPP.get(mapKey);            
                lstValues[1] = lstValues[1] + totalLValue;
                lstValues[2] = lstValues[2] + totalSanValue;
                mapValuesByPP.put(mapKey, lstValues);
                
                lstPledged = mapCollaterals.get(mapKey);
                if (lstPledged == null) 
                    lstPledged = new List<sobject>();
                lstPledged.add(objLoanColl);
                mapCollaterals.put(mapKey, lstPledged);
            }
            lstToUpdate = new List<Sobject>();
            
            sobject objToUpdate;
            for (string mapId:mapValuesByPP.keySet()) {
                lstValues = mapValuesByPP.get(mapId);
                if (lstValues == null) continue;
                if (!atRGLevel) {
                    objToUpdate = new LLC_BI__Product_Package__c();
                }
                else {
                    objToUpdate = new Risk_Group__c();
                }
                objToUpdate.put('Id', mapId);
                objToUpdate.put('Total_Loan_Value__c', lstValues[0]);
                objToUpdate.put('Total_Lendable_value__c', lstValues[1]);
                objToUpdate.put('Total_Santander_Value__c', lstValues[2]);
                lstPledged = mapCollaterals.get(mapId);
                if (lstPledged == null) {
                    objToUpdate.put(atRGLevel?'RGLTV__c':'LTV__c', 0);
                }
                else {  
                    objToUpdate.put(atRGLevel?'RGLTV__c':'LTV__c' , LTVPPCalculation.LTV(lstValues[0], atRGLevel, lstPledged));
                }
                lstToUpdate.add(objToUpdate);
            }
            if (lstToUpdate.size() > 0) update lstToUpdate;
            return 'success';
        }catch(exception e){
            return null;
        }
    }
    
    /*****************************************************************
* Called from Lightning Component to display summarize data at product package level
* PPID passed from lightnig component
* ***************************************************************/
    @Auraenabled
    public static LLC_BI__Product_Package__c getPPCalculations(string ppID){
        List<LLC_BI__Product_Package__c> lstPP;
        //system.debug('-->');
        //  wrapperObj =  new LTVPPWrapper();
        
        //Get product package record 
        try{
            lstPP = SOQLUtility.getPPrecordsforLTV(ppID);
            system.debug('lstPP-->'+lstPP);
            system.debug('lstPP-->'+lstPP[0]);   
            if(lstPP == null || lstPP.size() == 0){
                return null;
                    
            }
             
        }
        catch(exception e){
            return null;
        }
        return lstPP[0];   
    }
    
    
    /**************************************************************************
* Fucntion to calculate LTV
//MultipleCollateral//Exposure (Sum of Loan Facility Amount) - Santander Value(Sum of all Collateral except the highest) / Collateral Valuation (highest value collateral) * 100
//singleCollateral//Exposure(Sum of Loan Facility Amount)  / Collateral valuation * 100
//**************************************************************************/
    public static Decimal LTV(Decimal loanTotal, boolean atRGLevel, List<sobject> lstPledged){
        boolean isSuccess = true;
        //system.debug('loanTotal-->' +loanTotal);
        try {
            return calculateLTV(loanTotal, atRGLevel, lstPledged);
        } catch (Exception ex) {
            isSuccess = false;
        }
        return 0;
    }
    
    private static Decimal calculateLTV(Decimal loanTotal, boolean atRGLevel, List<sobject> collateralValue) {
        //Declarations
        Decimal santanderValue = 0;
        decimal totalsandervalue = 0;
        Decimal LTV = 0;
        Decimal highestSantanderValue = 0;
        Decimal highestCollateralValue = 0;
        
        decimal maxvalue = 0;
        integer totalCollateral = 0;
        integer totalSelectedColl = 0;
        
        //Filter Collateral Based on Flow Chart conditions
        totalCollateral = collateralValue.size();
            
        for(sobject colls:collateralValue)
        {
            totalsandervalue = totalsandervalue + (atRGLevel?(Decimal)colls.get('Santander_Value__c'):(Decimal)(colls.getSobject('LLC_BI__Collateral__r').get('Santander_Value__c'))); 
            //system.debug('totalsandervalue found ' + colls + ' ' + totalsandervalue);
            LLC_BI__Collateral__c objCollMngt = (LLC_BI__Collateral__c)(atRGLevel?colls:colls.getsobject('LLC_BI__Collateral__r'));
            
            if (validateCollateralCriteria(objCollMngt)) {
                totalSelectedColl++;
                if (totalSelectedColl == 1) {
                    maxvalue = (atRGLevel?(Decimal)colls.get('Santander_Value__c'):(Decimal)(colls.getSobject('LLC_BI__Collateral__r').get('Santander_Value__c')));
                    highestCollateralValue = (Decimal)(atRGLevel?colls.get('Collateral_Valuation_Value__c'):colls.getsobject('LLC_BI__Collateral__r').get('Collateral_Valuation_Value__c'));
                }
            }
        }
        if (totalSelectedColl > 0){
            highestSantanderValue  = (Decimal)(atRGLevel?collateralValue[0].get('Santander_Value__c'):collateralValue[0].getSobject('LLC_BI__Collateral__r').get('Santander_Value__c'));
        }
        santanderValue = totalsandervalue - maxValue;
        
        //system.debug('collateralValue-->' +collateralValue.size() + ' ' + collateralValue);
        //system.debug('highestSantanderValue-->' +highestSantanderValue);
        //system.debug('highestCollateralValue-->' +highestCollateralValue);
        //system.debug('loanTotal-->' +loanTotal);
        
        if(totalSelectedColl==0){
          //  wrapperObj.LTV = 0;
            //system.debug('LTV--> '+LTV);
            return 0;
        }
        
        
        if(totalSelectedColl==1){
            //system.debug('highestCollateralValue--> '+highestCollateralValue);
            if (totalCollateral == 1)     
                LTV = (loanTotal/highestCollateralValue)*100;
            else 
                LTV = ((loanTotal - santanderValue) /highestCollateralValue) * 100;
          //  wrapperObj.LTV = LTV;
            //system.debug('LTV--> '+LTV);
            LTV = LTV.setScale(2);
            return LTV;
        }
        
        if(totalSelectedColl>1){
            //Get IDS of Collaterals who satisfy the condition
            //System.debug('Selected Collaterals '+collateralValue);
            //System.debug('santanderValue '+santanderValue);
            
            //Calculation
            if (santanderValue == null) santanderValue = 0;
            LTV = ((loanTotal - santanderValue) /highestCollateralValue) * 100;
            LTV = LTV.setScale(2);
          //  wrapperObj.LTV = LTV;
            //System.debug('LTV------------>'+LTV);
            return LTV;
        }
        return 0;
    }
    
    private static boolean validateCollateralCriteria(LLC_BI__Collateral__c objColl) {
        //system.debug('objColl-->' +objColl);
        if((objColl.Collateral_Type_Formula__c ==  ConstantUtility.LTV_RESIDENTIAL_PROPERTY
            || objColl.Collateral_Type_Formula__c == ConstantUtility.LTV_SOCIAL_HOUSING
            || objColl.Collateral_Type_Formula__c == ConstantUtility.LTV_COMMERCIAL_PROPERTY
            || objColl.Collateral_Type_Formula__c == ConstantUtility.LTV_LARGE_PROPERTY_PORTFOLIO) 
           && objColl.Ranking__c ==  ConstantUtility.LTV_RANKING
           && objColl.Further_Advance_with_no_DoP__c == ConstantUtility.LTV_FURTHER_ADVANCE_WITH_NO_DOP  
           && objColl.Direct_Third_Party_Charge__c == ConstantUtility.LTV_DIRECT_THIRD_PARTY_CHARGE){
               //system.debug('valid coll ' + objColl);
               return true;
           }
        return false;
    }
    /********************************************************
* Called from LTVMain controller "Calculate LTV button"
* Calculated LTV on Risk Group Level
* ******************************************************/
    
    @AuraEnabled
    Public static Boolean LTVCalculation(String ppID){
        Boolean isSuccess = true;
        try{
            calculateLTVForPP(new List<String>{ppID}, true);
        } catch(exception e){
            return isSuccess;
        }
        return isSuccess;
    }
}