import com.metrobg.Classes.*;
import com.metrobg.Icons.Images;
import flash.events.Event;
import flash.net.URLRequest;
import flash.net.URLVariables;
import mx.collections.*;
import mx.controls.Alert;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.CloseEvent;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.events.ValidationResultEvent;
import mx.managers.PopUpManager;
import mx.modules.*;
import mx.rpc.http.HTTPService;
import mx.utils.ObjectUtil;
import mx.validators.EmailValidator;
import mx.validators.PhoneNumberValidator;
import mx.validators.StringValidator;
import mx.validators.ZipCodeValidator;

/*   Version Tracking

   started 10/9/2007

   1.2.6		10/09/2007	Added ability to print work orders after estimate entry.
   work orders print standard estimate header but no repair code
   grid. Instead prints testing data and QC information.
   1.2.7		10/12/2007	Added default repair item to data grid upon estimate entry
   so that the operator does not need to add a repair code prior
   to estimate completion.
   1.2.8		10/30/2007 addid tracking field to application. also refactored code in resultHandler
   case 4. created two new functions in the menuController to enable/disable CCProcessing based
   on the pay status

   1.2.9		10/31/2007 made the find button the default button for the application.
   Added the option to print the workorder / order from the alert box that's displayed
   after the successful save of the record that's initiated via the save WorkOrder menu item
   Made the customer radio button the default search type selection when the new Estimate menu
   item is selected.

   1.3.0		11/14/2007 restricted search field input to four (4) characters when
   looking up a customer record. This is an attempt to eliminate the duplicate
   client records.

   1.3.1		01/29/2008	added a module to handle the ACD of the models table.
   Also put all code related to model info into the modelComboBox component.
   Corrected code in the Code Maint form, misplaced break statements not properly ending
   the switch / case logic.
   1.3.2		01/31/2008 Added ability to capture credit cards in orders table to aid
   in problem resolution and rebilling if needed
   1.3.3		04/18/2008	minor bug fix related to recalculation of sales tax on recalled orders
   1.3.4		6/10/2008	updated the ccProcessing window to default address and zip
   to the client address and zip. also corrected a problem with the UpdatePayStatus
   service call. also changed method to post
   1.3.5		update shipping costs
   1.3.6		07/03/2008	increased the max char value for the serial number field per client.
   1.3.7		09/10/2008 removed the ability to process misc transactions. Only finalized work orders
   can be processed.
   1.3.8		6/5/2009 corrected issues with the removal or line items from the detail grid, the active
   record was being defined as selectedIndex -1 causing the record prior to the selected one to be removed.
   Fixed issues with the cc processing window. the address information was not being displayed
   in the text boxes.
   1.3.9		7/2/2009	Added ability to upload photos. Added upload icon and view photo icons.
   added new popupWindow UploadWindow as well as an audio file to sound after upload.
   1.4.0		7/4/2009 added image viewer window to the application

   1.5			8/30/2009 added a new serialNumberWindow component to application. this component will prompt
   for the replacement serial number when the user addes the code MISC 400.
   also remove the alternate serial number when the code is removed from the detail grid.
   1.6			5/31/2010	Added the ability to track the person who created the workorder and the person
   who last edited it.

   1.7.2		07/07/2010 extended area where approval code and card # are displayed

   1.7.5		7/10/11 modified print order function to call new PDF formatted invoice.


 */
[Bindable]
public var version:String = "1.7.5";

public var totalRecords:String;

[Bindable]
private var subTotal:Number = 0;

[Bindable]
private var random:Number = 0;

[Bindable]
public var ID:Number = 0;

[Bindable]
public var paid:Number = 0;

[Bindable]
private var taxTotal:Number = 0;

private var freightTotal:Number = 0;

[Bindable]
private var repairTotal:Number = 0;

private var myCursor:IViewCursor;

private var taxRate:Number = .075;

[Bindable]
public var searchType:String;

[Bindable]
public var xmlData:String;

public var clientObj:Client = new Client();

private var searchResult:String;

[Bindable]
public var itemAC:ArrayCollection = new ArrayCollection;

[Bindable]
public var codeListAC:ArrayCollection = new ArrayCollection;

[Bindable]
public var customerAC:ArrayCollection = new ArrayCollection;

public var currentCode:RepairCode;

[Bindable]
public var shipDateValid:Boolean = false;

private var receivedDateValid:Boolean = false;

[Bindable]
public var docType:String = "Estimate";

[Bindable]
private var searchArray:Array = new Array('Search History');

[Bindable]
private var searchAC:ArrayCollection = new ArrayCollection();

private var clientSelected:Boolean = false;

// tracks the status of the detail grid window
public var windowOpen:Boolean = false;

public var customerWindowOpen:Boolean = false;

public var password:String = 'blowfish';

public var vmode:String = 'Normal';

public var vResult:ValidationResultEvent;

private var orderSaved:Boolean = false;

private var strImageList:String;

private var allCodesWindow:AllCodesWindow;

private var customerWindow:CustomerWindow;

private var passwordWindow:PasswordWindow;

private var dateOutWindow:DateOutWindow;

private var ccProcessingWindow:CCProcessingWindow;

private var fileUploadWindow:UploadWindow;

private var v:ZipCodeValidator = new ZipCodeValidator();

private var e:EmailValidator = new EmailValidator();

private var s:StringValidator = new StringValidator();

private var p:PhoneNumberValidator = new PhoneNumberValidator;

public var imageWindow:ImageViewer;

public function makeRandom(service:mx.rpc.http.HTTPService):void
{
    random = NumberUtilities.getUnique();
    service.send();
}

