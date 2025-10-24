(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_WriteEncoder.st
 * Autor: Awalz
 * Erstellt: 23. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_WriteEncoder
	MC_ReadStatus_0.Axis	:= AxisREF;
	MC_ReadStatus_0.Enable	:= NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0();
	
	MC_BR_ReadDriveStatus_0.Axis			:= AxisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus	:= ADR(DriveStatus);
	MC_BR_ReadDriveStatus_0.Enable			:= NOT MC_BR_ReadDriveStatus_0.Error;
	MC_BR_ReadDriveStatus_0();
	
	MC_BR_InitModPos_0.Axis				:= AxisREF;	
	MC_BR_InitModPos_0();
	pAxis ACCESS AxisREF;
	EncIf_Act.scaling.load.rev_motor 	:= pAxis.encoder_if.parameter.scaling.load.rev_motor;
	EncIf_Act.scaling.load.units 		:= pAxis.encoder_if.parameter.scaling.load.units;
	CASE state OF
	
		ST_IDLE: IF enable THEN 
				IF check THEN 
					busy := TRUE;
//					scalePerimeter.realperimeter := UINT_TO_REAL (data.recipe.tool.cogCutting )* data.recipe.tool.cogmodul * 1000;
//					scalePerimeter.NumberToolSegments := MAX (1, data.recipe.tool.numberToolSegments);
					scalePerimeter();
//					EncIf_Set.scaling.load.rev_motor 	:= data.recipe.tool.gearRatioMotor * data.recipe.tool.cogCutting;
//					EncIf_Set.scaling.load.units 		:= data.recipe.tool.cogSupportSpindle * scalePerimeter.Scaledperimeter;
					EncIf_InitValid := TRUE;
					state :=  ST_SET_MODULO;

				END_IF
			
			END_IF
			
			
		ST_SETDATA_START://1
				
		ST_SETDATA_WAIT://2

		ST_SET_MODULO://3

			ModPeriod_Set	:= scalePerimeter.ToolSegmentPeriod;
			IF  ModPeriod_Set = MC_BR_InitModPos_0.Period THEN
				state := ST_QUIT; (* wenn gleiche Periode dann Periode icht ändern*)
			END_IF
			IF 0 < ModPeriod_Set < brmldexp( 2, 23) AND DriveStatus.NetworkInit AND(MC_ReadStatus_0.Disabled OR MC_ReadStatus_0.StandStill) AND  EncIf_InitValid THEN
				(*warum zwanzig RS FBs wo ist der Sinn*)	
				MC_BR_InitModPos_0.Factor	:= 1;
				MC_BR_InitModPos_0.Execute	:= TRUE;
				MC_BR_InitModPos_0.Period	:= ModPeriod_Set;
				(*	MC_BR_InitModPos_0();*)
				EncIf_InitValid := FALSE;
			END_IF;
			//complete modulo period setup by copying the downloaded parameters into the "Act" structure
			IF MC_BR_InitModPos_0.Done THEN
				ModPeriod_Act	:= MC_BR_InitModPos_0.Period;
				MC_BR_InitModPos_0.Execute	:= FALSE;
				EncIf_InitValid := TRUE;
				state := ST_QUIT;
			ELSIF MC_BR_InitModPos_0.Error THEN
				err.fnc := 'FB_WriteEncoder';
				err.text := 'Modulo Achse';
				err.state := ST_SETDATA_WAIT;
				err.id := MC_BR_InitModPos_0.ErrorID;
				err.set := TRUE;
				state := ST_ERROR;
			END_IF;

		ST_ERROR: //5
			IF LEN(err.fnc) < 1 THEN
				err.fnc := 'FB_WriteEncoder';
				err.text := ' Werkzeugdaten sind falsch';
			END_IF
			err(set := TRUE);
			state := ST_QUIT;
			
		ST_QUIT://6
			check := FALSE;
			busy := FALSE;
			state := ST_IDLE;
	END_CASE			

END_FUNCTION_BLOCK