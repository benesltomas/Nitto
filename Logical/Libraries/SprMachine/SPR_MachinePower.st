(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_MachinePower.st
 * Author: knausenbergl
 * Created: December 13, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Indicates status of machine control voltage </$Description$>*)
FUNCTION_BLOCK SPR_MachinePower
	
	R_TRIG_SwitchOn.CLK	:= SwitchOn;
	R_TRIG_SwitchOn();
	
	EStopRequest	:= NOT SafetyOk OR SwitchOff;
	
	CASE State OF
		
		//**********	DRIVES DISABLED, CONTROL VOLTAGE OFF	**********
		SPR_MACH_PWR_DISABLED:
			TOF_ControlVoltage.IN	:= FALSE;
			Release					:= FALSE;
			EStopMaster				:= TRUE;
			
			IF (NOT EStopRequest AND R_TRIG_SwitchOn.Q) THEN
				//switch on control voltage
				TOF_ControlVoltage.IN	:= TRUE;
				Release					:= TRUE;
				EStopMaster				:= FALSE;
				State	:= SPR_MACH_PWR_ENABLED;
			END_IF;	
		
		//**********	DRIVES ENABLED, CONTROL VOLTAGE ON		**********
		SPR_MACH_PWR_ENABLED:
			TOF_ControlVoltage.IN	:= TRUE;
			Release					:= TRUE;
			EStopMaster				:= FALSE;
		
			IF (EStopRequest) THEN
				//switch off control voltage (delayed)
				TOF_ControlVoltage.IN	:= FALSE;
				
				IF (AutoModeActive) THEN
					//stop master axis first if axes are running synchronized
					EStopMaster	:= TRUE;
					State		:= SPR_MACH_PWR_ESTOP_AUTO;	
				ELSE
					//disable drives
					Release			:= FALSE;
					EStopMaster		:= TRUE;
					State			:= SPR_MACH_PWR_DELAY_24V_OFF;
				END_IF;
			END_IF;
		
		//**********	ESTOP REQUESTED, MASTER STOPPING		**********
		SPR_MACH_PWR_ESTOP_AUTO:
			TOF_ControlVoltage.IN	:= FALSE;
			Release					:= TRUE;
			EStopMaster				:= TRUE;
			
			IF (NOT TOF_ControlVoltage.Q) THEN
				//timer expired, control voltage switched off
				Release	:= FALSE;
				State	:= SPR_MACH_PWR_DISABLED;
			ELSIF (MasterInStandstill) THEN
				//disable drives
				Release	:= FALSE;
				State	:= SPR_MACH_PWR_DELAY_24V_OFF;
			END_IF;
		
		//**********	DELAYED CONTROL VOLTAGE SWITCH OFF		**********
		SPR_MACH_PWR_DELAY_24V_OFF:
			TOF_ControlVoltage.IN	:= FALSE;
			Release					:= FALSE;
			EStopMaster				:= TRUE;
			
			IF (NOT TOF_ControlVoltage.Q) THEN
				//control voltage is switched off, go back to initial state
				State	:= SPR_MACH_PWR_DISABLED;
			END_IF;
		
		//**********	ERROR		**********
		SPR_MACH_PWR_ERROR:	
			TOF_ControlVoltage.IN	:= FALSE;
			Release					:= FALSE;
			EStopMaster				:= TRUE;
			
		ELSE
			TOF_ControlVoltage.IN	:= FALSE;
			Release					:= FALSE;
			EStopMaster				:= TRUE;
			State	:= SPR_MACH_PWR_ERROR;
		
	END_CASE;
	
	TOF_ControlVoltage.PT	:= SwitchOffDelay;
	TOF_ControlVoltage();
	ControlVoltage	:= TOF_ControlVoltage.Q;
	
END_FUNCTION_BLOCK