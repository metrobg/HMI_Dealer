/**
 * HMIServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:HMIService= new HMIService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addWhoAmIEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.WhoAmI();
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="com.heritagemfg.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:HMIService id="myService">
  *   <srv:WhoAmI_request_var>
  *		<srv:WhoAmI_request />
  *   </srv:WhoAmI_request_var>
  * </srv:HMIService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.WhoAmI_send()" />
  */
package com.heritagemfg
{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation WhoAmI completes with success
     * and returns some data
     * @eventType WhoAmIResultEvent
     */
    [Event(name="WhoAmI_result", type="com.heritagemfg.WhoAmIResultEvent")]
    
    /**
     * Dispatches when a call to the operation ListDealersByState completes with success
     * and returns some data
     * @eventType ListDealersByStateResultEvent
     */
    [Event(name="ListDealersByState_result", type="com.heritagemfg.ListDealersByStateResultEvent")]
    
    /**
     * Dispatches when a call to the operation ListDealersByName completes with success
     * and returns some data
     * @eventType ListDealersByNameResultEvent
     */
    [Event(name="ListDealersByName_result", type="com.heritagemfg.ListDealersByNameResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class HMIService extends EventDispatcher implements IHMIService
	{
    	private var _baseService:BaseHMIService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function HMIService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BaseHMIService(destination,rootURL);
        }
        
		//stub functions for the WhoAmI operation
          

        /**
         * @see IHMIService#WhoAmI()
         */
        public function whoAmI():AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.whoAmI();
            _internal_token.addEventListener("result",_WhoAmI_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IHMIService#WhoAmI_send()
		 */    
        public function whoAmI_send():AsyncToken
        {
        	return whoAmI();
        }
              
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _whoAmI_lastResult:String;
		[Bindable]
		/**
		 * @see IHMIService#WhoAmI_lastResult
		 */	  
		public function get whoAmI_lastResult():String
		{
			return _whoAmI_lastResult;
		}
		/**
		 * @private
		 */
		public function set whoAmI_lastResult(lastResult:String):void
		{
			_whoAmI_lastResult = lastResult;
		}
		
		/**
		 * @see IHMIService#addWhoAmI()
		 */
		public function addwhoAmIEventListener(listener:Function):void
		{
			addEventListener(WhoAmIResultEvent.WhoAmI_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _WhoAmI_populate_results(event:ResultEvent):void
		{
			var e:WhoAmIResultEvent = new WhoAmIResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             whoAmI_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the ListDealersByState operation
          

        /**
         * @see IHMIService#ListDealersByState()
         */
        public function listDealersByState(state:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.listDealersByState(state);
            _internal_token.addEventListener("result",_ListDealersByState_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IHMIService#ListDealersByState_send()
		 */    
        public function listDealersByState_send():AsyncToken
        {
        	return listDealersByState(_ListDealersByState_request.state);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _ListDealersByState_request:ListDealersByState_request;
		/**
		 * @see IHMIService#ListDealersByState_request_var
		 */
		[Bindable]
		public function get listDealersByState_request_var():ListDealersByState_request
		{
			return _ListDealersByState_request;
		}
		
		/**
		 * @private
		 */
		public function set listDealersByState_request_var(request:ListDealersByState_request):void
		{
			_ListDealersByState_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _listDealersByState_lastResult:QueryBeanType;
		[Bindable]
		/**
		 * @see IHMIService#ListDealersByState_lastResult
		 */	  
		public function get listDealersByState_lastResult():QueryBeanType
		{
			return _listDealersByState_lastResult;
		}
		/**
		 * @private
		 */
		public function set listDealersByState_lastResult(lastResult:QueryBeanType):void
		{
			_listDealersByState_lastResult = lastResult;
		}
		
		/**
		 * @see IHMIService#addListDealersByState()
		 */
		public function addlistDealersByStateEventListener(listener:Function):void
		{
			addEventListener(ListDealersByStateResultEvent.ListDealersByState_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _ListDealersByState_populate_results(event:ResultEvent):void
		{
			var e:ListDealersByStateResultEvent = new ListDealersByStateResultEvent();
		            e.result = event.result as QueryBeanType;
		                       e.headers = event.headers;
		             listDealersByState_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the ListDealersByName operation
          

        /**
         * @see IHMIService#ListDealersByName()
         */
        public function listDealersByName(name:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.listDealersByName(name);
            _internal_token.addEventListener("result",_ListDealersByName_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IHMIService#ListDealersByName_send()
		 */    
        public function listDealersByName_send():AsyncToken
        {
        	return listDealersByName(_ListDealersByName_request.name);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _ListDealersByName_request:ListDealersByName_request;
		/**
		 * @see IHMIService#ListDealersByName_request_var
		 */
		[Bindable]
		public function get listDealersByName_request_var():ListDealersByName_request
		{
			return _ListDealersByName_request;
		}
		
		/**
		 * @private
		 */
		public function set listDealersByName_request_var(request:ListDealersByName_request):void
		{
			_ListDealersByName_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _listDealersByName_lastResult:QueryBeanType;
		[Bindable]
		/**
		 * @see IHMIService#ListDealersByName_lastResult
		 */	  
		public function get listDealersByName_lastResult():QueryBeanType
		{
			return _listDealersByName_lastResult;
		}
		/**
		 * @private
		 */
		public function set listDealersByName_lastResult(lastResult:QueryBeanType):void
		{
			_listDealersByName_lastResult = lastResult;
		}
		
		/**
		 * @see IHMIService#addListDealersByName()
		 */
		public function addlistDealersByNameEventListener(listener:Function):void
		{
			addEventListener(ListDealersByNameResultEvent.ListDealersByName_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _ListDealersByName_populate_results(event:ResultEvent):void
		{
			var e:ListDealersByNameResultEvent = new ListDealersByNameResultEvent();
		            e.result = event.result as QueryBeanType;
		                       e.headers = event.headers;
		             listDealersByName_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//service-wide functions
		/**
		 * @see IHMIService#getWebService()
		 */
		public function getWebService():BaseHMIService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addHMIServiceFaultEventListener(listener:Function):void
		{
			addEventListener("fault",listener);
		}
		
		/**
		 * Internal function to re-dispatch the fault event passed on by the base service implementation
		 * @private
		 */
		 
		 private function throwFault(event:FaultEvent):void
		 {
		 	dispatchEvent(event);
		 }
    }
}