private function setDate():void
{
    var sysdate:Date = new Date;
    dateIN_df.selectedDate = sysdate;
    shipdate_df.selectedDate = sysdate;
    shipdate_df.enabled = false;
    shipDateValid = true;
    receivedDateValid = true;
}

private function chkDate(eventObj:CalendarLayoutChangeEvent):void
{
// Make sure selectedDate is not null.
    if (eventObj.currentTarget.selectedDate == null)
    {
        shipDateValid = false;
    }
    else
    {
        shipDateValid = true;
    }
}

private function chkReceivedDate(eventObj:CalendarLayoutChangeEvent):void
{
// Make sure selectedDate is not null.
    if (eventObj.currentTarget.selectedDate == null)
    {
        receivedDateValid = false;
    }
    else
    {
        receivedDateValid = true;
    }
    if (docType == "Estimate")
    { // make the ship date the same as the date in for estimates
        shipdate_df.selectedDate = new Date(dateIN_df.text);
        shipdate_df.enabled = false;
    }
}

public function refreshTotals():void
{
    tax_fld.text = nf.format(taxTotal);
    shipping_fld.text = nf.format(shipping_fld.text);
    discount_fld.text = nf.format(discount_fld.text);
    repairTotal = Number(nf.format(repairTotal));
}

private function dataGridCurrencyFormat(item:Object, column:Object):String
{
    return cf.format(item[column.dataField]);
}

private function init():void
{
    makeRandom(getCodes);
    setDate();
    focusManager.setFocus(search_fld);
    shipping_fld.text = "0.00";
    tax_fld.text = "0.00";
    discount_fld.text = "0.00";
    searchAC.source = searchArray;
    searchHistory_cbx.dataProvider = searchAC;
    this.moveToFront();
    //photo_ico.enabled = false;
    //upload_ico.enabled = false;
    this.superpanel1.title += " ver: " + version;
    this.x = (parentApplication.width - this.width) / 2
}

private function addShipping():void
{
    if (shipvia_cbx.selectedLabel == "FedEx")
    {
        shipping_fld.text = '30.00';
    }
    if (shipvia_cbx.selectedLabel == "Priority Mail")
    {
        shipping_fld.text = '10.00';
    }
    calculateTotal();
}

private function updateSearchField():void
{
    if (searchHistory_cbx.selectedLabel != "Search History")
    {
        search_fld.text = searchHistory_cbx.selectedLabel
        searchHistory_cbx.selectedIndex = 0;
    }
}

private function menuItemSelected(event:MenuEvent):void
{
    var action:String = event.item.@label;
    if (action == "New Customer")
    {
        mnewCustomer();
        p1.status = 'Adding new Customer';
        disableAllFields();
        name_fld.text = '';
        address_fld.text = '';
        suite_fld.text = '';
        city_fld.text = '';
        state_cbx.selectedIndex = 0;
        zipcode_fld.text = '';
        phone_fld.text = '';
        currentState = 'AddClient';
            //	add_cnv.visible = true;
            // display_cnv.visible = false;
    }
    if (action == "New Estimate")
    {
        docType = "Estimate";
        currentState = '';
        clearForm();
        enableAllFields()
        setDate();
        mnewEstimate();
        setDate(); // default date in to today
        p1.status = 'Adding new Estimate';
        ID = 0;
        itemAC.addItem({ id: "26665", code: "MISC 1.1", description: "ESTIMATE - ESTIMATE - ESTIMATE", price: "0.00" });
        searchGroup.selectedValue = "C";
        createdby.text = parentApplication.txtUSERID;
        lasteditby.text = parentApplication.txtUSERID;
    }
    if (action == "New Order")
    {
        docType = "Order";
        currentState = '';
        clearForm();
        enableAllFields()
        setDate();
        mnewOrder();
        setDate(); // default date in to today
        ID = 0;
        p1.status = 'Adding new Order';
        createdby.text = parentApplication.txtUSERID;
        lasteditby.text = parentApplication.txtUSERID;
    }
    if (action == "Save Order" || action == "Save Estimate")
    {
        if (saveOrderAsXml())
        {
            makeRandom(saveOrder);
            p1.status = 'Saving Record';
        }
    }
    if (action == "Delete Customer")
    {
        //currentState = '';	
        comments_ta.text += clientObj.getClientAsXml();
    }
    if (action == "Reopen Order")
    {
        showPasswordWindow();
    }
    if (action == "Update Estimate")
    {
        if (saveOrderAsXml())
        {
            makeRandom(updateEstimate);
            p1.status = 'Saving Estimate';
        }
        p1.title = "Repair Ticket -- " + docType + "  " + ID;
    }
    if (action == "Print Order" || action == "Print Estimate")
    {
        printOrder();
    }
    if (action == "Work Order")
    {
        navigateToURL(new URLRequest('http://www.heritagemfg.com/console/flex/queries/workOrder.cfm?orderid=' + ID));
    }
    if (action == "Convert to Order")
    {
        showDateOutWindow();
    }
    if (action == "Process Transaction")
    {
        showCCProcessingWindow();
    }
}

private function showNotePad():void
{
    if (ID == 0)
    {
        return;
    }
    if (!notes_sp.visible)
    {
        notes_sp.visible = true;
        makeRandom(getNotes);
    }
    else
    {
        notes_sp.visible = false;
    }
    return;
}

private function showUploadWindow():void
{
    if (ID == 0)
    {
        return;
    }
    else
    {
        openFileUploadWindow();
    }
}

private function saveNotes():void
{
    makeRandom(updateNotes);
}

private function saveClient():void
{
    if (!validateForm())
    {
        makeRandom(addClient);
        p1.status = 'Saving Record';
    }
    else
    {
        Alert.show("Required fields missing", "Attention", 0, this, null, Images.StopIcon, 0);
    }
}

