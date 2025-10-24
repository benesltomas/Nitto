(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprGeneral
 * File: SPR_Mux.st
 * Author: knausenbergl
 * Created: January 02, 2013
 ********************************************************************
 * Implementation of library SprGeneral
 ********************************************************************) 

(*<$Description$> Multiplexes pointers of any datatype </$Description$>*)
FUNCTION_BLOCK SPR_Mux
	
	C_Selector	:= LIMIT(0, Selector, (SIZEOF(pIn) / SIZEOF(pIn[0]) - 1) );
	
	IF (pIn[C_Selector] <> 0) THEN
		memcpy(ADR(Out_UDINT), pIn[C_Selector], SIZEOF(Out_UDINT) );
		memcpy(ADR(Out_DINT), pIn[C_Selector], SIZEOF(Out_DINT) );
		memcpy(ADR(Out_REAL), pIn[C_Selector], SIZEOF(Out_REAL) );
		memcpy(ADR(Out_BOOL), pIn[C_Selector], SIZEOF(Out_BOOL) );
		memcpy(ADR(Out_USINT), pIn[C_Selector], SIZEOF(Out_USINT) );
		memcpy(ADR(Out_INT), pIn[C_Selector], SIZEOF(Out_INT) );
		memcpy(ADR(Out_UINT), pIn[C_Selector], SIZEOF(Out_UINT) );
	END_IF;	
	
END_FUNCTION_BLOCK