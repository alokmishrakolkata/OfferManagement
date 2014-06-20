public class OutlierPredictionCtrlr{
	
	/*
    public Outlier_Prediction__c objOLP {get; set;}
    
    public integer dtl {get; set;}
    
    public List<Outlier_Prediction_Detail__c> lstDtls {get; set;}
    public List<Probable_Solutions__c> lstSLN {get; set;}
    
    public OutlierPredictionCtrlr(){
        objOLP = new Outlier_Prediction__c ();
        getDetails();
    }
    */
    public Account currentAccount {get;set;}
    public Asset[] assetsList {get;set;}
    public string allAssets {get;set;} 
    public List<Billing_History__c> billingHistorys{get;set;}
    public integer averageBill {get;set;}
    public integer lastBillAmount {get;set;}
    public integer customerLifeCycleValue {get;set;}
    public boolean isDue{get;set;}
    public OutlierPredictionCtrlr(ApexPages.StandardController controller) {
    	lastBillAmount = 0;
    	customerLifeCycleValue = 0;
    	averageBill = 0;
    	isDue = false;
    	allAssets = '';
    	currentAccount = (Account)controller.getRecord();
    	
    	currentAccount = [select id, Customer_Since__c,Changed_Plan_In__c from Account where id =:controller.getId()];
    	assetsList = [select Product2.name,name from Asset where accountid = :currentAccount.id];
    	for(Asset a: assetsList)
    		allAssets+=','+a.name;
    		
    	if(allAssets != null && allAssets.startswith(','))
    		allAssets = allAssets.substring(1);
    		
    	
    	billingHistorys = [select id,name,Account__c,Bill_Amount__c,Bill_Cycle__c,Due_Date__c,Paid_Date__c from Billing_History__c where account__c = :currentAccount.id order by Due_Date__c desc limit 4];
    	for(Billing_History__c bh: billingHistorys){
    		averageBill += Integer.valueof(bh.Bill_Amount__c);
    	}
    	
    	if(billingHistorys.size()>0){
    		lastBillAmount = Integer.valueof(billingHistorys.get(0).Bill_Amount__c);
    		if(billingHistorys.get(0).Paid_Date__c == null)
    			isDue = true;
    	}
    	
    	if(averageBill >0){
    		averageBill = averageBill/billingHistorys.size();
    		customerLifeCycleValue = averageBill * 12;
    	}
    	
    }
    
    
    /*
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
    */
}