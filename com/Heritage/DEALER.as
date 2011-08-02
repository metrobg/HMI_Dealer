package com.Heritage
{

    [RemoteClass(alias="com.Heritage.DEALER")]
    [Bindable]
    public class DEALER
    {
        public var ADDRESS:String = "";

        public var ADMIN_USER:String = "";

        public var CFUUID:String = "";

        public var CITY:String = "";

        public var CONTACT:String = "";

        public var EDIT_DATE:Date = null;

        public var EMAIL:String = "";

        public var FFL_NUMBER:String = "";

        public var FFL_EXPIRY:Date = null;

        public var HMI_ID:String = "";

        public var ID:Number = 0;

        public var LOCATOR:Number = 0;

        public var LAST_UPDATE:Date = null;

        public var NAME:String = "";

        public var PHONE:String = "";

        public var SALESGROUP:Number = 0;

        public var SALESREP:Number = 0;

        public var SOURCE:String = "";

        public var STATE:String = "";

        public var URL:String = "";

        public var ZIP:String = "";

        public function DEALER()
        {
        }

        public function fill(obj:Object):void
        {
            obj.id != null ? ID = obj.id : ID = 9999;
            obj.name != null ? NAME = obj.name : NAME = "Unknown";
            obj.address != null ? ADDRESS = obj.address : ADDRESS = "Unknown";
            obj.city != null ? CITY = obj.city : CITY = "Unknown";
            obj.state != null ? STATE = obj.state : STATE = "0";
            obj.phone != null ? PHONE = obj.phone : PHONE = "0000000000";
            obj.zip != null ? ZIP = obj.xip : ZIP = "99999";
            obj.email != null ? EMAIL = obj.email : EMAIL = "Unknown@unknown.com";
            obj.url != null ? URL = obj.url : URL = "Unknown";
            obj.source != null ? SOURCE = obj.source : SOURCE = "Unknown";
            obj.contact != null ? CONTACT = obj.contact : CONTACT = "need info"
            obj.hmi_id != null ? HMI_ID = obj.hmi_id : HMI_ID = "0";
        }
    }
}