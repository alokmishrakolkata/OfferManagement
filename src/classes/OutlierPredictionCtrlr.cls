public class OutlierPredictionCtrlr{

    public Outlier_Prediction__c objOLP {get; set;}
    
    public integer dtl {get; set;}
    
    public List<Outlier_Prediction_Detail__c> lstDtls {get; set;}
    public List<Probable_Solutions__c> lstSLN {get; set;}
    
    public OutlierPredictionCtrlr(){
        objOLP = new Outlier_Prediction__c ();
        getDetails();
    }
    
    
    public pagereference runDetail(){
        dtl = integer.valueOf(Math.rint((Math.random()*10)/2));
        //getDetails();
        getSolution();
        objOLP.Possible_Resolution__c = 'Check Bill Detail';
        return null;
    }
    public void getDetails(){
        List<Outlier_Prediction_Detail__c> lstRet = new List<Outlier_Prediction_Detail__c>();
        
        
            List<Outlier_Prediction_Detail__c> lstRet1 = [SELECT Id, Date__c, Description__c, No_of_Actions__c
                      FROM Outlier_Prediction_Detail__c];
            lstRet.add(lstRet1[0]);
            
        lstDtls = lstRet;
        getSolution();
    }
    
    public void getSolution(){
            lstSLN = new List<Probable_Solutions__c>();
            lstSLN.add(new Probable_Solutions__c ());
            
        if(dtl != null && dtl > 0){
        lstSLN  = [SELECT Id, Name, SLN__c, Solution__c FROM Probable_Solutions__c WHERE id='a079000000Jvr6r' Limit 1];//WHERE Solution_Category__c =: objOLP.Possible_Resolution__c];
        }
        
        
        
    }
}