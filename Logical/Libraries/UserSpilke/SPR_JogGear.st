(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_JogGear.st
 * Author: knausenbergl
 * Created: December 21, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Gear in and update the gear ratio as long as the Jog input is set </$Description$>*)
FUNCTION_BLOCK SPR_JogGear
	
	IS.R_TRIG_Jog.CLK	:= Jog;
	IS.R_TRIG_Jog();
	
	IS.MC_ReadStatus_0.Axis := Slave;
	IS.MC_ReadStatus_0.Enable := TRUE;
	IS.MC_ReadStatus_0();
	
	IS.GearRatioChanged	:= 
	(RatioNumerator <> IS.MC_GearIn_0.RatioNumerator) 
	OR (RatioDenominator <> IS.MC_GearIn_0.RatioDenominator);
	
	CASE IS.State OF
		
		//***************	IDLE	***************
		0:
			IF (IS.R_TRIG_Jog.Q) THEN
				IS.MC_GearIn_0.Acceleration				:= Acceleration;
				IS.MC_GearIn_0.Deceleration				:= Deceleration;
				IS.MC_GearIn_0.MasterParID				:= MasterParID;
				IS.MC_GearIn_0.MasterParIDMaxVelocity	:= MasterParIDMaxVelocity;
				IS.MC_GearIn_0.RatioDenominator			:= RatioDenominator;
				IS.MC_GearIn_0.RatioNumerator			:= RatioNumerator;
				IS.MC_GearIn_0.Execute		:= TRUE;
				IS.State	:= 1;
			END_IF;
			
		//***************	GEARING IN	***************
		1:		
			//error in gear FUB
			IF (IS.MC_GearIn_0.Error) THEN
				Error		:= TRUE;
				ErrorID		:= IS.MC_GearIn_0.ErrorID;
				IS.State	:= 255;
			//gear aborted by FUB other than halt	
			ELSIF (IS.MC_GearIn_0.CommandAborted) THEN
				CommandAborted	:= TRUE;	
				IS.State		:= 254;
			//trigger halt command	
			ELSIF (NOT Jog) THEN
				IS.MC_Halt_0.Deceleration	:= Deceleration;
				IS.State	:= 3;
			//change gear ratio	
			ELSIF (IS.GearRatioChanged) THEN
				IS.MC_GearIn_0.Execute	:= FALSE;
				IS.State	:= 100;
			//everything ok	
			ELSIF (IS.MC_GearIn_0.InGear) THEN
				IS.State	:= 2;
			END_IF;
			
		//***************	IN GEAR	***************
		2:
			//error in gear FUB
			IF (IS.MC_GearIn_0.Error) THEN
				Error		:= TRUE;
				ErrorID		:= IS.MC_GearIn_0.ErrorID;
				IS.State	:= 255;
			//gear aborted by FUB other than halt	
			ELSIF (IS.MC_GearIn_0.CommandAborted) THEN
				CommandAborted	:= TRUE;
				IS.State	:= 254;
			//trigger halt command	
			ELSIF (NOT Jog) THEN
				IS.MC_Halt_0.Deceleration	:= Acceleration;		
				IS.State	:= 3;
			//change gear ratio
			ELSIF (IS.GearRatioChanged) THEN
				IS.MC_GearIn_0.Execute	:= FALSE;
				IS.State				:= 100;
			END_IF;
			
		//***************	TRIGGER HALT	***************
		3:	
			//error in gear FUB
			IF (IS.MC_GearIn_0.Error) THEN
				Error		:= TRUE;
				ErrorID		:= IS.MC_GearIn_0.ErrorID;
				IS.State	:= 255;
			//gear aborted by FUB other than halt
			ELSIF (IS.MC_GearIn_0.CommandAborted) THEN
				CommandAborted	:= TRUE;
				IS.State		:= 254;
			//ok to trigger halt command	
			ELSE
				IS.MC_GearIn_0.Execute	:= FALSE;
				IF ( IS.MC_ReadStatus_0.DiscreteMotion OR IS.MC_ReadStatus_0.ContinuousMotion OR IS.MC_ReadStatus_0.SynchronizedMotion ) THEN
					IS.MC_Halt_0.Execute	:= TRUE;
				ELSE
				END_IF	
				IS.State	:= 254;
			END_IF;
		
		//***************	HALTING	***************
		4:
			//error in halt FUB
			IF (IS.MC_Halt_0.Error) THEN
				Error		:= TRUE;
				ErrorID		:= IS.MC_Halt_0.ErrorID;
				IS.State	:= 255;
			//halt FUB aborted	
			ELSIF (IS.MC_Halt_0.CommandAborted) THEN
				CommandAborted	:= TRUE;
				IS.State		:= 254;
			//everything OK, axis in standstill
			ELSIF (IS.MC_Halt_0.Done) THEN
				IS.State	:= 0;
			END_IF;
		
		//***************	CHANGE GEAR RATIO	***************
		100:
			IS.MC_GearIn_0.Acceleration				:= Acceleration;
			IS.MC_GearIn_0.Deceleration				:= Deceleration;
			IS.MC_GearIn_0.MasterParID				:= MasterParID;
			IS.MC_GearIn_0.MasterParIDMaxVelocity	:= MasterParIDMaxVelocity;
			IS.MC_GearIn_0.RatioDenominator			:= RatioDenominator;
			IS.MC_GearIn_0.RatioNumerator			:= RatioNumerator;
			IS.MC_GearIn_0.Execute	:= TRUE;
			IS.State	:= 1;
		
			//error in gear FUB
			IF (IS.MC_GearIn_0.Error) THEN
				Error		:= TRUE;
				ErrorID		:= IS.MC_GearIn_0.ErrorID;
				IS.State	:= 255;
			//gear aborted by FUB other than halt
			ELSIF (IS.MC_GearIn_0.CommandAborted) THEN
				IS.MC_GearIn_0.Execute	:= FALSE;
				CommandAborted			:= TRUE;
				IS.State	:= 254;
			//trigger halt command	
			ELSIF (NOT Jog) THEN
				IS.MC_Halt_0.Deceleration	:= Acceleration;
				IS.State	:= 3;
			END_IF;
		
		//***************	COMMAND ABORTED	***************
		254:
			//FUB reset, go back to init state
			IF (NOT Jog) THEN
				IS.MC_GearIn_0.Execute	:= FALSE;
				IS.MC_Halt_0.Execute	:= FALSE;
				CommandAborted			:= FALSE;
				IS.State	:= 0;
			END_IF;
			
		//***************	ERROR	***************
		255:
			//FUB reset, go back to init state
			IF (NOT Jog) THEN
				IS.MC_GearIn_0.Execute	:= FALSE;
				IS.MC_Halt_0.Execute	:= FALSE;
				Error		:= FALSE;
				ErrorID		:= ERR_OK;
				IS.State	:= 0;
			END_IF;
		
	END_CASE	
	
	IS.MC_GearIn_0.Slave	:= Slave;
	IS.MC_GearIn_0.Master	:= Master;
	IS.MC_GearIn_0();
	
	IS.MC_Halt_0.Axis	:= Slave;
	IS.MC_Halt_0();
	
	Busy	:= IS.MC_GearIn_0.Busy OR IS.MC_Halt_0.Busy;
	Halting	:= IS.MC_Halt_0.Busy;
	InGear	:= IS.MC_GearIn_0.InGear;
	
END_FUNCTION_BLOCK