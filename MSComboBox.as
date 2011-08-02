package
{
	 
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import mx.controls.ComboBox;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;



/*
		Implementing this feature is very simple because the ComboBox is a subclass of the ListBase class that 
		works as a dropdown to show and select items. And from the ListBase class it inherits the multiselection  
		property. So all we have to do is to set the allowMultipleSelection  property to true:
		
		Multiselection works when the user presses the CTRL or CMD button on the keyboard to select more than one item. So we need to set to true  the value of allowMultipleSelection property each time this button is pressed. This can be done by overridding the keyUpHandler and the keyDownHandler events. The event handlers have to:

		1) Set the global variable ctrlKey.
		2) Set the allowMultipleSelection property of the dropdown List.
		2) When ctrl is up close the dropdown and dispatch the change event.

		Remember to define the ctrlKey as global property of the combobox so that every functions can be accessed:
*/
	public class MSComboBox extends ComboBox
	{
		private var ctrlKey:Boolean = false;
		
		public function MSComboBox()
		{
			super();
		}
		 
	override protected function keyDownHandler(event:KeyboardEvent) : void {

 
		super.keyDownHandler( event );

		ctrlKey = event.ctrlKey;

		if ( ctrlKey )
			dropdown.allowMultipleSelection = true;

		}

	override protected function keyUpHandler(event:KeyboardEvent) : void {
		super.keyUpHandler( event );
		ctrlKey = event.ctrlKey;
			if ( !ctrlKey ) {
			   close();
			  var changeEvent:ListEvent = new ListEvent( ListEvent.CHANGE )
			  dispatchEvent( changeEvent );
         }
      }
  
      /*
      	Now we have a full ComboBox Flex control able to receive multiselection but when we click on an item the 
      	dropDown menu closes.We need to stop the closure of the ComboBox control if the Ctrl key pressed.
		To do this we override the close() method:     
      */
      
       override public function close(trigger:Event=null) : void {
			if ( !ctrlKey )
				super.close( trigger );
}
      
      
      /*
      	Finally we can expose the selectedItems and selectedIndices property of the ComboBox and set them to bindable 
      	when the change event is dispatched by the keyUpHandler .
		We need to check with an if() conditional statement if the dropdown (the istance name of the ListBase class) 
		is not null before getting its selectedItems property:
      */
      
	public function set selectedItems( value:Array ) : void {
			if ( dropdown )
				dropdown.selectedItems = value;
			}

[Bindable("change")]
	public function get selectedItems( ) : Array {
		if ( dropdown ) {
			return dropdown.selectedItems;
		} else {
			return null;
	   	}
 }
	public function set selectedIndices( value:Array ) : void {
		if ( dropdown )
			dropdown.selectedIndices = value;
	}

[Bindable("change")]
	public function get selectedIndices( ) : Array {
		if ( dropdown )
			return dropdown.selectedIndices;
		else
			return null;
	}
      
      
      
      
      
      
      
	}     		// end of class
}              // end of package