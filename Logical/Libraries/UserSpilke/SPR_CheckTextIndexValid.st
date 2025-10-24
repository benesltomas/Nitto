(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_CheckTextIndexValid.st
 * Author: knausenbergl
 * Created: November 23, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Checks if a textgroup index exists </$Description$>*)
FUNCTION_BLOCK SPR_CheckTextIndexValid
	
	Status	:= VA_Saccess(Enable, VCHandle);
	IF (Status = ERR_OK) THEN
		TextLength	:= SIZEOF(Text);
		Status		:= VA_GetTextByTextGroup(TRUE, VCHandle, TG_id, TGT_id, ADR(Text), ADR(TextLength) );
		Valid		:= (Status = ERR_OK);
		VA_Srelease(TRUE, VCHandle);
	ELSE
		Valid	:= FALSE;
	END_IF;
	
END_FUNCTION_BLOCK