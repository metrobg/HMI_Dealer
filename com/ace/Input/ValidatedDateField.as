package com.ace.Input
{
	 
	
	import flash.events.Event;
	
	import mx.controls.DateField;
	import mx.events.FlexEvent;
	
	/**
	 * Create an extended version of DateField that uses ValidatedTextInput to handle user typed
	 * dates. Dates can be entered in a number of formats including;
	 * mmddyyyy, mm/dd/yyyy, mm-dd-yyyy, dd-mon-yyyy, yyyymmdd
	 * 
	 * <pre>
	 * The date will be formatted to mm/dd/yyyy when focus leaves the field.
	 * 
	 * Validation will take place including min value & max value which are controlled by the 
	 * properties minValue and MaxValue. These can contain a date literal, sysdate (today) or 
	 * field:FieldName where FieldName is a ValidatedDateField or ValidatedTextInput field in 
	 * the parent container.
	 * </pre>
	 */
	public class ValidatedDateField extends DateField
	{
		/** Minimum Data Length after removing all formatting minimum size of value property */
		private var _minDataChars:int = 0;
		
		/** Maximum Data Length after removing all formatting maximum size of value property */
		private var _maxDataChars:int = 0;
		
		/** Minimum value Either a literal or pointer to value of another field using 
		 * 'Field:FieldName' */
		private var _minValue:String = "";
		
		/** Maximum value Either a literal or pointer to value of another field using 
		 * 'Field:FieldName' */
		private var _maxValue:String = "";

		/** Raw data suitable for DB entry */
		private var _value:String;
		
		/** promptLabel */
		private var _promptLabel:String;
		
		/** Has this field passed validation */
		private var _isValid:Boolean = true;
		
		/** Additional allowable characters */
		private var _charactersAlsoPermitted:String = "";
		
		/** should we format data */
		private var _formatData:Boolean = true;
		
		/** should we validate data */
		private var _doValidateData:Boolean = true;
		
		/** Default value A literal that represents the value that will replace the "text"
		 * value when the method setDefault is executed */
		private var _defaultValue:String = "";
		
		public function ValidatedDateField()
		{
			//TODO: implement function
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,initObject);
		}
		
	    override protected function createChildren():void
	    {
	        super.createChildren();
			removeChild(textInput);
			
			if(this.textInput)
			{ // Use ValidatedTextInput instead of TextInput and Setup various fields 
			  //needed by ValidatedTextInput
				textInput = new ValidatedTextInput();
				textInput["dataType"] = "date";
				textInput["formatter"] = "_dateFormat";
				textInput["minDataChars"] = _minDataChars;
				textInput["maxDataChars"] = _maxDataChars;
				textInput["minValue"] = _minValue;
				textInput["maxValue"] = _maxValue;
				textInput["id"] = "vti" + this.id;
				textInput["rootOwner"] = this;
				textInput["charactersAlsoPermitted"] = _charactersAlsoPermitted;
				textInput["formatData"] = _formatData;
				textInput["doValidateData"] = _doValidateData;
				textInput["defaultValue"] = _defaultValue;
				textInput.focusEnabled = false;
				
				textInput.addEventListener("focusOut",updateTextValue);
				textInput.addEventListener("textChanged",updateTextValue);
				addChild(textInput);
//				textInput.parentDrawsFocus = true;
			}
	    }
	    override public function set enabled(value:Boolean):void
	    {
	    	super.enabled = value;
	    	if(this.textInput)this.textInput["enabled"] = true;
	    	if(this.textInput)this.textInput["editable"] = value;
	    	
	    }

		private function initObject(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE,initObject);
			if (!this.width)this.width = 94;
			this.restrict = "0-9/" + _charactersAlsoPermitted;
//			this.textInput.initialize();
		}
		
		/**
		 * minDataChars - Allows the specification of the fewest number of characters allowed in this field.
		 * 
		 * @return the specified minimum Data Length
		 */
		[Inspectable( type="Number" , defaultValue=0 )]
		public function get minDataChars():Number 
		{
			return this._minDataChars;
		}
		
		/**
		 * Sets the specified minimum Data Length
		 */
		public function set minDataChars( minDataChars:Number ):void 
		{
			this._minDataChars = minDataChars;
			if(this.textInput)textInput["minDataChars"] = _minDataChars;
		}
		
		/**
		 * maxDataChars - Allows the specification of the largest number of characters allowed in this field.
		 * 
		 * @return the specified maximum Data Length
		 */
		[Inspectable( type="Number" , defaultValue=0 )]
		public function get maxDataChars():Number 
		{
			return this._maxDataChars;
		}
		
		/**
		 * Sets the specified maximum Data Length
		 */
		public function set maxDataChars( maxDataChars:Number ):void 
		{
			this._maxDataChars = maxDataChars;
			if(this.textInput)textInput["maxDataChars"] = _maxDataChars;
		}
		
		/**
		 * minValue - allows the specification of the minimum value that is allowed.  
		 * 
		 * <pre>
		 * This is data type dependent. Dates, numbers, times etc. are handled based on their data type.
		 * 
		 * A few notes;
		 * 
		 * For date fields, "sysdate" can be used to specify today.
		 * Reference to another field is also allowed and is specified using the syntax ‘field:FieldName’ 
		 * where ‘field:’ tells the module to look at another field, and ‘FieldName’ is the name of the 
		 * field whose ‘value’ property to look at
		 * </pre>
		 * 
		 * @return the specified minimum value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get minValue():String 
		{
			return this._minValue;
		} 
		/**
		 * Sets the the specified minimum value
		 */
		public function set minValue( minValue:String ):void 
		{
			this._minValue = minValue;
			if(this.textInput)textInput["minValue"] = _minValue;
		}
		
		/**
		 * maxValue - allows the specification of the maximum value that is allowed.
		 * 
		 * <pre>
		 * This is data type dependent. Dates, numbers, times etc. are handled based on their data type.
		 * 
		 * A few notes;
		 * 
		 * For date fields, "sysdate" can be used to specify today.
		 * Reference to another field is also allowed and is specified using the syntax ‘field:FieldName’ 
		 * where ‘field:’ tells the module to look at another field, and ‘FieldName’ is the name of the 
		 * field whose ‘value’ property to look at</pre>
		 * 
		 * @return the specified Maximum value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get maxValue():String 
		{
			return this._maxValue;
		} 
		/**
		 * Sets the specified Maximum value
		 */
		public function set maxValue( maxValue:String ):void 
		{
			this._maxValue = maxValue;
			if(this.textInput)textInput["minValue"] = _minValue;
		}

		/**
		 * charactersAlsoPermitted - allows a string of characters that are permitted in this field
		 * that would normally not be allowed based on the current dataType.
		 * 
		 * @return the specified charactersAlsoPermitted
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get charactersAlsoPermitted():String 
		{
			return this._charactersAlsoPermitted;
		}
		
		/**
		 * Sets the Characters Also Permitted
		 */
		public function set charactersAlsoPermitted( charactersAlsoPermitted:String ):void 
		{
			this._charactersAlsoPermitted = charactersAlsoPermitted;
			this.textInput["charactersAlsoPermitted"] = _charactersAlsoPermitted;
			this.restrict = "0-9/" + _charactersAlsoPermitted;
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
		}
		
		/**
		 * formatData - Specify whether the field should be formatted. Default is true.
		 * 
		 * @return the specified format data flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=false, enumeration="true,false" )]
		public function get formatData():Boolean 
		{
			return this._formatData;
		}
		
		/**
		 * Sets the specified format data flag.
		 */
		public function set formatData( formatData:Boolean ):void 
		{
			this._formatData = formatData;
		}
		
	
		/**
		 * doValidateData - specify the whether this field should be validated. Default is true. 
		 * 
		 * @return the specified validate data flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=true, enumeration="true,false" )]
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
		}
		
		/**
		 * value - Provides access to the "raw value" of the input.  
		 *
		 * There is no setter for this property, rather, just set the .text to be the value
		 * and the format functions will handle the rest.
		 *
		 * @return The raw value corresponding to what the user entered for the data type.
		 */
		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		override public function get value():Object 
		{
			if (_value == null) _value = "";
			return _value;
		}

		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		override public function set errorString(errorString:String):void
		{
			if(this.textInput) this.textInput["errorString"] = errorString;
		}

		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		override public function set text(textIn:String):void
		{
			super.text = textIn;
			this.textInput.text = textIn;
			_value = this.textInput.text;
		}

		/**
		 * isValid - Returns a boolean that defines whether the current value is valid.
		 */

		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		public function get isValid():Boolean 
		{
			return _isValid;
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
			if(this.textInput) this.textInput["defaultValue"] = _defaultValue;
		}
		
		private var inTextChanged:Boolean = false; // Flag to keep us from going into endless loops
												   // when the text property changes due to internal 
												   // functions.
		

		/**
		 * validateData - Method that will validate and format the data that has been entered.
		 */

		public function validateData():Boolean
		{
			var funTemp:Function = this.textInput["validateData"];
			_isValid = funTemp();
			return _isValid;
		}

		/* Set the text and value properties of this component */
		private function updateTextValue(event:Event):void
		{
			_value = this.textInput["value"];
			this.text = this.textInput.text;
		}
		
		/**
		 * setDefault - Method that will replace the value of the text property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			var funTemp:Function = this.textInput["setDefault"];
			funTemp();
		}

		/**
		 * getDefault - Method that will return the value of the defaultValue property.
		 * 
		 * This method returns the converted value, ie - if defaultValue is sysdate it
		 * will return the date in whatever format specified by the formatter.
		 */
		 
		public function getDefault():String
		{
			var funTemp:Function = this.textInput["getDefault"];
			return funTemp();
		}

	}
}