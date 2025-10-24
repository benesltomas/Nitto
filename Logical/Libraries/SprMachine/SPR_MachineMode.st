(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprMachine
 * File: SPR_MachineMode.st
 * Author: knausenbergl
 * Created: January 02, 2013
 ********************************************************************
 * Implementation of library SprMachine
 ********************************************************************) 

(*<$Description$> Selects the machine mode </$Description$>*)
FUNCTION_BLOCK SPR_MachineMode
	
	R_TRIG_TriggerAutoMode.CLK	:= TriggerAutoMode;
	R_TRIG_TriggerAutoMode();
	
	R_TRIG_TriggerManualMode.CLK	:= TriggerManualMode;
	R_TRIG_TriggerManualMode();
	
	CASE MachineMode OF
		
		//MANUAL MODE
		0:
			IF (AxesInStandstill AND (R_TRIG_TriggerAutoMode.Q AND NOT R_TRIG_TriggerManualMode.Q) ) THEN
				MachineMode	:= 1;
			END_IF;	
		
		//AUTO MODE
		1:	
			IF (MasterInStandstill AND (R_TRIG_TriggerManualMode.Q AND NOT R_TRIG_TriggerAutoMode.Q) ) THEN
				MachineMode	:= 0;
			END_IF;	
			
		//UNDEFINED, ERROR
		255:	
			
		ELSE
			MachineMode	:= 255;
		
	END_CASE;
	
	ManualModeActive	:= (MachineMode = 0);
	AutoModeActive		:= (MachineMode = 1);
	
END_FUNCTION_BLOCK