public function calculateTotal():void
{
    // sum prices from the items in the grid
    var tmpSubTotal:Number = 0;
    myCursor = itemAC.createCursor();
    while (!myCursor.afterLast)
    {
        tmpSubTotal += Number(myCursor.current.price);
        myCursor.moveNext();
    }
    subTotal = tmpSubTotal;
    if (state_cbx.stateCode == "FL" || clientObj.state == "FL")
    {
        taxTotal = subTotal * taxRate;
    }
    else
    {
        taxTotal = 0;
    }
    repairTotal = (subTotal + taxTotal + Number(shipping_fld.text)) - Number(discount_fld.text);
    refreshTotals();
}

public function enableSave():void
{
    dp2.item[1].@enabled = true; // enable save function
}

private function disableAllFields():void
{
    complaint_ta.enabled = false;
    model_cbx.enabled = false;
    serialno_fld.enabled = false;
    shipvia_cbx.enabled = false;
    payment_cbx.enabled = false;
    detailGrid.doubleClickEnabled = false;
    shipping_fld.enabled = false;
    show_btn.enabled = false;
    order_rb.enabled = false;
    serialno_rb.enabled = false;
    repair_code_rb.enabled = false;
    dateIN_df.enabled = false;
    shipdate_df.enabled = false;
    dateIN_df.enabled = false;
    dp2.item[0].editItem[0].@enabled = false; // disable new customer menu select
}

private function clearForm():void
{
// reset panel title
    p1.title = 'Repair Ticket --';
// customer form
    name_fld.text = '';
    address_fld.text = '';
    suite_fld.text = '';
    city_fld.text = '';
    state_cbx.selectedIndex = 0;
    zipcode_fld.text = '';
    phone_fld.text = '';
    name_lbl.text = '';
    address_lbl.text = '';
    suite_lbl.text = '';
    city_lbl.text = '';
    createdby.text = '';
    lasteditby.text = '';
    auth_message.text = '';
//      state_lbl.text = '';
    //zipcode_lbl.text = '';
    phone_lbl.text = '';
// header section'
    complaint_ta.text = '';
    model_cbx.selectedIndex = 0;
    payment_cbx.selectedIndex = 0;
    serialno_fld.text = '';
    altserialno_fld.text = '';
    shipvia_cbx.selectedIndex = 0;
    tracking_fld.text = '';
    //shipdate_df.text = '';
    //dateIN_df.text = '';
// detail item grid
    itemAC.removeAll();
    itemAC.refresh();
    detailGrid.dataProvider = itemAC;
    comments_ta.text = '';
// totals section
    subtotal_fld.text = '0.00';
    tax_fld.text = '0.00';
    shipping_fld.text = '0.00';
    discount_fld.text = '0.00'
    total_fld.text = '0.00';
// buttons 	  
    show_btn.enabled = false;
    order_rb.enabled = true;
    serialno_rb.enabled = true;
    repair_code_rb.enabled = false;
}

public function enableAllFields():void
{
    show_btn.enabled = true;
    order_rb.enabled = true;
    serialno_rb.enabled = true;
    repair_code_rb.enabled = true;
    dateIN_df.enabled = true;
    payment_cbx.enabled = true;
    model_cbx.enabled = true;
    serialno_fld.enabled = true;
    shipvia_cbx.enabled = true;
    //shipdate_df.enabled =  true;
    complaint_ta.enabled = true;
    comments_ta.enabled = true;
    detailGrid.doubleClickEnabled = true;
    comments_ta.enabled = true;
    shipping_fld.enabled = true;
}

private function clearSearchField():void
{
    search_fld.text = "";
}

/* call the service that will return a list of all repair codes in file.

 */
private function findAllCodes():void
{
    makeRandom(getCodes);
}

private function restrictInput(event:ItemClickEvent):void
{
    if (event.currentTarget.selectedValue == 'O')
    { // order
        search_fld.restrict = "0-9";
        search_fld.maxChars = 20;
    }
    else if (event.currentTarget.selectedValue == 'S')
    { // serial number or name
        search_fld.restrict = "0-9A-Z ";
        search_fld.maxChars = 20;
    }
    else if (event.currentTarget.selectedValue == 'C')
    { // customer
        search_fld.restrict = "0-9A-Z .";
        search_fld.maxChars = 4;
    }
    else
    {
        search_fld.restrict = "A-Z0-9 &_- ."; // repair code
        search_fld.maxChars = 20;
    }
    return
}

/* determine if we are looking for a repair code or customer based on the

   value of the selected radio button

 */
private function findCustomerOrCode():void
{
    if (searchArray.lastIndexOf(search_fld.text) < 0)
    {
        searchArray[0] = search_fld.text; // add new entry
        searchArray.unshift('Search History'); // keep this as the first item	          
        if (searchArray.length > 11)
        {
            searchArray.pop(); // keep the last 10 search items
        }
    }
    searchAC.refresh();
    if (searchGroup.selectedValue == "R" && search_fld.text != '')
    {
        findCode(search_fld.text);
    }
    else
    {
        if (searchGroup.selectedValue == "S" && search_fld.text != '')
        {
            makeRandom(snLookup);
        }
        else
        {
            if (searchGroup.selectedValue == "C" && search_fld.text != '')
            {
                makeRandom(customerLookup);
            }
            else
            {
                if (searchGroup.selectedValue == "O" && search_fld.text != '')
                {
                    makeRandom(orderLookup);
                }
                else
                {
                    Alert.show('Please enter a search parameter before you proceed', "Attention", 0, this, null, Images.StopIcon, 0);
                }
            }
        }
    }
}

/* display a popUP window containing the name address ... of those customers matching

   the parameters entered in the search box

 */
