public with sharing class ATTCreateOfferController {

		public string productId {get;set;}
		public string question {get;set;}
		
		public List<SelectOption> allOffers{get;set;}
		public List<SelectOption> selectedOffers{get;set;}
		public List<SelectOption> allQuestions{get;set;}
		public string selectedQuestion {get;set;}
		
	    public ATTCreateOfferController(){
	    	productId = System.currentPageReference().getParameters().get('id');
	    	
	    	
	    	allQuestions = new List<SelectOption>();
	    	List<DDQ__c> ddqs = [select Que_Description__c from DDQ__c where Products__c = :productId];
	    	for(DDQ__c ddq: ddqs){
	    		allQuestions.add(new Selectoption(ddq.id,ddq.Que_Description__c));
	    	}
	    	if(allQuestions.size()>0)
	    		selectedQuestion = allQuestions[0].getValue();
	    		
	    		
	    	
	    	allOffers = new List<SelectOption>();
	    	selectedOffers = new List<SelectOption>();
	    	List<Offers__c> offers = [select id,name,(select id, DDQ_recs__c, Offers_Master__c from Offer_DDQs__r) from Offers__c where Products__c = :productId];
	    	for(Offers__c offer: offers){
	    		
	    		boolean linked = false;
	    		for(Offer_DDQ__c oddq:offer.Offer_DDQs__r){
	    			if(offer.id==oddq.Offers_Master__c && selectedQuestion == oddq.DDQ_recs__c){
	    				selectedOffers.add(new Selectoption(offer.id,offer.name));
	    				linked = true;
	    				break;
	    			}
	    		}
	    		if(linked==false)
	    			allOffers.add(new Selectoption(offer.id,offer.name));
	    	}
	    	
	    }
		
		
		public Pagereference relate(){
			
			List<Offer_DDQ__c> upsertsOfferDDQs = new List<Offer_DDQ__c>();
			if(selectedOffers.size()>0 && selectedQuestion!=null && selectedQuestion!=''){
				for(Selectoption so: selectedOffers){
					
					Offer_DDQ__c oddq = new Offer_DDQ__c(DDQ_recs__c=selectedQuestion,Offers_Master__c=so.getValue(),ExternalKey__c=selectedQuestion+so.getValue());
					upsertsOfferDDQs.add(oddq);
				}
			}
			
			if(upsertsOfferDDQs.size()>0)
				upsert upsertsOfferDDQs ExternalKey__c;
				
			return null;
			
		}
		
		























	/*
		public string customerId {get;set;}
	    public Product2[] purchasedProducts {get;set;}
	    public ATTCreateOfferController(){
	        customerId = System.currentPageReference().getParameters().get('id');
	        
	        OrderItem[] ois = [select id,PricebookEntry.product2Id from OrderItem where order.accountId = :customerId];
	        set<id> productIds = new Set<id>();
	        for(OrderItem oi: ois){
	        	productIds.add(oi.PricebookEntry.product2Id);
	        }
	        
	        system.debug('-------------------------------------------------'+productIds);
	        purchasedProducts = [select name from Product2 where id in: productIds];
	        
	    }
	*/
	    
}