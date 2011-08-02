package com.Heritage
{

    [RemoteClass(alias="com.Heritage.WARRANTY")]
    [Bindable]
    public class WARRANTY
    {
        public var ID:String = "";

        public var DEALER:String = "";

        public var BARREL:String = "";

        public var CALIBER:String = "";

        public var NAME:String = "";

        public var ADDRESS:String = "";

        public var CITY:String = "";

        public var STATE:String = "";

        public var ZIP:String = "";

        public var EMAIL:String = "";

        public var SERIALNO:String = "";

        public var PURCHASE_DATE:Date = null;

        public var TS:Date = null;

        public var MODEL:String = "";

        public var DADDRESS:String = "";

        public var DCITY:String = "";

        public var DSTATE:String = "";

        public var DZIP:String = "";

        public function WARRANTY()
        {
        }
    }
}