private function showCustomerWindow():void
{
    if (!customerWindowOpen)
    {
        customerWindow = CustomerWindow(PopUpManager.createPopUp(this, CustomerWindow, false));
        customerWindow.ac = customerAC;
        customerWindow.selectedClient = clientObj;
        customerWindow.showCloseButton = true;
        customerWindowOpen = true;
        customerWindow.addEventListener("close", closeCustomerWindow);
        customerWindow.title = customerAC.length + " Matching Records found";
    }
    else
    {
        customerWindow.ac = customerAC;
    }
}

private function showPasswordWindow():void
{
    passwordWindow = PasswordWindow(PopUpManager.createPopUp(this, PasswordWindow, true));
    passwordWindow.showCloseButton = true;
    passwordWindow.addEventListener("close", closePasswordWindow);
    passwordWindow.title = "Enter Password to Reopen Order";
}

private function showCCProcessingWindow():void
{
    if (docType == "Estimate")
    {
        Alert.show("You Can't Process Estimates.\n Only finalized Orders", "Error", 4, this, null, Images.StopIcon);
        return;
    }
    else
    {
        ccProcessingWindow = CCProcessingWindow(PopUpManager.createPopUp(this, CCProcessingWindow, true));
        ccProcessingWindow.showCloseButton = true;
        ccProcessingWindow.client = this.clientObj;
        ccProcessingWindow.OrderID = this.ID;
        ccProcessingWindow.parentModule = this;
        ccProcessingWindow.addEventListener("close", closeCCProcessingWindowWindow);
    }
}

private function showDateOutWindow():void
{
    dateOutWindow = DateOutWindow(PopUpManager.createPopUp(this, DateOutWindow, true));
    dateOutWindow.showCloseButton = true;
    dateOutWindow.addEventListener("close", closeDateOutWindow);
    dateOutWindow.title = "Set ship date";
    dateOutWindow.parentModule = this;
    shipDateValid = false;
    dateOutWindow.validDate = shipDateValid;
}

/* display the full list of repair codes in a popUP window

 */
private function showWindow():void
{
    allCodesWindow = AllCodesWindow(PopUpManager.createPopUp(this, AllCodesWindow, false));
    allCodesWindow.ac = ArrayCollection(ObjectUtil.copy(codeListAC));
    allCodesWindow.showCloseButton = true;
    allCodesWindow.targetAC = itemAC;
    allCodesWindow.parentModule = this;
    allCodesWindow.addEventListener("close", closeCodeWindow);
}

private function validateFields():Boolean
{
    var formValid:Boolean = true;
    if (model_cbx.modelCode == null || serialno_fld.text == "")
    {
        formValid = false;
    }
    if (complaint_ta.text == '')
    {
        complaint_ta.text = "none";
    }
    if (itemAC.length == 0)
    {
        formValid = false;
    }
    if (payment_cbx.selectedIndex == 0 || shipvia_cbx.selectedIndex == 0)
    {
        formValid = false;
    }
    if (formValid && shipDateValid && receivedDateValid)
    {
        return true;
    }
    else
    {
        return false;
    }
}

/* close the password popUP window */
public function closePasswordWindow(event:CloseEvent):void
{
    if (password == passwordWindow.password)
    {
        reopenOrder.send();
        PopUpManager.removePopUp(passwordWindow);
    }
    else
    {
        Alert.show("Password did not match", "Failed");
    }
}

/* close the repair codes popUP wondow */
private function closeCodeWindow(event:CloseEvent):void
{
    toggleGrid();
    PopUpManager.removePopUp(allCodesWindow);
}

/* close the customer lookup popUP window */
private function closeCustomerWindow(event:CloseEvent):void
{
    populateClientFields(customerWindow.selectedClient)
    PopUpManager.removePopUp(customerWindow);
    customerWindowOpen = false;
}

private function closeCCProcessingWindowWindow(event:CloseEvent):void
{
    PopUpManager.removePopUp(ccProcessingWindow);
}

/* close the date out popUP window */
public function closeDateOutWindow(event:CloseEvent):void
{
    shipDateValid = dateOutWindow.validDate;
    shipdate_df.text = dateOutWindow.dateOut_df.text;
    PopUpManager.removePopUp(dateOutWindow);
    if (saveOrderAsXml() && shipDateValid)
    {
        p1.status = 'Converting Estimate';
        makeRandom(convertEstimate);
        p1.title = "Repair Ticket -- " + docType + "  " + ID;
    }
}

/* if the codes grid is visible , hide it, if it's hidden show it .

   also change the button lable so that it reflects the next toggle state

 */
public function toggleGrid():void
{
    if (!windowOpen)
    {
        showWindow();
        show_btn.label = "Hide Codes";
        windowOpen = true;
    }
    else
    {
        show_btn.label = "Show Codes";
        windowOpen = false;
        PopUpManager.removePopUp(allCodesWindow);
    }
}

/* remove an item from the detail arrayCollection.

   The item is removed when it's row is doubble clicked

 */
private function removeDetailItem(event:ListEvent):void
{
    var activeRecord:Number = event.rowIndex;
    if (detailGrid.selectedItem.code == "MISC 400")
        altserialno_fld.text = '';
    itemAC.removeItemAt(activeRecord);
    itemAC.refresh();
    calculateTotal();
}

