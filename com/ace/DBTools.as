package com.ace
{
	//import AppTools.CstageLOV;
	//import AppTools.GeneralLOV;
	
	 
	import com.ace.Input.ValidatedCheckBox;
	import com.ace.Input.ValidatedComboBox;
	import com.ace.Input.ValidatedDateField;
	import com.ace.Input.ValidatedRadioButtonBox;
	import com.ace.Input.ValidatedTextArea;
	import com.ace.Input.ValidatedTextInput;
	import com.metrobg.Components.VAComboBox;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.FormItem;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManager;
	import mx.utils.ObjectUtil;
	
	/**
	 * DBTools - Set of tools that simplifies handling of data entry fields
	 * within containers. The purpose is of this class is to more easily handle 
	 * moving data from an array collection into a group of fields in a container
	 * as well as building structures suitable for inserting and updating a database.
	 *
	 * <pre>
	 * Key concepts;
	 * 1) The fields must be of the "Validated" genre.
	 * 2) The field "id" must match the field name from the DB.
	 * 3) The fields must be contained within an object such as a box, canvas, etc. The
	 *    methods used in this package will recurse theough all clildren containers 
	 *    while processing fields.
	 * 4) When it is necessary to have "Validated" fields for purposes other than what 
	 *    is needed for these methods to work on, use prefixes. For example
	 *    if you need to work on a DB field called "FIELD_1", a ValidatedTextInput can
	 *    be created with an id = "pre_FIELD_1". When using the methods of this class 
	 *    make sure you use a strFieldPrefix of "pre_". The fields not to be used by
	 *    the methods of this class will ignore all fields without the prefix of "pre_." 
	 *  </pre>
	 */
	
	public class DBTools extends UIComponent
	{
		private var _dateFormat:DateFormatter = new DateFormatter;
		private var _strComma:String = "";
		private var _acInsertRecord:ArrayCollection = null;
		private var _insertFieldsContainer:Object = null;
		private var _strInsertTableName:String = "";
		private var _strRootDomain:String = "";
		private var _strInsertFieldsPrefix:String = "";
		private var _fncInsertComplete:Function = null;
		private var _fncBuildInsertComplete:Function = null;
		private var _bolBuildInsertOnly:Boolean = false;

		private var _updateFields:String = "";

		private var _acDataTable:ArrayCollection;
		private var _intCurrentRecord:int;
		private var _fieldsContainer:Object;
		private var _tableName:String;
		private var _strFieldsPrefix:String;
		private var _fncDeleteComplete:Function;

       	private var _securityFunction:Function;

		/**
		 * acInsertRecord - ArrayCollection containing the record to be inserted into
		 * a table. Used by calling program when buildInsertRecord is called.
		 * 
		 * @return acInsertRecord
		 */

		public function get acInsertRecord():ArrayCollection
		{
			return this._acInsertRecord;
		} 
		public function set acInsertRecord(acInsertRecord:ArrayCollection):void 
		{
			this._acInsertRecord = acInsertRecord;
		}

		/**
		 * securityFunction - Function that will return security token for use with 
		 * insert, updates and deletes.
		 * 
		 * @return securityFunction
		 */

		public function get securityFunction():Function
		{
			return this._securityFunction;
		} 
		public function set securityFunction( securityFunction:Function ):void 
		{
			this._securityFunction = securityFunction;
		}

		/**
		 * updateFields - Fields that have changed, and need to be updated.
		 * 
		 * @return updateFields
		 */

		public function get updateFields():String
		{
			return this._updateFields;
		} 
		public function set updateFields( updateFields:String ):void 
		{
			this._updateFields = updateFields;
		}

		private var _acUpdateRecord:ArrayCollection = new ArrayCollection;
		/**
		 * acUpdateRecord - Array collection that contains the data to be used by update or delete.
		 * 
		 * @return acUpdateRecord
		 */

		public function get acUpdateRecord():ArrayCollection
		{
			return this._acUpdateRecord;
		} 
		public function set acUpdateRecord( acUpdateRecord:ArrayCollection ):void 
		{
			this._acUpdateRecord = acUpdateRecord;
		}

		private var _insertResults:String = "";
		/**
		 * insertResults - String that contains the results from the last insert.
		 * 
		 * @return insertResults
		 */

		public function get insertResults():String
		{
			return this._insertResults;
		} 
		public function set insertResults( insertResults:String ):void 
		{
			this._insertResults = insertResults;
		}

		/**
		 * loadFieldData - Method that will move a record in an array collection
		 * to the related fields on the screen. Unless blank, it will ignore all 
		 * fields that do not match the strFieldsPrefix.
		 * 
		 * @param acDataTable The array collection containing one or more  records
		 * to move to relate fields on screen.
		 * 
		 * @param intRecNumber The record number (index) within the array collection to display.
		 * 
		 * @param fieldsContainer The container object on the screen that holds the fields
		 * in which to display the data. The module will recurse through child containers.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 */

		public function loadFieldData(acDataTable:ArrayCollection, intRecNumber:int,fieldsContainer:Object,strFieldsPrefix:String):void
		{
			if (intRecNumber > (acDataTable.length - 1)) return;
			_dateFormat.formatString = "MM/DD/YYYY"
			doFieldLoad(acDataTable,intRecNumber, fieldsContainer, strFieldsPrefix);
		}

		private function doFieldLoad(acDataTable:ArrayCollection, intRecNumber:int, fieldsContainer:Object,strFieldsPrefix:String):void
		{
			var strFieldID:String = "";
			for each (var field:Object in fieldsContainer.getChildren())
			{
				 if (isContainer(field))
				{
					doFieldLoad(acDataTable,intRecNumber,field,strFieldsPrefix);
				}
			
				if (field is ValidatedTextInput || field is ValidatedDateField || 
					field is ValidatedTextArea)
				{
					if (strFieldsPrefix.length > 0) 
					{
						strFieldID = field["id"].toString().replace(strFieldsPrefix + "_","");
					}
					else
					{
						strFieldID = field["id"].toString();
					}
					if (acDataTable[intRecNumber].hasOwnProperty(strFieldID))
					{
						if (acDataTable[intRecNumber][strFieldID] is Date ||
							field is ValidatedDateField)
						{
							if (acDataTable[intRecNumber][strFieldID] != null)
							{
								field["text"] = _dateFormat.format(acDataTable[intRecNumber][strFieldID]);
								field.validateData();
							}
							else
							{
								field["text"] = ""
							}
						}
						else
						{
							field["text"] = acDataTable[intRecNumber][strFieldID];
							field.validateData();
						}
					}

				}
				if (field is ValidatedComboBox ||  field is ValidatedCheckBox || field is ValidatedRadioButtonBox)
				{
					if (strFieldsPrefix.length > 0) 
					{
						strFieldID = field["id"].toString().replace(strFieldsPrefix + "_","");
					}
					else
					{
						strFieldID = field["id"].toString();
					}
					if (acDataTable[intRecNumber].hasOwnProperty(strFieldID))
					{
						field["value"] = acDataTable[intRecNumber][strFieldID]
					}
				}
			}
		}

		/**
		 * buildUpdateRecord - Method that will create everything needed to update 1 row in 
		 * a table. 
		 * <pre>
		 * Two main properties affected are;
		 * 
		 * 1) acUpdateRecord - This will be a one record array collection containing all fields 
		 * in the record to update.
		 * 
		 * 2) updateFields - This will be a string of fields that have changed. If this string is 
		 * empty, nothing has changed, and the update should not be done. 
		 * 
		 * Unless blank, it will ignore all fields that do not match the strFieldsPrefix.
		 * </pre>
		 * @param acDataTable The array collection containing one or more  records
		 * to move to relate fields on screen.
		 * 
		 * @param intRecNumber The record number (index) within the array collection to display.
		 * 
		 * @param fieldsContainer The container object on the screen that holds the fields
		 * in which to display the data. The module will recurse through child containers.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 */

		public function buildUpdateRecord(acDataTable:ArrayCollection, intCurrentRecord:int, fieldsContainer:Object, strFieldsPrefix:String):void
		{
			_strComma = "";
			_updateFields = "";
			_acUpdateRecord = new ArrayCollection;
			var objTemp:Object = ObjectUtil.copy(acDataTable[intCurrentRecord]);
			_acUpdateRecord.addItem(objTemp);
			doBuildUpdateRecord(fieldsContainer,strFieldsPrefix);
		}

		private function doBuildUpdateRecord(fieldsContainer:Object, strFieldsPrefix:String):void
		{
			var strFieldID:String="";
			for each (var field:Object in fieldsContainer.getChildren())
			{
				if (isContainer(field))
				{
					doBuildUpdateRecord(field, strFieldsPrefix);
				}
				if (field is ValidatedTextInput || field is ValidatedDateField || field is ValidatedComboBox || field is ValidatedCheckBox  || field is ValidatedTextArea || field is ValidatedRadioButtonBox)
				{
					if (strFieldsPrefix.length > 0)
					{
						strFieldID=field["id"].toString().replace(strFieldsPrefix + "_", "");
					}
					else
					{
						strFieldID=field["id"].toString();
					}
					if (_acUpdateRecord[0][strFieldID] || _acUpdateRecord[0][strFieldID] == null || _acUpdateRecord[0][strFieldID] == "" || _acUpdateRecord[0][strFieldID].toString().length > 0)
					{
						if (field["value"] || (_acUpdateRecord[0][strFieldID] != null))
						{
							//var strRecData:String = _acUpdateRecord[0][field["id"]]
							var strRecData:String=_acUpdateRecord[0][strFieldID]
							 
							var	 strFieldData:String=field["value"].valueOf();
							 
							//	if (_acUpdateRecord[0][field["id"]] is Date)
							if (_acUpdateRecord[0][strFieldID] is Date)
							{
								//strRecData = _dateFormat.format(_acUpdateRecord[0][field["id"]]);
								strRecData=_dateFormat.format(_acUpdateRecord[0][strFieldID]);
							}

							if (field is ValidatedTextInput)
							{
								if (field["dataType"] == "number")
								{ // get rid of leading and trailing 0's 012 or 12.30
									strFieldData=parseFloat(field["value"]).toString();
									strRecData=parseFloat(strRecData).toString();
								}
							}
							if ((strFieldData != strRecData))
							{
								if (field is ValidatedDateField)
								{
									_acUpdateRecord[0][strFieldID]=new Date(field["value"]);

								}
								else
								{
									 
										_acUpdateRecord[0][strFieldID] = field["value"].valueOf();

									 
								}
								_updateFields=_updateFields + _strComma + field["id"];
								_strComma=",";

							}
						}
					}
				}
			}
		}
		/**
		 * buildInsertRecord - Method that will gather all data from fields in a container and builds an insert
		 * statement. Unless blank, it will ignore all fields that do not match 
		 * the strFieldsPrefix.
		 * 
		 * @param fieldsContainer The container object on the screen that holds the fields
		 * in which to gather the data. The module will recurse through child containers. Unless
		 * blank, it will ignore all fields that do not match the strFieldsPrefix.
		 * 
		 * @param strTableName The name of a table to insert data into.
		 * 
		 * @param strRootDomain The server portion of the uri.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 * @param fncBuildInsertComplete A user defined function to execute on completion of insert.
		 * 
		 */

		public function buildInsertRecord(fieldsContainer:Object,strTableName:String,strRootDomain:String,strFieldsPrefix:String,fncBuildInsertComplete:Function):void
		{
			_insertFieldsContainer = fieldsContainer;
			_strInsertTableName = strTableName;
			_strRootDomain = strRootDomain;
			_strInsertFieldsPrefix = strFieldsPrefix;
			_fncBuildInsertComplete = fncBuildInsertComplete;
			_bolBuildInsertOnly = true;
			initInsert();
		}

		/**
		 * doInsert- Method that will gather all data from fields in a container and insert
		 * them into a table. Unless blank, it will ignore all fields that do not match 
		 * the strFieldsPrefix.
		 * 
		 * @param fieldsContainer The container object on the screen that holds the fields
		 * in which to gather the data. The module will recurse through child containers. Unless
		 * blank, it will ignore all fields that do not match the strFieldsPrefix.
		 * 
		 * @param strTableName The name of a table to insert data into.
		 * 
		 * @param strRootDomain The server portion of the uri.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 * @param fncInsertComplete A user defined function to execute on completion of insert.
		 * 
		 */

		public function doInsert(fieldsContainer:Object,strTableName:String,strRootDomain:String,strFieldsPrefix:String,fncInsertComplete:Function):void
		{
			_insertFieldsContainer = fieldsContainer;
			_strInsertTableName = strTableName;
			_strRootDomain = strRootDomain;
			_strInsertFieldsPrefix = strFieldsPrefix;
			_fncInsertComplete = fncInsertComplete;
			_bolBuildInsertOnly = false;
			initInsert();
		}
		
		private function initInsert():void
		{
			
		}

 		private function doInsertResults(acResult:ArrayCollection):void
 		{
		   
		}

		private function buildInsertData(fieldsContainer:Object):void
		{
	
		}

		/**
		 * doInsertData - This will insert a record into a table based the data in the
		 * ArrayCollection _acInsertRecord
		 * 
		 * @param strTableName The name of a table to insert data into.
		 * 
		 * @param strRootDomain The server portion of the uri.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 * @param fncInsertComplete A user defined function to execute on completion of insert.
		 * 
		 */
		public function doInsertData(strInsertTableName:String,fncInsertComplete:Function):void
		{
			_strInsertTableName = strInsertTableName;
			_fncInsertComplete = fncInsertComplete;
			insertData();
		}
		
		private function insertData():void
		{
		
		}

		private function insertDataResults(strResult:String):void
		{
			CursorManager.removeBusyCursor();
			_insertFieldsContainer = null;
			_insertResults = strResult;
			if (_fncInsertComplete != null) _fncInsertComplete(_insertResults);
		}

		/**
		 * deleteData - Method that will prompt the user, and depending on response delete a record.
		 * 
		 * @param acDataTable The array collection containing a record to delete
		 * 
		 * @param intRecNumber The record number (index) within the array collection to delete.
		 * 
		 * @param fieldsContainer The container object on the screen that holds the fields
		 * in which to delete. The module will recurse through child containers.
		 * 
		 * @param strTableName The name of a table to delete from.
		 * 
		 * @param strRootDomain The server portion of the uri.
		 * 
		 * @param strFieldsPrefix A prefix for all of the fields that will be affected. This is 
		 * used when there are fields in the container that are not to be affected by this method.
		 *  
		 * @param fncDeleteComplete A user defined function to execute on completion of deletion.
		 */

		public function deleteData(acDataTable:ArrayCollection, intCurrentRecord:int, fieldsContainer:Object, tableName:String, 
								   strRootDomain:String, strFieldsPrefix:String,fncDeleteComplete:Function):void
		{
			_acDataTable = acDataTable;
			_intCurrentRecord = intCurrentRecord;
			_fieldsContainer = fieldsContainer;
			_strFieldsPrefix = strFieldsPrefix;
			_tableName = tableName;
			_strRootDomain = strRootDomain;
			_fncDeleteComplete = fncDeleteComplete;
			
			Alert.show("Really Delete this record?","Delete Record",
					   Alert.YES|Alert.NO,
					   null,deleteDataHandler, null,Alert.NO);
		}
		
		private function deleteDataHandler(eventObj:CloseEvent):void
		{
			switch (eventObj.detail)
			{
				case Alert.YES:
					doDeleteData();
					break;
				case Alert.NO:
					if(_fncDeleteComplete != null) _fncDeleteComplete(false);
					break;
			}
		}
		
		private function doDeleteData():void
		{
		
		}
		
		private function deleteDataResults(strResult:String):void
		{
			CursorManager.removeBusyCursor();
			if (strResult.substr(0,6) == "Error:")
			{
				Alert.show(strResult);
			}
			else
			{
				Alert.show("Success: " + strResult);
				_acDataTable.removeItemAt(_intCurrentRecord);
				if(_fncDeleteComplete != null)_fncDeleteComplete(true);
			}
		}

		private function isContainer(obj:Object):Boolean
		{
			return (obj is Canvas || obj is FormItem || obj is TabNavigator || obj is HBox || obj is VBox ||
					obj is Panel || obj is TitleWindow ||obj is Grid|| obj is GridRow || obj is GridItem);
		}


	} // End Class
} // End Package