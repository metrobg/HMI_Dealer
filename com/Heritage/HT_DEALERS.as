package com.Heritage
{

    [RemoteClass(alias="com.Heritage.HT_DEALERS")]
    [Bindable]
    public class HT_DEALERS
    {
        public var ID:Number = 0;

        public var NAME:String = "";

        public var ADDRESS:String = "";

        public var CITY:String = "";

        public var STATE:String = "";

        public var PHONE:String = "";

        public var ADMIN_USER:String = "";

        public var EDIT_DATE:Date = null;

        public var ZIP:String = "";

        public var EMAIL:String = "";

        public var URL:String = "";

        public var SOURCE:String = "";

        public var CONTACT:String = "";

        public var CFUUID:String = "";

        public var LAST_UPDATE:Date = null;

        public var HMI_ID:Number = 0;

        public function HT_DEALERS()
        {
        }
    }
}