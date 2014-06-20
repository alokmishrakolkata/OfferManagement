public with sharing class CreateOfferController {

	public string customerId {get;set;}
	
	public CreateOfferController(){
		customerId = System.currentPageReference().getParameters().get('id');
		
		
	}
}