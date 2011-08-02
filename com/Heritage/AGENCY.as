package com.Heritage
{

    [RemoteClass(alias="com.Heritage.AGENCY")]
    [Bindable]
    public class AGENCY
    {
        public var AGENCY_ID:Number = 0;

        public var AGENCY_COMPANY:String = "";

        public var AGENCY_ADDRESS1:String = "";

        public var AGENCY_ADDRESS2:String = "";

        public var AGENCY_CITY:String = "";

        public var AGENCY_STATE:String = "";

        public var AGENCY_ZIP:String = "";

        public var AGENCY_PHONE:String = "";

        public var AGENCY_EXT:Number = 0;

        public var AGENCY_FAX:String = "";

        public var AGENCY_CONTACT:String = "";

        public var AGENCY_EMAIL:String = "";

        public var AGENCY_WEBADDRESS:String = "";

        public var AGENCY_SHORT_NAME:String = "";

        public function AGENCY()
        {
        }

        public function fill(obj:Object):void
        {
            AGENCY_ID = obj.AGENCY_ID;
            AGENCY_COMPANY = obj.AGENCY_COMPANY;
            AGENCY_ADDRESS1 = obj.AGENCY_ADDRESS1;
            AGENCY_ADDRESS2 = obj.AGENCY_ADDRESS2;
            AGENCY_CITY = obj.AGENCY_CITY;
            AGENCY_STATE = obj.AGENCY_STATE;
            AGENCY_ZIP = obj.AGENCY_ZIP;
            AGENCY_PHONE = obj.AGENCY_PHONE;
            AGENCY_EXT = obj.AGENCY_EXT;
            AGENCY_FAX = obj.AGENCY_FAX;
            AGENCY_CONTACT = obj.AGENCY_CONTACT;
            AGENCY_EMAIL = obj.AGENCY_EMAIL;
            AGENCY_WEBADDRESS = obj.AGENCY_WEBADDRESS;
            AGENCY_SHORT_NAME = obj.AGENCY_SHORT_NAME;
        }
    }
}