(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_MachineCtrl.st
 * Autor: Awalz
 * Erstellt: 13. Januar 2014
 ********************************************************************
 * Implementierung
 ********************************************************************) 

(* TODO: Hier werden Betriebszustände der Maschine generiert und an die Untergruppen weitergegeben  jeder EInheit hat BetrCtrl eingang*)
FUNCTION_BLOCK FB_MachineCtrl 
pullbreakSt.emcy_inputs.EMCY_Door1 := TRUE;
//	horntrig(CLK := UnwinderUnit.feederCtrl.horn);
//	IF horntrig.Q THEN 
//		IOs.ampel.Hupe.Value.ActOut := CONST.LAMP.BLINK1000;
	//	END_IF
	
	tasktimerPos := panel.clk.c200.Output;
	tasktimerNeg :=  NOT panel.clk.c200.Output;
	
	mode.status(set := TRUE, value := mode.ctrl.value);
	CASE state OF	
	CTRL_FIRST_START: 	
			(* Daten müssen geladen und Achse initialisiert werden.*)
		ac_init; (*Initialisierung der der Achsen*)
		webguiding.auto := TRUE;
		
		busy := TRUE;
		state := CTRL_EMERGENCYSTOP_BEFORE; 
		
	CTRL_MANUAL_BEFORE:
		busy := TRUE;
		(*panel.LDTControlOFF.Value.InVal := FALSE;
		panel.LDTControlON.Value.InVal := TRUE;
		panel.LDTAutomatic.Value.InVal := FALSE;*)
		IOs.ampel.Rot.aktion := CONST.LAMP.OFF;
		IF mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
			tmpMode := CONST.MACHINEMODES.MANUAL;
				ac_setMode;
				ac_getMode;	
				IOs.ValveAirON := TRUE;
				IOs.CEEPlugON := TRUE;
			IF NOT busy THEN
			(*	mode.status(set := TRUE, value := mode.ctrl.value);*)
				webguidingbuffer.auto := TRUE;
				webguiding.auto := TRUE;
				IOs.ampel.Gruen.aktion := CONST.LAMP.ON;
				state := CTRL_MANUAL;
			END_IF
		ELSE
			state := CTRL_MANUAL_AFTER;
		END_IF
		
	
	CTRL_MANUAL:
	
	(*safety.ResetStartupInhibit		:= NOT IOs.dIn.LDT_Reset.Value.InVal;
	safety.ResetSafeMC				:= safety.ResetUserSafeMC OR IOs.dIn.LDT_Reset.Value.InVal;*)
		bufferbrake_open := TRUE; 
		IF mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
		panel.LDTControlOFF.LDT.aktion := CONST.LAMP.OFF;
		panel.LDTControlON.LDT.aktion := CONST.LAMP.ON;
		panel.LDTJOG.LDT.aktion := CONST.LAMP.BLINK1000;
		UnwinderUnit.ctrl.BetrCtrl(set := TRUE, value := CONST.MACHINEMODES.MANUAL);

	(*	UnwinderUnit.unwinderOp.ctrl.BetrCtrl(set := TRUE, value := CONST.MACHINEMODES.MANUAL);*)
		(*	IF NOT cuttingUnit[1].status.dataOk OR NOT cuttingUnit[2].status.dataOk THEN
				panels.referenzieren.lamp.aktion := CONST.LAMP.OFF;
				panels.cplOn.lamp.aktion := CONST.LAMP.OFF;
			ELSIF NOT cuttingUnit[1].status.tmpCalibrated OR NOT cuttingUnit[2].status.tmpCalibrated THEN
				panels.referenzieren.lamp.aktion := CONST.LAMP.BLINK500;
				panels.cplOn.lamp.aktion := CONST.LAMP.OFF;
			ELSE
				panels.referenzieren.lamp.aktion := CONST.LAMP.ON;
				IF NOT cuttingUnit[1].status.ready OR NOT cuttingUnit[2].status.ready THEN
					panels.cplOn.lamp.aktion := CONST.LAMP.BLINK500;
				ELSE
					panels.cplOn.lamp.aktion := CONST.LAMP.ON;
				END_IF
			END_IF
			
			IF panels.referenzieren.key.rtrig.Q THEN
				cuttingUnit[1].ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.CALIBR);
				cuttingUnit[2].ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.CALIBR);
				winder.ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			ELSIF panels.cplOn.key.rtrig.Q THEN
				cuttingUnit[1].ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.CPL_ON);
			
				(*winder.ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.CPL_ON);*)
		(*	ELSIF panels.referenzieren.key.ftrig.Q OR panels.cplOn.key.ftrig.Q THEN
				pullBreakUnit1.ctrl.cmdCtrl.set(value := CONST.CUTTINGUNIT.CMDs.NO_CMD);*)
		ELSE
			busy := TRUE;
			err(reset := TRUE);
			state := CTRL_MANUAL_AFTER;
		END_IF
			
	CTRL_MANUAL_AFTER:
		bufferbrake_open := FALSE; 
		state:= CTRL_SETSTATEAFTER;
		(*ac_setStateAfter;*)
		
	CTRL_AUTO_BEFORE:
		
		busy := TRUE;
	(*	IOs.ampel.ondelay := T#5s;*)
		(*IOs.ampel.horn := TRUE;*)
		IOs.ampel.Rot.aktion := CONST.LAMP.OFF;
		IOs.ampel.Gruen.aktion := CONST.LAMP.ON;
		(*panel.LDTAutomatic.LDT.aktion := CONST.LAMP.ON;*)
		IF mode.ctrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			tmpMode :=CONST.MACHINEMODES.AUTOMATIC;
			ac_setMode;
			ac_getMode;
//			IOs.ValveAirON := TRUE;		
		(*	IF NOT busy THEN*)
				(*mode.status.set:= TRUE;*)
				mode.status(set:= TRUE, value := mode.ctrl.value);
			(*	IOs.lamps.green.aktion := CONST.LAMP.ON;*)
				busy := FALSE;
				err(reset := TRUE);
				(*panels.autoEin.lamp.aktion := CONST.LAMP.ON;*)
				webguidingbuffer.auto := TRUE;
				webguiding.auto := TRUE;
				state := CTRL_AUTO;
		(*	END_IF*)
		ELSE
			state := CTRL_AUTO_AFTER;
		END_IF

	CTRL_AUTO:
		IOs.ampel.horn := FALSE;
		IF mode.ctrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			panel.LDTJOG.LDT.aktion := CONST.LAMP.OFF;
			(*IF NOT cuttingUnit[1].status.tmpCalibrated OR NOT cuttingUnit[2].status.tmpCalibrated OR NOT printUnit.status.tmpCalibrated (* OR NOT cuttingUnit[3].status.tmpCalibrated  THEN*)
				(*panels.referenzieren.lamp.aktion := CONST.LAMP.BLINK500;
				panels.cplOn.lamp.aktion := CONST.LAMP.OFF;
			ELSE
				panels.referenzieren.lamp.aktion := CONST.LAMP.ON;
				IF NOT cuttingUnit[1].status.ready OR NOT cuttingUnit[2].status.ready OR NOT printUnit.status.ready  (* OR NOT cuttingUnit[3].status.ready  THEN*)
				(*	panels.cplOn.lamp.aktion := CONST.LAMP.BLINK500;
				ELSE
					panels.cplOn.lamp.aktion := CONST.LAMP.ON;
				END_IF
			END_IF*)
		ELSE
			panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
			err(reset := TRUE);
			busy := TRUE;
			state := CTRL_AUTO_AFTER;
		END_IF
		
	CTRL_AUTO_AFTER:
		state:= CTRL_SETSTATEAFTER;
		(*ac_setStateAfter;*)
	
		
	CTRL_RESET_START:
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE	
			tmpMode := CONST.MACHINEMODES.RESET;
			ac_setMode;
			busy := TRUE;
			state := CTRL_RESET;
			err(reset := TRUE);
		END_IF

	CTRL_RESET:
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			ac_getMode;
			IF NOT busy THEN
				mode.status(set := TRUE , value := CONST.MACHINEMODES.RESET);
				err(reset := TRUE);
				(*err.reset();*)
				state := CTRL_RESET_AFTER;
			END_IF
		END_IF

	CTRL_RESET_AFTER:
		IF mode.ctrl.value = CONST.MACHINEMODES.RESET THEN
			;
		ELSE
			(*err.reset();*)
			err(reset := TRUE);
	
		END_IF		
	(*************neu 30.04*)	
	CTRL_SAFETYSTOP_BEFORE:
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSE
			tmpMode := CONST.MACHINEMODES.SAFETYSTOP;
			ac_setMode;
			panel.LDTControlOFF.LDT.aktion := CONST.LAMP.ON;
			state := CTRL_SAFETYSTOP;
		END_IF		
		
		
	CTRL_SAFETYSTOP:
		(*ac_setMode;*)
		bufferbrake_open := FALSE; 
		ac_getMode;
		panel.LDTControlON.LDT.aktion := CONST.LAMP.OFF;
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF NOT busy THEN
			panel.LDTControlON.LDT.aktion := CONST.LAMP.OFF;
			mode.status(set := TRUE, value := CONST.MACHINEMODES.SAFETYSTOP);
			state := CTRL_SAFETYSTOP_AFTER;
		END_IF

	CTRL_SAFETYSTOP_AFTER:
			IOs.ValveAirON := FALSE;
			(*IOs.ampel.Gelb.Value.ActOut := TRUE;*)
			IOs.ampel.Gelb.aktion := CONST.LAMP.ON;
			(*IOs.ampel.Gruen.Value.ActOut := FALSE;*)
			IOs.ampel.Gruen.aktion := CONST.LAMP.OFF;
			panel.LDTControlON.LDT.aktion := CONST.LAMP.OFF;
			panel.LDTJOG.LDT.aktion := CONST.LAMP.OFF;
			panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
			(*neue 13.05*)
			panel.LDTControlOFF.LDT.aktion := CONST.LAMP.BLINK500;
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			(*panel.LDTControlON.LDT.aktion := CONST.LAMP.ON;*)
		(*	IOs.ampel.Gelb.Value.ActOut := FALSE;*)
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF; (*03.09.14*)

			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
//			IOs.ampel.Gruen.Value.ActOut := TRUE;
//			IOs.ampel.Gelb.Value.ActOut := FALSE;
			IOs.ampel.Gruen.aktion := CONST.LAMP.ON;
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
			panel.LDTJOG.LDT.aktion := CONST.LAMP.BLINK500;
			(*panel.LDTAutomatic.LDT.aktion := CONST.LAMP.BLINK500;*)
			state := CTRL_MANUAL_BEFORE;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			(*IOs.ampel.Gruen.Value.ActOut := TRUE;*)
			IOs.ampel.Gruen.aktion := CONST.LAMP.ON;
			(*IOs.ampel.Gelb.Value.ActOut := FALSE;*)
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
			(*panel.LDTAutomatic.LDT.aktion := CONST.LAMP.ON;*)
			state := CTRL_AUTO_BEFORE;
		END_IF
(*************)			
			
	CTRL_EMERGENCYSTOP_BEFORE:	
//		IOs.ampel.Rot.Value.InVal := TRUE;
//		IOs.ampel.Gelb.Value.InVal := FALSE;	
//		IOs.ampel.Gruen.Value.InVal := FALSE;
		IOs.ampel.Rot.aktion := CONST.LAMP.ON;
		IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
		IOs.ampel.Gruen.aktion := CONST.LAMP.OFF;
		tmpMode := CONST.MACHINEMODES.EMERGENCYSTOP;
		(*IF mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
			(*mainUnwinder.ctrl.BetrCtrl(set := TRUE, value := CONST.MACHINEMODES.MANUAL);*)
		ac_setMode;
		busy := TRUE;
		state := CTRL_EMERGENCYSTOP_BEFORE1;
		

		
	CTRL_EMERGENCYSTOP_BEFORE1:
		ac_getMode;
		panel.LDTControlOFF.LDT.aktion := CONST.LAMP.ON;//21.09.15
		panel.LDTControlON.LDT.aktion:= CONST.LAMP.BLINK1000;//21.09.15
		IF NOT busy THEN
			(*panel.LDTControlON.Value.InVal := FALSE;*)
			(*panel.LDTControlOFF.Value.InVal := TRUE;*)
				(*	IOs.air.on := FALSE;*)
				mode.status(set := TRUE, value := CONST.MACHINEMODES.EMERGENCYSTOP);
			state := CTRL_EMERGENCYSTOP;
		END_IF
		
	CTRL_EMERGENCYSTOP:
		(*IF safety.readyToSwitchOn THEN
			panels.steuerungEin.lamp.aktion := CONST.LAMP.BLINK500;
		ELSE
			panels.steuerungEin.lamp.aktion := CONST.LAMP.OFF;
		END_IF*)
	(*	ac_setMode;*)
		bufferbrake_open := FALSE; 
		IOs.CEEPlugON := FALSE;
		ac_getMode;
		IOs.ValveAirON := FALSE;
		panel.LDTJOG.LDT.aktion := CONST.LAMP.OFF;
		panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
		panel.LDTControlOFF.LDT.aktion := CONST.LAMP.ON;
		panel.LDTControlON.LDT.aktion:= CONST.LAMP.BLINK1000;
		IF mode.ctrl.value <> CONST.MACHINEMODES.EMERGENCYSTOP THEN
			panel.LDTControlON.LDT.aktion := CONST.LAMP.OFF;
			panel.LDTControlOFF.LDT.aktion:=  CONST.LAMP.ON;
		
			(*IOs.lamps.red.aktion := CONST.LAMP.OFF;
			err.reset();
			markPoints.reset();
			IOs.air.on := TRUE;*)
			err(reset := TRUE);
			busy := TRUE;
			state := CTRL_EMERGENCYSTOP_AFTER;
		END_IF
		
	CTRL_EMERGENCYSTOP_AFTER:
		panel.LDTControlON.LDT.aktion := CONST.LAMP.BLINK500;
		panel.LDTControlOFF.LDT.aktion:=  CONST.LAMP.ON;
		IOs.ValveAirON := FALSE;
		IOs.CEEPlugON := FALSE;
		IF panel.LDTControlON.LDT.button THEN
			(*IOs.controlOn := TRUE;*)
			(*IOs.CtrlPowerEmcyDel.Value.InVal := TRUE;*)
			state:= CTRL_SETSTATEAFTER;
			(*ac_setStateAfter;*)
		END_IF
		
	CTRL_SETSTATEAFTER:			
		IF mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP THEN
			state := CTRL_EMERGENCYSTOP_BEFORE;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.SAFETYSTOP THEN
			state := CTRL_SAFETYSTOP_BEFORE;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.RESET THEN
			state := CTRL_RESET_START;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
			state := CTRL_MANUAL_BEFORE;
		ELSIF mode.ctrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			state := CTRL_AUTO_BEFORE;
		END_IF
	END_CASE	
	
	ac_cyclic;	


END_FUNCTION_BLOCK