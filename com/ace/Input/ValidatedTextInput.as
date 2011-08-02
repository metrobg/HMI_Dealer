package com.ace.Input
{
    /**
     * Created by Paul Stearns
     * Some minor pieces may be left over from the work of Darron Schall. I gutted his
     * FormattedTextInput module to create this.
     *
     */
    import com.Utils.CharacterUtils;
    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import mx.controls.TextInput;
    import mx.events.FlexEvent;
    import mx.formatters.CurrencyFormatter;
    import mx.formatters.DateFormatter;
    import mx.formatters.NumberFormatter;
    import mx.formatters.PhoneFormatter;
    import mx.utils.StringUtil;

    [Event(name="validationComplete", type="flash.events.Event")];
    /**
     * postValidate Code to execute after validateData method completes.
     *
     **/
    [Event(name="postValidate", type="flash.events.DataEvent")]
    /**
     * ValidateTextInput is a Flex Class that extends the TextInput Class, the main functionality
     * differences are the addition of validation and formatting for standard data types such as
     * numbers and dates.
     *
     * <p>The existing property â€˜textâ€™ is used to access the â€œformattedâ€ data. In other words if a
     * currency â€œFormatterâ€ property is defined for a specific field the data with dollar signs
     * and commas is contained in the â€œtextâ€ attribute. The raw data, suitable for inserting into
     * a database is contained in the â€œvalueâ€ property.</p>
     *
     * <p>The only exception to this is for data type date fields. Prior to populating the value
     * property for date fields, the dateFormat mask is applied. Most database like their dates
     * in a specific format, and one of the features of the date field is the ability for the
     * user to enter dates in a number of formats, such as â€˜mmddyyyyâ€™, â€˜mm-dd-yyyyâ€™, â€˜mm/dd/yyyyâ€™,
     * â€˜yyyymmddâ€™, â€˜dd-mon-yyyyâ€™, â€˜month day, yearâ€™. This date will then be converted to the
     * standard date format using the â€˜_dateFormatâ€™ formatter.</p>
     *
     * <p>One interesting feature is the ability to validate data using minimum and maximum values.
     * For example if a two digit number needs to be between 25 and 50 set the minValue property
     * to 25 and the maxValue to be 50. If the minValue or maxValue  need to be set to another
     * field on the form, use the syntax â€˜field:FieldNameâ€™ where â€˜field:â€™ tells the module to
     * look at another field, and â€˜FieldNameâ€™ is the name of the field whose â€˜valueâ€™ property to
     * look at. Restrictions on this capability are the field must have a â€˜valueâ€™ property and
     * must be a member of the parent of the current field. When dealing with date fields a
     * keyword of â€˜sysdateâ€™ can be used. The keyword â€˜sysdateâ€™ means todayâ€™s date.</p>
     *
     * <p><pre> When invalid data is entered, two things occur;
     * 	1.	The fields errorString property is set to an appropriate error. This of course turns
     * 		on the error tooltip.
     *  2.	A property for the field isValid is set to false.</pre></p>
     *
     * <p>The only external methods that has been added are â€˜validateData(), setDefault()â€™ tvalidateData will cause
     * the validation and formatting routines to be run for this object. Once this has been done
     * the isValid property can be tested to verify if the data entered is valid. setDefault will cause the
     * default value to be moved to the text property.</p>
     *
     */
    public class ValidatedTextInput extends TextInput
    {
        // constants for createClassObject 
        public static var symbolName:String = "ValidatedTextInput";

        public static var symbolOwner:Object = ValidatedTextInput;

        /** Name of internal or external formatter class to use. */
        private var _formatter:String = "";

        /** Strin to use for internal formatter class if different from normal. */
        private var _formatString:String = "";

        /** Raw data suitable for DB entry */
        private var _value:String;

        /** Type of data to be input. Controls certain types of validation  */
        private var _dataType:String = "string";

        /** Additional allowable characters */
        private var _charactersAlsoPermitted:String = "";

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

        /** Range of values for validation
         * 'Field:FieldName' */
        private var _rangeValue:String = "";

        /** Default value A literal that represents the value that will replace the "text"
         * value when the method setDefault is executed */
        private var _defaultValue:String = "";

        /** Precision, number of characters after the decimal place for numbers */
        private var _precision:int = 0;

        /** If a number datatype allow sign flag. */
        private var _sign:Boolean = false;

        /** If any datatype force upper case */
        private var _upper:Boolean = false;

        /** If any datatype force lower case */
        private var _lower:Boolean = false;

        /** If root level owner, used when called by other components such as ValidatedDateField */
        private var _rootOwner:Object = parent;

        /** If creditcard force lower accept only those in the list */
        private var _ccAccepted:String = "ax,dc,ds,mc,vi";

        /** If email datatype Allow multiple addresses? */
        private var _multipleEmails:Boolean = false;

        /** promptLabel */
        private var _promptLabel:String;

        /** lPad */
        private var _lPad:String = "";

        /** rPad */
        private var _rPad:String = "";

        /** should we format data */
        private var _formatData:Boolean = true;

        /** should we validate data */
        private var _doValidateData:Boolean = true;

        /** Has this field passed validation */
        private var _isValid:Boolean = true;

        /** Do we allow partial dates, on date datatypes */
        private var _allowPartialDate:Boolean = false;

        /** Has this field passed validation */
        private var _validExceptions:String = "";

        /** Has this field passed when Validation is coomplete */
        private var _validationComplete:Boolean = true;

        /**  external validator function */
        private var _extValidateFunction:Function = null;

        private var _inTextChanged:Boolean = false; // Flag to keep us from going into endless loops

        // when the text property changes due to internal 
        // functions.
        private var _initialized:Boolean = false; // Flag to keep us from reinitializing before our time

        private var _tabOut:Function = null;

        private var _focusOutTab:Boolean = false;

        /**
         * The delegate to catch any changes to the text so we can always apply the formt
         */
        private var eventHandler:Function = this["textChanged"];

        /** Constructor */
        public function ValidatedTextInput()
        {
            super();
            // set up the eventHandler function to be passed to addEventListener in init
            this.addEventListener(Event.CHANGE, eventHandler);
            this.addEventListener(FlexEvent.CREATION_COMPLETE, initObject);
        }

        /**
         * Override the superclass init method to add the event handlers for making sure
         * any time the text changes that the input is validated against the format.
         */ //		override public function initialize():void
//		{
        private function initObject(event:Event):void
        {
            this.removeEventListener(FlexEvent.CREATION_COMPLETE, initObject);
            initFormatters();
            /**
             * Set up the allowable characters
             */
            if (!this.restrict)
                this.restrict = "";
            var strRestrict:String = ""
            switch (_dataType.toLowerCase())
            {
                case "number":
                    strRestrict += "0-9";
                    if (_sign)
                        strRestrict += "\-";
                    if (_precision > 0)
                        strRestrict += ".";
                    this.setStyle("textAlign", "right");
                    break;
                case "date":
                    strRestrict += "0-9/";
                    break;
                case "alpha":
                    strRestrict += "a-zA-Z"
                    break;
                case "alphanumeric":
                    strRestrict += "a-zA-Z0-9";
                    break;
                case "creditcard":
                    strRestrict += "0-9\-";
                    if (!this.maxChars)
                        this.maxChars = 19;
                    if (!_maxDataChars)
                        _maxDataChars = 19;
                    if (!_ccAccepted)
                        _ccAccepted = "ax,dc,ds,mc,vi";
                    if (!_formatter)
                        _formatter = "_ccFormat";
                    this.setStyle("textAlign", "right");
                    break;
                case "email":
                    strRestrict += "a-zA-Z0-9\\_\@\\-\.";
                    if (_multipleEmails)
                        strRestrict += "\;";
                    break;
                case "hh:mm":
                    strRestrict += "0-9:";
                    this.setStyle("textAlign", "right");
                    break;
                case "am/pm":
                    strRestrict += "0-9: AaPpMm"
                    this.setStyle("textAlign", "right");
                    break;
                case "24hr":
                    strRestrict += "0-9:";
                    this.setStyle("textAlign", "right");
                    break;
            }
            if (this.restrict.length > 0 && strRestrict.length > 0)
                this.restrict = this.restrict.replace(strRestrict, "");
            if (strRestrict.length > 0)
                this.restrict += strRestrict;
            if (_charactersAlsoPermitted.length > 0 && this.restrict.length > 0)
            {
                this.restrict += _charactersAlsoPermitted;
            }
            if (this.restrict.length == 0)
                this.restrict = null;
            // Set the number of enterable characters = to the number of allowable characters
            //	if the number of enterable characters is not set.
            if (!this.maxChars && _maxDataChars)
                this.maxChars = _maxDataChars;
            // Set the number of allowable characters = to the number of enterable characters
            //	if the number of allowable characters is not set.
            if (_maxDataChars == 0 && this.maxChars)
                _maxDataChars = this.maxChars;
            // Keep the init functionality of the TextInput by calling super.init
//			super.initialize();
            var event:Event;
            textChanged(event);
            setDefault();
            _initialized = true;
        }

        override protected function focusOutHandler(event:FocusEvent):void
        {
            // When exiting field validate.
            if (_value.length == 0 && _defaultValue.length > 0)
            {
                this.text = _defaultValue
            }
            validateData();
            if (errorString.length > 0)
            {
//				validateData();
                this.dispatchEvent(new MouseEvent("MouseOut"));
            }
            super.focusOutHandler(event);
        }

        override protected function focusInHandler(event:FocusEvent):void
        {
            if (_value.length > 0)
            {
                this.dispatchEvent(new MouseEvent("MouseOut"));
//				validateData();
            }
            if (errorString.length > 0)
            {
                this.dispatchEvent(new MouseEvent("mouseOver"));
            }
            this.setSelection(0, this.text.length);
            this.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            this.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            super.focusInHandler(event);
            _focusOutTab = false;
        }

        override protected function keyDownHandler(event:KeyboardEvent):void
        {
//			trace("event="+event.toString());
            this.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            if (event.keyCode == Keyboard.TAB)
                _focusOutTab = true;
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
                    this.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
                }
            }
        }

        /**
         * setDefault - Method that will replace the value of the text property with the
         * value of the defaultValue property.
         */
        public function setDefault():void
        {
            this.text = "";
            var strTemp:String = getMinMaxValues(_defaultValue);
            if (strTemp.toLowerCase() == "sysdate")
            {
                var dtTemp:Date = new Date;
                var objTemp:Object = this["_dateFormat"];
                strTemp = objTemp.format(dtTemp);
            }
            if (strTemp.toLowerCase() == "systime")
            {
                strTemp = SysTime(_dataType);
            }
            this.text = strTemp;
            this.errorString = "";
        }

        /**
         * getDefault - Method that will return the value of the defaultValue property.
         *
         * This method returns the converted value, ie - if defaultValue is sysdate it
         * will return the date in whatever format specified by the formatter.
         */
        public function getDefault():String
        {
            var strTemp:String = getMinMaxValues(_defaultValue);
            if (strTemp.toLowerCase() == "sysdate")
            {
                var dtTemp:Date = new Date;
                var objTemp:Object = this["_dateFormat"];
                strTemp = objTemp.format(dtTemp);
            }
            return strTemp;
        }

        private var inValidateData:Boolean = false;

        /**
         * validateData - Method that will validate and format the data that has been entered.
         */
        public function validateData():Boolean
        {
            if (_doValidateData == false || inValidateData == true)
                return true;
            _isValid = true;
            inValidateData = true;
            // Get the raw data
            extractValue();
            this.errorString = "";
            if (_lPad.length > 0)
            {
                _value = PadStr(_value, _lPad, _maxDataChars, "Left")
                this.text = PadStr(_value, _lPad, _maxDataChars, "Left")
            }
            if (_rPad.length > 0)
            {
                _value = PadStr(_value, _rPad, _maxDataChars, "Right")
                this.text = PadStr(_value, _rPad, _maxDataChars, "Right")
            }
            if (this.enabled == false || this.visible == false)
            {
                inValidateData = false;
                return true;
            }
            // Check for too many or too few characters entered.
            if (_value.length > _maxDataChars && _maxDataChars > 0)
                errorString += "Too many characters. ";
            if (_minDataChars > 0)
            {
                if (_value.length < 1)
                {
                    if (_rangeValue.substr(0, 1) != "," && _rangeValue.indexOf(",,") == -1 && _rangeValue.substr(_rangeValue.length - 1) != ",")
                        errorString += "Information required. ";
                }
                else
                {
                    if (_value.length < _minDataChars)
                        errorString += "Too few characters. ";
                }
            }
            // If number of characters are ok, check for other types of errors
            if (errorString.length == 0 && ((_minDataChars != 0 || _value.length > 0) || allowPartialDate))
            {
                switch (_dataType.toLowerCase())
                {
                    case "number":
                        validateNumber();
                        break;
                    case "alpha":
                        validateAlpha();
                        break;
                    case "alphanumeric":
                        validateAlphaNumeric();
                        break;
                    case "date":
                        validateDate();
                        break;
                    case "string":
                        validateString();
                        break;
                    case "creditcard":
                        validateCreditCard();
                        break;
                    case "email":
                        validateEMail();
                        break;
                    case "hh:mm":
                    case "am/pm":
                    case "24hr":
                        validateTime();
                }
            }
            if (_extValidateFunction != null && this.errorString.length == 0)
                this.errorString = _extValidateFunction();
            // Set property isValid so everyone else can see if our data is good.
            if (this.errorString.length > 0)
            {
                _isValid = false;
            }
            else
            {
                _isValid = true;
                // if a formatter is defined and we have no errors format the data.
                if (_formatData && _formatter && _value.length > 0)
                {
                    var objTemp:Object
                    if (_formatter.length > 0 && !(this[_formatter]))
                        initFormatters();
                    if (_formatter.substr(0, 1) == "_")
                    { // Use one of our predefined formatters.
                        objTemp = this[_formatter];
                        if (_formatter == "_nbrFormat" && _precision > 0)
                            objTemp.precision = _precision;
                        if (_formatString.length > 0)
                            objTemp.formatString = _formatString
                    }
                    else
                    { // Use a developer specified formatter.
                        objTemp = _rootOwner.getChildByName(_formatter.toString());
                    }
                    //				trace('_formatter=' + _formatter);
                    //				trace('objTemp.formatString=' + objTemp.formatString);
                    text = objTemp.format(_value);
                    if (text.length == 0)
                    { // This should never occur except during development.
                        if (_value.length < _maxDataChars)
                        {
                            switch (_dataType.toLowerCase())
                            {
                                case "number":
                                case "date":
                                case "hh:mm":
                                case "am/pm":
                                case "24hr":
                                case "creditcard":
                                    _value = PadStr(_value, "0", _maxDataChars, "Left")
                                    break;
                                case "alpha":
                                case "alphanumeric":
                                case "string":
                                    _value = PadStr(_value, " ", _maxDataChars, "Right")
                                    break;
                            }
                            text = objTemp.format(_value);
                        }
                        if (text.length == 0)
                        {
                            text = _value;
                            errorString = "Unexpected Error, formatter did not match data."
                            _isValid = false
                        }
                    }
                }
            }
//			trace('_isValid=' + _isValid);
            inValidateData = false;
            this.dispatchEvent(new DataEvent("postValidate"));
            return _isValid;
        }

        /**
         * formatter - Name of formatter to use to format the data. Either a formatter within the calling module or
         * one of the following;
         * <pre>
         * _usdFormat US Currency
         * _nbrFormat Number format
         * _dateFormat US Date Format
         * _phoneFormat US Phone Number Format
         * _ssnFormat US Social Security Number format
         * _ccFormat Credit Card Format
         * </pre>
         * @return the specified format
         */
        [Inspectable(type="String", defaultValue="")]
        public function get formatter():String
        {
            return this._formatter;
        }

        /**
         * Sets the format that the input value and text property will be formatted with
         */
        public function set formatter(formatter:String):void
        {
            this._formatter = formatter;
            var event:Event;
            textChanged(event);
        }

        /**
         * Format string for use when a predefined formatters is specified such as _dateFormat or _ssnFormat.
         * This format string that modifies the default format string for this instance of the object.
         *
         * @return the specified format
         */
        [Inspectable(type="String", defaultValue="")]
        public function get formatString():String
        {
            return this._formatString;
        }

        /**
         * Sets the format that the input value and text property will be formatted with
         */
        public function set formatString(formatString:String):void
        {
            this._formatString = formatString;
            if (_formatter.length > 0 && !(this[_formatter]))
                initFormatters();
            if (_formatter.length > 0)
                this[_formatter].formatString = _formatString
            var event:Event;
            textChanged(event);
        }

        /**
         * lPad allows the specification of a character to prepend to the text property.
         *
         * @return the specified lpad
         */
        [Inspectable(type="String", defaultValue="")]
        public function get lPad():String
        {
            return this._lPad;
        }

        /**
         * Sets the lpad that the input value and text property will be formatted with
         */
        public function set lPad(lPad:String):void
        {
            this._lPad = lPad;
            var event:Event;
            textChanged(event);
        }

        /**
         * rPad allows the specification of a character to append to the text property.
         *
         * @return the specified rPad
         */
        [Inspectable(type="String", defaultValue="")]
        public function get rPad():String
        {
            return this._rPad;
        }

        /**
         * Sets the rPad that the input value and text property will be formatted with
         */
        public function set rPad(rPad:String):void
        {
            this._rPad = rPad;
            var event:Event;
            textChanged(event);
        }

        /**
         * dataType - allows the specification of what type of data that can be entered.
         *
         * <pre>
         * The allowable types are;
         * number valid numbers,
         * date valid dates,
         * alpha valid alphabetic characters only,
         * alphaNumeric valid alphabetic and numbers,
         * string any typeable characters,
         * creditCard valid credit card numbers,
         * email valid email addresses,
         * hh:mm valid time,
         * am/pm valid 12 hour time,
         * 24hr valid 24 hour clock format time.
         * </pre>
         * @return the specified Data type
         */
        [Inspectable(type="String", defaultValue="string", enumeration="number,date,alpha,alphaNumeric,string,creditCard,email,hh:mm,am/pm,24hr")]
        public function get dataType():String
        {
            return this._dataType;
        }

        /**
         * Sets the data type
         */
        public function set dataType(dataType:String):void
        {
            this._dataType = dataType;
            var event:Event;
            textChanged(event);
        }

        /**
         * charactersAlsoPermitted - allows a string of characters that are permitted in this field
         * that would normally not be allowed based on the current dataType.
         *
         * @return the specified charactersAlsoPermitted
         */
        [Inspectable(type="String", defaultValue="")]
        public function get charactersAlsoPermitted():String
        {
            return this._charactersAlsoPermitted;
        }

        /**
         * Sets the Characters Also Permitted
         */
        public function set charactersAlsoPermitted(charactersAlsoPermitted:String):void
        {
            if (this._charactersAlsoPermitted.length > 0 && this.restrict)
            {
                this.restrict = this.restrict.replace(this._charactersAlsoPermitted, "");
            }
            this._charactersAlsoPermitted = charactersAlsoPermitted;
            var strTemp:String = this.text;
            if (_initialized)
            {
                var event:Event;
                initObject(event)
            }
            this.text = strTemp;
            textChanged(event);
        }

        /**
         * minDataChars - Allows the specification of the fewest number of characters allowed in this field.
         *
         * @return the specified minimum Data Length
         */
        [Inspectable(type="Number", defaultValue=0)]
        public function get minDataChars():Number
        {
            return this._minDataChars;
        }

        /**
         * Sets the specified minimum Data Length
         */
        public function set minDataChars(minDataChars:Number):void
        {
            this._minDataChars = minDataChars;
            var event:Event;
            textChanged(event);
            if ((_minDataChars > 0 && this.text.length > 0) || this.errorString.length > 0)
                this.validateData();
        }

        /**
         * maxDataChars - Allows the specification of the largest number of characters allowed in this field.
         *
         * @return the specified maximum Data Length
         */
        [Inspectable(type="Number", defaultValue=0)]
        public function get maxDataChars():Number
        {
            return this._maxDataChars;
        }

        /**
         * Sets the specified maximum Data Length
         */
        public function set maxDataChars(maxDataChars:Number):void
        {
            this._maxDataChars = maxDataChars;
            var event:Event;
            textChanged(event);
            if ((_maxDataChars > 0 && this.text.length > 0) || this.errorString.length > 0)
                this.validateData();
        }

        /**
         * minValue - allows the specification of the minimum value that is allowed.
         * <pre>
         * This is data type dependent. Dates, numbers, times etc. are handled based on their data type.
         *
         * A few notes;
         *
         * For date fields, "sysdate" can be used to specify today.
         * Reference to another field is also allowed and is specified using the syntax â€˜field:FieldNameâ€™
         * where â€˜field:â€™ tells the module to look at another field, and â€˜FieldNameâ€™ is the name of the
         * field whose â€˜valueâ€™ property to look at
         * </pre>
         * @return the specified minimum value
         */
        [Inspectable(type="String", defaultValue="")]
        public function get minValue():String
        {
            return this._minValue;
        }

        /**
         * Sets the the specified minimum value
         */
        public function set minValue(minValue:String):void
        {
            this._minValue = minValue;
            var event:Event;
            textChanged(event);
            if (_minValue.length > 0 && _value.length > 0)
                this.validateData();
        }

        /**
         * maxValue - allows the specification of the maximum value that is allowed.
         * <pre>
         * This is data type dependent. Dates, numbers, times etc. are handled based on their data type.
         *
         * A few notes;
         *
         * For date fields, "sysdate" can be used to specify today.
         * Reference to another field is also allowed and is specified using the syntax â€˜field:FieldNameâ€™
         * where â€˜field:â€™ tells the module to look at another field, and â€˜FieldNameâ€™ is the name of the
         * field whose â€˜valueâ€™ property to look at</pre>
         *
         * @return the specified Maximum value
         */
        [Inspectable(type="String", defaultValue="")]
        public function get maxValue():String
        {
            return this._maxValue;
        }

        /**
         * Sets the specified Maximum value
         */
        public function set maxValue(maxValue:String):void
        {
            this._maxValue = maxValue;
            var event:Event;
            textChanged(event);
            if (_maxValue.length > 0 && _value.length > 0)
                this.validateData();
        }

        /**
         * rangeValue - allows the specification a list of values to validate against value that is allowed.
         * <pre>
         * This is data type dependent. It is only applicable to datatype number, alpha, alphanum.
         *
         * A few notes;
         *
         * The format of the string is aaa,ccc,eee-ggg,nnn. This string will return valid if the input is
         * either aaa or ccc or between eee and ggg inclusive or nnn.
         *
         * </pre>
         *
         * @return the specified Range value
         */
        [Inspectable(type="String", defaultValue="")]
        public function get rangeValue():String
        {
            return this._rangeValue;
        }

        /**
         * Sets the specified Range value
         */
        public function set rangeValue(rangeValue:String):void
        {
            this._rangeValue = rangeValue;
            var event:Event;
            textChanged(event);
            if (_rangeValue.length > 0 && _value.length > 0)
                this.validateData();
        }

        /**
         * defaultValue - allows the specification of a default value for a field.
         * To set the current text/value properties use the the setDefault() method.
         *
         * @return the specified defaultValue
         */
        [Inspectable(type="String", defaultValue="")]
        public function get defaultValue():String
        {
            return this._defaultValue;
        }

        /**
         * Sets the specified Default value
         */
        public function set defaultValue(defaultValue:String):void
        {
            this._defaultValue = defaultValue;
        }

        /**
         * precision - used with number data types to specify the maxinum
         * number of characters after the decimal point. The default is 0.
         *
         * @return the specified decimal precision
         */
        [Inspectable(type="Number", defaultValue=0)]
        public function get precision():Number
        {
            return this._precision;
        }

        /**
         * Sets the specified decimal precision
         */
        public function set precision(precision:Number):void
        {
            this._precision = precision;
            var event:Event;
            textChanged(event);
        }

        /**
         * sign - used for number data types. Allows the entry of a sign for negative numbers.
         * The default is false.
         *
         * @return the specified sign flag.
         */
        [Inspectable(type="Boolean", defaultValue=false, enumeration="true,false")]
        public function get sign():Boolean
        {
            return this._sign;
        }

        /**
         * Sets the specified sign flag.
         */
        public function set sign(sign:Boolean):void
        {
            this._sign = sign;
            var event:Event;
            textChanged(event);
        }

        /**
         * upper - Specifies whether to force the field to upper case. The default is false.
         *
         * @return the specified upper flag.
         */
        [Inspectable(type="Boolean", defaultValue=false, enumeration="true,false")]
        public function get upper():Boolean
        {
            return this._upper;
        }

        /**
         * Sets the specified upper flag.
         */
        public function set upper(upper:Boolean):void
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
        [Inspectable(type="Boolean", defaultValue=false, enumeration="true,false")]
        public function get lower():Boolean
        {
            return this._lower;
        }

        /**
         * Sets the specified lower case flag.
         */
        public function set lower(lower:Boolean):void
        {
            this._lower = lower;
            var event:Event;
            textChanged(event);
        }

        /**
         * rootOwner - specifies the top level parent component. It is used
         * when components such as ValidatedDateField calls this component.
         *
         * @return the specified top level parent component.
         */
        [Inspectable(type="Object", defaultValue=parent)]
        public function get rootOwner():Object
        {
            return this._rootOwner;
        }

        /**
         * Sets the specified lower case flag.
         */
        public function set rootOwner(rootOwner:Object):void
        {
            this._rootOwner = rootOwner;
            var event:Event;
            textChanged(event);
        }

        /**
         * ccAccepted - Specifies the credit card types allowed. The default is "ax,dc,ds,mc,vi".
         *
         * @return the specified Data type
         */
        [Inspectable(type="String", defaultValue="ax,dc,ds,mc,vi")]
        public function get ccAccepted():String
        {
            return this._ccAccepted;
        }

        /**
         * Sets the Credit Cards Accepted
         */
        public function set ccAccepted(ccAccepted:String):void
        {
            this._ccAccepted = ccAccepted;
            var event:Event;
            textChanged(event);
        }

        /**
         * multipleEmails - specify whether this field could have multiple email addresses.
         * The default is false.
         *
         * @return the specified sign flag.
         */
        [Inspectable(type="Boolean", defaultValue=false, enumeration="true,false")]
        public function get multipleEmails():Boolean
        {
            return this._multipleEmails;
        }

        /**
         * Sets the specified multipleEmails flag.
         */
        public function set multipleEmails(multipleEmails:Boolean):void
        {
            this._multipleEmails = multipleEmails;
            var event:Event;
            textChanged(event);
        }

        /**
         * formatData - Specify whether the field should be formatted. Default is true.
         *
         * @return the specified format data flag.
         */
        [Inspectable(type="Boolean", defaultValue=true, enumeration="true,false")]
        public function get formatData():Boolean
        {
            return this._formatData;
        }

        /**
         * Sets the specified format data flag.
         */
        public function set formatData(formatData:Boolean):void
        {
            this._formatData = formatData;
            var event:Event;
            textChanged(event);
        }

        /**
         * extValidateFunction - Specify any external validation routines.
         *
         * @return the specified  external validation routine.
         */
        public function get extValidateFunction():Function
        {
            return this._extValidateFunction;
        }

        /**
         * Sets the specified  external validation routine.
         */
        public function set extValidateFunction(extValidateFunction:Function):void
        {
            this._extValidateFunction = extValidateFunction;
            var event:Event;
            textChanged(event);
        }

        /**
         * tabOut - A function to execute if the tabkey is pressed..
         *
         * @return the specified tabOut Function
         */
        [Inspectable(type="Function", defaultValue="")]
        public function get tabOut():Function
        {
            return this._tabOut;
        }

        /**
         * Sets the the specified tabOut
         */
        public function set tabOut(tabOut:Function):void
        {
            this._tabOut = tabOut;
        }

        /**
         * focusOutTab - A boolean defining if the last focus out was a tab.
         *
         * @return  focusOutTab
         */
        public function get focusOutTab():Boolean
        {
            return this._focusOutTab;
        }

        /**
         * Sets the the specified focusOutTab
         */
        public function set focusOutTab(focusOutTab:Boolean):void
        {
            this._focusOutTab = focusOutTab;
        }

        /**
         * doValidateData - specify the whether this field should be validated. Default is true.
         *
         * @return the specified validate data flag.
         */
        [Inspectable(type="Boolean", defaultValue=true, enumeration="true,false")]
        public function get doValidateData():Boolean
        {
            return this._doValidateData;
        }

        /**
         * Sets the specified validate data flag.
         */
        public function set doValidateData(doValidateData:Boolean):void
        {
            this._doValidateData = doValidateData;
        }

        /**
         * validExceptions - specify a list of acceptable values that would otherwise generate and error.
         *
         * For example 0s or 9s might be allowed on a date field, so the value
         * of this property might be "00000000,99999999"
         *
         * @return the specified Data type
         */
        [Inspectable(type="String", defaultValue="")]
        public function get validExceptions():String
        {
            return this._validExceptions;
        }

        /**
         * Sets the Credit Cards Accepted
         */
        public function set validExceptions(validExceptions:String):void
        {
            this._validExceptions = validExceptions;
            var event:Event;
            textChanged(event);
        }

        /**
         * promptLabel - Specify a human readable label for the field.
         *
         * @return the specified promptLabel
         */
        [Inspectable(type="String", defaultValue="")]
        public function get promptLabel():String
        {
            return this._promptLabel;
        }

        /**
         * Sets the the specified promptLabel
         */
        public function set promptLabel(promptLabel:String):void
        {
            this._promptLabel = promptLabel;
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
        public function get value():String
        {
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
            var reApostrophe:RegExp = new RegExp("'", "g");
            return _value.replace(reApostrophe, "''");
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
         * Sets the the specified isValid
         */
        public function set isValid(isValid:Boolean):void
        {
            this._isValid = isValid;
        }

        /**
         * allowPartialDate - Allows just year, or year/month in date fields.
         *
         * <pre>
         * This is for dates where the day, or month or year can be blank. The missing
         * components will be returned as spaces, and the date will be displayed in
         * yyyy-mm-dd format.
         * </pre>
         */
        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(type="Boolean", defaultValue=false, enumeration="true,false")]
        public function get allowPartialDate():Boolean
        {
            return _allowPartialDate;
        }

        /**
         * Sets the the specified allowPartialDate
         */
        public function set allowPartialDate(allowPartialDate:Boolean):void
        {
            this._allowPartialDate = allowPartialDate;
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
//				validateData();
            }
            return;
        }

        /**
         * textChanged - Event handler that gets invoked when things change. Basically we get the raw data from
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
        public function extractValue():void
        {
            // reset the value since we're trying to extract a new value from the text
            _value = "";
            for (var i:Number = 0; i < text.length; i++)
            {
                // examine the current character in our loop
                var char:String = text.charAt(i);
                switch (dataType.toLowerCase())
                {
                    case "number":
                        if (CharacterUtils.isDigit(char, _sign, (_precision > 0)) || CharacterUtils.isValid(char, _charactersAlsoPermitted))
                        {
                            _value += char;
                        }
                        break;
                    case "date":
                        if (CharacterUtils.isDigit(char, false, false) || CharacterUtils.isValid(char, _charactersAlsoPermitted))
                        {
                            _value += char;
                        }
                        break;
                    case "alpha":
                        if (CharacterUtils.isUpperCase(char) || CharacterUtils.isLowerCase(char) || CharacterUtils.isValid(char, _charactersAlsoPermitted))
                        {
                            _value += char;
                        }
                        break;
                    case "alphanumeric":
                        if (CharacterUtils.isUpperCase(char) || CharacterUtils.isLowerCase(char) || CharacterUtils.isDigit(char, false, false) || CharacterUtils.isValid(char, _charactersAlsoPermitted))
                        {
                            _value += char;
                        }
                        break;
                    case "creditcard":
                        if (CharacterUtils.isDigit(char, false, false) || CharacterUtils.isValid(char, _charactersAlsoPermitted))
                        {
                            _value += char;
                        }
                        break;
                    default:
                        _value += char;
                }
                // Convert to upper or lower case as needed.
                if (_upper)
                    _value = _value.toUpperCase();
                if (_lower)
                    _value = _value.toLowerCase();
            }
        }

        /**
         * Pad a string with your character of choice either on the left or right
         */
        private function PadStr(InString:String, PadChar:String, OutLen:int, RightLeft:String):String
        {
            var WrkString:String = new String(InString);
            if (WrkString.length == 0)
                return "";
            if (WrkString.length >= OutLen)
                return WrkString;
            var PadString:String = new String(PadChar);
            for (var i:int = 1; PadString.length < (OutLen - WrkString.length); i++)
            {
                PadString += PadChar;
            }
            if (RightLeft.toUpperCase() == "RIGHT")
            {
                WrkString += PadString;
                return WrkString;
            }
            else
            {
                WrkString = PadString + WrkString;
                return WrkString;
            }
        }

        /**
         * Validation routines.
         *
         */
        private function validateNumber():void
        {
            var strTest:String = _value;
            if (_charactersAlsoPermitted.length > 0)
            {
                var rgxPermitted:RegExp = new RegExp("[" + _charactersAlsoPermitted + "]", "gim");
                strTest = _value.replace(rgxPermitted, "");
            }
            var aryTemp:Array = strTest.split('.')
            if (aryTemp.length > 2 || ((aryTemp.length > 1) && (_precision == 0)))
                errorString += "Too many decimal characters. ";
            if (aryTemp.length > 1)
            {
                if (aryTemp[1].toString().length > _precision)
                    errorString += "Too many characters after decimal point. ";
            }
            if (strTest.indexOf("-") > -1 && !sign)
                errorString += "Negative values not allowed. ";
            if (_precision > 0 && errorString.length < 1)
            {
                if (aryTemp.length < 2)
                {
                    _value = aryTemp[0] + "." + PadStr('0', '0', _precision, "RIGHT");
                }
                else
                {
                    _value = aryTemp[0] + "." + PadStr(aryTemp[1], '0', _precision, "RIGHT");
                }
                strTest = _value;
            }
            if (errorString.length == 0)
            {
                var nbrTest:Number = 0;
                var nbrValue:Number = 0;
                if (_precision == 0)
                {
                    nbrValue = parseInt(strTest, 10);
                }
                else
                {
                    nbrValue = parseFloat(strTest);
                }
                if (getMinMaxValues(_minValue).length > 0)
                {
                    if (_precision == 0)
                    {
                        nbrTest = parseInt(getMinMaxValues(_minValue), 10);
                    }
                    else
                    {
                        nbrTest = parseFloat(getMinMaxValues(_minValue));
                    }
                    if (nbrValue < nbrTest)
                        errorString += "Value too Small. \n The minimum is " + getMinMaxValues(_minValue);
                }
                if (getMinMaxValues(_maxValue).length > 0)
                {
                    if (_precision == 0)
                    {
                        nbrTest = parseInt(getMinMaxValues(_maxValue), 10);
                    }
                    else
                    {
                        nbrTest = parseFloat(getMinMaxValues(_maxValue));
                    }
                    if (nbrValue > nbrTest)
                        errorString += "Value too Large. \n The maximum is " + getMinMaxValues(_maxValue);
                }
                if (_rangeValue.length > 0)
                {
                    if (!CheckNbrValue(nbrValue, _rangeValue))
                        errorString += "Value not in range. " + _rangeValue;
                }
            }
        }

        private function validateAlpha():void
        {
            if (_lower)
                text = text.toLowerCase();
            if (_upper)
                text = text.toUpperCase();
            if (errorString.length == 0)
            {
                if (getMinMaxValues(_minValue).length > 0)
                {
                    if (_value < getMinMaxValues(_minValue))
                    {
                        errorString += "Value too Small. \n The minimum is " + getMinMaxValues(_minValue);
                    }
                }
                if (getMinMaxValues(_maxValue).length > 0)
                {
                    if (_value > getMinMaxValues(_maxValue))
                    {
                        errorString += "Value too Great. \n The minimum is " + getMinMaxValues(_maxValue);
                    }
                }
                if (_rangeValue.length > 0)
                {
                    if (!CheckStrValue(_value, _rangeValue))
                        errorString += "Value not in range. " + _rangeValue;
                }
            }
        }

        private function validateAlphaNumeric():void
        {
            if (_lower)
                text = text.toLowerCase();
            if (_upper)
                text = text.toUpperCase();
            if (errorString.length == 0)
            {
                if (getMinMaxValues(_minValue).length > 0)
                {
                    if (_value < getMinMaxValues(_minValue))
                    {
                        errorString += "Value too Small. \n The minimum is " + getMinMaxValues(_minValue);
                    }
                }
                if (getMinMaxValues(_maxValue).length > 0)
                {
                    if (_value > getMinMaxValues(_maxValue))
                    {
                        errorString += "Value too Great. \n The minimum is " + getMinMaxValues(_maxValue);
                    }
                }
                if (_rangeValue.length > 0)
                {
                    if (!CheckStrValue(_value, _rangeValue))
                        errorString += "Value not in range. " + _rangeValue;
                }
            }
        }

        private function validateDate():void
        {
            if (allowPartialDate == false || (allowPartialDate == true && StringUtil.trim(_value).length == 8))
            { //Do full date testing
                var dtTest:Date = new Date;
                if (_validExceptions.length > 0)
                {
                    if (_validExceptions.indexOf(_value) > -1)
                    {
                        errorString = "";
                        return;
                    }
                }
                var aryDate:Object = CvtDateIn(_value);
                if (aryDate["Year"] == 0 || aryDate["Month"] == 0 || aryDate["Day"] == 0)
                {
                    errorString = "Invalid Date.";
                }
                else
                {
                    dtTest = new Date(aryDate["Year"], (aryDate["Month"] - 1), aryDate["Day"], 0, 0, 0, 0);
                    if (aryDate["Year"] == dtTest.fullYear && aryDate["Month"] == (dtTest.month + 1) && aryDate["Day"] == dtTest.date)
                    {
                        if (_formatter.length > 0)
                        {
                            if (!(this[_formatter]))
                                initFormatters();
                            if (_formatter != "_dateRevFormat")
                            {
                                _value = this[_formatter].format(dtTest);
                            }
                            else
                            {
                                text = PadStr(aryDate["Year"], "0", 2, "Left") + PadStr(aryDate["Month"], "0", 2, "Left") + PadStr(aryDate["Day"], "0", 2, "Left");
                                _value = text;
                            }
                        }
                        else
                        {
                            errorString = "A formatter must be specified for date fields.";
                        }
                    }
                    else
                    {
                        errorString = "Invalid Date.";
                    }
                }
                if (errorString.length == 0)
                {
                    var dtValue:Date = dtTest;
                    dtTest = new Date;
                    dtTest = new Date(dtTest.fullYear, dtTest.month, dtTest.date, 0, 0, 0, 0);
                    if (getMinMaxValues(_minValue).length > 0)
                    {
                        if (getMinMaxValues(_minValue).toLowerCase() != "sysdate")
                        {
                            aryDate = CvtDateIn(getMinMaxValues(_minValue));
                            dtTest = new Date(aryDate["Year"], (aryDate["Month"] - 1), aryDate["Day"], 0, 0, 0, 0);
                        }
                        if (dtValue < dtTest)
                            errorString += "Date too Early. \n The minimum is " + getMinMaxValues(_minValue);
                    }
                    dtTest = new Date;
                    dtTest = new Date(dtTest.fullYear, dtTest.month, dtTest.date, 23, 59, 59, 99);
                    if (getMinMaxValues(_maxValue).length > 0)
                    {
                        if (getMinMaxValues(_maxValue).toLowerCase() != "sysdate")
                        {
                            aryDate = CvtDateIn(getMinMaxValues(_maxValue));
                            dtTest = new Date(aryDate["Year"], (aryDate["Month"] - 1), aryDate["Day"], 0, 0, 0, 0);
                        }
                        if (dtValue > dtTest)
                            errorString += "Date too Late. \n The maximum is " + getMinMaxValues(_maxValue);
                    }
                }
            }
            else
            { // Do partial Date testing
                var strDateTest:String = StringUtil.trim(_value);
                if (strDateTest.length == 0)
                {
                    _value = "        ";
                }
                else
                {
                    if (strDateTest.length != 0 && strDateTest.length != 4 && strDateTest.length != 6)
                    {
                        errorString += "Cannot have a partial month, day, or year";
                    }
                    else
                    {
                        var intYear:int = parseInt(_value.substr(0, 4), 10);
                        if (intYear < 1850)
                            errorString += "Year cannot be before 1850";
                        if (strDateTest.length > 4)
                        {
                            var intMonth:int = parseInt(_value.substr(4, 2), 10);
                            if (intMonth < 1 || intMonth > 12)
                                errorString += "Invalid month";
                        }
                    }
                    _value = PadStr(strDateTest, " ", 8, "Right");
                }
            }
        }

        private function validateTime():void
        {
            var MinuteSeq:Number = CvTimeIn(_value);
            if (MinuteSeq == -1)
            {
                errorString = "Invalid Time - Enter HH:MM AM/PM";
                return;
            }
            if (getMinMaxValues(_minValue).length > 0)
            {
                var MinValIn:String = getMinMaxValues(_minValue).toLowerCase();
                if (MinValIn == "SYSTIME")
                    MinValIn = SysTime("24HR");
                var MinVal:Number = CvTimeIn(MinValIn);
                if (MinuteSeq < MinVal)
                {
                    errorString = "Invalid Time - value cannot be less than " + MinValIn;
                    return;
                }
            }
            if (getMinMaxValues(_maxValue).length > 0)
            {
                var MaxValIn:String = getMinMaxValues(_maxValue).toLowerCase();
                if (MaxValIn == "SYSTIME")
                    MaxValIn = SysTime("24HR");
                var MaxVal:Number = CvTimeIn(MaxValIn);
                if (MinuteSeq > MaxVal)
                {
                    errorString = "Invalid Time - value cannot be more than " + MaxValIn;
                    return;
                }
            }
            this.text = CvTimeOut(MinuteSeq, _dataType);
        }

        private function validateString():void
        {
            if (errorString.length == 0)
            {
                if (getMinMaxValues(_minValue).length > 0)
                {
                    if (_value < getMinMaxValues(_minValue))
                    {
                        errorString += "Value too Small. \n The minimum is " + getMinMaxValues(_minValue);
                    }
                }
                if (getMinMaxValues(_maxValue).length > 0)
                {
                    if (_value > getMinMaxValues(_maxValue))
                    {
                        errorString += "Value too Great. \n The minimum is " + getMinMaxValues(_maxValue);
                    }
                }
                if (_rangeValue.length > 0)
                {
                    if (!CheckStrValue(_value, _rangeValue))
                        errorString += "Value not in range. " + _rangeValue;
                }
            }
            this.text = _value;
        }

        private function validateCreditCard():void
        {
            var strCCType:String = getValidCreditCard(_value);
            var strCCMask:String = "";
            if (strCCType.substr(0, 3) == "Bad")
            {
                errorString = "Invalid Credit Card Number (" + strCCType + ")";
            }
            else
            {
                if (_ccAccepted.indexOf(strCCType) > -1)
                {
                    switch (strCCType)
                    {
                        case "vi": // Visa
                            strCCMask = "####-####-####-####";
                            break;
                        case "mc": // Mastercard
                            strCCMask = "####-####-####-####";
                            break;
                        case "ds": // Discover
                            strCCMask = "####-####-####-####";
                            break;
                        case "ax": // American Express
                            strCCMask = "####-######-#####";
                            break;
                        case "dc": // Diners
                            strCCMask = "####-######-####";
                            break;
                    }
                }
                else
                {
                    errorString = "Credit Card not Accepted  (" + strCCType + ")";
                }
            }
            if (errorString.length == 0)
            {
                _formatString = strCCMask;
                _formatter = "_ccFormat";
                _ccFormat.formatString = _formatString;
            }
        }

        private function validateEMail():void
        {
            var reEmail:RegExp = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/;
            if (_lower)
                text = text.toLowerCase();
            if (_upper)
                text = text.toUpperCase();
            if (_multipleEmails)
            {
                var aryEmails:Array = _value.split(";");
                for (var i:int = 0; i < aryEmails.length; i++)
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

        /**
         * Convert a date string of a variety of formats into an object containing
         * a numeric year, month and day.
         */
        private function CvtDateIn(InString:String):Object
        {
            var Year:int = 0;
            var Month:int = 0;
            var Day:int = 0;
            var WrkString:String = new String(InString);
            var DateValues:Array;
//			if ( /^(1[3-9]|[2-9][0-9])[0-9]{6}$/.test(WrkString) ){
            if (/^(18|19|20|21)[0-9][0-9](0[[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/.test(WrkString))
            {
                // test for yyyymmdd
                Month = parseInt(InString.substring(4, 6), 10);
                Day = parseInt(InString.substring(6, 8), 10);
                Year = parseInt(InString.substring(0, 4), 10);
            }
            if (/^(0[0-9]|1[012])([012][0-9]|3[01])([0-9][0-9]|[0-9]{4})$/.test(WrkString))
            {
                // test for mmddyyyy or mmddyy
                Month = parseInt(InString.substring(0, 2), 10);
                Day = parseInt(InString.substring(2, 4), 10);
                Year = parseInt(InString.substring(4, InString.length), 10);
            }
            if (/^[0-9][0-3][0-9]{3,5}$/.test(InString) && Month + Day + Year == 0)
            {
                // test for mddyyyy or mddyy
                Month = parseInt(InString.substring(0, 1), 10);
                Day = parseInt(InString.substring(1, 3), 10);
                Year = parseInt(InString.substring(3, InString.length), 10);
            }
            if (/^[01]?[0-9][-\/][0-3]?[0-9][-\/][0-9]{2,4}$/.test(InString))
            {
                // test for mm/dd/yyyy or mm-dd-yyyy or m/dd/yyyy or m/d/yyyy
                // or m-dd-yyyy or m-d-yyyy or any of the above with yy instead of yyyy
                var Delim:String = "";
                if (InString.indexOf("/") != -1)
                {
                    Delim = "/";
                }
                else
                {
                    Delim = "-";
                }
                DateValues = InString.split(Delim);
                Month = parseInt(DateValues[0], 10);
                Day = parseInt(DateValues[1], 10);
                Year = parseInt(DateValues[2], 10);
            }
            if (/^[0-3]?[0-9]-[JjFfMmAaSsOoNnDd][AaEePpUuCcOo][NnBbRrYyLlGgPpTtVvCc]-[0-9]{2,4}$/.test(InString) && Month == 0)
            {
                //test for dd-mon-yyyy or d-mon-yyyy or any of the above with yy instead of yyyy
                DateValues = InString.split("-");
                Month = "|JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|".indexOf("|" + DateValues[1].toUpperCase() + "|");
                Month = Math.floor(Month / 4) + 1;
                Day = parseInt(DateValues[0], 10);
                Year = parseInt(DateValues[2], 10);
            }
            if (/^[JjFfMmAaSsOoNnDd][AaEePpUuCcOo][NnBbRrYyLlGgPpTtVvCc]/.test(InString))
            {
                //test for Month day, year with or without the comman and 2 or 4 digit year.
                WrkString = InString.replace(/,/, "")
                if (/[A-Za-z]+ [0-3]?[0-9] [0-9]{2,4}/.test(WrkString))
                {
                    DateValues = WrkString.split(" ");
                    Month = "|JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|".indexOf("|" + DateValues[0].substring(0, 3).toUpperCase() + "|");
                    Month = Math.floor(Month / 4) + 1;
                    Day = parseInt(DateValues[1], 10);
                    Year = parseInt(DateValues[2], 10);
                }
            }
            if (Year < 100)
            {
                var Today:Date = new Date();
                Year += Math.floor(Today.getFullYear() / 100) * 100;
                if (Year > (Today.getFullYear() + 5))
                    Year -= 100;
            }
            var GregDate:Object = new Object();
            GregDate.length = 3;
            GregDate["Year"] = Year;
            GregDate["Month"] = Month;
            GregDate["Day"] = Day;
            return GregDate;
        }

        private function CvTimeIn(InData:String):Number
        {
            var MinuteSeq:Number = parseInt("0", 10);
            var WrkData:String = InData.replace(/^[ \t]+/g, "") + "";
            if (/^[0-9]{4}/.test(WrkData))
                WrkData = WrkData.substring(0, 2) + ":" + WrkData.substring(2, WrkData.length);
            if (/^[0-9]{3}/.test(WrkData))
                WrkData = "0" + WrkData.substring(0, 1) + ":" + WrkData.substring(1, WrkData.length);
            if (/^[0-9]:/.test(WrkData))
                WrkData = "0" + WrkData;
//			if (! (/(0[1-9]|1[0-2]):[0-5][0-9]\s+([ap]m|[AP]M)/.test(WrkData)) ) 
            if (!(/^([01][0-9]|2[0-3]):[0-5][0-9][aApP]?[mM]?$/.test(WrkData)))
            {
                return -1;
            }
            var Hour:Number = parseInt(WrkData.substring(0, 2), 10);
            var Minute:Number = parseInt(WrkData.substring(3, 5), 10);
            var AmPm:String = WrkData.substring(5, 7).toUpperCase();
            if (WrkData.length == 7 && ((Hour > 12 && AmPm == "AM") || (Hour < 1 && AmPm == "PM")))
            {
                return -1;
            }
            if (Hour > 11 && AmPm == "AM")
                Hour = parseInt("0", 10);
            MinuteSeq = Minute + (Hour * 60);
            if (Hour < 12 && AmPm == "PM")
                MinuteSeq += 720;
            return MinuteSeq;
        }

        private function CvTimeOut(InSeq:Number, Format:String):String
        {
            var Minute:Number = (InSeq % 60);
            var Hour:Number = Math.floor(InSeq / 60);
            var AmPm:String = "";
            if (Format.toLowerCase() == "am/pm")
            {
                if (Hour > 11)
                {
                    AmPm = "PM";
                    if (Hour > 12)
                        Hour -= 12
                }
                else
                {
                    AmPm = "AM";
                    if (Hour < 1)
                        Hour = 12;
                }
            }
            return PadStr(Hour.toString(), "0", 2, "Left") + ":" + PadStr(Minute.toString(), "0", 2, "Left") + AmPm;
        }

        private function SysTime(Format:String):String
        {
            if (Format == null)
                Format = "am/pm";
            var Time:Date = new Date();
            return CvTimeOut(CvTimeIn(PadStr(String(Time.getHours().toString()), "0", 2, "LEFT") + PadStr(String(Time.getMinutes().toString()), "0", 2, "LEFT")), Format);
        }

        /**
         * Get the value used for min/max compares. It is either a literal, or if the
         * first six characters of the value contains "field" it will get the value of a
         * sibling field with the name specified after the :
         */
        private function getMinMaxValues(strValIn:String):String
        {
            var args:Array = strValIn.split(":");
            if (args[0].toUpperCase() != "FIELD")
            {
                return strValIn;
            }
            else
            {
                if (_rootOwner == null)
                    _rootOwner = parent;
                if (_rootOwner is ValidatedDateField)
                    _rootOwner = parent.parent;
                var objTemp:Object = _rootOwner.getChildByName(args[1].toString());
                if (objTemp)
                {
                    if (objTemp["value"])
                    {
                        return objTemp["value"].toString();
                    }
                    else
                    {
                        return objTemp["text"].toString();
                    }
                }
                else
                {
                    return "";
                }
            }
        }

        /**
         * Validate Credit Card
         *
         * Returns Appropriate mask for credit card type, or error
         *
         */
        private function getValidCreditCard(ccnum:String):String
        {
            var strCardType:String = "";
            switch (true)
            {
                case RegExp(/^4\d{3}-?\d{4}-?\d{4}-?\d{4}$/).test(ccnum): // Visa: length 16, prefix 4, dashes optional.
                    strCardType = "vi";
                    break;
                case RegExp(/^5[1-5]\d{2}-?\d{4}-?\d{4}-?\d{4}$/).test(ccnum): // Mastercard: length 16, prefix 51-55, dashes optional.
                    strCardType = "mc";
                    break;
                case RegExp(/^6011-?\d{4}-?\d{4}-?\d{4}$/).test(ccnum): // Discover: length 16, prefix 6011, dashes optional.
                    strCardType = "ds";
                    break;
                case RegExp(/^3[4,7]\d{13}$/).test(ccnum): // American Express: length 15, prefix 34 or 37.
                    strCardType = "ax";
                    break;
                case RegExp(/^3[0,6,8]\d{12}$/).test(ccnum): // Diners: length 14, prefix 30, 36, or 38.
                    strCardType = "dc";
                    break;
                default:
                    return "Bad Format"
            }
            var aryTemp:Array = ccnum.split("-");
            ccnum = aryTemp.join("");
            // Checksum ("Mod 10")
            // Add even digits in even length strings or odd digits in odd length strings.
            var checksum:int = 0;
            var i:int = 0;
            for (i = (2 - (ccnum.length % 2)); i <= ccnum.length; i += 2)
            {
                checksum += parseInt(ccnum.charAt(i - 1), 10);
            }
            // Analyze odd digits in even length strings or even digits in odd length strings.
            var intTemp:int = ((ccnum.length % 2) + 1);
            for (i = intTemp; i < ccnum.length; i += 2)
            {
                var digit:int = parseInt(ccnum.charAt(i - 1), 10) * 2;
                if (digit < 10)
                {
                    checksum += digit;
                }
                else
                {
                    checksum += (digit - 9);
                }
            }
            if ((checksum % 10) == 0)
            {
                return strCardType;
            }
            else
            {
                return "Bad CheckSum";
            }
        }

        private function CheckNbrValue(nbrValue:Number, strRangeValue:String):Boolean
        {
            var aryValues:Array = strRangeValue.split(",");
            var bolCheck:Boolean = false;
            var nbrLowValue:Number;
            var nbrHighValue:Number;
            if (isNaN(nbrValue))
            {
                if (_rangeValue.substr(0, 1) == "," || _rangeValue.indexOf(",,") == -1 || _rangeValue.substr(_rangeValue.length - 1) == ",")
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            for (var i:int = 0; i < aryValues.length; i++)
            {
                var strValue:String = aryValues[i];
                if (strValue.substr(0, 1) == "-")
                {
                    nbrLowValue = parseFloat(strValue);
                    nbrHighValue = nbrLowValue;
                }
                else
                {
                    var aryValueRange:Array = strValue.split("-");
                    nbrLowValue = parseFloat(aryValueRange[0]);
                    if (aryValueRange.length == 1)
                    {
                        nbrHighValue = nbrLowValue;
                    }
                    else
                    {
                        nbrHighValue = parseFloat(aryValueRange[1]);
                    }
                }
                bolCheck = (nbrValue >= nbrLowValue && nbrValue <= nbrHighValue);
                if (bolCheck)
                    break;
            }
            return bolCheck;
        }

        private function CheckStrValue(strTest:String, strRangeValue:String):Boolean
        {
            var aryValues:Array = strRangeValue.split(",");
            var bolCheck:Boolean = false;
            var strLowValue:String;
            var strHighValue:String;
            for (var i:int = 0; i < aryValues.length; i++)
            {
                var strValue:String = aryValues[i];
                var aryValueRange:Array = strValue.split("-");
                strLowValue = aryValueRange[0];
                if (aryValueRange.length == 1)
                {
                    strHighValue = strLowValue;
                }
                else
                {
                    strHighValue = aryValueRange[1];
                }
                bolCheck = (strTest >= strLowValue && strTest <= strHighValue);
                if (bolCheck)
                    break;
            }
            return bolCheck;
        }

        /**
         * Internal Formatters
         *
         */
        private var _usdFormat:CurrencyFormatter;

        private var _nbrFormat:NumberFormatter;

        private var _dateFormat:DateFormatter;

        private var _dateRevFormat:PhoneFormatter;

        private var _phoneFormat:PhoneFormatter;

        private var _ssnFormat:PhoneFormatter;

        private var _ccFormat:PhoneFormatter;

        /**
         * Initialize all internal formatters.
         *
         * Use the property formatString if provided and applicable for the type of formatter.
         */
        private function initFormatters():void
        {
//        	trace('_ssnFormat.formatString=' + _ssnFormat.formatString);
            if (_usdFormat == null)
            {
                _usdFormat = new mx.formatters.CurrencyFormatter();
                _usdFormat.precision = 2;
                _usdFormat.currencySymbol = "$";
                _usdFormat.decimalSeparatorFrom = ".";
                _usdFormat.decimalSeparatorTo = ".";
                _usdFormat.useNegativeSign = _sign;
                _usdFormat.useThousandsSeparator = true;
                _usdFormat.alignSymbol = "left";
            }
            if (_nbrFormat == null)
            {
                _nbrFormat = new mx.formatters.NumberFormatter();
                _nbrFormat.precision = 0;
                _nbrFormat.useNegativeSign = true;
                _nbrFormat.useThousandsSeparator = true;
            }
            if (_dateFormat == null)
            {
                _dateFormat = new mx.formatters.DateFormatter();
                if (_formatString.length > 0)
                {
                    _dateFormat.formatString = _formatString;
                }
                else
                {
                    _dateFormat.formatString = "MM/DD/YYYY";
                }
            }
            if (_dateRevFormat == null)
            {
                _dateRevFormat = new mx.formatters.PhoneFormatter();
                if (_formatString.length > 0)
                {
                    _dateRevFormat.formatString = _formatString;
                }
                else
                {
                    _dateRevFormat.formatString = "####-##-##";
                }
            }
            if (_phoneFormat == null)
            {
                _phoneFormat = new mx.formatters.PhoneFormatter();
                if (_formatString.length > 0)
                {
                    _phoneFormat.formatString = _formatString;
                }
                else
                {
                    _phoneFormat.formatString = "(###) ###-####";
                }
            }
            if (_ssnFormat == null)
            {
                _ssnFormat = new mx.formatters.PhoneFormatter();
                if (_formatString.length > 0)
                {
                    _ssnFormat.formatString = _formatString;
                }
                else
                {
                    _ssnFormat.formatString = "###-##-####";
                }
            }
            if (_ccFormat == null)
            {
                _ccFormat = new mx.formatters.PhoneFormatter();
                if (_formatString.length > 0)
                {
                    _ccFormat.formatString = _formatString;
                }
                else
                {
                    _ccFormat.formatString = "####-####-####-####";
                }
            }
        }
    }
}