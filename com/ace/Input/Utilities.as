package com.ace.Input
{
    import com.metrobg.Components.VAComboBox;
    import mx.containers.Canvas;
    import mx.containers.ControlBar;
    import mx.containers.FormItem;
    import mx.containers.Grid;
    import mx.containers.GridItem;
    import mx.containers.GridRow;
    import mx.containers.HBox;
    import mx.containers.Panel;
    import mx.containers.TabNavigator;
    import mx.containers.TitleWindow;
    import mx.containers.VBox;
    import mx.controls.DataGrid;
    import mx.controls.Text;

    /**
     * Utilities is a group of methods used to work with Validated input fields within
     * a container.
     */
    public class Utilities
    {
        /**
         * ValidateAll will loop through all children of the object passed looking for
         * ValidatedTextInput objects. It fires the ValidateData method on each one
         * and checks the isValid property to determine if there are errors in the data.
         *
         * If one or more errors exist it returns false. If all
         * fields have valid data it returns true.
         *
         * @param object Container of fields. Canvas, Box, etc. containing one or more
         * validated input type fields, such as ValidatedTextInput, ValidatedDateField, etc.
         */
        public static function validateAll(object:Object):Boolean
        {
            var bolAllValid:Boolean = true;
            var bolTemp:Boolean;
            for each (var field:Object in object.getChildren())
            {
                if (field is ValidatedTextInput || field is ValidatedDateField || field is VAComboBox || field is ValidatedComboBox || field is ValidatedTextArea || field is ValidatedRadioButtonBox)
                {
                    bolTemp = field.validateData();
                    if (bolTemp)
                        bolTemp = field.isValid;
                    if (bolAllValid)
                        bolAllValid = bolTemp;
                }
//				if (field["id"]) trace('field["id"]=' + field["id"] + "|bolTemp=" + bolTemp + '|bolAllValid=' + bolAllValid);
                if (isContainer(field))
                {
                    bolTemp = validateAll(field);
                    if (bolAllValid)
                        bolAllValid = bolTemp;
                }
            }
            return bolAllValid;
        }

        /**
         * setQueryAll - This method will allow percent and undescore characters to be type for all
         * fields in and object, if there the field has a restricted character set.
         * Its purpose is to allow the wildcard characters used by oracle "like" statements.
         *
         * @param object Container of fields. Canvas, Box, etc. containing one or more
         * validated input type fields, such as ValidatedTextInput, ValidatedDateField, etc.
         * @param objRestrict Is a variable used during recursion to temporarily hold
         * charactersAlsoPermitted for all validated fields that contained charactersAlsoPermitted.
         * @param queryFields Comma delimited list of fields to allow query entry on. If
         * empty, all fields are allowed to build query.
         * @return Object to hold charactersAlsoPermitted for all validated fields that contained
         * charactersAlsoPermitted.
         */
        public static function setQueryAll(object:Object, objRestrict:Object, queryFields:String):Object
        {
            var strQueryFields:String = "," + queryFields + ",";
            if (!objRestrict)
                objRestrict = new Object;
            for each (var field:Object in object.getChildren())
            {
                if (field is ValidatedTextInput || field is ValidatedDateField || field is ValidatedTextArea)
                {
                    objRestrict[field["id"]] = field["charactersAlsoPermitted"];
                    if (field["charactersAlsoPermitted"].toString().indexOf("_%><=") < 0)
                        field["charactersAlsoPermitted"] += "_%><=";
                    if (field["editable"] == false)
                        field["editable"] = true;
                    if (field["enabled"] == false)
                        field["enabled"] = true;
                    if (!(field is ValidatedTextArea))
                        field["formatData"] = false;
                    field["doValidateData"] = false;
                }
                if (field is ValidatedComboBox || field is ValidatedRadioButtonBox)
                {
                    if (field["enabled"] == false)
                        field["enabled"] = true;
                    field["doValidateData"] = false;
                }
                if (field is Text)
                    field["text"] = "";
                /* if ((field is LOV || field is GeneralLOV) && field["enabled"] == false)
                   {
                   field["enabled"] = true;
                 }   GG */
                if (queryFields.length > 0)
                {
                    if (field is ValidatedTextInput || field is ValidatedDateField || field is ValidatedTextArea || field is ValidatedComboBox || field is ValidatedRadioButtonBox)
                    {
                        if (strQueryFields.indexOf("," + field["id"] + ",") < 0)
                        {
                            field["enabled"] = false;
                            if (field.hasOwnProperty("editable"))
                                field["editable"] = false;
                        }
                    }
                }
                if (field is ValidatedCheckBox)
                {
                    field["enabled"] = false;
                }
                if (isContainer(field))
                {
                    objRestrict = setQueryAll(field, objRestrict, queryFields);
                }
            }
            return objRestrict;
        }

        /**
         * clearAll - This method will set all Validated objects to blanks.
         *
         * @param object Container of fields. Canvas, Box, etc. containing one or more
         * validated input type fields, such as ValidatedTextInput, ValidatedDateField, etc.
         **/
        public static function clearAll(object:Object):void
        {
            for each (var field:Object in object.getChildren())
            {
                if (field is ValidatedTextInput || field is ValidatedDateField || field is ValidatedTextArea)
                {
                    field["enabled"] = true;
                    field["editable"] = true;
                    field["text"] = "";
                    field["errorString"] = "";
                }
                if (field is VAComboBox)
                {
                    field["selectedIndex"] = 0;
                }
                if (field is ValidatedComboBox || field is ValidatedCheckBox || field is ValidatedRadioButtonBox)
                {
                    field["value"] = "";
                    field["errorString"] = "";
                    if (field["enabled"] == false)
                        field["enabled"] = true;
                    if (field is ValidatedComboBox)
                        if (field["editable"] == true)
                            field["editable"] = false;
                    if (field is ValidatedComboBox)
                        field["selectedIndex"] = 0;
                }
                if (field is Text)
                    field["text"] = "";
                if (field is DataGrid)
                {
                    field["dataProvider"] = null;
                }
                if (isContainer(field))
                {
                    clearAll(field);
                }
            }
        }

        /**
         * setDefaultAll - This method will set all Validated objects contained in the
         * object passed to their default value.
         *
         * @param object Container of fields. Canvas, Box, etc. containing one or more
         * validated input type fields, such as ValidatedTextInput, ValidatedDateField, etc.
         */
        public static function setDefaultAll(object:Object):void
        {
            for each (var field:Object in object.getChildren())
            {
                if (field is ValidatedTextInput || field is ValidatedDateField || field is ValidatedTextArea || field is ValidatedComboBox || field is ValidatedCheckBox || field is ValidatedRadioButtonBox)
                {
                    field.setDefault();
                    field["doValidateData"] = true;
                }
                if (field is Text)
                    field["text"] = "";
                if (isContainer(field))
                {
                    setDefaultAll(field);
                }
            }
        }

        /**
         * setDisabledAll - This method will set all Validated objects contained in the
         * object passed to a disabled state (enabled = false).
         *
         * @param object Container of fields. Canvas, Box, etc. containing one or more
         * validated input type fields, such as ValidatedTextInput, ValidatedDateField, etc.
         */
        public static function setDisabledAll(object:Object):void
        {
            for each (var field:Object in object.getChildren())
            {
                if (field is ValidatedTextInput || field is ValidatedTextArea)
                {
                    field["enabled"] = true;
                    field["editable"] = false;
                }
                if (field is ValidatedComboBox || field is ValidatedCheckBox || field is VAComboBox || field is ValidatedRadioButtonBox || field is ValidatedDateField)
                {
                    field["enabled"] = false;
                }
                if (isContainer(field))
                {
                    setDisabledAll(field);
                }
            }
        }

        /**
         * isContainer - This method is used to determine if an object is a container.
         */
        private static function isContainer(obj:Object):Boolean
        {
            return (obj is Canvas || obj is FormItem || obj is TabNavigator || obj is HBox || obj is VBox || obj is Panel || obj is TitleWindow || obj is ControlBar || obj is Grid || obj is GridRow || obj is GridItem);
        }
    }
}