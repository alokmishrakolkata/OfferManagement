public class ATTOfferPageControllerExt {
	
	public string strRejectOpt {get; set;}
	
	public Account currentAccount {get;set;}
	public List<Offers__c> newOffers {get;set;}
	public List<OfferWrapper> newOfferWrappers {get;set;}
	public List<QuestionWrapper> dynamicQuestionWrappers {get;set;}
	public List<Asset> customerAssets {get;set;}
	public string selectedOffer {get;set;}
	public boolean boolMasterCheckQuestions {get;set;}
	
	public List<AgentScript> agentScripts {get;set;}
	
	
	public boolean renderOffers {get;set;}
	public ATTOfferPageControllerExt(ApexPages.StandardController controller) {
		renderOffers = false;
		agentScripts = new List<AgentScript>();
		agentScripts.add(new AgentScript('1.Statement: Can I use your personal information during our conversation in making you the best offer from AT&T','boolean'));
		agentScripts.add(new AgentScript('2.What can I help you with today','boolean'));
		agentScripts.add(new AgentScript('3.	If don’t own Uverse TV then who is your provider?','boolean'));
		agentScripts.add(new AgentScript('4.	If don’t own Uverse internet then who is your provider?','boolean'));
		agentScripts.add(new AgentScript('5.	If don’t use cellular service then who is your provider?','boolean'));
		agentScripts.add(new AgentScript('6.	If don’t use AT&T long Distance, the who is your provider?','boolean'));
		agentScripts.add(new AgentScript('7.	If yes to any of 3,4,5 or 6, then goto next best offer','boolean'));

		
		



		
		
		
		boolMasterCheckQuestions=false;
		currentAccount= (Account)controller.getRecord();
		if(currentAccount==null){
			currentAccount = new Account(id='0019000000vC0tV');
		}
		customerAssets = [select id,Name,Product2Id from Asset where accountId = :currentAccount.id];
		set<id> assetsProductIds = new set<id>();
		for(Asset a: customerAssets){
			assetsProductIds.add(a.Product2Id);
		}
		
		dynamicQuestionWrappers = new List<QuestionWrapper>();
		List<DDQ__c> dynamicQuestions = [SELECT id,name,Que_Description__c, (select DDQ_recs__c,Offer_Description_Beta__c,Offered_Prod_id__c,Offers_Master__c,Offers_Product_Name_beta__c from Offer_DDQs__r) from DDQ__c where products__c in :assetsProductIds];
		for(DDQ__c ddq: dynamicQuestions){
			if(ddq.Offer_DDQs__r.size()>0)
				dynamicQuestionWrappers.add(new QuestionWrapper(ddq));
		}
		
		newOffers = new List<Offers__c>();
		newOfferWrappers = new List<OfferWrapper>();
		system.debug('----'+dynamicQuestions);
		
		viewOffers();
	}
	
	public Pagereference viewOffers(){
		
		
		newOffers = new List<Offers__c>();
		newOfferWrappers = new List<OfferWrapper>();
		set<id> offerIds = new set<id>();
		for(QuestionWrapper qWrapper: dynamicQuestionWrappers){
			system.debug('==============qWrapper.bCheck==='+qWrapper.bCheck+'  '+qWrapper.dynamicQuestion.Offer_DDQs__r);
			qWrapper.bCheck = true;
			
			if(qWrapper.bCheck){
				boolMasterCheckQuestions = true;
				for(Offer_DDQ__c oddq: qWrapper.dynamicQuestion.Offer_DDQs__r){
					offerIds.add(oddq.Offers_Master__c);
				}
			}
		}
		
		//if(offerIds.size() >0 ){
			newOffers = [select id, popularity__c,is_Cross_Sell__c ,Offer_Price__c,First_Bill__c,name,Offer_Description__c, Feature1__c,Feature2__c,Feature3__c,Feature4__c,Feature5__c,Feature1_Details__c,Feature2_Details__c,Feature3_Details__c,Feature4_Details__c,Feature5_Details__c,(select id,Product_Name_text__c ,Offer_Description__c,product__c from Offer_Line_Items__r) from Offers__c /*where id in:offerIds*/ order by popularity__c desc];
		//}
		
		for(Offers__c o: newOffers){
			newOfferWrappers.add(new OfferWrapper(o));
		}
		return null;
	}
	public Pagereference viewOffersMasterSelect(){
		
		
		newOffers = new List<Offers__c>();
		newOfferWrappers = new List<OfferWrapper>();
		set<id> offerIds = new set<id>();
		for(QuestionWrapper qWrapper: dynamicQuestionWrappers){
			system.debug('==============qWrapper.bCheck==='+qWrapper.bCheck+'  '+qWrapper.dynamicQuestion.Offer_DDQs__r);
			//qWrapper.bCheck = true;
			qWrapper.bCheck = boolMasterCheckQuestions;
			if(qWrapper.bCheck){
				for(Offer_DDQ__c oddq: qWrapper.dynamicQuestion.Offer_DDQs__r){
					offerIds.add(oddq.Offers_Master__c);
				}
			}
		}
		
		if(offerIds.size() >0 ){
			newOffers = [select id, popularity__c, is_Cross_Sell__c ,Offer_Price__c,First_Bill__c,name,Offer_Description__c, Feature1__c,Feature2__c,Feature3__c,Feature4__c,Feature5__c,Feature1_Details__c,Feature2_Details__c,Feature3_Details__c,Feature4_Details__c,Feature5_Details__c,(select id,Product_Name_text__c ,Offer_Description__c,product__c from Offer_Line_Items__r) from Offers__c where id in:offerIds  order by popularity__c desc];
		}
		
		for(Offers__c o: newOffers){
			newOfferWrappers.add(new OfferWrapper(o));
		}
		return null;
	}
	
	
	public Pagereference selectOffer(){
		
		return null;
	}
	
	public class OfferWrapper{
		public Offers__c offer{get;set;}
		public boolean selected{get;set;}
		public List<OfferLineItemWrapper> offerLineItemWrappers {get;set;}
		public List<String> offerFeatures {get;set;}
		public List<String> offerFeatureDetails {get;set;}
		public string popularityColor{get;set;}
		public OfferWrapper(Offers__c offer){
			
			system.debug('-----------------------------------------------------------------'+offer.popularity__c);
			popularityColor = '#FF3399';
			if(offer.popularity__c<40)
				popularityColor = 'green';
			else if(offer.popularity__c<70)
				popularityColor = '#FFCC66';
				
			offerFeatures = new List<String>();
			offerFeatureDetails = new List<String>();
			if(offer.Feature1__c!=null)
				offerFeatures.add(offer.Feature1__c);
			if(offer.Feature2__c!=null)
				offerFeatures.add(offer.Feature2__c);
			if(offer.Feature3__c!=null)
				offerFeatures.add(offer.Feature3__c);
			if(offer.Feature4__c!=null)
				offerFeatures.add(offer.Feature4__c);
			if(offer.Feature5__c!=null)
				offerFeatures.add(offer.Feature5__c);
				
			if(offer.Feature1_Details__c!=null)
				offerFeatureDetails.add(offer.Feature1_Details__c);
			if(offer.Feature2_Details__c!=null)
				offerFeatureDetails.add(offer.Feature2_Details__c);
			if(offer.Feature3_Details__c!=null)
				offerFeatureDetails.add(offer.Feature3_Details__c);
			if(offer.Feature4_Details__c!=null)
				offerFeatureDetails.add(offer.Feature4_Details__c);
			if(offer.Feature5_Details__c!=null)
				offerFeatureDetails.add(offer.Feature5_Details__c);
			
			offerLineItemWrappers = new List<OfferLineItemWrapper>();
			this.offer = offer;
			for(Offer_Line_Item__c oli:offer.Offer_Line_Items__r){
				offerLineItemWrappers.add(new OfferLineItemWrapper(oli));
			}
		}
	}
	
	public Pagereference SubmitAgentAcripts(){
		
		for(AgentScript agS: agentScripts){
			//if(agS.answer){
				renderOffers = true;
			//}
		}
		return null;	
	}
	
	public class OfferLineItemWrapper{
		public Offer_Line_Item__c offerLineItem{get;set;}
		public boolean active{get;set;}
		
		public OfferLineItemWrapper(Offer_Line_Item__c oli){
			this.offerLineItem = oli;
			this.active = true;
		}
	}
	
	
	public class AgentScript{
		
		public AgentScript(string q, string t){
			question=q;
			//answer = a;
			questiontype = t;
			//questiontype = 'boolean';
		}
		
		public string question {get;set;}
		public boolean answer {get;set;}
		public string answerT {get;set;}
		public string questiontype {get;set;}
		
	}
	
	public class QuestionWrapper{
		public QuestionWrapper(DDQ__c question){
			this.dynamicQuestion = question;
			this.bCheck = false;
		}
		
		public DDQ__c dynamicQuestion {get;set;}
		public boolean bCheck {get;set;}
	}

	
	public List<Account> getaccsandtmember() 
  {
      List<Account> accounts = [Select Id, Name,(select id,name from Contacts) BillingCountry from Account];
      return accounts;
  }
  
  public pagereference insertNotes(){
  	//strRejectOpt
  	Note objNotes = new Note(ParentId=currentAccount.Id,
                          	isPrivate=false,
                            Title=strRejectOpt,
                          	Body=strRejectOpt);
	insert objNotes;
	return null;
  }

}