(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprMachine
 * File: SprMachine.typ
 * Author: knausenbergl
 * Created: December 21, 2012
 ********************************************************************
 * Data types of library SprMachine
 ********************************************************************)

TYPE
	emuSprMachine_PowerState : 
		(
		SPR_MACH_PWR_DISABLED,
		SPR_MACH_PWR_ENABLED,
		SPR_MACH_PWR_ESTOP_AUTO,
		SPR_MACH_PWR_DELAY_24V_OFF,
		SPR_MACH_PWR_ERROR
		);
END_TYPE
