// ActionScript file
import flash.events.Event;

private function getResultOk1(r:Number, event:Event):void
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
                Alert.show('No Matching Records found', "Attention", 0, this, null, Images.badIcon, 0);
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
                //  p1.title = "Repair Ticket -- " + docType + "  " + ID;
                orderSaved = true;
                msaveOrder();
                if (docType == "Estimate")
                {
                    Alert.show(docType + ' ' + ID + ' Completed ' + "\nWould you like to print the Work Order ?", "Success", 3, this, WOprintClickHandler, Images.okIcon);
                        //Alert.show(docType + ' ' + ID + ' Completed ',"Success",0,this,null,Images.okIcon,0);
                }
                else
                {
                }
            }
            else
            {
                Alert.show('Update Failed', "Error", 0, this, null, Images.badIcon, 0);
            }
            break;
        case 4:
            var paid:Number = 0;
            if (orderLookup.lastResult.workorder.status == "1")
            {
                if (Number(orderLookup.lastResult.workorder.itemcount) == 0)
                {
                    Alert.show('No Matching Records found', "Attention", 0, this, null, Images.badIcon, 0);
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
                }
                disableAllFields();
                detailGrid.doubleClickEnabled = false;
                order_rb.enabled = true;
                serialno_rb.enabled = true;
                prepareReprint(orderLookup);
                currentState = '';
            }
            else
            {
                Alert.show('No Matching Records found', "Attention", 0, this, null, Images.badIcon, 0);
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
                Alert.show(snLookup.lastResult.orders.recordcount + ' Records Found', "Success", 0, this, null, Images.okIcon, 0);
                currentState = 'History';
            }
            else
            {
                Alert.show("Serial Number not found", "Attention", 0, this, null, Images.badIcon, 0);
            }
            break;
        case 7:
            /*  addClient
               http://www.heritagemfg.com/console/flex/queries/updateClient.cfm

             */
            var returnCode:String = addClient.lastResult.root.status;
            if (Number(returnCode) == 2)
            {
                Alert.show("Problem adding Record", "Error", Alert.OK, this, null, Images.warningIcon);
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
                Alert.show("Client " + name_fld.text + " Added", "Success", Alert.OK, this, null, Images.okIcon);
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
                Alert.show("Problem Converting Estimate", "Error", Alert.OK, this, null, Images.warningIcon);
            }
            else
            {
                docType = "Order";
                //p1.title = 'Repair Ticket -- Order ' + ID;
                dp2.item[3].@enabled = false; // disable convert to order 
                //p1.status = 'Estimate Converted'; 
                Alert.show("Estimate Converted.\nWould you like to print the Order ?", "Success", 3, this, OprintClickHandler, Images.okIcon);
                mconvertToOrder();
            }
            break;
        case 9:
            /*  reopenOrder

               http://www.heritagemfg.com/console/flex/queries/reopenOrder.cfm

             */
            if (reopenOrder.lastResult.root.status == "2")
            {
                Alert.show("Problem reopening Order", "Error", Alert.OK, this, null, Images.warningIcon);
            }
            else
            {
                search_fld.text = String(ID);
                //p1.status = 'Order Reopened'; 
                Alert.show("Reopen Completed.\nProceed with edits", "Success", Alert.OK, this, null, Images.okIcon);
                makeRandom(orderLookup);
            }
            break;
        case 10:
            /*  updateEstimate
               http://www.heritagemfg.com/console/flex/queries/updateEstimate.cfm

             */
            if (updateEstimate.lastResult.root.status == "2")
            {
                Alert.show("Problem updating Estimate", "Error", Alert.OK, this, null, Images.warningIcon);
            }
            else
            {
                //p1.title = 'Repair Ticket -- Estimate ' + ID;
                //p1.status = 'Estimate Updated'; 
                Alert.show("Estimate Updated ", "Success", Alert.OK, this, null, Images.okIcon);
            }
            break;
        default:
            Alert.show('Error Detected!!', "Attention", 0, this, null, Images.badIcon, 0);
            break;
        case 11:
            notes_ta.text = getNotes.lastResult.order.notes;
            break;
        case 12:
            //  returnCode = saveNotes.lastResult.status; 
            if (Number(updateNotes.lastResult.status) == 2)
            {
                Alert.show("Problem updating Notes", "Error", 3, this, null, Images.warningIcon);
            }
            else
            {
                Alert.show("Notes updated", "Success", Alert.OK, this, null, Images.okIcon);
            }
            break;
    }
}