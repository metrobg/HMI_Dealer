package com.Utils
{

    /**
     * Contains reuseable methods related to characters
     */
    public class CharacterUtils
    {
        /**
         * Checks to see if a string is a single character
         *
         * @param ch The string to test against
         * @return true if ch is a character, false otherwise
         */
        public static function isCharacter(ch:String):Boolean
        {
            // A character is defined as a string having length of
            // exactly 1.
            if (ch.length != 1)
                return false;
            return true;
        }

        /**
         * Determines if a character is lowercase or not
         *
         * @param ch The string to test against
         * @return true if ch is a lowercase character, false otherwise
         */
        public static function isLowerCase(ch:String):Boolean
        {
            // make sure that ch is a character first
            if (!isCharacter(ch))
                return false;
            // check for ch being between 'a' and 'z' inclusive
            if (ch >= 'a' && ch <= 'z')
                return true;
            // not a lowercase character
            return false;
        }

        /**
         * Determines if a character is uppercase or not
         *
         * @param ch The string to test against
         * @return true if ch is a uppercase character, false otherwise
         */
        public static function isUpperCase(ch:String):Boolean
        {
            // make sure that ch is a character first
            if (!isCharacter(ch))
                return false;
            // check for ch being between 'A' and 'Z' inclusive
            if (ch >= 'A' && ch <= 'Z')
                return true;
            // not an uppercase character
            return false;
        }

        /**
         * Determines if a character is a digit or not
         *
         * @param ch The string to test against
         * @return true if ch is a digit character, false otherwise
         */
        public static function isDigit(ch:String, signed:Boolean, decimal:Boolean):Boolean
        {
            // make sure that ch is a character first
            if (!isCharacter(ch))
                return false;
            // check for ch being between '0' and '9' inclusive
            if (ch >= '0' && ch <= '9')
                return true;
            if ((signed && (ch == '-')) || (decimal && (ch == '.')))
                return true;
            // not a numeric character
            return false;
        }

        /**
         * Determines if a character is in list
         *
         * @param ch The string to test.
         * @param strList The string to test against.
         * @return true if ch is in strList, false otherwise
         */
        public static function isValid(ch:String, strList:String):Boolean
        {
            // make sure that ch is a character first
            if (!isCharacter(ch))
                return false;
            // check for ch being in the list of valid characters
            if (strList.indexOf(ch) >= 0)
                return true;
            // not a digit character
            return false;
        }
    }
}