package com.Heritage
{

    [RemoteClass(alias="com.Heritage.PURCHASE_GROUP")]
    [Bindable]
    public class PURCHASE_GROUP
    {
        public var GROUP_ID:Number = 0;

        public var GROUP_COMPANY:String = "";

        public var GROUP_ADDRESS1:String = "";

        public var GROUP_ADDRESS2:String = "";

        public var GROUP_CITY:String = "";

        public var GROUP_STATE:String = "";

        public var GROUP_ZIP:String = "";

        public var GROUP_PHONE:String = "";

        public var GROUP_EXT:Number = 0;

        public var GROUP_FAX:String = "";

        public var GROUP_CONTACT:String = "";

        public var GROUP_EMAIL:String = "";

        public var GROUP_WEBADDRESS:String = "";

        public function PURCHASE_GROUP()
        {
        }

        public function fill(obj:Object):void
        {
            GROUP_ID = obj.GROUP_ID;
            GROUP_COMPANY = obj.GROUP_COMPANY;
            GROUP_ADDRESS1 = obj.GROUP_ADDRESS1;
            GROUP_ADDRESS2 = obj.GROUP_ADDRESS2;
            GROUP_CITY = obj.GROUP_CITY;
            GROUP_STATE = obj.GROUP_STATE;
            GROUP_ZIP = obj.GROUP_ZIP;
            GROUP_PHONE = obj.GROUP_PHONE;
            GROUP_EXT = obj.GROUP_EXT;
            GROUP_FAX = obj.GROUP_FAX;
            GROUP_CONTACT = obj.GROUP_CONTACT;
            GROUP_EMAIL = obj.GROUP_EMAIL;
            GROUP_WEBADDRESS = obj.GROUP_WEBADDRESS;
        }
    }
}