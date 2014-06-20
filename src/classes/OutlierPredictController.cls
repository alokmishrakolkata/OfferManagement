public class OutlierPredictController
{        public string txtArea {get; set;}
        public string SelectedVal {get; set;}
        public string Description {get; set;}
        public boolean isDispOpt1 {get; set;}
        public boolean isDispOpt2 {get; set;}
        public boolean isDispOpt3 {get; set;}
        public boolean isDispOpt4 {get; set;}
        public boolean isDispOpt5 {get; set;}
        public boolean anOption {get; set;}
        public List<Billing_History__c> billingHistorys{get;set;}
        public OutlierPredictController()
        {
        	anOption = false;
        }
        
        public Account currentAccount {get;set;}
        public OutlierPredictController(ApexPages.StandardController controller) {
        	currentAccount = (Account)controller.getRecord();
        }
        public void getInfo()
        {
                /*List<demotm__Outlier_Prediction__c> lstRet = [SELECT Id, demotm__Description__c, demotm__Prediction__c
                                                                                                                  FROM demotm__Outlier_Prediction__c
                                                                                                                  WHERE demotm__Prediction__c =:SelectedVal];
                if(!lstRet.isEmpty() && )                                                                                                  
                Description = lstRet[0].demotm__Description__c;*/
                isDispOpt1 = false;
                isDispOpt2 = false;
                isDispOpt3 = false;
                isDispOpt4 = false;
                isDispOpt5 = false;
                anOption = false;
                if(SelectedVal == 'Payment made after due date')
                {
                    isDispOpt1 = true;
                    anOption = true;
                }
                else if(SelectedVal == 'Discount Not applied')
                {
                    isDispOpt2 = true;
                    anOption = true;
                }
                else if(SelectedVal == 'Billing Dispute')
                {
                    isDispOpt3 = true;
                    anOption = true;
                    
                    billingHistorys = [select id,name,Account__c,Bill_Amount__c,Bill_Cycle__c,Due_Date__c,Paid_Date__c from Billing_History__c where account__c = :currentAccount.id order by createddate desc];
                    
                }
                else if(SelectedVal == 'Adjustment Not Showing up')
                {
                    isDispOpt4 = true;
                    anOption = true;
                }else if(SelectedVal=='Devices/assets'){
                	isDispOpt5 = true;
                    anOption = true;
                    
                    assests = [Select Status, PurchaseDate, Price,quantity, Name From Asset where accountId = :currentAccount.id order by createddate desc];
                }

                system.debug('====>'+Description);
        }
        public Asset[] assests {get;set;}
        
        public List<SelectOption> getOptions()
        {
                List<SelectOption> lstOptions = new List<SelectOption>();
                lstOptions.add(new SelectOption('--Please Select--', '--Please Select--'));
                
                Schema.DescribeFieldResult result = demotm__Outlier_Prediction__c.demotm__Prediction__c.getDescribe();
                List<Schema.PicklistEntry> lstPicklistVal = result.getPicklistValues();
                
                for(Schema.PicklistEntry entry :lstPicklistVal)
                        lstOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
                
                return lstOptions;
        }
}