public function validateForm():Boolean
{
    var err:Boolean = false;
    var field:TextInput;
    v.domain = "US or Canada";
    v.listener = zipcode_fld;
    vResult = v.validate(zipcode_fld.text);
    if (vResult.type == ValidationResultEvent.INVALID)
    {
        err = true;
    }
    s.listener = name_fld;
    vResult = s.validate(name_fld.text);
    if (vResult.type == ValidationResultEvent.INVALID)
    {
        err = true;
    }
    s.listener = address_fld;
    vResult = s.validate(address_fld.text);
    if (vResult.type == ValidationResultEvent.INVALID)
    {
        err = true;
    }
    s.listener = city_fld;
    vResult = s.validate(city_fld.text);
    if (vResult.type == ValidationResultEvent.INVALID)
    {
        err = true;
    }
    p.listener = phone_fld;
    vResult = p.validate(phone_fld.text);
    if (vResult.type == ValidationResultEvent.INVALID)
    {
        err = true;
    }
    return err;
}

// called when an item is doubbled clicked in the history grid
private function showOrder(event:ListEvent):void
{
    search_fld.text = historyGrid.selectedItem.id;
    search_fld.text = search_fld.text.toUpperCase();
    makeRandom(orderLookup);
}

private function makeClient(serviceName:Object):Client
{
    clientObj.id = serviceName.lastResult.customerlist.record.id;
    clientObj.name = serviceName.lastResult.customerlist.record.name;
    clientObj.address = serviceName.lastResult.customerlist.record.address;
    clientObj.suite = serviceName.lastResult.customerlist.record.suite;
    clientObj.city = serviceName.lastResult.customerlist.record.city;
    clientObj.state = serviceName.lastResult.customerlist.record.state;
    clientObj.zipcode = serviceName.lastResult.customerlist.record.zipcode;
    clientObj.phone = serviceName.lastResult.customerlist.record.phone;
    return clientObj;
}

private function prepareReprint(serviceName:Object):void
{
    docType = serviceName.lastResult.workorder.documenttype;
    repair_code_rb.enabled = true;
    ID = serviceName.lastResult.workorder.id;
    paid = Number(serviceName.lastResult.workorder.paid);
    p1.title = "Repair Ticket -- " + docType + "  " + ID;
    show_btn.enabled = true;
    // populate client object
    clientObj.id = serviceName.lastResult.workorder.client.id;
    clientObj.name = serviceName.lastResult.workorder.client.name;
    clientObj.address = serviceName.lastResult.workorder.client.address;
    clientObj.suite = serviceName.lastResult.workorder.client.suite;
    clientObj.city = serviceName.lastResult.workorder.client.city;
    clientObj.state = serviceName.lastResult.workorder.client.state;
    clientObj.zipcode = serviceName.lastResult.workorder.client.zipcode;
    clientObj.phone = serviceName.lastResult.workorder.client.phone;
    // populate form fields with client data
    populateClientFields(clientObj);
    complaint_ta.text = serviceName.lastResult.workorder.header.complaint;
    comments_ta.text = serviceName.lastResult.workorder.totals.notes;
    payment_cbx.selectedItem = serviceName.lastResult.workorder.header.payment;
    model_cbx.setModel = serviceName.lastResult.workorder.header.model;
    serialno_fld.text = serviceName.lastResult.workorder.header.serialno;
    altserialno_fld.text = serviceName.lastResult.workorder.header.altserialno;
    shipdate_df.text = serviceName.lastResult.workorder.header.shipdate;
    tracking_fld.text = serviceName.lastResult.workorder.header.tracking;
    dateIN_df.text = serviceName.lastResult.workorder.header.datein;
    shipvia_cbx.selectedItem = serviceName.lastResult.workorder.header.shipvia;
    tax_fld.text = serviceName.lastResult.workorder.totals.tax;
    shipping_fld.text = serviceName.lastResult.workorder.totals.shipping;
    discount_fld.text = serviceName.lastResult.workorder.totals.discount;
    repairTotal = 0;
    calculateTotal();
    p1.status = 'Recalled ' + docType;
    mReprint(docType); // enable / disable menu items per doc type
    if (docType == "Estimate")
    {
        // may need to update these fields when converting from estimate to order
        dateIN_df.enabled = true;
        //shipdate_df.enabled = false;   // the ship date field tracks the date in field for estimates
        serialno_fld.enabled = true; // allow serial number to be updates
        model_cbx.enabled = true; // allow model to be changed  	
        shipDateValid = true;
        receivedDateValid = true;
        payment_cbx.enabled = true;
        shipvia_cbx.enabled = true;
        comments_ta.enabled = true;
        complaint_ta.enabled = true;
        shipping_fld.enabled = true;
        // allow items to be removed from estimate
        detailGrid.doubleClickEnabled = true;
    }
}

private function getTotalsAsXml():String
{
    var retString:String = "<totals>";
    retString += " <subtotal>" + subtotal_fld.text + "</subtotal>";
    retString += " <tax>" + tax_fld.text + "</tax>";
    retString += " <shipping>" + shipping_fld.text + "</shipping>";
    retString += " <discount>" + discount_fld.text + "</discount>";
    retString += " <total>" + total_fld.text + "</total>";
    retString += " <notes>" + comments_ta.text + "</notes>";
    retString += "</totals>";
    return retString;
}

private function getGridAsXml():String
{
    var vxml:String = "<items>";
    myCursor = itemAC.createCursor();
    while (!myCursor.afterLast)
    {
        vxml += "<item>";
        vxml += "<code>" + myCursor.current.code + "</code>";
        vxml += "<description>" + myCursor.current.description + "</description>";
        vxml += "<price>" + myCursor.current.price + "</price>";
        vxml += "</item>";
        myCursor.moveNext();
    }
    vxml += "</items>";
    return vxml;
}

private function OprintClickHandler(event:CloseEvent):void
{
    if (event.detail == Alert.YES)
    {
        printOrder();
    }
}

private function WOprintClickHandler(event:CloseEvent):void
{
    if (event.detail == Alert.YES)
    {
        printWorkOrder();
    }
}

