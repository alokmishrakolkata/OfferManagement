public class AccCrntrl_new {
    list<asset> fetchAssets=new list<asset>();
    Set<Id> baseProdName=new Set<id>();
    public list<DDQ__c> DDQlist {get;set;}
    public list<wrapClas> displyWrap {get;set;}
    public list<Offer_DDQ__c> gtOffers {get;set;}
    public string tabRef {get;set;}
    public Id offernm {get;set;}
    set<id> DDQ_id=new set<Id>();
    public list<ShopClas> selectedoffr {get;set;}
    ID AccID;
    list<Contact> con=new list<contact>();
    Set<id> offerId=new set<id>();
    public list<Offer_Line_Item__c> offrelinItm {get;set;}
    public boolean renOffer {get;set;}
    public boolean renLead {get;set;}
    list<DDQ__c>  initialDDQ=new list<ddq__c>(); 
    set<id> fetSelectedOfr=new set<Id>();
    public Order od {get;set;}
    public Lead nLead {get;set;}
    public Set<Id> acceptedOfferst=new set<Id>();
    Public list<offers__c> acceptedOffercount=new list<offers__c>();

    public AccCrntrl_new(ApexPages.StandardController controller) {
        renoffer=false;
        renLead=false;
        displyWrap=new list<wrapclas>();
        DDQlist=new list<DDQ__c>();
        AccID= controller.getid();
        selectedoffr=new list<ShopClas>(); 
        con=[SELECT id,lastname,name,company__c from contact where accountid=:accid limit 1];

        fetchAssets= [select id,product2id,name from asset where accountid=:AccID];
        for(Asset asItr:fetchAssets){
            baseProdName.add(asItr.product2id);
        }


        if(baseProdName.size()>0){
            initialDDQ=[SELECT id,name,Que_Description__c from DDQ__c where products__c in :baseProdName];
        }      
        SYSTEM.DEBUG('###1'+initialDDQ);

        set<id> fetchID=new set<id>();
        for(DDQ__c DDQ_loop:initialDDQ)
            fetchID.add(DDQ_loop.id);
        set<id> finalid=new set<id>();
        SYSTEM.DEBUG('###2'+fetchID);

        list<Offer_DDQ__c> testD=new list<offer_ddq__c>();
        testD=[select id,DDQ_recs__c from Offer_DDQ__c where DDQ_recs__c in:fetchID];
        SYSTEM.DEBUG('###3'+testD);

        for(offer_ddq__c tDDQOffr:testD){
            finalID.add(tDDQOffr.ddq_recs__c);
        }


        ddqlist=[SELECT id,name,Que_Description__c from DDQ__c where id in :finalid order by Questions_Hit_rank__c limit 2];

        WrapClas tempwrap;
        for(DDQ__C Dvar:DDQlist){
            tempwrap=new wrapclas();
            tempwrap.DDqrec=Dvar;
            tempwrap.optn='None';
            displyWrap.add(tempwrap);
            DDQ_id.add(Dvar.id);
        }
    }

    public class wrapClas{
        public DDQ__c DDqrec {get;set;}
        public string optn {get;set;}
    }

    public void changeQue(){

        fetSelectedOfr.add(offernm);
        gtOffers=new list<Offer_DDQ__c>();


        gtOffers=[select id,Offers_Master__c from Offer_DDQ__c where DDQ_recs__c in:fetSelectedOfr];

        for(Offer_DDQ__c ofDq:gtOffers){
            offerId.add(ofDq.Offers_Master__c);
        }

        offrelinItm=new list<Offer_Line_Item__c>();
        offrelinItm=[select id,Product_Name_text__c ,Offer_Description__c,offers__r.Accepted_Offer_Count__c,product__c,offers__c from Offer_Line_Item__c where offers__c in:offerId];
    }

    public void shoppingcart(){
        System.debug('@@@'+tabRef);
      
        Offer_Line_Item__c tempOfferLinItm=new Offer_Line_Item__c();

        shopclas tempShopClas=new shopClas();

        Integer idx = 0,lstIndx=0;
        for(; idx<offrelinItm.size(); idx++){
            if(offrelinItm[idx].Offer_Description__c.equals(tabRef))
                break;
        }
        lstIndx=idx <= offrelinItm.size() ? idx : -1; 

        //Putting items in shopping cart
        tempOfferLinItm=offrelinItm.remove(lstIndx);
        tempShopClas.prodId=tempOfferLinItm.product__c;
        tempShopClas.prodName=tempOfferLinItm.Product_Name_text__c;
        selectedoffr.add(tempShopClas); 
        acceptedOfferst.add(tempOfferLinItm.offers__c);
    }

    public class ShopClas{
        public Id prodId {get;set;}
        public string prodName {get;set;}
        public integer quantty {get;set;}
        public double price {get;set;}
        public string selectedOffer {get;set;}
    }    

    public void createOdr(){

        try{
            set<id> offerPordictIds = new set<id>();
            for(shopClas varShop:selectedoffr){
                offerPordictIds.add(varShop.prodId);
            }

            list<pricebook2> priceId1=[SELECT id from pricebook2 where isstandard=true];
            od=new Order();
            od.accountid=AccID;
            od.EffectiveDate=date.today();
            od.status='Draft';
            od.pricebook2id=priceId1[0].id;
            insert od;
             renoffer=true;

            list<pricebookentry> priceId=[SELECT id,product2Id from pricebookentry where product2Id in :offerPordictIds and pricebook2id in:priceId1 ];//pricebook2id=:priceId1[0].id];
            Map<id,id> mapProductidPriceBookid = new Map<id,id>();
            for(pricebookentry p:priceId){
                mapProductidPriceBookid.put(p.product2Id,p.id);
            }

            list<orderitem> odrItmList=new list<orderitem>();
            orderitem odr;
            for(shopClas varShop:selectedoffr){ 
                odr=new orderitem();
                odr.Product__c=varShop.prodId;
                //  odr.Pricebookentryid=mapProductidPriceBookid.get(varShop.prodId);
                System.debug('@@@qw'+mapProductidPriceBookid.get(varShop.prodId));
                odr.Pricebookentryid= mapProductidPriceBookid.get(varShop.prodId);                  //'01u900000064elLAAQ';
                odr.quantity=varShop.quantty;
                odr.UnitPrice=varShop.price;
                odr.orderid=od.id;
                odrItmList.add(odr);
            }
            if(odrItmList.size()>0)
                insert odrItmList;
             acceptedOffercount=[SELECT id,Accepted_Offer_Count__c from offers__c where id in: acceptedOfferst];
             for(offers__c varOffer:acceptedOffercount){
               varOffer.Accepted_Offer_Count__c=varOffer.Accepted_Offer_Count__c+1;
             }
             update acceptedOffercount;
                        
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'New Order Created.');//Same old drama 
            ApexPages.addMessage(myMsg);                       
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
     }

    public void  createLead(){
        try{
            String prod='';
            for(shopClas varShop:selectedoffr){
                prod+=varShop.prodName+',';
            }
            nLead=new Lead();
            nLead.lastname=con[0].name;    
            nLead.company=con[0].company__C;
            nLead.Product_Interest__c=prod;
            insert nLead;  
            renLead=true;
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'New Lead Created.');//Same old drama 
            ApexPages.addMessage(myMsg);
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }
    
    public pagereference seeOrder(){
     Pagereference pg=new pagereference('/'+od.id);
     return pg;
    }
    
    public pagereference seeLead(){
     Pagereference pg=new pagereference('/'+nLead.id);
     return pg;
    }
    

}