(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_automaticMaster.st
 * Autor: Awalz
 * Erstellt: 1. April 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_automaticMaster: 
	CASE state OF
	ST_IDLE:
	(*	pulsHorn(IN := FALSE);*)


		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			handWheel.reset := TRUE;
			panel.LDTAutomatic.LDT.aktion := CONST.LAMP.BLINK500;
			panel.LDTJOG.LDT.aktion := CONST.LAMP.OFF;
		(*	errorKlemmungVornUnten.active := FALSE;
			errorKlemmungHintenUnten.active := FALSE;
			IF unitsStatus.durchmesserStop THEN
				errorDiameterStop.active := TRUE;
			ELSE
				errorDiameterStop.active := FALSE;
				IF unitsStatus.klemmungVornStop THEN
					errorKlemmungVornUnten.active := TRUE;
				ELSIF unitsStatus.klemmungHintenStop THEN
					errorKlemmungHintenUnten.active := TRUE;
				ELSIF unitsStatus.unwinderNotUp THEN
					errorUnwinderNotUp.active := TRUE;
				ELSE
					errorUnwinderNotUp.active := FALSE;*)
					IF unitsStatus.ready AND cuttingunit2.emcy_inputs.EMCY_DoorsClosed AND  cuttingunit1.emcy_inputs.EMCY_DoorsClosed AND  webbuffer.emcy_inputs.EMCY_DoorsClosed AND pullbreak.emcy_inputs.EMCY_DoorsClosed AND
				 longcutter.emcy_inputs.EMCY_DoorsClosed AND cuttingunit2.emcy_inputs.EMCY_DoorsClosed  AND safety.RequestSLS THEN
					(*AND unitsStatus.clampingback AND unitsStatus.clampingfront AND unitsStatus.clampingsplicetable *)
						(*NOT (UnwinderUnit.clamp.toDown_o OR UnwinderUnit.splicetable.clampAfter.toDown_o OR 
						UnwinderUnit.splicetable.clampBefore.toDown_o OR UnwinderUnit.unwinderDrv.clamp.toDown_o 
						OR UnwinderUnit.unwinderOp.clamp.toDown_o) THEN*)
						(*AND datacom.mach.loaded AND datacom.recipe.loaded AND datacom.tools.com.loaded THEN*)
						state := ST_AXIS_RUN;
					END_IF
				(*END_IF
			END_IF*)
		ELSE
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		END_IF
	
	ST_AXIS_RUN:
		IF axis.busy OR axis.cmd <> CONST.AXIS.NOACTION THEN
			axis.cmd := CONST.AXIS.NOACTION;
		ELSE
			panel.LDTAutomatic.LDT.aktion := CONST.LAMP.ON;
			IOs.ampel.ondelay := T#3s;
			IOs.ampel.horn := TRUE;
			axis(cmd := CONST.AXIS.MOVE_VELOCITY, velocity := handWheel.setVelocity);
			state := ST_AXIS_RUN_FAST;
		END_IF	
	(*	ELSE
			data.set.override := 0;
			axis.ctrl.ref.PlcToNc.Override := data.set.override;
			axis.ctrl( cmd := CONST.AXIS.START, position := axis.ctrl.ref.NcToPlc.ActPos + 9999999999999, velocity := STARTVELO);
			panels.autoLangsam.lamp.aktion :=  const.LAMP.BLINK500;
			panels.autoSchnell.lamp.aktion :=  const.LAMP.BLINK500;

			IOs.tasterflascheAbwickler.jog.lamp.aktion := const.LAMP.BLINK500;
			IOs.tasterflascheLongford.jog.lamp.aktion := const.LAMP.BLINK500;
			IOs.tasterflscheSpender.jog.lamp.aktion := const.LAMP.BLINK500;
			state := ST_AXIS_RUN_FAST;
		END_IF*)

	ST_AXIS_RUN_FAST:
		axis();	
		IF  NOT safety.RequestSLS THEN
			IOs.ampel.Gelb.aktion := CONST.LAMP.BLINK500;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.BLINK500; (* um zu signalisieren dass der Safetyrequest gedückt werden muss*)
		ELSE
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.OFF;
		END_IF	
		 // Geschwindigkeitsänderung mit Handrad auf dem Panel
		axis(cmd := CONST.AXIS.MOVE_VELOCITY, velocity := handWheel.setVelocity);
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
//			errorKlemmungVornUnten.active := FALSE;
//			errorKlemmungHintenUnten.active := FALSE;
//			errorDiameterStop.active := FALSE;
//			errorUnwinderNotUp.active := FALSE;
			axis(cmd := CONST.AXIS.STOP, ruck := 0, verzoegerung := 120000 );
			state := ST_AXIS_STOP;
		ELSIF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC OR NOT unitsStatus.ready OR NOT safety.RequestSLS  THEN
//			errorKlemmungVornUnten.active := FALSE;
//			errorKlemmungHintenUnten.active := FALSE;
//			errorDiameterStop.active := FALSE;
//			errorUnwinderNotUp.active := FALSE;
			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 120000 );
			state := ST_AXIS_STOP; 
		ELSIF unitsStatus.diameterStop THEN
