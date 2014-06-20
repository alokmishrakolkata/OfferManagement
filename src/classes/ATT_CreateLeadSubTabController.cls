public class ATT_CreateLeadSubTabController {
    
    public Lead newLead{get;set;}
    public string offerId {get;set;}
    public string accountId {get;set;}
    
    public Task newtask {get;set;}
    public ATT_CreateLeadSubTabController(){
    	newtask = new Task();
    	
        offerId = system.currentPageReference().getParameters().get('offerId');
        accountId = system.currentPageReference().getParameters().get('accountId');
        
        //newTask.WhatId = accountId;
        
        newLead = new Lead();
        
        Offers__c offer = [select id, (select id,Product__c,Product__r.name,Product_Name_text__c from Offer_Line_Items__r) from Offers__c where id = :offerId];
        Account cAccount = [select id,name,phone from Account where id = :accountId];
        
        
        String prod='';
        for(Offer_Line_Item__c oli: offer.Offer_Line_Items__r){
            prod+=oli.Product__r.name+';';
        }
        
        
        newLead.Offer__c = offerId;   
        newLead.lastname=cAccount.name; 
        newLead.Company = cAccount.name;  
        newLead.Status = 'Working - Contacted'; 
        newLead.phone = cAccount.Phone;
        //newLead.email = cAccount.email;
        
        //newLead.company=cAccount.company__C;
        newLead.ProductInterest__c=prod;
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'New Lead Created.');//Same old drama 
        ApexPages.addMessage(myMsg);
                                  
     }
     
     public Pagereference createLead(){
        insert newLead;
        
        newtask.WhoId = newLead.id;
        
        if(newtask.Subject != null && newtask.Subject != '')
        	insert newtask;
        return new ApexPages.StandardController(newLead).view();
     }
    
}