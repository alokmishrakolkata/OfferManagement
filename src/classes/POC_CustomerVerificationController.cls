public class POC_CustomerVerificationController {
	
	public Account currentAccount {get;set;}
	public AddressValidator addressVal {get;set;}
	public POC_CustomerVerificationController(ApexPages.StandardController controller){
		currentAccount= (Account)controller.getRecord();
		currentAccount = [select id, name, phone,SSN__c,Billing_Account_Number__c,Billing_Address__c from Account where id = :currentAccount.id];
		
		addressVal = new AddressValidator();
		getData();
	}
	
	public PageReference verify(){
		
		integer validationCount = 0;
		if(addressVal.ban) validationCount++;
		if(addressVal.ssn) validationCount++;
		if(addressVal.address) validationCount++;
		if(addressVal.phone) validationCount++;
		if(addressVal.name) validationCount++;
		
		if(validationCount<3){
			addressVal.isVerified=false;
			apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'At least 3 attributes should be validated correctly');
    		apexpages.addmessage(msg);
		}else{
			addressVal.isVerified=true;
		}
		
		return null;
	}
	
	public class AddressValidator{
		
		public Boolean ban {get;set;}
		public Boolean ssn {get;set;}
		public Boolean address {get;set;}
		public Boolean phone {get;set;}
		public Boolean name {get;set;}
		
		public Boolean isVerified {get;set;}
		
		
		public AddressValidator(){
			ban=false;
			ssn=false;
			address=false;
			phone=false;
			name=false;
			isVerified=false;
		}
		
	}
	
	public List<gaugeData> dataX {get;set;}
	public List<gaugeData> getData() {
		/*
        double NPS_score = 0;
        CA_NPS_Score__c score = [Select Id, Name, Total_NPS_Score__c, Most_Current__c  From CA_NPS_Score__c Where Most_Current__c = true];
		*/
		
		integer score = 0;
		AggregateResult[] groupedResults   = [SELECT createdById, sum(TotalAmount) totalOAmount     FROM Order where createdById=:UserInfo.getUserId()     GROUP BY createdById];
		if(groupedResults.size()>0){
			score = Integer.valueOf((decimal)groupedResults.get(0).get('totalOAmount'));
		}
		
		//score=3000;
        dataX = new List<gaugeData>();
        
        dataX.add(new gaugeData('Total', score));
        //dataX.add(new gaugeData('NPS', 20));
        //dataX.add(new gaugeData('NPS', 30));
        return dataX;
    }
    public class gaugeData {
        public String name { get; set; }
        public decimal score { get; set; }
        public decimal lowRange { get; set; }
        public decimal highRange { get; set; }

        public gaugeData(String name, decimal npsScore) {
            this.name = name;
            this.lowRange = 2000;
            this.highRange = 5000;
            this.score = npsScore;
        }
    }

}