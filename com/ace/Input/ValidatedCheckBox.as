package com.ace.Input
{
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.events.FlexEvent;
	
	/**
	 * Create an extended version of the CheckBox that allows the definition of checked and un checked values.
	 * 
	 * <pre>
	 * The developer defines the value to be returned when the checkbox is checked and unchecked. Conversely if a value is 
	 * set programmatically the checkbox is checked or unchecked based on the value. 
	 * 
	 * Optionally a value can be defined as the "valid" value. If the value is not equal what is defined
	 * it is considered invalid.
	 * 
	 * </pre>
	 */
	public class ValidatedCheckBox extends CheckBox
	{
		/** Checked Value - the value to return when the checkbox is checked */
		private var _checkedValue:String = "";
		
		/** Unchecked Value - the value to return when the checkbox is unchecked */
		private var _uncheckedValue:String = "";
		
		/** Value - the value to return */
		private var _value:String = "";
		
		/** should we validate data */
		private var _doValidateData:Boolean = true;
		
		/** Has this field passed validation */
		private var _isValid:Boolean = true;
		
		/** Valid value when blank either value is valid */
		private var _validValue:String = "";
		
		/** promptLabel */
		private var _promptLabel:String;
		
		/** Default value A literal that represents the value that will replace the "value"
		 * property when the method setDefault is executed */
		private var _defaultValue:String = "";
		
		private var _eventHandler:Function = this["checkData"];
		
		public function ValidatedCheckBox()
		{
			super();
			this.addEventListener(Event.CHANGE,_eventHandler)
			this.addEventListener(FlexEvent.CREATION_COMPLETE, init);
		}
		public function init(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, init)
			this.setStyle("disabledColor",this.getStyle("color"));
		 	this.setStyle("disabledIconColor",this.getStyle("iconColor"));
		}

		/**
		 * checkedValue - Value to be returned when checkbox is checked.
		 * 
		 * @return the specified checked value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get checkedValue():String 
		{
			return this._checkedValue;
		} 
		/**
		 * Sets the the specified checked value
		 */
		public function set checkedValue( checkedValue:String ):void 
		{
			this._checkedValue = checkedValue;
		}
		
		/**
		 * uncheckedValue - Value to be returned when checkbox is unchecked.
		 * 
		 * @return the specified unchecked value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get uncheckedValue():String 
		{
			return this._uncheckedValue;
		} 
		/**
		 * Sets the the specified unchecked value
		 */
		public function set uncheckedValue( uncheckedValue:String ):void 
		{
			this._uncheckedValue = uncheckedValue;
		}
		
		/**
		 * validValue - Valid value, if blank either value is valid.
		 * 
		 * Used for validation, if this value exists, the "value" of this checkbox must
		 * be equal to this value. 
		 * 
		 * @return the specified valid value
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get validValue():String 
		{
			return this._validValue;
		} 
		/**
		 * Sets the the specified valid value
		 */
		public function set validValue( validValue:String ):void 
		{
			this._validValue = validValue;
		}
		
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
		 * value - Provides access to the data of the input.  
		 * <pre>
		 * This will return the value for either checked or unchecked value for this field.
		 * If set programmatically it will either check or uncheck the box based on the
		 * value provided.
		 * </pre>
		 * @default ""
		 * @return The raw value corresponding to what the user entered for the data type.
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get value():String 
		{
			return this._value;
		} 
		/**
		 * Sets the the specified value
		 */
		public function set value( value:String ):void 
		{
			switch (value)
			{
				case _checkedValue:
					this.selected = true;
					this._value = value;
					break;

				case _uncheckedValue:
					this.selected = false;
					this._value = value;
					break;
				default:
					this.selected = false;
					this._value = _uncheckedValue;
			}
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
			var event:Event;
		}
		
		/**
		 * setDefault - Method that will replace the value of the value property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			this.value = _defaultValue;
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

		private function checkData(event:Event):void
		{
			if (this.selected)
			{
				_value = _checkedValue;
			}
			else
			{
				_value = _uncheckedValue;
			}
			validateData();
		}

		/**
		 * validateData - Method that will validate the data that has been entered.
		 */

		public function validateData():Boolean
		{
			if (_doValidateData)
			{
				_isValid = (_value == _checkedValue || _value == _uncheckedValue);
				if (_isValid && _validValue.length > 0)
				{
					_isValid = (_value ==_validValue);
				}
				if (!_isValid) 
				{
					this.errorString = "This is an invalid choice.";
				}
				else
				{
					this.errorString = "";
				}
			}
			return _isValid;
		}
	}
}