package com.Heritage
{

    [RemoteClass(alias="com.Heritage.SALESREP")]
    [Bindable]
    public class SALESREP
    {
        public var REP_ID:Number = 0;

        public var REP_FNAME:String = "";

        public var REP_LNAME:String = "";

        public var REP_ADDRESS1:String = "";

        public var REP_ADDRESS2:String = "";

        public var REP_CITY:String = "";

        public var REP_STATE:String = "";

        public var REP_ZIP:String = "";

        public var REP_PHONE:String = "";

        public var REP_FAX:String = "";

        public var REP_MOBILE:String = "";

        public var REP_EMAIL:String = "";

        public var REP_REGION:String = "";

        public var REP_SALESGROUP:Number = 0;

        public var REP_HMI_ID:Number = 0;

        public var REP_PHONE_EXT:Number = 0;

        public function SALESREP()
        {
        }

        public function fill(obj:Object):void
        {
            REP_ID = obj.REP_ID;
            REP_FNAME = obj.REP_FNAME;
            REP_LNAME = obj.REP_LNAME;
            REP_ADDRESS1 = obj.REP_ADDRESS1;
            REP_ADDRESS2 = obj.REP_ADDRESS2;
            REP_CITY = obj.REP_CITY;
            REP_STATE = obj.REP_STATE;
            REP_ZIP = obj.REP_ZIP;
            REP_PHONE = obj.REP_PHONE;
            REP_FAX = obj.REP_FAX;
            REP_MOBILE = obj.REP_MOBILE;
            REP_EMAIL = obj.REP_EMAIL;
            REP_REGION = obj.REP_REGION;
            REP_SALESGROUP = obj.REP_SALESGROUP;
            REP_HMI_ID = obj.REP_HMI_ID;
            REP_PHONE_EXT = obj.REP_PHONE_EXT;
        }
    }
}