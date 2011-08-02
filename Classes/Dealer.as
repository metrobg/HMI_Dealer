package Classes
{

    [Bindable]
    public class Dealer
    {
        public function Dealer()
        {
        }

        private var _ID:Number;

        private var _NAME:String;

        private var _ADDRESS:String;

        private var _CITY:String;

        private var _STATE:String;

        private var _PHONE:String;

        private var _ZIP:String;

        private var _EMAIL:String;

        private var _URL:String;

        private var _SOURCE:String;

        private var _HMI_ID:Number;

        private var _CONTACT:String;

        public function get id():Number
        {
            return _ID;
        }

        public function set id(value:Number):void
        {
            _ID = value;
        }

        public function get name():String
        {
            return _NAME;
        }

        public function set name(value:String):void
        {
            _NAME = value;
        }

        public function get address():String
        {
            return _ADDRESS;
        }

        public function set address(value:String):void
        {
            _ADDRESS = value;
        }

        public function get city():String
        {
            return _CITY;
        }

        public function set city(value:String):void
        {
            _CITY = value;
        }

        public function get state():String
        {
            return _STATE;
        }

        public function set state(value:String):void
        {
            _STATE = value;
        }

        public function get phone():String
        {
            return _PHONE;
        }

        public function set phone(value:String):void
        {
            _PHONE = value;
        }

        public function get zip():String
        {
            return _ZIP;
        }

        public function set zip(value:String):void
        {
            _ZIP = value;
        }

        public function get email():String
        {
            return _EMAIL;
        }

        public function set email(value:String):void
        {
            _EMAIL = value;
        }

        public function get url():String
        {
            return _URL;
        }

        public function set url(value:String):void
        {
            _URL = value;
        }

        public function get source():String
        {
            return _SOURCE;
        }

        public function set source(value:String):void
        {
            _SOURCE = value;
        }

        public function get contact():String
        {
            return _CONTACT;
        }

        public function set contact(value:String):void
        {
            _CONTACT = value;
        }

        public function get hmi_id():Number
        {
            return _HMI_ID;
        }

        public function set hmi_id(value:Number):void
        {
            _HMI_ID = value;
        }

        public function fill(obj:Object):void
        {
            obj.id != null ? _ID = obj.id : _ID = 9999;
            obj.name != null ? _NAME = obj.name : _NAME = "Unknown";
            obj.address != null ? _ADDRESS = obj.address : _ADDRESS = "Unknown";
            obj.city != null ? _CITY = obj.city : _CITY = "Unknown";
            obj.state != null ? _STATE = obj.state : _STATE = "0";
            obj.phone != null ? _PHONE = obj.phone : _PHONE = "0000000000";
            obj.zip != null ? _ZIP = obj.zip : _ZIP = "99999";
            obj.email != null ? _EMAIL = obj.email : _EMAIL = "Unknown@unknown.com";
            obj.url != null ? _URL = obj.url : _URL = "Unknown";
            obj.source != null ? _SOURCE = obj.source : _SOURCE = "Unknown";
            obj.contact != null ? _CONTACT = obj.contact : _CONTACT = "need info"
            obj.hmi_id != null ? _HMI_ID = obj.hmi_id : _HMI_ID = 0;
        }
    }
}