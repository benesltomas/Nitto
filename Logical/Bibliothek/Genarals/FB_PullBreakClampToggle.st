(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_PullBreakClampToggle.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_PullBreakClampToggle
buttomToggle(clk := clk);
	IF enable THEN 
		IF buttomToggle.LDT.rtrig.Q (*AND NOT buttomToggle2.LDT.rtrig.Q *)THEN
			IF NOT onewayini THEN
				IF isup THEN (*Sensorausgang *)
					toUp_o := FALSE;
					toDown_o := TRUE;
				ELSE
					toDown_o := FALSE;
					toUp_o := TRUE;
				END_IF
		 	ELSE
		 		IF isdown THEN
					toDown_o := FALSE;
					toUp_o := TRUE;
				ELSE
					toDown_o :=TRUE;
					toUp_o := FALSE;
				END_IF
			END_IF
		END_IF
		
			IF isdown AND buttomToggle2.LDT.button AND (state = 0) THEN
				limiterForward_o := FALSE;
				limiterBackward_o := TRUE;
				Time1.IN := TRUE;
				Time1.PT := T#3s;
				state := 1;
			ELSIF buttomToggle2.LDT.button AND (state = 0) THEN
				limiterForward_o := TRUE;
				limiterBackward_o := FALSE;
				toDown_o := TRUE;
				toUp_o := FALSE;
				state := 0;
			END_IF
			IF NOT limiterSwitchDrvSide AND NOT limiterSwitchOpSide AND Time1.Q AND (state = 1) THEN
				Time1.IN := FALSE;
				toDown_o := FALSE;
				toUp_o := TRUE;
				state := 0;
			END_IF
					
			Time1();
	ELSE 
//		toDown_o :=FALSE;
//		toUp_o := FALSE;
	END_IF
	IF init THEN
		toUp_o := TRUE;
		init := FALSE;
	END_IF
	
	IF 	 NOT onewayini THEN
		buttomToggle.LDT.aktion := SEL((toUp_o AND isup), CONST.LAMP.OFF, CONST.LAMP.ON);
	ELSE
		buttomToggle.LDT.aktion := SEL((toUp_o AND NOT isdown ), CONST.LAMP.OFF, CONST.LAMP.ON);
	END_IF


END_FUNCTION_BLOCK