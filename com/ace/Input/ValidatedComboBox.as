package com.ace.Input
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.ComboBox;
	
	/**
	 * Create an extended version of the ComboBox that allows the definition of invalid indexes and
	 * multiple keystroke selection.
	 * 
	 * <pre>
	 * The developer defines one or more invalid indexes in a comma separated list using the property badIndexes.
	 * Most commonly the developer would specify "0" which is the first element in the list.
	 * 
	 * New properties are;
	 * badIndexes - A string that allows the developer to define a comma separated list of invalid indexes.
	 * isVald - A boolean that defines whether the field is valid.
	 * 
	 * New Methods are;
	 * validateData() - This method checks if the data is valid and returns true if valid, false if invalid.
	 * </pre>
	 */
	public class ValidatedComboBox extends ComboBox
	{
		/** Bad indexes - A comma separated list of invalid indexes. */
		private var _badIndexes:String = "";
		
		/** Has this field passed validation */
		private var _isValid:Boolean = true;
		
		/** value */
		private var _value:Object;
		
		/** should we validate data */
		private var _doValidateData:Boolean = true;
		
		/** promptLabel */
		private var _promptLabel:String;
		
		
		/** dataType */
		private var _dataType:String = "string";
		
		/** dataField */
		private var _dataField:String = "DATA";
		
		/** toolTipField */
		private var _toolTipField:String = "";
		
		/** Default value A literal that represents the value that will replace the "value"
		 * property when the method setDefault is executed */
		private var _defaultValue:String = "";
		
		private var _eventHandler:Function = this["checkData"];
		
		private var _tabOut:Function = null;
		
		private var _typedText:String = "";
		
		public function ValidatedComboBox()
		{
			//TODO: implement function
			super();
			this.addEventListener(Event.CHANGE,_eventHandler)
		}
		
		/**
		 * badIndexes- A comma seperated list of indexes that will be considered invalid. 
		 * 
		 * @return the specified bad indexes
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get badIndexes():String 
		{
			return this._badIndexes;
		} 
		/**
		 * Sets the the specified bad indexes
		 */
		public function set badIndexes( badIndexes:String ):void 
		{
			this._badIndexes = badIndexes;
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
		 * dataType - specify whether to use numeric or string matching when setting
		 * the value of this field.
		 * 
		 * <p>
		 * Use this field when the drop down's data is a number. Particularly useful if 
		 * the current field in the database is string and can contain leading zeroes.
		 * </p>  
		 * 
		 * @return the specified validate data flag.
		 */
		[Inspectable( type="String" , defaultValue=false, enumeration="string,number" )]
		public function get dataType():String
		{
			return this._dataType;
		}
		
		/**
		 * Sets the specified validate data flag.
		 */
		public function set dataType( dataType:String ):void 
		{
			this._dataType = dataType;
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
		}
		
		/**
		 * toolTipField - Specify a field in the dataProvider whose value will be used as the
		 * to populate the toolTip. 
		 * 
		 * @return the specified toolTipField
		 */
		[Inspectable( type="String" , defaultValue="" )]
		public function get toolTipField():String 
		{
			return this._toolTipField;
		} 
		/**
		 * Sets the the specified toolTipField
		 */
		public function set toolTipField( toolTipField:String ):void 
		{
			this._toolTipField = toolTipField;
		}
		
		/**
		 * defaultValue - allows the specification of a default value for a field.
		 * To set the current text/value properties use the the setDefault() method.
		 * 
		 * @return the specified defaultValue value
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
		 * dataField - the field to be used as the data field from the dataProvider.
		 * 
		 * The value of the field defined here is what the value is set to based 
		 * on the selection.  
		 * 
		 * @return the specified dataFiel
		 */
		[Inspectable( type="String" , defaultValue="DATA" )]
		public function get dataField():String 
		{
			return this._dataField;
		} 
		/**
		 * Sets the the specified dataField
		 */
		public function set dataField( dataField:String ):void 
		{
			this._dataField = dataField;
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
		 * isValid - Returns a boolean that defines whether the current value is valid.
		 */

		public function get isValid():Boolean 
		{
			return _isValid;
		}
		
		override public function get value():Object
		{
			return _value;
		}
		
		override public function set dataProvider(dpValue:Object):void
		{
			var objCurrentValue:Object = _value;
			super.dataProvider = dpValue;
			_value = objCurrentValue;
			if (dpValue != null)
			{
				if (dpValue.length > 0)
				{
					if (_value != null) 
					{
						if(_value.toString().length > 0) setSelectedItem(_value);
					}
					else
					{
						_value = this.selectedItem[dataField];
					}
		 			if (this.selectedIndex == -1)
					{
						this.selectedIndex = 0;
		//				_value = "";
						_value = this.selectedItem[dataField];
						if (this.selectedItem != null)
							if (this.selectedItem.hasOwnProperty(dataField)) _value = this.selectedItem[dataField];
					}
				}
			}
		}
		
		override public function set selectedIndex(intValue:int):void
		{
			super.selectedIndex = intValue;
			if (intValue > -1)
			{
				if (this.selectedItem != null)
				{
					if (this.selectedItem.hasOwnProperty(dataField)) _value = this.selectedItem[dataField];
				}
			}
		}
		
		/**
		 * Sets the the specified value based on the item selected.
		 */
		
		public function set value(value:Object): void
		{
			this.selectedIndex = 0;
			if (value != null)
			{
				setSelectedItem(value);
				_value = value;
			}
			else
			{
				_value = "";
			}
 			if (this.selectedIndex > -1)
			{
				if (this.selectedItem != null)
					if (this.selectedItem.hasOwnProperty(dataField)) _value = this.selectedItem[dataField];
			}
		}

		private function checkData(event:Event):void
		{
			if (this.selectedItem)
			{
				this.
				_value = this.selectedItem[dataField];
				validateData();
			}
		}

		/**
		 * setDefault - Method that will replace the value of the value property with the 
		 * value of the defaultValue property.
		 */
		 
		public function setDefault():void
		{
			_value = _defaultValue;
			setSelectedItem(_value);
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
		 * validateData - Method that will validate the data that has been entered.
		 */

		public function validateData():Boolean
		{
			var aryTemp:Array = _badIndexes.split(",");
			if (_doValidateData)
			{
				_isValid = ((aryTemp.indexOf(this.selectedIndex.toString()) == -1) &&
							(this.selectedIndex > -1));
				if (!_isValid) 
				{
					this.errorString = '"' + this.selectedLabel + '" is an invalid choice. ' + 
											 this.selectedLabel.toString();
				}
				else
				{
					this.errorString = "";
				}
			}
			return _isValid;
		}

		private function setSelectedItem(strFindItem:Object):void
		{
			var strDataItem:String = "";
			if (this.dataProvider != null)
			{
				this.selectedIndex = -1;
				if (_dataType == "number")
				{
					strFindItem = String(parseInt(strFindItem.toString(),10));
				} 
				for (var i:int=0;i<this.dataProvider.length;i++)
				{
					if (this.dataProvider[i] != null)
					{
						if (_dataType == "number")
						{
							strDataItem = String(parseInt(this.dataProvider[i][dataField].toString(),10));
						} 
						else
						{
							strDataItem = this.dataProvider[i][dataField].toString();
						}
						if (strDataItem == strFindItem && strDataItem.length == strFindItem.toString().length)
						{
							this.selectedIndex = i;
	 						if (_toolTipField.length > 0)
							{
								this.toolTip = this.dataProvider[i][_toolTipField]
							}
							break;
						}
					}
				}
			}
		}
		
 		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			_typedText = "";
			validateData()
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			_typedText = "";
			this.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
		}

		override protected function textInput_changeHandler(event:Event):void
		{
			_typedText += this.textInput.text;
//			trace('_typedText=' + _typedText);
 			if (!findFirstItem(_typedText))
			{
				_typedText = _typedText.substr(0,_typedText.length -1);
				findFirstItem(_typedText);
			}
		}
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
//			trace("event="+event.toString());
			this.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
			event.preventDefault();
			if ((event.keyCode == Keyboard.TAB && _tabOut == null) || event.keyCode == Keyboard.ENTER) return;
			if (event.keyCode == Keyboard.TAB)
			{
				_tabOut();
			}
 		    if(!event.ctrlKey)
			{
				if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE)
				{
					_typedText = _typedText.substr(0,_typedText.length -1);
					findFirstItem(_typedText);
				}
				if (event.keyCode == Keyboard.DOWN || event.keyCode == Keyboard.RIGHT)
				{
					_typedText = "";
					if (this.dropdown.selectedIndex < this.dataProvider.length - 1)
					{
						this.selectedIndex++;
						this.dropdown.selectedIndex++;
						this.dropdown.scrollToIndex(this.dropdown.selectedIndex);
						_value = this.selectedItem[dataField];
					}
				}
				if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.LEFT)
				{
					_typedText = "";
					if (this.dropdown.selectedIndex > 0)
					{
						this.selectedIndex--;
						this.dropdown.selectedIndex--;
						this.dropdown.scrollToIndex(this.dropdown.selectedIndex);
						_value = this.selectedItem[dataField];
					}
				}
				if ((event.charCode > 31) && (event.charCode < 128))
				{
					_typedText += String.fromCharCode(event.charCode);
	 				if (!findFirstItem(_typedText))
					{
						_typedText = _typedText.substr(0,_typedText.length -1);
					}
				}
 			}
// 			trace("_typedText=" + _typedText);
			this.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
//		    super.keyDownHandler(event);
 		}
 		
		private function findFirstItem(strFindItem:String):Boolean
		{
			if (this.dataProvider != null)
			{
				if (strFindItem.length == 0)
				{
					this.selectedIndex = 0;
					this.dropdown.selectedIndex = 0;
					this.dropdown.scrollToIndex(0);
					_value = this.selectedItem[dataField];
					return true;
				}
				this.dispatchEvent(new MouseEvent("mouseOut"));
				for (var i:int=0;i<this.dataProvider.length;i++)
				{
					if (this.dataProvider[i][this.labelField].toString().substr(0,strFindItem.length).toUpperCase() == strFindItem.toUpperCase())
					{
						this.selectedIndex = i;
						this.dropdown.selectedIndex = i;
						this.dropdown.scrollToIndex(i);
						_value = this.selectedItem[dataField];
 						if (_toolTipField.length > 0)
						{
							this.toolTip = this.dataProvider[i][_toolTipField]
							this.dispatchEvent(new MouseEvent("mouseOver"));
						}
						return true;
					}
				}
			}
			return false;
		}
		

	}
}