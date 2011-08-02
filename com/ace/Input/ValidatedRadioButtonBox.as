package com.ace.Input
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Box;
	import mx.controls.RadioButton;
	import mx.events.FlexEvent;
	 
	/**
	 * Create an extended version of the Box that allows incorporates ValidatedRadioButtonGroup.
	 * 
	 * <p>
	 * This allows the creation of a box that encapsulates a RadioButtonGroup with validation.
	 * The purpose of this is to allow a single UIComponent that incorporates a RadioButtonGroup
	 * with validation and a flexible container.
	 * </p>
	 * @example
	 * The following is a simple application that shows some of the functionality;
	 * <pre>
	 * &lt;?xml version="1.0" encoding="utf-8"?&gt;
	 * &lt;mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" xmlns:ns1="Classes.panel.&#42;" xmlns:inp="Classes.Input.&#42;"&gt;
	 * 	&lt;ns1:SuperPanel x="171" y="88" width="726" height="521"&gt;
	 * 		&lt;mx:Canvas width="100%" height="100%" id="myCanvas"&gt;
	 * 			&lt;inp:ValidatedTextInput x="260" y="411" id="input2"/&gt;
	 * 
	 * 			&lt;mx:Button x="32" y="411" label="Disable" 
	 * 				click="rbg2.enabled=!rbg2.enabled;(rbg2.enabled)?btnEnable2.label='Disable':btnEnable2.label='Enable'" id="btnEnable2"/&gt;
	 * 
	 * 			&lt;mx:Button x="124" y="411" label="Clear" click="rbg2.value=null;"/&gt;
	 * 
	 * 			&lt;mx:Button x="187" y="411" label="Set" click="rbg2.value=input2.text;"/&gt;
	 * 
	 * 			&lt;mx:Button x="441" y="411" label="Set default" click="rbg2.setDefault();"/&gt;
	 * 
	 * 			&lt;mx:Button x="551" y="411" label="Validate" click="rbg2.validateData();"/&gt;
	 * 			
	 * 			&lt;inp:ValidatedRadioButtonBox x="372" y="29" width="281" height="22" direction="horizontal" 
	 * 				id="rbg2" required="true" defaultValue="test3"&gt;
	 * 				&lt;mx:RadioButton label="Button 1" value="test1"/&gt;
	 * 				&lt;mx:RadioButton label="Button 2" value="test2"/&gt;
	 * 				&lt;mx:RadioButton label="Button 3" value="test3"/&gt;
	 * 			&lt;/inp:ValidatedRadioButtonBox&gt;
	 * 
	 * 		&lt;/mx:Canvas&gt;
	 * 	&lt;/ns1:SuperPanel&gt;
	 * 	
	 * &lt;/mx:Application&gt;
	 * </pre>
	 */
	public class ValidatedRadioButtonBox extends Box
	{
		  // -------------------------------------------------------------------------
		  //
		  // Properties 
		  //      
		  // -------------------------------------------------------------------------
		private var _group:ValidatedRadioButtonGroup;
		 
		/** Value - the value to return */
		private var _value:Object = "";
		
		/** should we validate data */
		private var _doValidateData:Boolean = true;
		
		/** Is something checked required */
		private var _required:Boolean = true;
		
		/** Has this field passed validation */
		private var _isValid:Boolean = true;
		
		/** promptLabel */
		private var _promptLabel:String;
		
		/** errorString */
		private var _errorString:String;

		/** Default value A literal that represents the value that will replace the "value"
		 * property when the method setDefault is executed */
		private var _defaultValue:String = "";
		

		/**
		 * doValidateData - specify the whether this field should be validated. Default is false. 
		 * 
		 * @return the specified validate data flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=false, enumeration="true,false" )]
		public function get doValidateData():Boolean 
		{
			return this._doValidateData;
		}
		
		/**
		 * Sets the specified validate data flag.
		 */
		public function set doValidateData( doValidateData:Boolean ):void 
		{
			this._doValidateData = doValidateData;
			if (this._group)_group.doValidateData = doValidateData;
		}
		
		/**
		 * required - specify the whether this field must have at something selected. 
		 * Default is true. 
		 * 
		 * @return the specified required flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=true, enumeration="true,false" )]
		public function get required():Boolean 
		{
			return this._required;
		}
		
		/**
		 * Sets the specified validate data flag.
		 */
		public function set required( required:Boolean ):void 
		{
			this._required = required;
			if (this._group)_group.required = required;
		}
		
		/**
		 * promptLabel - Specify a human readable label for the field.
		 * 
		 * @return the specified promptLabel
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get promptLabel():String 
		{
			return this._promptLabel;
		} 
		/**
		 * Sets the the specified promptLabel
		 */
		public function set promptLabel( promptLabel:String ):void 
		{
			this._promptLabel = promptLabel;
			if (this._group)_group.promptLabel = promptLabel;
		}
		
		/**
		 * errorString - Specify an errorString for the field.
		 * 
		 * Sets the the specified errorString
		 */
		override public function set errorString( errorString:String ):void 
		{
			this._errorString = errorString;
			if (this._group)_group.errorString = errorString;
		}
		
		/**
		 * value - Provides access to the "raw value" of the input.  
		 *
		 * @return The raw value corresponding to what the user entered for the data type.
		 */
		[Inspectable( type="object" , defaultValue="" )]
		public function get value():Object
		{
			return _group.selectedValue;
		} 
		
		/**
		 * Sets the the specified value
		 */
		public function set value( value:Object ):void 
		{
			this._value = value;
			if (this._group)_group.value = value;
		}
		
		/**
		 * defaultValue - allows the specification of a default value for a field.
		 * To set the current text/value properties use the the setDefault() method.
		 * 
		 * @return the specified Maximum value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get defaultValue():String 
		{
			return this._defaultValue;
		} 
		/**
		 * Sets the specified Default value
		 */
		public function set defaultValue( defaultValue:String ):void 
		{
			this._defaultValue = defaultValue;
			if (this._group)_group.defaultValue = defaultValue;
		}
		
		/**
		 * setDefault - Method that will replace the value of the value property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			_group.setDefault();
		}
		
		/**
		 * getDefault - Method that will return the value of the defaultValue property.
		 * 
		 * This method returns the defaultValue it exists to provide a consistenet api
		 * between all "validated" components.
		 */
		 
		public function getDefault():String
		{
			return _defaultValue;
		}

		
		/**
		 * isValid - Returns a boolean that defines whether the current value is valid.
		 */

		public function get isValid():Boolean 
		{
			return _isValid;
		}

		/**
		 * Override value property setter.
		 * 
		 */

		/**
		 * validateData - Method that will validate the data that has been entered.
		 */

		public function validateData():Boolean
		{
			return this._group.validateData();
		}
		  // -------------------------------------------------------------------------
		  //
		  // Constructor 
		  //      
		  // -------------------------------------------------------------------------
		 
		  public function ValidatedRadioButtonBox()
		  {
		    super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, init);
			
		    _group = new ValidatedRadioButtonGroup();
		    _group.doValidateData = this._doValidateData;
		    _group.defaultValue = this._defaultValue;
		    _group.errorString = this._errorString;
		    _group.promptLabel = this._promptLabel;
		    _group.required = this._required;
		    _group.value = this._value;
		  }
		 
		 public function init(event:FlexEvent):void
		 {
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, init)
		 	this.setStyle("paddingTop", 0);
		 	this.setStyle("paddingBottom", 0);
		 	this.setStyle("paddingLeft", 0);
		 	this.setStyle("paddingRight", 0);
		 	this.setStyle("verticalAlign", "middle");
			for each (var field:Object in this.getChildren())
			{
				if (field is RadioButton)
				{
				 	field.setStyle("disabledIconColor",field.getStyle("iconColor"));
				 	
				 	field.setStyle("disabledColor",getStyle("color"));
				 	
				 	if (field.value == _defaultValue && _defaultValue.length > 0)
				 	{
				 		field.selected = true;
				 		_value = _defaultValue;
				 	}
				}
			 }
		 }
		 
		  // -------------------------------------------------------------------------
		  //
		  // Overridden Methods 
		  //      
		  // -------------------------------------------------------------------------
		 
		  override public function addChild(child:DisplayObject):DisplayObject
		  {
		    if (child is RadioButton)
		    {
				RadioButton(child).group = _group;
		    }
		 
		    return super.addChild(child);
		  }
	 
	}
}