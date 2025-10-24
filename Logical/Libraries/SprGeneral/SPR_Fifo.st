(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: Fifo
 * File: Fifo.st
 * Author: knausenbergl
 * Created: October 19, 2012
 ********************************************************************
 * Implementation of library Fifo
 ********************************************************************) 

(*<$Description$> Implementation of a DINT Fifo </$Description$>*)
FUNCTION_BLOCK SPR_Fifo
	MaxElements	:= SIZEOF(Value)/SIZEOF(Value[0]);
	
	//reset FIFO
	IF (Reset > Reset_1) THEN
		memset(ADR(Value), 0, SIZEOF(Value) );
		AddIndex	:= 0;
		RemoveIndex	:= 0;
		ActElements	:= 0;
	END_IF;
	Reset_1	:= Reset;
	
	//remove value from FIFO
	IF (Remove > Remove_1) THEN
		IF (ActElements >= 1) THEN
			Value[RemoveIndex]	:= 0;
			RemoveIndex			:= UINT_TO_USINT( (RemoveIndex + 1) MOD MaxElements);
			ActElements			:= ActElements - 1;
		END_IF;	
	END_IF;
	Remove_1	:= Remove;
	
	//add value to FIFO
	IF (Add > Add_1) THEN
		IF (ActElements < MaxElements) THEN
			Value[AddIndex]		:= InValue;
			AddIndex			:= UINT_TO_USINT( (AddIndex + 1) MOD MaxElements);
			ActElements			:= ActElements + 1;
		ELSE				
		END_IF;	
	END_IF;
	Add_1	:= Add;
	
	OutValue	:= Value[RemoveIndex];
	Full		:= (ActElements >= MaxElements);
	
END_FUNCTION_BLOCK