private function getHeaderAsXml():String
{
    var retString:String = '<header>';
    retString += "  <model>" + model_cbx.modelCode + "</model>";
    retString += "  <serialno>" + serialno_fld.text.toUpperCase() + "</serialno>";
    retString += "  <altserialno>" + altserialno_fld.text + "</altserialno>";
    retString += "  <complaint>" + complaint_ta.text + "</complaint>";
    retString += "  <shipvia>" + shipvia_cbx.selectedLabel + "</shipvia>";
    retString += "  <payment>" + payment_cbx.selectedLabel + "</payment>";
    retString += "  <shipdate>" + shipdate_df.text + "</shipdate>";
    retString += "  <datein>" + dateIN_df.text + "</datein>";
    retString += "  <createdby>" + parentApplication.txtUSERID + "</createdby>";
    retString += "  <lasteditby>" + parentApplication.txtUSERID + "</lasteditby>";
    retString += "</header>";
    return retString;
}

private function saveOrderAsXml():Boolean
{
    if (validateFields())
    {
        calculateTotal();
        var retString:String = '<?xml version="1.0"?>';
        retString += '<workorder>';
        retString += "<id>" + ID + "</id>";
        retString += "<documenttype>" + docType + "</documenttype>";
        retString += clientObj.getClientAsXml();
        retString += getGridAsXml();
        retString += getHeaderAsXml();
        retString += getTotalsAsXml()
        retString += '</workorder>';
        xmlData = retString;
        //saveOrder.send();
        return true;
    }
    else
    {
        Alert.show('Please check the following fields:\n' + 'Serial Number\n' + 'Model Number\n' + 'Ship Date\n' + 'You also need at least 1 repair code', "Unable to Save", 0, this, null, Images.WarningIcon, 0);
        return false;
    }
}

public function populateClientFields(client:Client):void
{
    clientSelected = true;
    name_lbl.text = client.name;
    address_lbl.text = client.address;
    suite_lbl.text = client.suite;
    city_lbl.text = client.city + "  " + client.state + "  " + client.zipcode;
    phone_lbl.text = pf.format(client.phone);
}

private function printOrder():void
{
    var retString:String = '<workorder>';
    retString += "<id>" + ID + "</id>";
    retString += "<documenttype>" + docType + "</documenttype>";
    retString += clientObj.getClientAsXml();
    retString += getGridAsXml();
    retString += getHeaderAsXml();
    retString += getTotalsAsXml()
    retString += '</workorder>';
    xmlData = retString;
    navigateToURL(new URLRequest('http://www.heritagemfg.com/console/flex/queries/receipt.cfm?orderid=' + ID));
}

private function printOrderNew():void
{
    var request:URLRequest = new URLRequest('http://milo.metrobg.com/HMI/ROInvoiceServlet');
    var formData:URLVariables = new URLVariables();
    formData.orderid = ID;
    request.data = formData;
    request.method = "POST";
    navigateToURL(request);
}

private function printWorkOrder():void
{
    navigateToURL(new URLRequest('http://www.heritagemfg.com/console/flex/queries/workOrder.cfm?orderid=' + ID));
}

private function displayAlert(message:String):void
{
    Alert.show(message, "Attention", 0, this, null, Images.WarningIcon, 0);
}

/* look up a repair code in the arrayCollection based on the value entered in the search box.

   if found the code is added to the detail grid, otherwise display an alert box

 */
private function findCode(code:String):void
{
    var found:Boolean = false;
    myCursor = codeListAC.createCursor();
    while (!myCursor.afterLast)
    {
        if (myCursor.current.code == code.toUpperCase())
        {
            itemAC.addItem(myCursor.current);
            found = true;
            detailGrid.dataProvider = itemAC;
            itemAC.refresh();
            calculateTotal();
            refreshTotals();
            break;
        }
        myCursor.moveNext();
    }
    if (!found)
    {
        makeRandom(singleCode); // look for the code in the db in case it was just added
            // since we last started		  	    
    }
}

private function moveToFront():void
{
    // move the shape to the front by moving it to the front-most
    // index (which is always numChildren - 1)
    if (this)
        if (this.owner)
            if (this.owner.name)
                if (parentApplication)
                    parentApplication.setChildIndex(parentApplication.getChildByName(this.owner.name), parentApplication.numChildren - 1);
}

