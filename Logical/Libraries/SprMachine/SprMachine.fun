(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprMachine
 * File: SprMachine.fun
 * Author: knausenbergl
 * Created: December 21, 2012
 ********************************************************************
 * Functions and function blocks of library SprMachine
 ********************************************************************)

FUNCTION_BLOCK SPR_MachinePower (*Power on/off drives*)
	VAR_INPUT
		SwitchOn : BOOL; (*Command to switch on power*)
		SwitchOff : BOOL; (*Command to switch off power*)
		SafetyOk : BOOL; (*Safety OK, no EStop requested*)
		SwitchOffDelay : TIME; (*Delay for switching off 24V control voltage e.g. in the case of an EStop*)
		AutoModeActive : BOOL; (*Machine in automatic mode*)
		MasterInStandstill : BOOL; (*Master axis standing still (state Standstill OR Errorstop)*)
	END_VAR
	VAR_OUTPUT
		EStopMaster : BOOL; (*Emergency stop master axis*)
		ControlVoltage : BOOL; (*Connected to digital output for 24V control voltage *)
		Release : BOOL; (*Release for MC_Power function blocks*)
	END_VAR
	VAR
		State : emuSprMachine_PowerState;
		R_TRIG_SwitchOn : R_TRIG;
		TOF_ControlVoltage : TOF;
		EStopRequest : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_MachineMode (*Selects the machine mode*)
	VAR_INPUT
		AxesInStandstill : BOOL; (*all axes in standstill*)
		MasterInStandstill : BOOL; (*master axis in standstill*)
		TriggerAutoMode : BOOL; (*positive edge triggers a transition to auto mode if all axes are in standstill*)
		TriggerManualMode : BOOL; (*positive edge triggers a transition to manual mode if master is in standstill*)
	END_VAR
	VAR_OUTPUT
		ManualModeActive : BOOL;
		AutoModeActive : BOOL;
	END_VAR
	VAR
		MachineMode : USINT;
		R_TRIG_TriggerAutoMode : R_TRIG;
		R_TRIG_TriggerManualMode : R_TRIG;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_BatchProduction (*Triggers a reduction of the master velocity and stop of master when the end of a batch is reached*)
	VAR_INPUT
		Enable : BOOL; (*enable batch production*)
		ActVelocity : REAL; (*actual master velocity [Master Units / s]*)
		Deceleration : REAL; (*master deceleration [Master Units / s²]*)
		ActProductCount : UDINT; (*actual product count*)
		SetProductCount : UDINT; (*target product count*)
		ProductLength : REAL; (*product length [Master Units]*)
		DistanceAtReducedVel : REAL; (*distance to be travelled with reduced velocity [Master Units]*)
	END_VAR
	VAR_OUTPUT
		BatchComplete : BOOL; (*target product count reached, batch complete*)
		ReduceVelocity : BOOL; (*end of batch almost reached, reduce velocity*)
	END_VAR
	VAR
		StoppingDistance : REAL; (*braking distance to reach standstill at actual velocity*)
		RemainingDistance : REAL; (*remaining distance in batch*)
		DeltaCount : DINT; (*SetProductCount - ActProductCount*)
		State : USINT;
	END_VAR
END_FUNCTION_BLOCK
