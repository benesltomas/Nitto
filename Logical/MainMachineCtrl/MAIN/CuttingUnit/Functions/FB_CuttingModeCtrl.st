(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_Cuttingmode.st
 * Autor: Awalz
 * Erstellt: 20. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CuttingModeCtrl

	CASE state OF
		ST_IDLE_BEFORE:	
			busy := FALSE;
			state := ST_IDLE;
			
		ST_IDLE:
			IF mode <> CONST.CUTTINGUNIT.MODEs.DISABLE THEN
				busy := TRUE;
				err(reset := TRUE);
				IF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
					IF mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN
						state := ST_FREECUTTING_BEFORE;
					ELSIF mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
						state := ST_SYNCCUTTING_BEFORE;
					END_IF
				END_IF
		END_IF
			
		ST_IDLE_QUIT:
			busy := FALSE;
			IF mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN
				err(reset := TRUE);
				state := ST_IDLE_BEFORE;
			END_IF	
			
		ST_FREECUTTING_BEFORE:
			busy := FALSE;
			state := ST_FREECUTTING;
	
		ST_FREECUTTING:
			IF mode <> CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN
				camCtrl(enable := FALSE, machineMaster := machineMaster, axis := axis, scalePerimeter := scalePerimeter, data := data, status := status,
						markpoints := markpoints, getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset, CONST := CONST);
				busy := TRUE;
				err(reset := TRUE);
				IF mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN
					state := ST_IDLE_BEFORE;
				ELSIF mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
					state := ST_SYNCCUTTING_BEFORE;
				END_IF
			ELSE
				camCtrl(enable := TRUE, machineMaster := machineMaster, axis := axis, scalePerimeter := scalePerimeter, data := data, status := status,
						markpoints := markpoints, getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset, CONST := CONST);
			END_IF;	
			
			
		ST_SYNCCUTTING_BEFORE:
	//		status.mode.set(value := CONST.CUTTINGUNIT.MODEs.SYNC_RUN);
	//		SetGearRatio(GearRatio := 1, Slave := masterAxis.ctrl.ref );
			busy := FALSE;
			state := ST_SYNCCUTTING;	
				
			
			
		ST_SYNCCUTTING:
			IF mode <> CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
				busy := TRUE;
				state := ST_SYNCCUTTING_AFTER;
			ELSE
				camCtrl(enable := TRUE, machineMaster := machineMaster, axis := axis, scalePerimeter := scalePerimeter, data := data, status := status,
						markpoints := markpoints, getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset, CONST := CONST);

			END_IF


		ST_SYNCCUTTING_AFTER:
			camCtrl(enable := FALSE, machineMaster := machineMaster, axis := axis, scalePerimeter := scalePerimeter, data := data, status := status,
						markpoints := markpoints, getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset, CONST := CONST);	
			state := ST_IDLE;

			

	END_CASE	
END_FUNCTION_BLOCK