public class ATT_CreateOrderSubTabController {
	public List<id> productIds = new List<id>();
	public string offerId {get;set;}
	public string accountId {get;set;}
	
	public Order newOrder {get;set;}
	public list<orderitem> orderProducts {get;set;}
	public ATT_CreateOrderSubTabController(){
		
		newOrder = new Order();
		orderProducts=new list<orderitem>();
		
		offerId = system.currentPageReference().getParameters().get('offerId');
		accountId = system.currentPageReference().getParameters().get('accountId');
		
		
		if(offerId == null){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Offer not found.');//Same old drama 
            ApexPages.addMessage(myMsg);
            return;  
		}
		if(accountId == null){ 
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Account not found.');//Same old drama 
            ApexPages.addMessage(myMsg);  
            return;
		}
		
		Offers__c offer = [select id, (select id,Product__c,Product_Name_text__c from Offer_Line_Items__r) from Offers__c where id = :offerId];
		for(Offer_Line_Item__c oli: offer.Offer_Line_Items__r){
			productIds.add(oli.product__c);
		} 
		

        list<pricebook2> priceId1=[SELECT id from pricebook2 where isstandard=true];
        newOrder.accountid=accountId;
        newOrder.EffectiveDate=date.today();
        newOrder.status='Draft';
        newOrder.pricebook2id=priceId1[0].id;
            //insert newOrder;

        list<pricebookentry> priceId=[SELECT id,product2Id,UnitPrice  from pricebookentry where product2Id in :productIds and pricebook2id in:priceId1 ];//pricebook2id=:priceId1[0].id];
        Map<id,pricebookentry> mapProductidPriceBookid = new Map<id,pricebookentry>();
        for(pricebookentry p:priceId){
            mapProductidPriceBookid.put(p.product2Id,p);
        }

        
        orderitem orderProduct;
        for(id productId : productIds){ 
            orderProduct=new orderitem();
            orderProduct.Product__c=productId;
            System.debug('@@@qw'+mapProductidPriceBookid.get(productId));
            orderProduct.PricebookentryId = mapProductidPriceBookid.get(productId).id;
            orderProduct.Pricebookentry = mapProductidPriceBookid.get(productId);                  //'01u900000064elLAAQ';
            orderProduct.UnitPrice = mapProductidPriceBookid.get(productId).UnitPrice;
            orderProducts.add(orderProduct);
        }
            //if(orderProducts.size()>0)
                //insert orderProducts;
             
                        
                                  
     }
     
     public Pagereference createOrder(){
     	insert newOrder;
     	for(OrderItem oi: orderProducts){
     		oi.OrderId = newOrder.id;
     	}
     	insert orderProducts;
     	
     	return new ApexPages.StandardController(newOrder).view();
     }
	
}