private function getResultOk(r:Number, event:Event):void
{
    switch (r)
    {
        case 1:
            codeListAC = ArrayCollection(getCodes.lastResult.codeList.record);
            detailGrid.dataProvider = itemAC;
            break;
        case 2:
            orderSaved = false;
            var records:int = int(customerLookup.lastResult.customerlist.recordcount);
            if (records == 0)
            {
                Alert.show('No Matching Records found', "Attention", 0, this, null, Images.BadIcon, 0);
                break;
            }
            if (records == 1)
            {
                clientObj = makeClient(customerLookup);
                populateClientFields(clientObj); // only one record found so fill out the form
            }
            else
            {
                customerAC = ArrayCollection(customerLookup.lastResult.customerlist.record);
                showCustomerWindow(); // display grid of matching client records    
            }
            show_btn.enabled = true;
            repair_code_rb.enabled = true;
            enableAllFields();
            break;
        case 3:
            if (saveOrder.lastResult.root.status == "1")
            {
                ID = saveOrder.lastResult.root.orderid;
                p1.title = "Repair Ticket -- " + docType + "  " + ID;
                orderSaved = true;
                msaveOrder();
                if (docType == "Estimate")
                {
                    Alert.show(docType + ' ' + ID + ' Completed ' + "\nWould you like to print the Work Order ?", "Success", 3, this, WOprintClickHandler, Images.OKIcon);
                        //Alert.show(docType + ' ' + ID + ' Completed ',"Success",0,this,null,Images.okIcon,0);
                }
                else
                {
                }
            }
            else
            {
                Alert.show('Update Failed', "Error", 0, this, null, Images.BadIcon, 0);
            }
            break;
        case 4:
            var paid:Number = 0;
            /*  orderLookup
               http://www.heritagemfg.com/console/flex/queries/getOrder.cfm

             */
            if (orderLookup.lastResult.workorder.status == "1")
            {
                if (Number(orderLookup.lastResult.workorder.itemcount) == 0)
                {
                    Alert.show('No Matching Records found', "Attention", 0, this, null, Images.BadIcon, 0);
                    break;
                }
                paid = Number(orderLookup.lastResult.workorder.paid);
                if (paid == 0)
                {
                    enableCCProcessing()
                }
                else
                {
                    disableCCProcessing()
                }
                auth_message.text = orderLookup.lastResult.workorder.totals.message;
                createdby.text = orderLookup.lastResult.workorder.header.createdby;
                lasteditby.text = orderLookup.lastResult.workorder.header.lasteditby;
                if (Number(orderLookup.lastResult.workorder.itemcount) > 1)
                {
                    itemAC.removeAll();
                    // fill the detail grid with the repair codes
                    itemAC = ArrayCollection(orderLookup.lastResult.workorder.items.item);
                    detailGrid.dataProvider = itemAC;
                    itemAC.refresh();
                }
                else
                {
                    itemAC.removeAll();
                    itemAC.addItem({ code: orderLookup.lastResult.workorder.items.item.code, description: orderLookup.lastResult.workorder.items.item.description, price: orderLookup.lastResult.workorder.items.item.price });
                    itemAC.refresh();
                    //	upload_ico.enabled = true;
                    trace("upload enabled");
                }
                disableAllFields();
                detailGrid.doubleClickEnabled = false;
                order_rb.enabled = true;
                serialno_rb.enabled = true;
                prepareReprint(orderLookup);
                currentState = '';
                if (Number(orderLookup.lastResult.workorder.header.photo) == 1)
                {
                    photo_ico.visible = true;
                    photo_ico
                    strImageList = orderLookup.lastResult.workorder.header.images;
                }
                else
                {
                    photo_ico.visible = false;
                }
            }
            else
            {
                Alert.show('No Matching Records found', "Attention", 0, this, null, Images.BadIcon, 0);
            }
            break;
        case 5:
            if (singleCode.lastResult.codeList.record.status == "1")
            {
                itemAC.addItem({ id: singleCode.lastResult.codeList.record.id, code: singleCode.lastResult.codeList.record.code, description: singleCode.lastResult.codeList.record.description, price: singleCode.lastResult.codeList.record.price });
            }
            else
            {
                displayAlert("Repair Code not found");
            }
            break;
        case 6:
            /*  snLookup
               http://www.heritagemfg.com/console/flex/queries/snLookup.cfm
             */
            if (snLookup.lastResult.orders.status == "1" && int(snLookup.lastResult.orders.recordcount) > 0)
            {
                historyGrid.dataProvider = snLookup.lastResult.orders.record;
                disableAllFields();
                order_rb.enabled = true;
                serialno_rb.enabled = true;
                Alert.show(snLookup.lastResult.orders.recordcount + ' Records Found', "Success", 0, this, null, Images.OKIcon, 0);
                currentState = 'History';
            }
            else
            {
                Alert.show("Serial Number not found", "Attention", 0, this, null, Images.BadIcon, 0);
            }
            break;
        case 7:
            /*  addClient
               http://www.heritagemfg.com/console/flex/queries/updateClient.cfm

             */
            var returnCode:String = addClient.lastResult.root.status;
            if (Number(returnCode) == 2)
            {
                Alert.show("Problem adding Record", "Error", Alert.OK, this, null, Images.WarningIcon);
            }
            else
            {
                clientObj.id = addClient.lastResult.root.record.id;
                clientObj.name = addClient.lastResult.root.record.name;
                clientObj.address = addClient.lastResult.root.record.address;
                clientObj.suite = addClient.lastResult.root.record.suite;
                clientObj.city = addClient.lastResult.root.record.city;
                clientObj.state = addClient.lastResult.root.record.state;
                clientObj.zipcode = addClient.lastResult.root.record.zipcode;
                clientObj.phone = addClient.lastResult.root.record.phone;
                Alert.show("Client " + name_fld.text + " Added", "Success", Alert.OK, this, null, Images.OKIcon);
                dp2.item[0].editItem[0].@enabled = false; // disable new customer menu selection
                dp2.item[1].editItem[0].@enabled = false; // disable save customer			        			        
                clearForm();
                populateClientFields(clientObj);
                currentState = '';
                enableAllFields();
                break;
            }
        case 8:
            /*  convertEstimate
               http://www.heritagemfg.com/console/flex/queries/convertEstimate.cfm
             */
            if (convertEstimate.lastResult.root.status == "2")
            {
                Alert.show("Problem Converting Estimate", "Error", Alert.OK, this, null, Images.WarningIcon);
            }
            else
            {
                docType = "Order";
                p1.title = 'Repair Ticket -- Order ' + ID;
                dp2.item[3].@enabled = false; // disable convert to order 
                p1.status = 'Estimate Converted';
                Alert.show("Estimate Converted.\nWould you like to print the Order ?", "Success", 3, this, OprintClickHandler, Images.OKIcon);
                mconvertToOrder();
            }
            break;
        case 9:
            /*  reopenOrder

               http://www.heritagemfg.com/console/flex/queries/reopenOrder.cfm

             */
            if (reopenOrder.lastResult.root.status == "2")
            {
                Alert.show("Problem reopening Order", "Error", Alert.OK, this, null, Images.WarningIcon);
            }
            else
            {
                search_fld.text = String(ID);
                p1.status = 'Order Reopened';
                Alert.show("Reopen Completed.\nProceed with edits", "Success", Alert.OK, this, null, Images.OKIcon);
                makeRandom(orderLookup);
            }
            break;
        case 10:
            /*  updateEstimate
               http://www.heritagemfg.com/console/flex/queries/updateEstimate.cfm

             */
            if (updateEstimate.lastResult.root.status == "2")
            {
                Alert.show("Problem updating Estimate", "Error", Alert.OK, this, null, Images.WarningIcon);
            }
            else
            {
                p1.title = 'Repair Ticket -- Estimate ' + ID;
                p1.status = 'Estimate Updated';
                Alert.show("Estimate Updated ", "Success", Alert.OK, this, null, Images.OKIcon);
            }
            break;
        default:
            Alert.show('Error Detected!!', "Attention", 0, this, null, Images.BadIcon, 0);
            break;
        case 11:
            notes_ta.text = getNotes.lastResult.order.notes;
            break;
        case 12:
            //  returnCode = saveNotes.lastResult.status; 
            if (Number(updateNotes.lastResult.status) == 2)
            {
                Alert.show("Problem updating Notes", "Error", 3, this, null, Images.WarningIcon);
            }
            else
            {
                Alert.show("Notes updated", "Success", Alert.OK, this, null, Images.OKIcon);
            }
            break;
    }
}

