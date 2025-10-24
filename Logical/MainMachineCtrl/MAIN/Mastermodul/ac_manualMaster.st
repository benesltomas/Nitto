(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualMaster.st
 * Autor: Awalz
 * Erstellt: 1. April 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_manualMaster:
		IF  NOT safety.RequestSLS THEN
			IOs.ampel.Gelb.aktion := CONST.LAMP.BLINK500;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.BLINK500; (* um zu signalisieren dass der Safetyrequest gedückt werden muss*)
		ELSE
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.OFF;
		END_IF 
	CASE state OF

	ST_IDLE:
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			axis.MC_ReadStatus_0();	
			IF axis.MC_BR_ReadDriveStatus_0.Error THEN
				axis.cmd := CONST.AXIS.RESET;
				state := ST_RESET_WAIT;
			ELSIF unitsStatus.ready (*AND NOT (UnwinderUnit.clamp.toDown_o OR UnwinderUnit.splicetable.clampAfter.toDown_o OR 
											 UnwinderUnit.splicetable.clampBefore.toDown_o OR UnwinderUnit.unwinderDrv.clamp.toDown_o 
												OR UnwinderUnit.unwinderOp.clamp.toDown_o) *)THEN
				(*datacom.mach.loaded AND datacom.recipe.loaded AND datacom.tools.com.loaded*)
			(*	errorKlemmungVornUnten.active := FALSE;
				errorKlemmungHintenUnten.active := FALSE;
				panels.fwSlow.lamp.aktion := CONST.LAMP.BLINK500;*)
				panel.LDTJOG.LDT.aktion := CONST.LAMP.BLINK500;
			
				IF summerystartstop.jog AND safety.RequestSLS THEN (* alle Türen sind zu es darf von jeder Stelle gejoggt werden*)
					panel.LDTAutomatic.LDT.aktion := CONST.LAMP.OFF;
//					axis.BasicControl.Parameter.Acceleration := 5000;
//					axis.BasicControl.Parameter.Deceleration := 5000;
					axis(cmd := CONST.AXIS.JOG_POS, velocity := data.startSpeed/16666.67); 
					panel.LDTJOG.LDT.aktion := CONST.LAMP.ON;
					busy := TRUE;
					state := ST_AXIS_RUN_SLOW;

				ELSIF cuttingunit1.emcy_inputs.EMCY_DoorsClosed AND webbuffer.emcy_inputs.EMCY_DoorsClosed AND longcutter.emcy_inputs.EMCY_DoorsClosed AND 
					cuttingunit2.emcy_inputs.EMCY_DoorsClosed AND summerystartstop.boxwebbuffer.jog.LDT.button THEN
					axis(cmd := CONST.AXIS.JOG_POS, velocity := data.startSpeed/16666.67); 
					panel.LDTJOG.LDT.aktion := CONST.LAMP.ON;
					busy := TRUE;
					state := ST_AXIS_RUN_SLOW_PB1;

				ELSIF  webbuffer.emcy_inputs.EMCY_DoorsClosed AND pullbreak.emcy_inputs.EMCY_DoorsClosed AND
				 longcutter.emcy_inputs.EMCY_DoorsClosed AND cuttingunit2.emcy_inputs.EMCY_DoorsClosed AND summerystartstop.boxcutting1.jog.LDT.button THEN
					axis(cmd := CONST.AXIS.JOG_POS, velocity := data.startSpeed/16666.67); 
					panel.LDTJOG.LDT.aktion := CONST.LAMP.ON;
					busy := TRUE;
					state := ST_AXIS_RUN_SLOW_CUT1;
				ELSIF webbuffer.emcy_inputs.EMCY_DoorsClosed AND pullbreak.emcy_inputs.EMCY_DoorsClosed AND cuttingunit1.emcy_inputs.EMCY_DoorsClosed AND 
					summerystartstop.boxlongcutter.jog.LDT.button THEN
					axis(cmd := CONST.AXIS.JOG_POS, velocity := data.startSpeed/16666.67); 
					panel.LDTJOG.LDT.aktion := CONST.LAMP.ON;
					busy := TRUE;
					state := ST_AXIS_RUN_SLOW_CUT2;
				END_IF
			
			ELSE 
				IF unitsStatus.clampingfront  THEN
					errorclampingfront.active := TRUE;
				ELSE
					errorclampingfront.active := FALSE; 
				END_IF
				IF unitsStatus.clampingback THEN
					errorclampingback.active := TRUE;
				ELSE
					errorclampingback.active := FALSE;
				END_IF
			END_IF
		ELSE
			axis(cmd := CONST.AXIS.NOACTION);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		END_IF

	ST_AXIS_RUN_SLOW:
		axis();
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL OR NOT unitsStatus.ready OR NOT summerystartstop.jog  THEN			
			axis.MC_ReadStatus_0();
			axis.verzoegerung := 120000;
			axis(cmd := CONST.AXIS.STOP);
			state := ST_AXIS_STOP;		
		END_IF

//
	ST_AXIS_RUN_SLOW_PB1:
			axis();
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL OR NOT unitsStatus.ready OR NOT summerystartstop.			boxwebbuffer.jog.LDT.button OR NOT webbuffer.emcy_inputs.EMCY_DoorsClosed 
		OR NOT cuttingunit1.emcy_inputs.EMCY_DoorsClosed OR NOT longcutter.emcy_inputs.EMCY_DoorsClosed 			OR NOT cuttingunit2.emcy_inputs.EMCY_DoorsClosed THEN			
			axis.MC_ReadStatus_0();
			axis.verzoegerung := 120000;
			axis(cmd := CONST.AXIS.STOP);
			state := ST_AXIS_STOP;		
		END_IF

	ST_AXIS_RUN_SLOW_CUT1: 
			axis();
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL OR NOT unitsStatus.ready OR NOT summerystartstop.			boxcutting1.jog.LDT.button OR NOT webbuffer.emcy_inputs.EMCY_DoorsClosed 
		OR NOT pullbreak.emcy_inputs.EMCY_DoorsClosed OR NOT longcutter.emcy_inputs.EMCY_DoorsClosed OR 			NOT cuttingunit2.emcy_inputs.EMCY_DoorsClosed THEN			
			axis.MC_ReadStatus_0();
			axis.verzoegerung := 80000;
			axis(cmd := CONST.AXIS.STOP);
			state := ST_AXIS_STOP;		
		END_IF

	ST_AXIS_RUN_SLOW_CUT2:
			axis();
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL OR NOT unitsStatus.ready OR NOT summerystartstop.			boxlongcutter.jog.LDT.button OR NOT webbuffer.emcy_inputs.EMCY_DoorsClosed 
		OR NOT pullbreak.emcy_inputs.EMCY_DoorsClosed  OR NOT cuttingunit1.emcy_inputs.EMCY_DoorsClosed 		THEN			
			axis.MC_ReadStatus_0();
			axis.verzoegerung := 120000;
			axis(cmd := CONST.AXIS.STOP);
			state := ST_AXIS_STOP;		
		END_IF

	ST_AXIS_STOP:
		IF NOT axis.busy THEN
			axis(cmd := CONST.AXIS.NOACTION);
			IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
				busy := TRUE;
				StateCtrl := CTRL_MANUAL_AFTER;
			ELSE
				busy := FALSE;
			END_IF
			state := ST_IDLE;
		END_IF
		
		
	ST_RESET_WAIT:
		axis();
		IF NOT axis.busy THEN
			axis.cmd := CONST.AXIS.NOACTION;
			state := ST_IDLE;
		END_IF


	ST_ERROR:
		busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			state := ST_IDLE;
			(*err.reset();*)
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		END_IF;

	END_CASE

END_ACTION