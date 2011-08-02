// ActionScript file


private function mnewCustomer():void {
	dp2.item[1].@enabled = true;               // enable save function
	dp2.item[0].editItem[0].@enabled = true;   // enable new customer menu selection
	dp2.item[1].editItem[1].@enabled = true;  // disable save estimate
	dp2.item[1].editItem[2].@enabled = false;  // disable save order
	dp2.item[3].@enabled = false;             // disable conversion
}

private function mnewEstimate():void {
	      dp2.item[1].@enabled = true;               // enable save function 
	   	  dp2.item[0].editItem[0].@enabled = true;   // enable new customer menu selection
	   	  dp2.item[1].editItem[0].@enabled = true;   // enable save customer
	   	  dp2.item[1].editItem[1].@enabled = true;   // enable save estimate
	   	  dp2.item[1].editItem[2].@enabled = false;  // disable save order
	   	  dp2.item[3].@enabled = false;             // disable conversion
	   	  dp2.item[6].@enabled = true                // enable cc processing
}

private function mnewOrder():void {
	      dp2.item[1].@enabled = true;              // enable save function
	   	  dp2.item[0].editItem[0].@enabled = true;  // enable new customer menu selection
	   	  dp2.item[1].editItem[0].@enabled = true;   // enable save customer
	   	  dp2.item[1].editItem[1].@enabled = false; // disable save estimate
	   	  dp2.item[1].editItem[2].@enabled = true;  // enable save order
	   	  dp2.item[3].@enabled = false;             // disable conversion	
	   	  dp2.item[6].@enabled = true                // enable cc processing
}

private function mconvertToOrder():void {
	
	
	dp2.item[1].@enabled = false;                   // disable save menu
	dp2.item[1].editItem[1].@enabled = false;       // disable save estimate
	dp2.item[2].@enabled = true;                   // enable print menu
    dp2.item[4].editItem[0].@enabled = false;       // disable update estimate
    dp2.item[4].editItem[1].@enabled = false;       // disable update order
	dp2.item[5].@enabled = true;                    // enable reopen	
	dp2.item[6].@enabled = true                // enable cc processing
	
	   	  
}
private function mReprint(document_type:String):void {
	
	if(document_type == "Order") {
	     dp2.item[1].@enabled = false;  // disable save menu item if this is a recalled item	
	     dp2.item[2].@enabled = true;  // enable print menu
	     dp2.item[4].editItem[0].@enabled = false;  // disable update estimate
	     dp2.item[4].editItem[1].@enabled = false;  // disable update order
	     dp2.item[5].@enabled = true;  // enable reopen 
	} else {
            dp2.item[1].@enabled = false;  // disable save menu item if this is a recalled estimate	
		    dp2.item[2].@enabled = true;  // enable print menu
		    dp2.item[3].@enabled = true;             // enable convert to order
			dp2.item[4].editItem[0].@enabled = true;  // enable update estimate
	     	dp2.item[4].editItem[1].@enabled = false;  // disable update order
	     	dp2.item[5].@enabled = false;  // disable reopen 
	     	
	}
}

private function msaveOrder():void {
	    dp2.item[2].@enabled = true;    // enable print menu selection
        dp2.item[1].@enabled = false;  // disable save function
}

private function enableCCProcessing():void {
	    dp2.item[6].@enabled = true                // enable cc processing
        
}

private function disableCCProcessing():void {
	    dp2.item[6].@enabled = false               // disable cc processing
        
}
/* if (docType == "Estimate" ) {
		            	dp2.item[1].editItem[1].@enabled = true;  // enable save Estimate
		            }  else {
		            	dp2.item[1].editItem[2].@enabled = true;  // enable save order
		            } */




