//		(*errorKlemmungVornUnten.active := FALSE;
//			errorKlemmungHintenUnten.active := FALSE;
//			errorUnwinderNotUp.active := FALSE;
//			errorDiameterStop.active := TRUE;*)
			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 120000);
			state := ST_AXIS_STOP;
//		ELSIF 	unitsStatus.clampingfront THEN
//			(*errorKlemmungVornUnten.active := TRUE;
//			errorKlemmungHintenUnten.active := FALSE;
//			errorUnwinderNotUp.active := FALSE;
//			errorDiameterStop.active := FALSE;*)
//			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 4000 );
//		(*	panels.stopSchnell.lamp.aktion := const.LAMP.ON; (*J.H.*)
//			state := ST_AXIS_STOP;
//		ELSIF unitsStatus.clampingback THEN
//		(*	errorKlemmungVornUnten.active := FALSE;
//			errorKlemmungHintenUnten.active := TRUE;
//			errorUnwinderNotUp.active := FALSE;
//			errorDiameterStop.active := FALSE;*)
//			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 4000 );
//			(*panels.stopSchnell.lamp.aktion := const.LAMP.ON; (*J.H.*)
//			state := ST_AXIS_STOP;
//		ELSIF unitsStatus.clampingsplicetable THEN
//		(*	errorKlemmungVornUnten.active := FALSE;
//			errorKlemmungHintenUnten.active := TRUE;
//			errorUnwinderNotUp.active := FALSE;
//			errorDiameterStop.active := FALSE;*)
//			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 4000 );
//			(*panels.stopSchnell.lamp.aktion := const.LAMP.ON; (*J.H.*)
//			state := ST_AXIS_STOP;
		END_IF


	ST_AXIS_VELO_CHANGE:
	(*	pulsHorn.IN := TRUE;
		axis.ctrl();
		timer();
		IF panels.runFast.key.rtrig.Q THEN
			IF data.set.override <> endOverride THEN
				data.set.override := endOverride;
			ELSE
				data.set.override := actOverride;
			END_IF
		END_IF*)
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC OR NOT unitsStatus.ready THEN
			axis.verzoegerung :=120000;
			axis.cmd := CONST.AXIS.STOP; 
		
			state := ST_AXIS_STOP;
	(*	ELSIF timer.Q THEN
			timer(in := FALSE);
			state := ST_AXIS_RUN_FAST;*)
		END_IF;

	ST_AXIS_STOP:

		IF NOT axis.busy THEN
			axis(cmd := CONST.AXIS.NOACTION);
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
				busy := TRUE;
				panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
				axis.cmd := CONST.AXIS.NOACTION;
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE
				 IF NOT axis.busy THEN
					axis.cmd := CONST.AXIS.NOACTION;
					busy := FALSE;
					state := ST_IDLE;
				END_IF
			END_IF
		END_IF

//	ST_AXIS_UNWINDER_STOP:
//		axis.();
//		IF NOT axis.ctrl.Busy THEN
//			axis.ctrl(cmd := CONST.AXIS.NOACTION);
//			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
//				errorUnwinderNotUp.active := FALSE;
//				Busy := TRUE;
//				StateCtrl := CTRL_AUTO_AFTER;
//			ELSE
//				Busy := FALSE;
//			END_IF
//		END_IF*);

	ST_AXIS_DURCHMSTOP:

		IF NOT axis.busy THEN
			axis(cmd := CONST.AXIS.NOACTION);
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
//				errorDiameterStop.active := FALSE;
				busy := TRUE;
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE
				busy := FALSE;
			END_IF
		END_IF;

	ST_BAHN_END:
	(*	busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			state := ST_IDLE;
			err.reset();
			Busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		END_IF*);

	ST_ERROR:
	(*	err.flag := TRUE;
		busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			state := ST_IDLE;
			err.reset();
			Busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		END_IF*);
	END_CASE
END_ACTION