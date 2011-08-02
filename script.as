// ActionScript file
import flash.events.Event;
import mx.controls.Alert;
import mx.events.ItemClickEvent;
import com.metrobg.Icons.Images1;
import com.metrobg.Classes.NumberUtilities;
import mx.rpc.http.HTTPService;

[Bindable] public var totalRecords:String;
 
[Bindable]  public var searchType:String;
[Bindable] private var random:Number;
 
private function makeRandom(service:mx.rpc.http.HTTPService):void {
	             random = NumberUtilities.getUnique();
	             service.send();
}

private function clearSearchField():void {
				search_fld.text = "";
				ta1.text = "";
			}
			
			private function gridItemClicked(eventObj:Event):void {				
				var item:String  = resultGrid.selectedItem.sn;
				
				  if (item == null) {
				  	return;
				  } else {
				  	makeRandom(detailRequest);
				  }								 
			}
			
private function getResultOk(r:Number,event:Event):void {
	//ta1.text = "result status = " + r;
		if(!r){
     		Alert.show('Error sending data!!');     		
    		return;
		}
	if(r == 1) {
       resultGrid.dataProvider = lookUpRequest.lastResult.items.record;
       totalRecords = lookUpRequest.lastResult.items.count;
       Application.application.gridPanel.title = "Search Results: " + totalRecords;
 } else {
 
     if (r == 2) {
     	ta1.htmlText = "";
 	    ta1. htmlText = detailRequest.lastResult.items.comments;
	       } else {
		      Alert.show("item not found","Attention");
	       }
	
     }
}