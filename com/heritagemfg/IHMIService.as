
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.heritagemfg{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IHMIService
    {
    	//Stub functions for the WhoAmI operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @return An AsyncToken
    	 */
    	function whoAmI():AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function whoAmI_send():AsyncToken;
        
        /**
         * The whoAmI operation lastResult property
         */
        function get whoAmI_lastResult():String;
		/**
		 * @private
		 */
        function set whoAmI_lastResult(lastResult:String):void;
       /**
        * Add a listener for the whoAmI operation successful result event
        * @param The listener function
        */
       function addwhoAmIEventListener(listener:Function):void;
       
       
    	//Stub functions for the ListDealersByState operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param state
    	 * @return An AsyncToken
    	 */
    	function listDealersByState(state:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function listDealersByState_send():AsyncToken;
        
        /**
         * The listDealersByState operation lastResult property
         */
        function get listDealersByState_lastResult():QueryBeanType;
		/**
		 * @private
		 */
        function set listDealersByState_lastResult(lastResult:QueryBeanType):void;
       /**
        * Add a listener for the listDealersByState operation successful result event
        * @param The listener function
        */
       function addlistDealersByStateEventListener(listener:Function):void;
       
       
        /**
         * The listDealersByState operation request wrapper
         */
        function get listDealersByState_request_var():ListDealersByState_request;
        
        /**
         * @private
         */
        function set listDealersByState_request_var(request:ListDealersByState_request):void;
                   
    	//Stub functions for the ListDealersByName operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param name
    	 * @return An AsyncToken
    	 */
    	function listDealersByName(name:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function listDealersByName_send():AsyncToken;
        
        /**
         * The listDealersByName operation lastResult property
         */
        function get listDealersByName_lastResult():QueryBeanType;
		/**
		 * @private
		 */
        function set listDealersByName_lastResult(lastResult:QueryBeanType):void;
       /**
        * Add a listener for the listDealersByName operation successful result event
        * @param The listener function
        */
       function addlistDealersByNameEventListener(listener:Function):void;
       
       
        /**
         * The listDealersByName operation request wrapper
         */
        function get listDealersByName_request_var():ListDealersByName_request;
        
        /**
         * @private
         */
        function set listDealersByName_request_var(request:ListDealersByName_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseHMIService;
	}
}