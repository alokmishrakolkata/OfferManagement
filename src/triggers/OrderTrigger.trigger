trigger OrderTrigger on Order (after insert, before update) {
	AgentGoal__c [] ags = [select Agent__c,Target__c from AgentGoal__c where Agent__c=:UserInfo.getUserId()];
	if(ags.size()==0){
		AgentGoal__c ag = new AgentGoal__c(Agent__c = UserInfo.getUserId());
		insert ag;
		ags.add(ag);
	}
    if(trigger.isInsert && trigger.isafter){
    	
		order [] ordersToUpdate = new List<Order>();
        for(Order o: trigger.new){
            ordersToUpdate.add(new Order(id=o.id,Agent_Goal__c= ags.get(0).id));    
        }
        update  ordersToUpdate;
    }
    
    if(trigger.isUpdate && trigger.isBefore){
		for(Order o: trigger.new){
            o.Agent_Goal__c = ags.get(0).id;            
        }
    }
}