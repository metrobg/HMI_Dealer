// ActionScript file
	import mx.collections.ArrayCollection;
	import mx.events.*;
	import mx.controls.Alert;
	 
	[Bindable]
     public var myAC:ArrayCollection = new ArrayCollection;
     
     [Bindable]
     public var mode:String = 'update';
     
     private var newKey:Number;
     
     private var activeRecord:Number;
     private var returnCode:Number;
     
[Embed(source="assets/Add.png")]
        [Bindable]
        public var addCls:Class;  
[Embed(source="assets/Close.png")]
         [Bindable]
         public var closeCls:Class;  

[Embed(source="assets/Delete.png")]
        [Bindable]
         public var deleteCls:Class;  
[Embed(source="assets/Form.png")]
         [Bindable]
         public var formCls:Class;              

[Embed(source="assets/List.png")]
        [Bindable]
        public var imgCls:Class;  

[Embed(source="assets/Ok.png")]
        [Bindable]
        public var okCls:Class; 
        
[Embed(source="assets/Preview.png")]  
        [Bindable]
        public var previewCls:Class;
 
 [Embed(source="assets/Remove.png")]
        [Bindable]
        public var removeCls:Class; 
               
[Embed(source="assets/Save.png")]
        [Bindable]
        public var saveCls:Class; 
        
[Embed(source="assets/Search.png")]
        [Bindable]
        public var searchCls:Class;   
             
[Embed(source="assets/Stop.png")]
        [Bindable]
        public var stopCls:Class;  
                    
[Embed(source="assets/Update.png")]
       [Bindable]
       public var updateCls:Class;  
              
[Embed(source="assets/Warning.png")]
        [Bindable]
        public var warningCls:Class;  
        
 
        
        
private function getResultOk(r:Number,event:Event):void {
		switch(r)
		{
			case 1:
			   myAC = getCodes.lastResult.codeList.record;
			   resultGrid.dataProvider = myAC;           		
               break;
			case 2:			
				returnCode = updateRepairCode.lastResult.root.status; 
			    if(Number(returnCode) == 2) {
			    	Alert.show("Problem updating Record", "Error", 3, this, null,warningCls);
			    		    	 
		         } 	else {
		         	currentState = '';
		         	updateGrid();
		         }	 	  
			   break;
			case 3:
			  returnCode = addRepairCode.lastResult.root.status; 
			    if(Number(returnCode) == 2) {
			    	Alert.show("Problem adding record","Error");			    				         	    			    	 
		         } else {
		         	 var itemObj:Object = new Object; 	
			    	itemObj = {id:addRepairCode.lastResult.root.id,
			                   code:addRepairCode.lastResult.root.code,
			                   description:addRepairCode.lastResult.root.description,
			                   price:addRepairCode.lastResult.root.price}
			        addItemToGrid(itemObj); 
			        Alert.show("Record Added", "Success", Alert.OK, this, null,okCls);
			        currentState = '';	
			        break;
		         } 
		     case 4:
		           returnCode = deleteRepairCode.lastResult.root.status;
			         if(Number(returnCode) == 2) {
			         	Alert.show("Problem deleting Record", "Error", Alert.OK, this, null,warningCls);
			         
			         } else {
			            Alert.show("Record Deleted","Success", Alert.OK, this, null,okCls);
			         	removeItemFromGrid(activeRecord);
			         	currentState = '';
			         	break;
		         }
		     case 999:
		         Alert.show("Unknown Error","Attention", Alert.OK, this, null,stopCls);
		         break;  
			}
		}
		
private function gridItemSelected(event:ListEvent):void{
			     activeRecord  = event.rowIndex -1;
				 currentState="Edit";
				 mode = 'update';
				 delete_btn.enabled = true;										
		}  
		 
 
private function buttonHandler(value:String):void{
	if(value == 'delete')
	    mode = 'delete';
	switch(mode) 
	   {
		case "update":
			updateRepairCode.send();
			currentState = '';
			break;
		case 'add':
		    addRepairCode.send();
		    break;
		case 'delete':
		     deleteCode();
		     break;	    
	   }	 	
}

private function alertClickHandler(event:CloseEvent):void {
	             if (event.detail==Alert.YES) {
                     deleteRepairCode.send();                   
                  }  
}


private function addRecord():void {
			     code_fld.text = '';
			     description_ta.text = '';
			     price_fld.text = '';
			     mode = 'add';
			     currentState = 'Edit';
			     delete_btn.enabled = false;
			}
			
private function addItemToGrid(obj:Object):void {
			     myAC.addItemAt(obj,0);
			     resultGrid.dataProvider = myAC;
			     myAC.refresh();		
	} 	
		
private function removeItemFromGrid(position:Number):void {
			     myAC.removeItemAt(position);
			     resultGrid.dataProvider = myAC;
			     myAC.refresh();
		
	} 	

private function deleteCode():void {
	             mode = 'delete';
	      	  //   Alert.show("Delete Code " + code_fld.text.toUpperCase(), "Really Delete", 3, this, alertClickHandler);
                 Alert.show("Delete Code " + code_fld.text.toUpperCase(), "Really Delete", 3, this, alertClickHandler,warningCls);
}       
                  
private function updateGrid():void {
		         if ( this.resultGrid.selectedItem !== null) {
			        myAC.setItemAt({
			        id:id_fld.text,
			        code:code_fld.text,
			        price:price_fld.text,
			        description: description_ta.text},
			        activeRecord);
			        myAC.refresh();
		}
	} 