FUNCTION_BLOCK ConvertHex
(* Implementation of ConvertHex *)

(**********************************************************************************************************************)
(* Object name: ConvertHex                                                                                                                              	*)
(* Author:      Christoph Trappl,  B&R                                                                                                               	*)
(* Site:        Eggelsberg                                                                                                                             	*)
(* Created:     27-aug-2003                                                                                                                           	*)
(* Restriction: -----                                                                                                                          	*)
(* Description: Converts a decimal value to hexadecimal ASCII                                                                                                                                	*)
(*                                                                                                                                                              	*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Version 1.00.1   27-aug-2003  Christoph Trappl								*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Version 1.00.2   02-feb-2004  Peter Hauser									*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Development tool: B&R Automation Studio V2.3.0.9 							*)
(*----------------------------------------------------------------------------------------------------------------------------------------	*)
(* Comment:                                                                                                                     			*)
(**********************************************************************************************************************)


(* Execute Functionblock when enable = true *)
IF (Enable = 1) THEN

//210812,TB: CONSTANT EXECUTION_BUSY replaced	by standard
//	Status := EXECUTION_BUSY;
	Status := ERR_FUB_BUSY;

	(* reset the complete memory area, that will be overwritten during the function execution *)
	memset(pHexValue, 0, SIZEOF(HexASCII));

	HexASCII[0]:= 0;
	HexASCII[1]:= 0;
	HexASCII[2]:= 0;
	HexASCII[3]:= 0;
	HexASCII[4]:= 0;
	HexASCII[5]:= 0;
	HexASCII[6]:= 0;
	HexASCII[7]:= 0;

	IF SizeDecValue = 0 THEN
		IF (DecValue > 16#FFFFFFF)  THEN
			Index:= 7;
		ELSIF (DecValue > 16#FFFFFF) THEN
			Index:= 6;
		ELSIF (DecValue > 16#FFFFF) THEN
			Index:= 5;
		ELSIF (DecValue > 16#FFFF) THEN
			Index:= 4;
		ELSIF (DecValue > 16#FFF) THEN
			Index:= 3;
		ELSIF (DecValue > 16#FF) THEN
			Index:= 2;
		ELSIF (DecValue > 16#F) THEN
			Index:= 1;
		ELSE
			Index:= 0;
		END_IF
	ELSIF SizeDecValue = 1 THEN
		Index:= 1;
	ELSIF SizeDecValue = 2 THEN
		Index:= 3;
	ELSIF SizeDecValue = 4 THEN
		Index:= 7;
	END_IF

	REPEAT
		IF DecValue > 0 OR SizeDecValue > 0 THEN
			End:= 0;
			Rest:= DecValue MOD HEX_BASE;
			DecValue:= DecValue / HEX_BASE;

			IF ( (Rest >= 0) AND (Rest <= 9) ) THEN
				HexASCII[Index]:= UDINT_TO_USINT((48 + Rest));
			ELSE
				HexASCII[Index]:= UDINT_TO_USINT((55 + Rest));
			END_IF

			Index:= Index - 1;
		END_IF

		IF (DecValue = 0 AND SizeDecValue = 0) OR Index < 0 THEN
			Index:= 0;
			End:= 1;
		END_IF
	UNTIL
		End = 1
	END_REPEAT;

	memcpy(pHexValue, ADR(HexASCII), SIZEOF(HexASCII));
//210812,TB: CONSTANT EXECUTION_OK replaced	by standard
//	Status := EXECUTION_OK;
	Status := ERR_OK;
ELSE
	Status:= ENABLE_NOT_SET;
END_IF





END_FUNCTION_BLOCK
