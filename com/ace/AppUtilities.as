package AppTools
{
	import flash.text.TextFormat;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.UITextField;
	import mx.formatters.DateFormatter;
	import mx.formatters.PhoneFormatter;
	import mx.utils.ObjectProxy;

	/**
	 * AppUtilities - Miscellaneous utilities specific for this application.
	 */
	public class AppUtilities
	{
		private var _dateFormat:DateFormatter;
		private var _phoneFormat:PhoneFormatter;
		private var _ssnFormat:PhoneFormatter;
		private var _dateSTRFormat:PhoneFormatter;

		/**
		 * CheckRoles - Compare user's roles against roles allowed.
		 *
		 * @param aryUserRoles User's roles.
		 * @param aryModuleRoles Roles to check against, usually those specified for
		 * a specific module.
		 * @return Whether a match was found.
		 */

		public function CheckRoles(aryUserRoles:Array, aryModuleRoles:Array):Boolean
		{
			// Return True if one of the current user's roles matches a role in the list passed in aryModuleRoles
			// else return false
			var bolRoleTest:Boolean = false;
			for (var i:int = 0; i < aryUserRoles.length; i++)
			{
				for (var j:int = 0; j < aryModuleRoles.length; j++)
				{
					bolRoleTest = (aryUserRoles[i] == aryModuleRoles[j]);
					if (bolRoleTest)
						break;
				}
				if (bolRoleTest)
					break;
			}
			return bolRoleTest
		}

		/**
		 * convertStringToInt - Convert a string up to four bytes in length to
		 * an integer.
		 * <p>
		 * Conversion algorithm is to add each byte raised to its appropriate power
		 * ((n^8*x), where n is the character and x is its ordinal position - 1)  starting
		 * on the right.
		 * </p>
		 * @param strIn String up to 4 bytes long to convert. Strings less than four bytes
		 * will have chr(0) prepended for each character missing.
		 * @return Integer value of the input string.
		 */
		public function convertStringToInt(strIn:String):int
		{
			var result:String;
			var strTemp:String = strIn;
			if (strIn.length < 4)
			{
				var intExtraChar:int = 4 - strIn.length;
				for (var i:int = 0; i < intExtraChar; i++)
				{
					strTemp = String.fromCharCode(0) + strTemp;
				}
			}
			var aryBytes:Array = strTemp.split("");

			return aryBytes[0].charCodeAt(0) * 16777216 + aryBytes[1].charCodeAt(0) * 65536 + aryBytes[aryBytes.length - 2].charCodeAt(0) * 256 + aryBytes[aryBytes.length - 1].charCodeAt(0)
		}

		/**
		 * showDate - Format date as YYYY-MM-DD for data grids.
		 *
		 * @param item dataGrid row.
		 * @param column dataGrid column.
		 * @return String formatted.
		 */
		public function showDate(item:Object, column:DataGridColumn):String
		{
			var field:String = column.dataField;
			if (item[field] is Date)
			{
				if (_dateFormat == null)
				{
					_dateFormat = new mx.formatters.DateFormatter();
					_dateFormat.formatString = "YYYY-MM-DD";
				}
				return _dateFormat.format(item[field]);
			}
			else
			{
				if (_dateSTRFormat == null)
				{
					_dateSTRFormat = new mx.formatters.PhoneFormatter();
					_dateSTRFormat.formatString = "####-##-##";
				}
				if (item[field] == 0)
				{
					return '-';
				}
				else
				{
					return _dateSTRFormat.format(item[field]);
				}

			}
		}

		/**
		 * showSSN - Format Social Security Number ###-##-#### for data grids.
		 *
		 * @param item dataGrid row.
		 * @param column dataGrid column.
		 * @return String formatted.
		 */
		public function showSSN(item:Object, column:DataGridColumn):String
		{
			var field:String = column.dataField;
			if (_ssnFormat == null)
			{
				_ssnFormat = new mx.formatters.PhoneFormatter();
				_ssnFormat.formatString = "###-##-####";
			}
			if (item[field] == 0)
			{
				return '-';
			}
			else
			{
				return _ssnFormat.format(item[field]);
			}
		}

		/**
		 * showPhone - Format Phone Number (###)###-#### for data grids.
		 *
		 * @param item dataGrid row.
		 * @param column dataGrid column.
		 * @return String formatted.
		 */
		public function showPhone(item:Object, column:DataGridColumn):String
		{
			var field:String = column.dataField;
			if (_phoneFormat == null)
			{
				_phoneFormat = new mx.formatters.PhoneFormatter();
				_phoneFormat.formatString = "(###)###-####";
			}
			if (item[field] == 0)
			{
				return '-';
			}
			else
			{
				return _phoneFormat.format(item[field]);
			}
		}

		/**
		 * sumColumn - Sum all of the values in a specific column of an Array Collection.
		 *
		 * @param acInput Array collection containing the column to sum.
		 * @param strColumnName Name of colum to sum.
		 * @return Sum of column.
		 *
		 */
		public function sumColumn(acInput:ArrayCollection, strColumnName:String):Number
		{
			var nbrTotal:Number = 0;
			for (var i:int = 0; i < acInput.length; i++)
			{
				nbrTotal += Number(acInput[i][strColumnName]);
			}
			return nbrTotal;
		}

		/**
		 * moveToFront - Move the current panel on top of everything else.
		 *
		 */
		public function moveToFront(inObject:Object):void
		{
			// move the shape to the front by moving it to the front-most
			// index (which is always numChildren - 1)
			if (inObject.hasOwnProperty("parentApplication"))
				inObject["parentApplication"].setChildIndex(inObject["parentApplication"].getChildByName(inObject["owner"].name),
															inObject["parentApplication"].numChildren - 1);
		}

		/**
		 * getDateRange - Method to return a starting and ending date.
		 *
		 * @param strRangeID Defines the range of dates needed.
		 * <pre>
		 * curryear - January 1st through December 31st of this year.
		 * currmonth - 1st through last day of this month.
		 * currday - Today.
		 * prevyear - January 1st through December 31st of last year
		 * prevmonth - 1st through last day of last month
		 * prevday - Yesterday.
		 * ytd - Year to date.
		 * mtd - Month to date.
		 * yearendtoday - 1 year ending today.
		 * </pre>
		 * @return Array containing two dates.
		 *
		 */
		public function getDateRange(strRangeID:String):Array
		{
			var dateFormat:DateFormatter = new DateFormatter;
			dateFormat.formatString = "MM/DD/YYYY";
			var now:Date = new Date();
			var startDate:Date = new Date();
			var strStartDate:String = "";
			var endDate:Date = new Date();
			var strEndDate:String = "";
			switch (strRangeID)
			{
				case "curryear":
					startDate = new Date(now.fullYear, 0, 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, 11, 31, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "currmonth":
					startDate = new Date(now.fullYear, now.getMonth(), 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, now.getMonth() + 1, 0, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "currday":
					strStartDate = dateFormat.format(now);
					strEndDate = dateFormat.format(now);
					break;

				case "prevyear":
					startDate = new Date(now.fullYear - 1, 0, 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear - 1, 11, 31, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "prevmonth":
					startDate = new Date(now.fullYear, now.getMonth() - 1, 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, now.getMonth(), 0, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "prevday":
					strStartDate = dateFormat.format(now.day - 1);
					strEndDate = dateFormat.format(now.day - 1);
					break;

				case "ytd":
					startDate = new Date(now.fullYear, 0, 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, now.getMonth(), now.day, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "mtd":
					startDate = new Date(now.fullYear, now.getMonth(), 1, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, now.getMonth(), now.day, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

				case "yearendtoday":
					startDate = new Date(now.fullYear - 1, now.getMonth(), now.day, 0, 0, 0, 0);
					strStartDate = dateFormat.format(startDate);
					endDate = new Date(now.fullYear, now.getMonth(), now.day, 0, 0, 0, 0);
					strEndDate = dateFormat.format(endDate);
					break;

			}
			var aryDates:Array = new Array;
			aryDates[0] = strStartDate;
			aryDates[1] = strEndDate;
			return aryDates;
		}

		/**
		 * loadDataGrid - Create a datagrid from an array collection.
		 * <p>
		 * This method will reformat an existing datagrid to create a column for each field in an
		 * array collection. It will then set the data grid's dataprovider to the array collection.
		 * </p>
		 * @param acInput Array collection for input.
		 * @param dgOutput Data grid to reformat and send data to.
		 * @param bolSort Boolean to define whether to sort the column's by the column name.
		 *
		 */
		public function loadDataGrid(acInput:ArrayCollection, dgOutput:DataGrid, bolSort:Boolean):void
		{
			var arFields:ArrayCollection = new ArrayCollection;
			for (var objField:Object in acInput[0])
			{
				arFields.addItem({ Label: objField, Data: objField });
			}
			if (bolSort)
			{
				var sfData:SortField = new SortField();
				sfData.name = "Label";
				var stData:Sort = new Sort();
				stData.fields = [ sfData ];
				arFields.sort = stData;
				arFields.refresh();
			}

			var aryColumns:Array = new Array;
			for (var i:int; i < arFields.length; i++)
			{
				var dgColumn:DataGridColumn = new DataGridColumn();
				dgColumn.dataField = arFields[i]["Data"];
				dgColumn.headerText = arFields[i]["Label"];
				dgColumn.wordWrap = dgOutput.variableRowHeight;
				aryColumns.push(dgColumn);
			}
			dgOutput.columns = aryColumns;
			dgOutput.horizontalScrollPolicy = "on"
			dgOutput.dataProvider = acInput;
			optimiseGridColumns(dgOutput, true);
		}

		/**
		 * optimiseGridColumns - Method that will change the width of each column in a
		 * 						 data grid based on the headers and data.
		 * <p>
		 * Based on the bolExpand parameter this method will set the width of each
		 * column in a data grid to either (true) the maximum of the column header
		 * or data, or (false) the maximum width of just the data.
		 *
		 * When analyzing the data for columd width, this method uses just the first 10
		 * rows of data for performance reasons.
		 * </p>
		 * @param dg Data grid to perform operations on.
		 * @param bolExpand Boolean to determine what to use for column width.
		 */
		public function optimiseGridColumns(dg:DataGrid, bolExpand:Boolean):void
		{
			var dgCol:DataGridColumn;
			var renderer:UITextField;
			var tf:TextFormat;
			var col:int;
			if (dg.columnCount > 0 && dg.dataProvider != null)
			{
				// initialize widths array
				var widths:Array = new Array(dg.columnCount);
				for (col = 0; col < widths.length; ++col)
				{
					widths[col] = -1;
				}
				var intCountMax:int = dg.dataProvider.length;
				if (intCountMax > 10)
					intCountMax = 10; // it takes too long to search all rows set max to 10 or row count.
				var intRowCount:int = 0;
				// go through each data item in the grid, estimate
				// the width of the text in pixels
				for each (var item:Object in dg.dataProvider)
				{
					intRowCount++;
					if (intRowCount <= intCountMax)
					{
						for (col = 0; col < widths.length; ++col)
						{
							renderer = new DataGridItemRenderer();
							// Must add to datagrid as child so that it inherits
							// properties essential for text width estimation,
							// such as font size
							dg.addChild(renderer);

							dgCol = dg.columns[col] as DataGridColumn;
							renderer.text = dgCol.itemToLabel(item);
							widths[col] = Math.max(renderer.measuredWidth + 10, widths[col]);

							// remove renderer from datagrid when we're done
							dg.removeChild(renderer);
						}
					}
				}
				if (bolExpand)
				{
					// go through headers in the grid, estimate the width of
					// the text in pixels, assuming the text is bold
					for (col = 0; col < widths.length; ++col)
					{
						// it's ok to reuse renderer, but I chose not
						// to for safety reasons. Optimize if needed.
						renderer = new DataGridItemRenderer();

						// Must add to datagrid as child so that it inherits
						// properties essential for text width estimation,
						// such as font size
						dg.addChild(renderer);

						dgCol = dg.columns[col] as DataGridColumn;
						renderer.text = dgCol.headerText;

						tf = renderer.getTextFormat();
						tf.bold = true;
						renderer.setTextFormat(tf);

						widths[col] = Math.max(renderer.measuredWidth + 25, widths[col]);

						// remove renderer from datagrid when we're done
						dg.removeChild(renderer);
					}
				}

				// set width of columns to determined values
				for (col = 0; col < widths.length; ++col)
				{
					if (widths[col] != -1)
					{
						dg.columns[col].width = widths[col];
					}
				}
			}
		}

		/**
		 *
		 * cloneArrayCollection - This method will return an array collection,
		 * 					 	  that is an exact copy of another arraycollection
		 * 						  that does not share the same address space.
		 *
		 * @param acIn ArrayCollection to process.
		 * @return processed ArrayCollection.
		 *
		 */
		public function cloneArrayCollection(acIn:ArrayCollection):ArrayCollection
		{
			var acTemp:ArrayCollection = new ArrayCollection;
			for each (var item:Object in acIn)
			{
				acTemp.addItem(item);
			}
			return acTemp;
		}

		/**
		 *
		 * proxyCollection - This method will return an process an array collection,
		 * 					 so that its values can be used in mxml objects without the
		 * 					 "unable to bind property" error.
		 *
		 * @param acIn ArrayCollection to process.
		 * @return processed ArrayCollection.
		 *
		 */
		public function proxyCollection(acIn:ArrayCollection):ArrayCollection
		{
			var aryTemp:Array = new Array();
			for (var objRow:Object in acIn)
			{
				aryTemp[objRow] = new ObjectProxy(acIn[objRow]);
			}
			return new ArrayCollection(aryTemp);
		}
		
		/**
		 * Pad a string zeroes of choice to the left.
		 * 
		 * @param InString String to pad.
		 * @param OutLen Size of output string.
		 * @return string padded. 
		 */
		public function zeroPad( InString:String, OutLen:int):String
		{
			return PadStr( InString, "0", OutLen, "LEFT" )
		}
		
		/**
		 * Pad a string with your character of choice to the left.
		 * 
		 * @param InString String to pad.
		 * @param PadChar String to pad with, commonly zero or space.
		 * @param OutLen Size of output string.
		 * @return string padded. 
		 */
		public function lPad( InString:String, PadChar:String, OutLen:int):String
		{
			return PadStr( InString, PadChar, OutLen, "LEFT" )
		}
		
		/**
		 * Pad a string with your character of choice to the right.
		 * 
		 * @param InString String to pad.
		 * @param PadChar String to pad with, commonly zero or space.
		 * @param OutLen Size of output string.
		 * @return string padded. 
		 */
		public function rPad( InString:String, PadChar:String, OutLen:int):String
		{
			return PadStr( InString, PadChar, OutLen, "RIGHT" )
		}
		
		/**
		 * Pad a string with your character of choice either on the left or right
		 * 
		 * @param InString String to pad.
		 * @param PadChar String to pad with, commonly zero or space.
		 * @param OutLen Size of output string.
		 * @return string padded. 
		 */
		public function PadStr( InString:String, PadChar:String, OutLen:int, RightLeft:String ):String
		{
		    var WrkString:String = new String(InString);
			if (WrkString.length >= OutLen) return WrkString;
			var PadString:String = new String(PadChar);
			for (var i:int=1; PadString.length < (OutLen - WrkString.length); i++)
			{
			    PadString += PadChar;
			}
			if (RightLeft.toUpperCase() == "RIGHT")
			{
			    WrkString += PadString;
				return WrkString;
			}
			else
			{
				WrkString = PadString  + WrkString;
				return WrkString;
			}
		}

	}
}