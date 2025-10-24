(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: HlpStr
 * File: HlpStr.fun
 * Author: beutert
 * Created: May 21, 2010
 ********************************************************************
 * Functions and function blocks of library HlpStr
 ********************************************************************)

FUNCTION findstr : UINT (*find a specified string in a given string*)
	VAR_INPUT
		IN1 : STRING[1000];
		IN2 : STRING[80];
		StartPos : UINT;
	END_VAR
	VAR
		ReturnVal : UINT;
		Str2 : STRING[1000];
		wStrLen : UINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK findchar (*find a specified character in a given string*)
	VAR_INPUT
		enable : BOOL;
		pString : UDINT;
		Char : USINT;
		StartPos : UINT;
	END_VAR
	VAR_OUTPUT
		CharPos : UINT;
		status : UINT;
	END_VAR
	VAR
		ptByte_a : REFERENCE TO ARRAY[0..999] OF USINT;
		wStrLen : UINT;
		CharFound : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION LTRIM : UINT (*delete blanks at beginning of string*)
	VAR_INPUT
		enable : BOOL;
		pString : UDINT;
	END_VAR
	VAR
		status : UINT;
		szHlpStr1 : STRING[1000];
		wStrLen : UINT;
		pByte : REFERENCE TO USINT;
		wStrLenHlp : UINT;
	END_VAR
END_FUNCTION

FUNCTION l2str : UINT (*convert an UDINT value to string*)
	VAR_INPUT
		value : UDINT;
		pString : UDINT;
	END_VAR
	VAR
		lRest : UDINT;
		ii : USINT;
		lDivisor : UDINT;
		lQuot : UDINT;
		szQuot : STRING[80];
	END_VAR
END_FUNCTION

FUNCTION RTRIM : UINT (*TODO: Add your comment here*)
	VAR_INPUT
		enable : BOOL;
		pString : UDINT;
	END_VAR
	VAR
		status : UINT;
		szHlpStr1 : STRING[1000];
		wStrLen : UINT;
		pByte : REFERENCE TO USINT;
		wStrLenHlp : UINT;
		bDbg : USINT;
	END_VAR
END_FUNCTION

FUNCTION TRIM : UINT (*TODO: Add your comment here*)
	VAR_INPUT
		enable : BOOL;
		pString : UDINT;
	END_VAR
	VAR
		status : UINT;
	END_VAR
END_FUNCTION
