/****************************************************************
* @Author: Alagar
* @Class: GeWS_PCSMautoDecision
* @Description: This is the structure of the PCSM payload request
*****************************************************************/
public class GeWS_PCSM_payloadStructure{
    
    //START of bureau
    public class request {
        public string control { get; set; }
        public string customer { get; set; }
    }
    
    public class personalInfo{
        public string personalCode { get; set; }
        public string personalType { get; set; }
        public string personalInfo { get; set; }
    }
    //END of Bureau
    
    //Start of GET DECISION
    public class customer{
        public string customerId { get; set; }
        public string ratings { get; set; }
        public string address { get; set; }
        public string collateral { get; set; }
        public string policyException { get; set; }
        public string newProducts { get; set; }
        public string existingProducts { get; set; }
        public string serviceAbility { get; set; }
        public string Director { get; set; }
        public string financials { get; set; }
    }
    
    //END of GET DECISION
    
}