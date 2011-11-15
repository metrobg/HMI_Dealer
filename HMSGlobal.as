// ActionScript file
import Classes.ModuleHandlerClass;
import com.metrobg.Classes.NumberUtilities;
import flash.net.registerClassAlias;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.MenuEvent;
import mx.managers.CursorManager;
import mx.managers.HistoryManager;
import mx.managers.IBrowserManager;
import mx.managers.PopUpManager;
import mx.messaging.messages.RemotingMessage;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

private var bm:IBrowserManager;

private var _historyManager:HistoryManager;

[Bindable]
private var fName:String;

[Bindable]
private var lName:String;

[Bindable]
public var txtUSERID:String;

public var moduleHandlerClass:ModuleHandlerClass;

public var reportRunner:ReportRunner;

private var reportRunnerOpen:Boolean

[Bindable]
private var user:String

public var allowDealerModifications:Boolean = false;

public var ReportRunnerURL:String;

private var dp2:XMLList;

[Bindable]
public var flexID:String;

public var acRepMain:ArrayCollection;

public var acAgencyMain:ArrayCollection;

public var acGroupMain:ArrayCollection;

public var acModelsMain:ArrayCollection;

//[Bindable] public var security:Number = 0;
private function init():void
{
    Security.loadPolicyFile('http://www.heritagemfg.com/crossdomain.xml');
    flexID = mx.core.Application.application.parameters.xr4aq;
    webService.WhoAmI();
    moduleHandlerClass = new ModuleHandlerClass(this);
    reportRunnerOpen = false;
    ReportRunnerURL = "http://milo.metrobg.com/HMI/ReportRunner";
    registerClassAlias("flex.messaging.messages.RemotingMessage", RemotingMessage);
    loadData();
}

public function loadData():void
{
    loadAgencies();
    loadReps();
    webService.loadModels();
}

private function loadAgencies():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.AGENCYGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.getAllAgency();
}

private function loadReps():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.SALESREPGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.getAllReps();
}

public function makeRandom():Number
{
    var rn:Number;
    rn = NumberUtilities.getUnique();
    return rn;
}

public function menuItemSelected(event:MenuEvent):void
{
    var action:Number = Number(event.item.@value);
    switch (action)
    {
        case 10:
            var strNewModule:String = moduleHandlerClass.getNextModule();
            trace("module " + strNewModule);
            if (strNewModule != null)
            {
                trace("action: " + event.item.@action + " " + strNewModule);
                moduleHandlerClass.addModule(event.item.@action, this[strNewModule]);
            }
            break;
        case 51:
            openReportRunner(event.item.@label, event.item.@action, event.item.@option);
            break;
        default:
            Alert.show("Unknown menu selection", "Error");
    }
}

private function openReportRunner(name:String, template:String, option:String):void
{
    if (!reportRunnerOpen)
    {
        reportRunner = ReportRunner(PopUpManager.createPopUp(this, ReportRunner, false));
        reportRunner.showCloseButton = true;
        reportRunner.addEventListener(CloseEvent.CLOSE, closeHandler);
        reportRunnerOpen = true;
        reportRunner.reportName = name;
        reportRunner.reportTemplate = template;
        reportRunner.x = (this.width - reportRunner.width) / 2;
        reportRunner.y = 55;
    }
    else
    {
        reportRunner.allOff(); // turn off all options
        reportRunner.reportTemplate = template;
        reportRunner.reportName = name;
    }
    if (option.length == 1)
    {
        reportRunner.enableCanvas(option);
    }
    else
    {
        for (var i:int = 0; i < option.length; i++)
        {
            reportRunner.enableCanvas(option.substr(i, 1));
        }
    }
}

private function closeHandler(event:CloseEvent):void
{
    PopUpManager.removePopUp(reportRunner);
    reportRunnerOpen = false;
}

public function removeModule(strModule:String):void
{
    var mdlModule:ModuleLoader = this[strModule];
    moduleHandlerClass.closeModule(strModule);
}

private function displayMenu():void
{
    dp2 = XMLList(getMenu.lastResult);
    menubar.dataProvider = dp2;
}

private function WhoAmI_result(evt:ResultEvent):void
{
    txtUSERID = String(evt.result).split("|", 2)[1];
    this.user = String(evt.result).split("|", 2)[0];
    switch (user)
    {
        case "unknown":
            this.menubar.visible = false;
            break;
        case "root":
            menubar.visible = true;
            allowDealerModifications = true;
            security = 99;
            break;
        case "admin":
            menubar.visible = true;
            allowDealerModifications = true;
            security = 4;
            break;
        case "staff":
            this.menubar.visible = true;
            allowDealerModifications = true;
            security = 3
            break;
        case "repairs":
            this.menubar.visible = true;
            allowDealerModifications = true;
            security = 1
            break;
        case "accounting":
            this.menubar.visible = true;
            allowDealerModifications = true;
            security = 2
            break;
        default:
            menubar.visible = true;
            allowDealerModifications = false;
            security = 0;
            break;
    }
    getMenu.send();
}

private function WhoAmI_fault(evt:FaultEvent):void
{
    Alert.show("Unable to log you in\n Make sure you are logged into the ECart", evt.type);
}

private function loadModels_result(evt:ResultEvent):void
{
    acModelsMain = ArrayCollection(evt.result);
}

private function loadModels_fault(evt:FaultEvent):void
{
    Alert.show("Unable to load model codes", evt.type);
}

public function onServiceDataReady(event:ResultEvent):void
{
    var act:Object = event.token;
    switch (act.message.operation)
    {
        case "getAllAsQuery":
            acRepMain = act.result as ArrayCollection
            break;
        case "getAllReps":
            acRepMain = new ArrayCollection(act.result as Array);
            break;
        case "getRepByAgency":
            acRepMain = new ArrayCollection();
            acRepMain = act.result;
            break;
        case "getAllAgency":
            acAgencyMain = new ArrayCollection(act.result as Array);
            var agencyList:Array = new Array();
            for (var i:int = 0; i < acAgencyMain.length; i++)
            {
                agencyList.push(acAgencyMain[i].AGENCY_ID);
            }
            acAgencyMain.addItemAt({ AGENCY_ID: agencyList.toString(), AGENCY_SHORT_NAME: "All" }, 0);
            break;
        case "getAllGroups":
            acGroupMain = new ArrayCollection(act.result as Array);
            acGroupMain.refresh();
            break;
    }
}

private function onServiceFault(event:FaultEvent):void
{
    // Or clock-cursor will spin forever (:
    CursorManager.removeBusyCursor();
    var act:Object = event.token;
    // Do your own error processing with event.fault.faultstring, etc...
    Alert.show(event.fault.faultString, 'Error');
}