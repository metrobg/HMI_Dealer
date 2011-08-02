package Classes
{
	import mx.core.Application;
	import mx.controls.Alert;
	import mx.modules.ModuleLoader;
	import mx.events.ModuleEvent;
	
public class ModuleHandlerClass {
	
 private var _application:Application;
 public var openModules:Number = 0;
 	 
public function ModuleHandlerClass(currentApp:Application) {	
	this._application = currentApp;
}
		
public function addModule(strModuleFile:String,mdlModule:ModuleLoader):String {
		var strModuleURL:String =  strModuleFile
		mdlModule.url = strModuleURL;
		_application["progress"].visible = true;
		//setChildIndex(progress, this.numChildren - 1);
	    _application["progress"].source = mdlModule;
		mdlModule.loadModule();	
		var strModuleName:String = mdlModule.name.substr(mdlModule.name.indexOf(".")+1);
		trace("adding module: " + strModuleName);
		return strModuleName;
}		
	 
public function closeModule(strModule:String):void {
			var mdlModule:ModuleLoader = _application[strModule];
			mdlModule.unloadModule();
			mdlModule.url = null;
	   		openModules--;
	   		trace("closing module: " + strModule);
} 

public function errorHandler(strModule:String,e:ModuleEvent):void {
	Alert.show("There was an error loading the module." + 
	    	   " Please contact the Help Desk.");
	closeModule(strModule);
	_application["progress"].visible = false;
	_application["progress"].source = null;
	_application["progress"].setProgress(0,0);
	
}
		
public function getNextModule():String {
	trace("looking for next module");
	var strNewModule:String = null;
		for (var i:int=0;i<10;i++) {
		  if (_application["module"+i.toString()].url == null) {
			strNewModule = "module"+i.toString()
			break
		 }
	}
	if (strNewModule == null) {
		Alert.show("Too many modules are open, please close some and try again.");
	}
	    return strNewModule;

}

private function ModuleFocus(strModule:String):void {
	var mdlModule:ModuleLoader = this[strModule.substr(strModule.indexOf(".")+1)];
	mdlModule.visible;
	
}

public function moduleLoadDone(mdlModule:ModuleLoader):void {
	_application["progress"].visible = false;
	_application["progress"].source = null;
	_application["progress"].setProgress(0,0);
	openModules++;
	trace("module loaded");
}
	
	}
}