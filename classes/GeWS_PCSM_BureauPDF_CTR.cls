public class GeWS_PCSM_BureauPDF_CTR {
    
    public string str { get; set; }
    
    public GeWS_PCSM_BureauPDF_CTR(){
        Id recId = ApexPages.currentPage().getParameters().get('id');
        
        Account acc = [Select Id,Name from Account where Id=: recId Limit 1];
        str = 'Account Name : '+ acc.Name;
    }
        
}