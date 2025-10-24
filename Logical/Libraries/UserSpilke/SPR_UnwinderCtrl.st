(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_UnwinderCtrl.st
 * Author: knausenbergl
 * Created: December 15, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Controls an unwinder with a magnet particle brake </$Description$>*)
FUNCTION_BLOCK SPR_UnwinderCtrl
	
	CASE State OF
		
		//********************	DISABLED	********************
		0:
			IF (Enable) THEN
				State	:= 1;
			END_IF;
		
		//********************	ACTIVE	********************
		1:
			IF (NOT Enable) THEN
				State	:= 0;
			ELSIF ( (WNCPidCtrl_0.status >= 34350) AND (WNCPidCtrl_0.status <= 34449) ) THEN
				State	:= 2;
			END_IF;
		
		//********************	ERROR	********************
		2:	
			IF (NOT Enable) THEN
				State	:= 0;
			END_IF;
		
	END_CASE;
	
	
	
END_FUNCTION_BLOCK