private function openFileUploadWindow():void
{
    fileUploadWindow = UploadWindow(PopUpManager.createPopUp(this, UploadWindow, true));
    fileUploadWindow.showCloseButton = true;
    fileUploadWindow.parentModule = this;
    fileUploadWindow.orderID = String(ID);
    fileUploadWindow.addEventListener("close", closefileUploadWindow);
}

private function closefileUploadWindow(event:CloseEvent):void
{
    PopUpManager.removePopUp(fileUploadWindow);
}

public function showPhotos():void
{
    //Alert.show("Photo viewing not completed yet","Sorry");
    openImageWindow();
}

private function openImageWindow():void
{
    imageWindow = ImageViewer(PopUpManager.createPopUp(this, ImageViewer, true));
    imageWindow.showCloseButton = true;
    imageWindow.strImageList = strImageList;
    imageWindow.strOrder = String(ID);
    imageWindow.addEventListener("close", closeImageWindow);
}

private function closeImageWindow(event:CloseEvent):void
{
    PopUpManager.removePopUp(imageWindow);
}

/* ***********************************************************************************   */
private function mnewCustomer():void
{
    dp2.item[1].@enabled = true; // enable save function
    dp2.item[0].editItem[0].@enabled = true; // enable new customer menu selection
    dp2.item[1].editItem[1].@enabled = true; // disable save estimate
    dp2.item[1].editItem[2].@enabled = false; // disable save order
    dp2.item[3].@enabled = false; // disable conversion
}

private function mnewEstimate():void
{
    dp2.item[1].@enabled = true; // enable save function 
    dp2.item[0].editItem[0].@enabled = true; // enable new customer menu selection
    dp2.item[1].editItem[0].@enabled = true; // enable save customer
    dp2.item[1].editItem[1].@enabled = true; // enable save estimate
    dp2.item[1].editItem[2].@enabled = false; // disable save order
    dp2.item[3].@enabled = false; // disable conversion
    dp2.item[6].@enabled = true // enable cc processing
}

private function mnewOrder():void
{
    dp2.item[1].@enabled = true; // enable save function
    dp2.item[0].editItem[0].@enabled = true; // enable new customer menu selection
    dp2.item[1].editItem[0].@enabled = true; // enable save customer
    dp2.item[1].editItem[1].@enabled = false; // disable save estimate
    dp2.item[1].editItem[2].@enabled = true; // enable save order
    dp2.item[3].@enabled = false; // disable conversion	
    dp2.item[6].@enabled = true // enable cc processing
}

private function mconvertToOrder():void
{
    dp2.item[1].@enabled = false; // disable save menu
    dp2.item[1].editItem[1].@enabled = false; // disable save estimate
    dp2.item[2].@enabled = true; // enable print menu
    dp2.item[4].editItem[0].@enabled = false; // disable update estimate
    dp2.item[4].editItem[1].@enabled = false; // disable update order
    dp2.item[5].@enabled = true; // enable reopen	
    dp2.item[6].@enabled = true // enable cc processing
}

private function mReprint(document_type:String):void
{
    if (document_type == "Order")
    {
        dp2.item[1].@enabled = false; // disable save menu item if this is a recalled item	
        dp2.item[2].@enabled = true; // enable print menu
        dp2.item[4].editItem[0].@enabled = false; // disable update estimate
        dp2.item[4].editItem[1].@enabled = false; // disable update order
        dp2.item[5].@enabled = true; // enable reopen 
    }
    else
    {
        dp2.item[1].@enabled = false; // disable save menu item if this is a recalled estimate	
        dp2.item[2].@enabled = true; // enable print menu
        dp2.item[3].@enabled = true; // enable convert to order
        dp2.item[4].editItem[0].@enabled = true; // enable update estimate
        dp2.item[4].editItem[1].@enabled = false; // disable update order
        dp2.item[5].@enabled = false; // disable reopen 
    }
}

private function msaveOrder():void
{
    dp2.item[2].@enabled = true; // enable print menu selection
    dp2.item[1].@enabled = false; // disable save function
}

private function enableCCProcessing():void
{
    dp2.item[6].@enabled = true // enable cc processing
}

private function disableCCProcessing():void
{
    dp2.item[6].@enabled = false // disable cc processing
}