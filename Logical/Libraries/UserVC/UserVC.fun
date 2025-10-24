
FUNCTION_BLOCK Sort
	VAR_INPUT
		enable : BOOL;
		pStringArray : UDINT;
		StringLen : UINT;
		ArrayLen : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		xcnt : UINT;
		ycnt : UINT;
		StepCounter : UINT;
		SortStep : USINT;
		FileNameBuffer : STRING[80];
		pChar1 : REFERENCE TO USINT;
		pChar2 : REFERENCE TO USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ConvertHex
	VAR_INPUT
		Enable : BOOL;
		pHexValue : UDINT;
		DecValue : UDINT;
		SizeDecValue : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		HexASCII : ARRAY[0..7] OF USINT;
		Index : SINT;
		End : USINT;
		Rest : UDINT;
	END_VAR
END_FUNCTION_BLOCK
