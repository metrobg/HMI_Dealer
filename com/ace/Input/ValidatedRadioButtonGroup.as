package com.ace.Input
{
	import flash.events.Event;
	
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	
	/**
	 * Create an extended version of the RadioButtonGroup that allows validation.
	 * 
	 * <pre>
	 * The main enhancements are the required property and the ability to set the selectedValue 
	 * using the value property.  
	 * </pre>
	 */
	public class ValidatedRadioButtonGroup extends RadioButtonGroup
	{
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
		
		private var _eventHandler:Function = this["checkData"];
		
		public function ValidatedRadioButtonGroup()
		{
			super();
			this.addEventListener(Event.CHANGE,_eventHandler)
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
			if (_doValidateData = false)
			{
				var rb:RadioButton;
				for (var i:int = 0; i < this.numRadioButtons;i++)
				{
					rb = this.getRadioButtonAt(i);
					rb.errorString = "";
					_isValid = true;
					this.errorString = "";
				}
			}
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
		 * errorString - Specify an errorString for the field.
		 * 
		 * @return the specified errorString
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get errorString():String 
		{
			return this._errorString;
		} 
		/**
		 * Sets the the specified errorString
		 */
		public function set errorString( errorString:String ):void 
		{
			this._errorString = errorString;
		}
		
		/**
		 * value - Provides access to the "raw value" of the input.  
		 *
		 * There is no setter for this property, rather, just set the .text to be the value
		 * and the format functions will handle the rest.
		 *
		 * @return The raw value corresponding to what the user entered for the data type.
		 */
		[Inspectable( type="Object")]
		public function get value():Object
		{
			return this._value;
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
		}
		
		/**
		 * setDefault - Method that will replace the value of the value property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			this.selectedValue = _defaultValue;
			this.validateData();
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
			validateData();
		}

		/**
		 * Override value property setter.
		 * 
		 */
		[Bindable("change")]
	    [Bindable("valueCommit")]
	    [Inspectable(category="General", defaultValue="")]
		
		public function set value(objValue:Object):void
		{
			this.selectedValue = objValue;
			if (this.selectedValue != objValue)
			{
				if (this.selection != null)
				{
					if (this.selection.hasOwnProperty("label"))
					{
						if (this.selectedValue != this.selection.label && objValue == null)
						{
							this.selection = null;
						}
					}
				}
			} 
			this.validateData();
			return;
		}
		/**
		 * validateData - Method that will validate the data that has been entered.
		 */

		public function validateData():Boolean
		{
			if (_doValidateData)
			{
				var rb:RadioButton;
				if (this.selection == null && required == true)
				{
					for (var i:int = 0; i < this.numRadioButtons;i++)
					{
						rb = this.getRadioButtonAt(i);
						rb.errorString = "A selection is required";
						_isValid = false;
						this.errorString = "A selection is required";
					}
				}
				else
				{
					for (i = 0; i < this.numRadioButtons;i++)
					{
						rb = this.getRadioButtonAt(i);
						rb.errorString = "";
						_isValid = true;
						this.errorString = "";
					}
					this.errorString = "";
				}
			}
			return _isValid;
		}
	}
}