package com.ace.Input
{
	import com.ace.CharacterUtils;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.TextArea;
	
	/**
	 * ValidatedTextArea - Extended version of TextArea that allows validation on minimum and 
	 * maximum lengths.
	 * 
	 * 
	 * 
	 */
	public class ValidatedTextArea extends TextArea
	{
		/** Data Type */
		private var _dataType:String = "string";
		
		/** Minimum Data Length after removing all formatting minimum size of value property */
		private var _minDataChars:int = 0;
		
		/** Maximum Data Length after removing all formatting maximum size of value property */
		private var _maxDataChars:int = 0;
		
		/** Raw data suitable for DB entry */
		private var _value:String;
		
		/** promptLabel */
		private var _promptLabel:String;
		
		/** Additional allowable characters */
		private var _charactersAlsoPermitted:String = "";
		
		/** If any datatype force upper case */
		private var _upper:Boolean = false;
		
		/** If any datatype force lower case */
		private var _lower:Boolean = false;
		
		/** If email datatype Allow multiple addresses? */
		private var _multipleEmails:Boolean = false;
		
		/** should we validate data */
		private var _doValidateData:Boolean = true;
		
		/** Has this field passed validation */
		private var _isValid:Boolean = true;
		
		/** Default value A literal that represents the value that will replace the "text"
		 * value when the method setDefault is executed */
		private var _defaultValue:String = "";
		
		private var _inTextChanged:Boolean = false; // Flag to keep us from going into endless loops
												   // when the text property changes due to internal 
												   // functions.
		private var _initialized:Boolean = false; // Flag to keep us from reinitializing before our time
		
		private var _tabOut:Function = null;
		
		private var inValidateData:Boolean = false;
		
		/**
		 * The delegate to catch any changes to the text so we can always apply the formt 
		 */
		private var eventHandler:Function = this["textChanged"];
		
		public function ValidatedTextArea():void
		{
			super();
			this.addEventListener(Event.CHANGE,eventHandler);
		}
		
 		override public function initialize():void
		{
			/**
			 * Set up the allowable characters
			 */
			if (!this.restrict) this.restrict = "";
			var strRestrict:String = ""
			switch (_dataType.toLowerCase())
			{
				case "alpha":
					strRestrict += "a-zA-Z "
					break;
					
				case "alphanumeric":
					strRestrict += "a-zA-Z0-9 ";
					break;

				case "email":
					strRestrict += "a-zA-Z0-9@\.";
					if (_multipleEmails) strRestrict += "\;";
					break;
			}
			if (this.restrict.length > 0 && strRestrict.length > 0)this.restrict = this.restrict.replace(strRestrict,"");
			if (strRestrict.length > 0) this.restrict += strRestrict;
			if (_charactersAlsoPermitted.length > 0 && this.restrict.length > 0) 
			{
				this.restrict += _charactersAlsoPermitted;
			}
			if (this.restrict.length == 0) this.restrict = null;
			// Set the number of enterable characters = to the number of allowable characters
			//	if the number of enterable characters is not set.
			if (!this.maxChars && _maxDataChars) this.maxChars = _maxDataChars;
			// Set the number of allowable characters = to the number of enterable characters
			//	if the number of allowable characters is not set.
			if (_maxDataChars == 0 && this.maxChars) _maxDataChars = this.maxChars;
			// Keep the init functionality of the TextArea by calling super.init
			super.initialize();
			var event:Event;
			textChanged(event);
			 _initialized = true;
		}
		
		/**
		 * dataType - allows the specification of what type of data that can be entered.
		 * 
		 * <pre>
		 * The allowable types are;
		 * number valid numbers,
		 * alpha valid alphabetic characters only,
		 * alphaNumeric valid alphabetic and numbers,
		 * string any typeable characters,
		 * email valid email addresses,
		 * </pre>
		 * @return the specified Data type
		 */
		[Inspectable( type="String" , defaultValue="string", enumeration="alpha,alphaNumeric,string,email")]
		public function get dataType():String 
		{
			return this._dataType;
		}
		
		/**
		 * Sets the data type
		 */
		public function set dataType( dataType:String ):void 
		{
			this._dataType = dataType;
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
		 * upper - Specifies whether to force the field to upper case. The default is false. 
		 * 
		 * @return the specified upper flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=false, enumeration="true,false"  )]
		public function get upper():Boolean 
		{
			return this._upper;
		}
		
		/**
		 * Sets the specified upper flag.
		 */
		public function set upper( upper:Boolean ):void 
		{
			this._upper = upper;
			var event:Event;
			textChanged(event);
		}
		
		/**
		 * lower - specifies whether to force characters to lower case. Default is false.
		 * 
		 * @return the specified lower case flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=false, enumeration="true,false"  )]
		public function get lower():Boolean 
		{
			return this._lower;
		}
		
		/**
		 * Sets the specified lower case flag.
		 */
		public function set lower( lower:Boolean ):void 
		{
			this._lower = lower;
			var event:Event;
			textChanged(event);
		}
		
		/**
		 * multipleEmails - specify whether this field could have multiple email addresses.
		 * The default is false.
		 * 
		 * @return the specified sign flag.
		 */
		[Inspectable( type="Boolean" , defaultValue=false, enumeration="true,false" )]
		public function get multipleEmails():Boolean 
		{
			return this._multipleEmails;
		}
		
		/**
		 * Sets the specified multipleEmails flag.
		 */
		public function set multipleEmails( multipleEmails:Boolean ):void 
		{
			this._multipleEmails = multipleEmails;
			var event:Event;
			textChanged(event);
		}
		
		/**
		 * doValidateData - specify the whether this field should be validated. Default is true. 
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
			var event:Event;
			textChanged(event);
		}
		
		/**
		 * defaultValue - allows the specification of a default value for a field.
		 * To set the current text/value properties use the the setDefault() method.
		 * 
		 * @return the specified defaultValue
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
		public function get value():Object 
		{
			if (_value == null) _value = "";
			return _value;
		}

		/**
		 * dbValue - Provides access to the "raw value" of the input suitable for insertion into database.  
		 *
		 * There is no setter for this property, rather, just set the .text to be the value
		 * and the format functions will handle the rest.
		 *
		 * @return The raw value corresponding to what the user entered for the data type. All
		 * apostrophes are replaced with two apostrophes to allow insertion into database.
		 */
		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		public function get dbValue():String 
		{
			var reApostrophe:RegExp = new RegExp("'","g");
			return _value.replace(reApostrophe,"''");
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
		 * Override text property setter.
		 * This will allow us to execute our functions everytime the data changes progammatically
		 */
		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		
		override public function set text(strText:String):void
		{
			super.text = strText;
			if (_inTextChanged == false && inValidateData == false)
			{
				var event:Event;
				textChanged(event);
				validateData();
			}
			return;
		}
		
		/**
		 * setDefault - Method that will replace the value of the text property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			this.text = _defaultValue;
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
		 * Event handler that gets invoked when things change. Basically we get the raw data from
		 * the text property and stuff it into the value property.
		 */
		public function textChanged(event:Event):void 
		{
			if (text != null)
			{
				_inTextChanged = true;
				extractValue();
				_inTextChanged = false;
			}
		}
		
		/**
		 * extractValue - Scan the text the user entered and try to extract a value
		 * that matches the types of data for this dataType.  This gives us a raw value that
		 * we can later validate and apply the format to so that it will be
		 * displayed correctly. It also gives us the value that would be best to insert into ad DB.
		 */
		public function extractValue():void {
			
			// reset the value since we're trying to extract a new value from the text
			_value = "";
			
			for ( var i:Number = 0; i < text.length; i++ ) 
			{
				// examine the current character in our loop
				var char:String = text.charAt( i );
				
				switch (dataType.toLowerCase())
				{
					case "alpha":
						if (CharacterUtils.isUpperCase(char) || CharacterUtils.isLowerCase(char)||
							CharacterUtils.isValid(char,_charactersAlsoPermitted))
						{
							_value += char;
						}
						break;

					case "alphnumeric":
						if (CharacterUtils.isUpperCase(char) || CharacterUtils.isLowerCase(char) || 
							CharacterUtils.isDigit(char, false, false)||
							CharacterUtils.isValid(char,_charactersAlsoPermitted))
						{
							_value += char;
						}
						break;

					default :
						_value += char;
				}
				// Convert to upper or lower case as needed.
				if (_upper) _value = _value.toUpperCase();
				if (_lower) _value = _value.toLowerCase();
			}
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			// When exiting field validate.
			validateData();
 			if (errorString.length > 0) 
			{
				validateData();
				this.dispatchEvent(new MouseEvent("MouseOut"));
			}
 
			super.focusOutHandler(event);
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			if (_value.length > 0)
			{
				this.dispatchEvent(new MouseEvent("MouseOut"));
				validateData();
			}

 			if (errorString.length > 0) 
			{
				this.dispatchEvent(new MouseEvent("mouseOver"));
			}
			this.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
			super.focusInHandler(event);
		}

		override protected function keyDownHandler(event:KeyboardEvent):void
		{
//			trace("event="+event.toString());
			this.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
			if (event.keyCode == Keyboard.TAB && _tabOut != null)
			{
				_tabOut();
			}
			else
			{
				if (event.keyCode == Keyboard.TAB || event.keyCode == Keyboard.ENTER) 
				{
					return;
				}
				else
				{
				this.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
				}
			}
		}
		
		/**
		 * tabOut - A function to execute if the tabkey is pressed..
		 * 
		 * @return the specified tabOut Function
		 */
		[Inspectable( type="Function" , defaultValue="" )]
		public function get tabOut():Function 
		{
			return this._tabOut;
		} 
		/**
		 * Sets the the specified tabOut
		 */
		public function set tabOut( tabOut:Function ):void 
		{
			this._tabOut = tabOut;
		}
		
		/**
		 * validateData - Method that will validate and format the data that has been entered.
		 */
		public function validateData():Boolean
		{
			/**
			 * Create a method that will validate and format the data that has been entered.
			 */
			if (doValidateData == false) return true;
			inValidateData = true;
			// Get the raw data
			extractValue();
			this.errorString = "";
			// Check for too many or too few characters entered.
			if (_value.length > _maxDataChars && _maxDataChars > 0)	errorString += "Too many characters. ";
			if (_value.length < _minDataChars && _minDataChars > 0)	errorString += "Too few characters. ";
			// If number of characters are ok, check for other types of errors
			if (errorString.length == 0 && (_minDataChars != 0 ||_value.length > 0))
			{
				switch (_dataType.toLowerCase())
				{
					case "alpha":
						validateAlpha();
						break;
					case "alphanumeric":
						validateAlphaNumeric();
						break;
					case "string":
						validateString();
						break;
					case "email":
						validateEMail();
						break;
				}
			}
			// Set property isValid so everyone else can see if our data is good.
			if (this.errorString.length > 0) 
			{
				_isValid = false;
			}
			else
			{
				_isValid = true
			}
			// if a formatter is defined and we have no errors format the data.
			inValidateData = false;
			return _isValid;
		}

		private function validateAlpha():void
		{
			if (_lower) text = text.toLowerCase();
			if (_upper) text = text.toUpperCase();
		
		}

		private function validateAlphaNumeric():void
		{
			if (_lower) text = text.toLowerCase();
			if (_upper) text = text.toUpperCase();

		}
		private function validateString():void
		{
			this.text = _value;
		}

		private function validateEMail():void
		{
			var reEmail:RegExp = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/ ;
			if (_multipleEmails)
			{
				var aryEmails:Array = _value.split(";");
				for (var i:int = 0 ; i < aryEmails.length; i++)
				{
					if (!reEmail.test(aryEmails[i]))
					{
						errorString += "Error in Email Address '" + aryEmails[i] + "'\n";
					}
				}
			}
			else
			{
				if (!reEmail.test(_value))
				{
					errorString += "Error in Email Address '" + _value + "'\n";
				}
			}
		}
			
	}
}