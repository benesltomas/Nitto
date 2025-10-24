(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_inline.st
 * Autor: awalz
 * Erstellt: 22. August 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_inline: 
CASE state OF
	ST_IDLE:

		IF BetrCtrl.value = CONST.MACHINEMODES.AUTOMATIC THEN
			IF unitsStatus.ready (*AND unitsStatus.clampingback AND unitsStatus.clampingfront AND unitsStatus.clampingsplicetable *)THEN
						state := ST_AXIS_RUN;
			END_IF
				
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
			IOs.ampel.ondelay := T#5s;
			IOs.ampel.horn := TRUE;
			axis(cmd := CONST.AXIS.MOVE_VELOCITY, velocity := inlineVelocity.setVelocity);
			IOs.machineReady := TRUE;
			state := ST_AXIS_RUN_FAST;
		END_IF	

	ST_AXIS_RUN_FAST:
	(*	axis();	*)
		IF  NOT safety.RequestSLS THEN (*gelbe Ampel blinken lassen wenn die Safety speed nicht freigegeben ist*)
			IOs.ampel.Gelb.aktion := CONST.LAMP.BLINK500;
			panel.LDTRESET.LDT.aktion := CONST.LAMP.BLINK500;	
		ELSE
			IOs.ampel.Gelb.aktion := CONST.LAMP.OFF;
				panel.LDTRESET.LDT.aktion := CONST.LAMP.OFF;
				
		END_IF	
 		// Geschwindigkeitsänderung abhängig vom Tänzer des Zufuhr
		axis(cmd := CONST.AXIS.MOVE_VELOCITY, velocity := inlineVelocity.setVelocity);
		IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
			axis(cmd := CONST.AXIS.STOP, ruck := 2000, verzoegerung := 40000 );
			state := ST_AXIS_STOP;
		ELSIF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC OR NOT unitsStatus.ready OR NOT safety.RequestSLS THEN
			axis( cmd := CONST.AXIS.STOP, ruck := 20000, verzoegerung := 80000 );
			state := ST_AXIS_STOP; 
		END_IF
	
	ST_AXIS_STOP:
		IF  NOT axis.busy THEN
			axis(cmd := CONST.AXIS.NOACTION);
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
				busy := TRUE;
				IOs.machineReady := FALSE;
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


	ST_ERROR:
	err.flag := TRUE;
		busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
			state := ST_IDLE;
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_AUTO_AFTER;
		END_IF;
	END_CASE
END_ACTION