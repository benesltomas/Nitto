(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_PackBeltCtrl.st
 * Autor: okrebs
 * Erstellt: 23. November 2016
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_PackBeltCtrl
	
	PackBelt_HW;
	PackBelt_DrvIf;
	PackBelt_DiDoIf;
	
	// Initialisation
	IF firststart THEN
		pAxis ACCESS axisREF;
		
		MC_BR_JogVelocity_0.Axis := axisREF;
		MC_Power_0.Axis := axisREF;
		MC_Stop_0.Axis := axisREF;
		MC_Reset_0.Axis := axisREF;
		MC_ReadStatus_0.Axis := axisREF;
		Time_Conveyor_To_Box_s := 2;
		Range_Conveyor_To_Box := 200000;  // vorher 300000 // OKrebs // 09.09.21
		
		firststart := FALSE;
	END_IF
	
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_BR_JogVelocity_0.Acceleration	:= data.acceleration;
	MC_BR_JogVelocity_0.Deceleration	:= data.deceleration;
	TP_PowerOn(IN := Start_TP_PowerOn, PT := T#100ms); // Zeit um den Motor einzuschalten
	IF conveyor.axis.ctrl.MC_ReadActualVelocity_0.Velocity > 0 AND MC_ReadStatus_0.ContinuousMotion THEN
		Time_Conveyor_To_Box_s := (masterModul.data.periodLength + Range_Conveyor_To_Box) / conveyor.axis.ctrl.MC_ReadActualVelocity_0.Velocity; // Zeit bis der letzte Stanzling in die Box fällt
	END_IF
//	TON_Nitto_Table_Full(IN := conveyor.counters.Nitto_Table_Full, PT := REAL_TO_TIME(Time_Conveyor_To_Box_s * 1000));
	TON_Nitto_Table_Full(IN := conveyor.counters.Nitto_Table_Full, PT := T#200ms); // vorher 500ms // OKrebs // 09.09.21
	Start_TP_PowerOn := FALSE;

	R_TRIG_NittoTableFull(CLK := TON_Nitto_Table_Full.Q);
	R_TRIG_LowerSpeed(CLK := sensorLowerSpeed OR testLowerSpeed);
	R_TRIG_Stop(CLK := sensorStop OR TestStop);
	
	// 24.07.18 // OKrebs // Resetfunktion
	IF panel.LDTRESET.LDT.button AND (MC_ReadStatus_0.Error OR MC_ReadStatus_0.Errorstop)  THEN
		MC_Reset_0.Execute := TRUE;
		state := ST_WAIT;
	END_IF
	/////////////////////

	/////////////////////////////////////STEUERUNG/////////////////////////////////////////////
	CASE state OF
	
		ST_WAIT:
			IF (switchAutomatic AND R_TRIG_NittoTableFull.Q AND NOT sensorBoxesPresent) OR
				(switchManual AND buttonStart AND NOT sensorBoxesPresent) THEN
				MC_Power_0.Enable := TRUE;
				Start_TP_PowerOn := TRUE;
			END_IF
			
			IF NOT TP_PowerOn.Q AND MC_ReadStatus_0.StandStill THEN
				MC_BR_JogVelocity_0.Velocity := data.highSpeed;
				MC_BR_JogVelocity_0.Enable := TRUE;
				MC_BR_JogVelocity_0.JogPositive := TRUE;
				state := ST_MOVE_FAST;
			END_IF
		
		ST_MOVE_FAST:
			IF R_TRIG_LowerSpeed.Q THEN
				MC_BR_JogVelocity_0.Velocity := data.lowSpeed;
				state := ST_MOVE_SLOW;
			END_IF
		
		ST_MOVE_SLOW:
			IF R_TRIG_Stop.Q THEN
				MC_BR_JogVelocity_0.JogPositive := FALSE;
				MC_BR_JogVelocity_0.Enable := FALSE;
			END_IF
			
			IF MC_ReadStatus_0.StandStill THEN
				MC_Power_0.Enable := FALSE;
			END_IF
			
			IF MC_ReadStatus_0.Disabled THEN
				state := ST_WAIT;
			END_IF

	END_CASE
	
	///////////////////////////////////////////////////////////////////////////////////////////
	
	MC_ReadStatus_0();
	MC_Reset_0();
	MC_Power_0();
	MC_Stop_0();
	MC_BR_JogVelocity_0();
	
	
END_FUNCTION_BLOCK