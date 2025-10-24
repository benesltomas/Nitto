(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CuttingCofig.st
 * Autor: Awalz
 * Erstellt: 19. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CuttingConfig
	writeEncoder( AxisREF := axis.ctrl.AxisREF, data := data, scalePerimeter := scalePerimeter);
	pAxis ACCESS axis.ctrl.AxisREF;	
	axis.ctrl.BasicControl.Parameter.Deceleration	:= 120000.0;
	axis.ctrl.BasicControl.Parameter.Acceleration	:= 120000.0;
	
	CASE state OF
		ST_IDLE:
			IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN 
				busy := TRUE;
				err(reset := TRUE);
				cmdtmp := cmd;
				IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
					state := ST_ABORT;
				ELSE
					IF cmd = CONST.CUTTINGUNIT.CMDs.CALIBR THEN   (*Referenziert die CutterAxis*) 
						state := ST_INIT_START;//  ST_CALIBR_START;//  ST_SETDATA_START;//Achse referenzieren
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.INIT THEN
						state := ST_INIT_START;//Referenzsensor initialisieren, nicht beim Referenzmode mcHOME_DIRECT
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.CPL_ON THEN
						state := ST_GENERATE_TABLE_START;//Kurvenscheibe ertellen und Achse koppeln
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.SETDATA THEN 
						state := ST_SETDATA_START;//Encoder initialisieren (Auflösung für die Vorschubkonstante)
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.CPL_OFF THEN 
						state := ST_CPLOFF_START;//Achse stoppen damit die Achse abgekoppelt wird
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.DEINIT THEN
						state := ST_DEINIT;//Achse ausschalten
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.SYNC THEN
						state := ST_SYNC_START;//Achse synchroniesieren
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
						state := ST_MOVE_START;
					END_IF
				END_IF
			END_IF
		//
		ST_SETDATA_START://2
			IF axis.ctrl.MC_ReadStatus_0.StandStill  THEN 
				IF NOT axis.ctrl.busy THEN 
					writeEncoder.check := TRUE;
					state:= ST_SETDATA_WAIT;	
				END_IF
			ELSIF status.isCoupled(*axis.ctrl.MC_ReadStatus_0.SynchronizedMotion*) THEN
				state:= ST_CPLOFF_START;
			ELSIF status.isInitialized THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				state := ST_INIT_START; //  ST_DEINIT_CPLSLAVEOFF_START;
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled THEN
				writeEncoder.InverseDirection := data.recipe.tool.addSupportSpindle;
				writeEncoder.check := TRUE;
				state:= ST_SETDATA_WAIT;
			ELSIF axis.ctrl.MC_ReadStatus_0.Errorstop THEN
				err(set := TRUE ,fnc := 'FB_CuttinConfig' ,text := 'axis.ctrl', state := ST_SETDATA_START, id := axis.ctrl.MC_BR_ReadDriveStatus_0.ErrorID);
				state := ST_ERROR;
			END_IF

		ST_SETDATA_WAIT://4
			IF (axis.ctrl.MC_ReadStatus_0.Disabled OR axis.ctrl.MC_ReadStatus_0.StandStill) AND NOT axis.ctrl.busy THEN
				writeEncoder(enable := TRUE, AxisREF := axis.ctrl.AxisREF, data := data, scalePerimeter := scalePerimeter);
				axis.ctrl.Cmd := CONST.AXIS.NOACTION; 
				IF NOT writeEncoder.busy AND  NOT writeEncoder.check THEN (* Encoder initialisierung ist abgeschloßen jetzt kann referenzeirt werden*)
					status.isInitialized := TRUE;// Encoder hat neue Auflösung
					status.isSynchronized := FALSE; 
					status.isCalibrated := FALSE; //nicht referenziert
					axis.ctrl.BasicControl.AxisState.Homed := FALSE;
					writeEncoder(enable := FALSE, AxisREF := axis.ctrl.AxisREF, data := data, scalePerimeter := scalePerimeter);
					IF cmd =  CONST.CUTTINGUNIT.CMDs.CALIBR AND 
						(data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN  OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT) THEN (* wenn calibrieren dann in Init*)
						axis.ctrl.Cmd := CONST.AXIS.POWER_OFF;
						state := ST_INIT_START;
					ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.CALIBR AND data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN//14.04.15
						axis.ctrl.Cmd := CONST.AXIS.POWER_ON;//15.04.15
						state := ST_CALIBR_START;
					ELSIF cmd = CONST.CUTTINGUNIT.CMDs.SETDATA THEN(* nur die Auflösung geändert*)
						cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;//15.04.15
						state := ST_QUIT; 
					END_IF
				END_IF
			END_IF 
		
		ST_INIT_START://10
	
			IF NOT  axis.ctrl.MC_ReadStatus_0.Disabled THEN //23.04.15
				axis.ctrl.Cmd := CONST.AXIS.POWER_OFF; 
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled AND NOT axis.ctrl.busy  THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION; 
				pAxis.dig_in.level.reference := ncACTIV_HI + ncFORCE;(*initialisierung des Referenzeingamgs in der Maschine ist der Sonsor akiv low*)
				//				InitAxisSubjectPar.Axis := axis.ctrl.AxisREF; (* d.h. wenn keine Lücke dann leuchtet die SensorLed nicht*)
				InitAxisSubjectPar.Subject := ncDIG_IN;//102
				InitAxisSubjectPar.Execute := TRUE;
				IF InitAxisSubjectPar.Done THEN 
					axis.refSwitchConfig(Enable := TRUE);
					InitAxisSubjectPar.Execute := FALSE;
					axis.ctrl.Cmd := CONST.AXIS.POWER_ON; //23.04.15
					state := ST_CALIBR_START;
				ELSIF InitAxisSubjectPar.Error THEN 
					err.text := 'Parameter ncDIG_IN nicht initialisiert';
					err.state := state;
					state := ST_ERROR;
				END_IF 
				(*END_IF*)
			END_IF

	
		ST_CALIBR_START: //20 (* Achse wieder einschalten*)
			//		InitAxisSubjectPar();
			axis.refSwitchConfig();
			IF axis.ctrl.MC_ReadStatus_0.Disabled THEN 
				axis.ctrl.Cmd := CONST.AXIS.POWER_ON; 
			ELSIF NOT axis.ctrl.busy AND axis.ctrl.MC_ReadStatus_0.StandStill AND NOT powerbridge.pressurepresent AND (data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN  OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT)THEN
				axis.ctrl.BasicControl.AxisState.Homed := FALSE; // falls die Achse bereits referenziert ist
				axis.ctrl.BasicControl.Parameter.HomeMode := mcHOME_SWITCH_GATE;
				axis.ctrl.BasicControl.Parameter.HomePosition := 0;
				axis.ctrl.Cmd := CONST.AXIS.CALIBR;(* Achse referenzieren*)
				state := ST_CALIBR_WAIT;
			ELSIF NOT axis.ctrl.busy AND axis.ctrl.MC_ReadStatus_0.StandStill AND NOT powerbridge.pressurepresent AND data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN
				axis.ctrl.BasicControl.AxisState.Homed := FALSE; // falls die Achse bereits referenziert ist
				axis.ctrl.BasicControl.Parameter.HomeMode := mcHOME_DIRECT;
				axis.ctrl.BasicControl.Parameter.HomePosition := 0;
				axis.ctrl.Cmd := CONST.AXIS.CALIBR;(* Achse referenzieren*)
				state := ST_CALIBR_WAIT;
			ELSIF powerbridge.pressurepresent THEN 
				err.text := 'Stanze steht unter Druck';
				err.state := state;
				state := ST_ERROR;
			ELSIF axis.ctrl.MC_ReadStatus_0.Errorstop THEN //die Achse geht in ErrorStop wenn die sichere Geschwindigkeit überschritten wird
				//			err.text := 'Werkzeug falsch parametriert';
				//			err.fnc := 'MC_Home';
				//			err.set := TRUE;
				//			err.state := state;
				err := axis.ctrl.err;
				state := ST_ERROR;
			ELSIF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN 
				state := ST_QUIT;
			END_IF
		
		ST_CALIBR_WAIT://22
			axis.refSwitchConfig();
			IF axis.ctrl.BasicControl.AxisState.Homed AND(data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT) THEN 	
				axis.refSwitchConfig(Enable := FALSE);
				cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;
				status.isCalibrated := TRUE;(* Achse ist referenziert*)
				state := ST_CALIBR_START_NULLPOS;
			ELSIF axis.ctrl.BasicControl.AxisState.Homed AND data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN 	
				axis.refSwitchConfig(Enable := FALSE);
				cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;
				status.isCalibrated := TRUE;
				state := ST_CALIBR_WAIT_NULLPOS;//da keine Bewegung notwendig
			ELSIF axis.ctrl.MC_ReadStatus_0.Disabled AND cmd = CONST.CUTTINGUNIT.CMDs.SETDATA THEN
				state := ST_SETDATA_WAIT;
			ELSIF axis.ctrl.MC_ReadStatus_0.Errorstop THEN //die Achse geht in ErrorStop wenn die sichere Geschwindigkeit überschritten wird
				err.text := 'Werkzeug falsch parametriert';
				err.fnc := 'MC_Home';
				err.set := TRUE;
				err.state := state;
				state := ST_ERROR;
			ELSIF cmd <> CONST.CUTTINGUNIT.CMDs.CALIBR THEN //Stanze beim Referenzieren stoppen
				axis.ctrl.Cmd := CONST.AXIS.STOP;
				IF NOT axis.ctrl.busy THEN 
					axis.ctrl.Cmd := CONST.AXIS.NOACTION;
					state := ST_QUIT;	(*abwarten bis die Achse nicht busy ist*)
				END_IF
			END_IF	
		
		
		ST_CALIBR_START_NULLPOS://24
			IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				state := ST_ABORT;
			ELSIF axis.ctrl.busy OR axis.ctrl.Cmd <> CONST.AXIS.NOACTION THEN
				axis.ctrl(Cmd := CONST.AXIS.NOACTION);
			ELSIF  NOT axis.ctrl.busy THEN(* jetzt halbe Drehung vorfahren*)
				axis.ctrl.Position := 1000; // 1mm da der Sensor oben sitzt
				axis.ctrl.Acceleration := 120000;
				axis.ctrl.Deceleration := 120000;
				axis.ctrl.Velocity :=1.7;
				axis.ctrl.Cmd := CONST.AXIS.SETPOS;
				state := ST_CALIBR_WAIT_NULLPOS;
				(* Homeposition ist wo das Werkzeug/Blech den Anfang hat da darf korregiert werden*)
			END_IF

		ST_CALIBR_WAIT_NULLPOS://26
			IF NOT axis.ctrl.busy THEN
				IF status.isCalibrated THEN // 13.03.15 Stanze ist referenziert dann koppeln
					axis.ctrl.Cmd := CONST.AXIS.NOACTION;
					cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON;
					state := ST_GENERATE_TABLE_START;
				ELSIF NOT status.isCalibrated THEN
					axis.ctrl.Cmd := CONST.AXIS.NOACTION;
					state := ST_QUIT;
				END_IF
			ELSIF axis.ctrl.MC_ReadStatus_0.Errorstop THEN //Achse hat einen Fehler
				err := axis.ctrl.err;
				err.state := state;
				state := ST_ERROR;
			END_IF
	
		ST_GENERATE_TABLE_START: //35
			IF  cmd = CONST.CUTTINGUNIT.CMDs.CPL_ON OR cmdtmp = CONST.CUTTINGUNIT.CMDs.CPL_ON THEN //cmdtmp fürs automatisches Koppeln
				IF axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.Disabled THEN
					camtable.index := 3;
					axis.cplCam.Execute := FALSE;
					camtable.createCam := TRUE;
					state := ST_GENERATE_TABLE_WAIT;
				ELSIF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN //19.02.15
					state := ST_QUIT;
				ELSIF axis.ctrl.MC_ReadStatus_0.Error OR axis.ctrl.MC_ReadStatus_0.Errorstop THEN
					err.set := TRUE;
					err.state := ST_GENERATE_TABLE_START;
					err.fnc := 'FB_CuttingConfig';
					state := ST_ERROR;
				END_IF
			ELSE
				state := ST_QUIT;
			END_IF

		ST_GENERATE_TABLE_WAIT://36
			camtable(AxisREF := axis.ctrl.AxisREF, CONST := CONST, MasterAxisREF := machineMaster.AxisREF, data := data, scalePerimeter:= scalePerimeter,  Name := status.name );
			IF camtable.done THEN
				camtable.createCam := FALSE;
				state := ST_CPL_TABLE_START;
			ELSIF camtable.err.flag THEN
				err := camtable.err;
				err();
				state := ST_ERROR;
			END_IF
		
		ST_CPL_TABLE_START: //37
			camtable((*createCam := FALSE,*)CONST := CONST, AxisREF := axis.ctrl.AxisREF, MasterAxisREF := machineMaster.AxisREF, data := data, scalePerimeter:= scalePerimeter,  Name := status.name );
			IF axis.ctrl.MC_ReadStatus_0.StandStill  AND camtable.camTableID > 0 AND NOT camtable.done THEN
				axis.cplCam.Master :=  machineMaster.AxisREF;
				axis.cplCam.Slave := axis.ctrl.AxisREF;  
				axis.cplCam.StartMode :=  mcDIRECT;
				axis.cplCam.MasterOffset := 0;// machineMaster.MC_ReadActualPosition_0.Position;(*pMasterAxis.monitor.s mach keinen Sinn da die Kurvenscheibe periodisch ist*) ;
				axis.cplCam.SlaveOffset := 0;
				axis.cplCam.MasterScaling := 1; 
				axis.cplCam.SlaveScaling  := 1;
				axis.cplCam.CamTableID  := camtable.camTableID (*1*);
				state := ST_CPL_EXECUTE;
			ELSIF NOT axis.ctrl.MC_ReadStatus_0.StandStill THEN 
				state := ST_QUIT;
			ELSIF axis.cplCam.Error THEN
				err(set := TRUE ,fnc := 'FB_CuttinConfig' ,text := 'MC_CamIn', state := ST_CPL_TABLE_START, id :=  axis.cplCam.ErrorID);
				axis.cplCam.Execute := FALSE;
				state := ST_ERROR;
			ELSIF camtable.camTableID = 0 THEN
				err(set := TRUE ,fnc := 'FB_CuttinConfig' ,text := 'camtable', state := ST_CPL_TABLE_START, id :=  camtable.err.id);
				state := ST_ERROR;
			END_IF

		ST_CPL_CAMTABLE://38
			axis.cplCam( Master :=  machineMaster.AxisREF, Slave := axis.ctrl.AxisREF);
			axis.cplCam.Execute := TRUE;
			IF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
				axis.cplCam.Execute := FALSE;
				cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;	
				state := ST_QUIT;
			ELSIF axis.cplCam.Error THEN
				axis.cplCam.Execute := FALSE;
				err(set := TRUE ,fnc := 'FB_CuttinConfig' ,text := 'MC_CamIn', state := ST_CPL_TABLE_START, id :=  axis.cplCam.ErrorID);
				state := ST_ERROR;
			ELSIF axis.cplCam.CommandAborted THEN
				axis.cplCam.Execute := FALSE;
				state := ST_CPL_EXECUTE;
			END_IF

		ST_CPL_EXECUTE: //39
			axis.cplCam( Master :=  machineMaster.AxisREF, Slave := axis.ctrl.AxisREF);
			axis.cplCam.Execute := FALSE;
			state := ST_CPL_CAMTABLE;	

		ST_CPLOFF_START://80 (* bei B&R funktioniert der MC_gearout nur mit MC_Gearin deshalb MC_stop*)
			IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				state := ST_ABORT;
			ELSIF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion  THEN
				axis.MC_BR_Phasing_0 (Enable := FALSE, InitData := FALSE); 
				IF NOT 	axis.MC_BR_Phasing_0.Busy THEN
					axis.ctrl.Cmd := CONST.AXIS.STOP;
					IF axis.ctrl.busy THEN
						state := ST_CPLOFF_WAIT;
					END_IF
				END_IF	
			ELSIF axis.ctrl.MC_ReadStatus_0.StandStill THEN
				IF NOT axis.ctrl.busy THEN
					state := ST_CPLOFF_WAIT;
				END_IF
			END_IF

		ST_CPLOFF_WAIT://81
			IF  axis.ctrl.MC_ReadStatus_0.StandStill AND cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
			ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.SETDATA THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				status.isCalibrated := FALSE;
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
				state := ST_SETDATA_START;
			ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.CALIBR THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				status.isCalibrated := FALSE;
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
				state := ST_SETDATA_START;
			ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.INIT THEN
				status.isCalibrated := FALSE;
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				state := ST_INIT_START;
			ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.DEINIT THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				status.isCalibrated := FALSE;
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
				state := ST_DEINIT_CPLSLAVEOFF_START;
			ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.SYNC THEN
				status.isCoupled := FALSE;
				status.isSynchronized := FALSE;
				state := ST_SYNC_START;
			ELSIF axis.ctrl.MC_ReadStatus_0.StandStill AND NOT axis.ctrl.busy AND cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				state := ST_MOVE_START;
			ELSIF axis.ctrl.MC_ReadStatus_0.StandStill AND NOT axis.ctrl.busy  AND cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
				axis.ctrl.Cmd := CONST.AXIS.NOACTION;
				state := ST_MOVE_START;
			ELSE
				state := ST_QUIT;
			END_IF

		ST_DEINIT_CPLSLAVEOFF_START://67
			IF status.isCoupled THEN
				state := ST_CPLOFF_START;
			ELSE
				state := ST_DEINIT;
			END_IF


		ST_DEINIT:
			IF NOT axis.ctrl.busy THEN
				IF axis.ctrl.MC_ReadStatus_0.Error OR axis.ctrl.MC_ReadStatus_0.Errorstop  THEN
					err.state := state;
					state := ST_ERROR;
				ELSE
					status.isInitialized := FALSE;
					status.isSynchronized := FALSE;
					status.isCalibrated := FALSE;
					IF cmdtmp = CONST.CUTTINGUNIT.CMDs.SETDATA THEN
						state := ST_SETDATA_START;
					ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.CALIBR THEN
						state := ST_SETDATA_START;
					ELSIF cmdtmp = CONST.CUTTINGUNIT.CMDs.INIT THEN
						axis.ctrl.Cmd := CONST.AXIS.NOACTION;
						state := ST_INIT_START;
					ELSE 
						axis.ctrl.Cmd := CONST.AXIS.POWER_OFF;
						IF NOT axis.ctrl.busy THEN
							axis.ctrl.Cmd := CONST.AXIS.NOACTION;
							state := ST_QUIT;
						END_IF
					END_IF
				END_IF
			END_IF

//		ST_MOVE_START:// 40 falls die Achse nicht initialisiert ist
//			IF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN 
//				state:= ST_CPLOFF_START;	
//			ELSIF NOT axis.MC_BR_Phasing_0.Busy  AND axis.ctrl.MC_ReadStatus_0.StandStill AND cmd <>  CONST.CUTTINGUNIT.CMDs.NO_CMD  THEN	
//				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
//					axis.ctrl(Cmd := CONST.AXIS.JOG_NEG, Velocity := 3, Acceleration := 120000, Deceleration := 120000,);
//				ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
//					axis.ctrl(Cmd := CONST.AXIS.JOG_POS, Velocity := 3, Acceleration := 120000, Deceleration := 120000);
//				END_IF	
//			ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
//				axis.ctrl(Cmd := CONST.AXIS.NOACTION );
//				state := ST_MOVE_QUIT;
//			END_IF

//***********************neu********************// OKrebs 14.01.16		
		ST_MOVE_START:// 40 falls die Achse nicht initialisiert ist
			IF powerbridge.pressurepresent THEN
			err.set := TRUE;
			err.text := 'cutteraxis unter Druck';
			err.state := state;
			(*	powerbridge.bridgedownbutton.buttonDown.LDT.button := TRUE; *)
			//				state := ST_ERROR;			
			ELSIF NOT axis.MC_BR_Phasing_0.Busy  AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND cmd <>  CONST.CUTTINGUNIT.CMDs.NO_CMD AND NOT powerbridge.pressurepresent THEN					
				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN			
					axis.MC_BR_Phasing_0.Acceleration := 90000;
					axis.MC_BR_Phasing_0.ApplicationMode := mcVELOCITY_CONTROL ;
					axis.MC_BR_Phasing_0.Slave := axis.ctrl.AxisREF;
					axis.MC_BR_Phasing_0.Velocity := - 16666.67 * 3; //1m/min
					axis.MC_BR_Phasing_0.Enable := TRUE;
					axis.MC_BR_Phasing_0.InitData := TRUE;			
					axis.MC_BR_Phasing_0.PerformVelocityControl := TRUE;					
				ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW (*AND TON_0.Q*) THEN
					axis.MC_BR_Phasing_0.Acceleration := 90000;
					axis.MC_BR_Phasing_0.ApplicationMode := mcVELOCITY_CONTROL;
					axis.MC_BR_Phasing_0.Slave := axis.ctrl.AxisREF;
					axis.MC_BR_Phasing_0.Velocity := 16666.67 * 3; //1m/min
					axis.MC_BR_Phasing_0.Enable := TRUE;
					axis.MC_BR_Phasing_0.InitData := TRUE;
					axis.MC_BR_Phasing_0.PerformVelocityControl := TRUE;					
				END_IF	
			ELSIF NOT axis.MC_BR_Phasing_0.Busy  AND axis.ctrl.MC_ReadStatus_0.StandStill AND cmd <>  CONST.CUTTINGUNIT.CMDs.NO_CMD AND NOT powerbridge.pressurepresent THEN	
				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
					axis.ctrl(Cmd := CONST.AXIS.JOG_NEG, Velocity := 3, Acceleration := 120000, Deceleration := 120000);
				ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
					axis.ctrl(Cmd := CONST.AXIS.JOG_POS, Velocity := 3, Acceleration := 120000, Deceleration := 120000);
				END_IF	
			ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.NO_CMD AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
				axis.MC_BR_Phasing_0.Velocity := 0;
				axis.MC_BR_Phasing_0.PerformVelocityControl := FALSE;
				axis.MC_BR_Phasing_0.InitData := FALSE;
				IF axis.MC_BR_Phasing_0.ShiftAttained THEN
					axis.MC_BR_Phasing_0.Enable := FALSE;
					state := ST_QUIT;	
				END_IF
			ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.NO_CMD AND (axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.ContinuousMotion) THEN
				axis.ctrl(Cmd := CONST.AXIS.NOACTION);
				state := ST_QUIT;	
			ELSIF  axis.ctrl.MC_ReadStatus_0.Disabled THEN
				state := ST_QUIT;	
			ELSE 
				
			END_IF

//******************************************************************************
		
		ST_MOVE_WAIT:
			axis.ctrl();
			IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				axis.ctrl(Cmd := CONST.AXIS.NOACTION );
				state := ST_MOVE_QUIT;
			END_IF
		//
		ST_MOVE_QUIT: (* hier evtl. koppeln*)
			//		IF axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.Errorstop 
			//			OR axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.Error THEN
			//			state := ST_QUIT;
			IF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN //AW 19.05.15
				state := ST_QUIT;//Wenn Stanze nicht aktiv dann nicht koppeln
			ELSIF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN OR 
				data.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT THEN
				cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON; 
				cmdtmp := cmd;
				state := ST_GENERATE_TABLE_START;
			END_IF



		ST_CPL_WAIT:
			axis.cplCam( Master :=  machineMaster.AxisREF, Slave := axis.ctrl.AxisREF);
			IF axis.cplCam.Busy AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
				axis.cplCam( Execute := FALSE, Master :=  machineMaster.AxisREF, Slave := axis.ctrl.AxisREF);
				status.isCoupled := TRUE;
				state := ST_QUIT;
			ELSIF axis.cplCam.Error THEN
				err.id := axis.cplCam.ErrorID;
				err.fnc := 'axis.cplCam';
				err.state := state;
				state := ST_ERROR;
			END_IF
		//	
		ST_SYNC_START://70
			timer(PT := T#2s);
			axis.MC_BR_Phasing_0.Enable := FALSE; 
			axis.MC_BR_Phasing_0.InitData := FALSE;
			getNextUnitSyncPos(machineMaster := machineMaster, uAxis := axis.ctrl, markpoints := markpoints, 
			uData := data, scalePerimeter := scalePerimeter, setCutOffset := setCutOffset, CONST := CONST);
			syncDiff := getNextUnitSyncPos.syncDataBefore.correctionNoLimit;
			IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				state := ST_ABORT;
			ELSIF NOT machineMaster.MC_ReadStatus_0.StandStill THEN
				err.set := TRUE;
				err.state := state;
				err.text := 'MasterModulAxis steht nicht';
				state := ST_ERROR;
			ELSIF powerbridge.pressurepresent AND NOT timer.Q THEN
				err.set := TRUE;
				err.text := 'cutteraxis unter Druck';
				err.state := state;
			(*	powerbridge.bridgedownbutton.buttonDown.LDT.button := TRUE; *)
				timer.IN := TRUE;
//				state := ST_ERROR;
			ELSIF timer.IN AND timer.Q THEN 
				timer.IN := FALSE;
			ELSIF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND NOT powerbridge.pressurepresent AND NOT axis.MC_BR_Phasing_0.Active AND NOT axis.MC_BR_Phasing_0.Busy AND syncDiff <> 0 AND NOT timer.Q THEN
				//				getNextUnitSyncPos(machineMaster := machineMaster, uAxis := axis.ctrl, markpoints := markpoints, 
				//									uData := data, scalePerimeter := scalePerimeter, setCutOffset := setCutOffset);
				//				syncDiff := getNextUnitSyncPos.syncDataBefore.correctionNoLimit;
				//				IF syncDiff < -0.1 OR syncDiff > 0.1 THEN
				getNextUnitSyncPos.trigger := TRUE;
				axis.MC_BR_Phasing_0.Enable := TRUE;
				axis.MC_BR_Phasing_0.Acceleration := 90000;
				axis.MC_BR_Phasing_0.ApplicationDistance := scalePerimeter.realperimeter;
				axis.MC_BR_Phasing_0.ApplicationMode := mcTIME_BASED;//1;//mcMASTER_POSITION_BASED;
				axis.MC_BR_Phasing_0.Slave := axis.ctrl.AxisREF;
				axis.MC_BR_Phasing_0.ShiftMode := mcRELATIVE;//1
				axis.MC_BR_Phasing_0.Velocity := 16666.67; //1m/min
				axis.MC_BR_Phasing_0.Shift := syncDiff;// zu korregierende Strecke
				axis.MC_BR_Phasing_0.InitData := TRUE;
				err.text := '';
				state := ST_SYNC_START_CORRECTION;
				
			ELSIF syncDiff = 0 (*AND NOT axis.ctrl.MC_ReadStatus_0.SynchronizedMotion *)THEN //beim ersten Durchlauf wenn keine Marken eingelesen war
				err(set := TRUE, fnc := 'FB_CuttingConfig',text := 'Kein Synchroner Punkt-Marken, neue einlesen', state := ST_SYNC_START);
				state := ST_QUIT;
			ELSIF  axis.ctrl.MC_ReadStatus_0.StandStill THEN //Stanze nicht ist gekoppelt keine Aufsynchronisation möglich
				state := ST_QUIT;
			END_IF

		ST_SYNC_START_CORRECTION: //73

			IF  axis.MC_BR_Phasing_0.Active THEN  
				state := ST_SYNC_WAIT_CORRECTION;
			ELSIF axis.MC_BR_Phasing_0.Error THEN
				err(set := TRUE, fnc := 'MC_BR_Phasing_0 in FB_CuttingConfig',text := 'MC_BR_Phasing_0', state := ST_SYNC_START_CORRECTION, id := axis.MC_BR_Phasing_0.ErrorID);
				axis.MC_BR_Phasing_0.InitData := FALSE;
				state := ST_ERROR;
			END_IF
		//
		ST_SYNC_WAIT_CORRECTION://74
			IF axis.MC_BR_Phasing_0.ShiftAttained THEN
				axis.MC_BR_Phasing_0.InitData := FALSE;
				axis.MC_BR_Phasing_0.Enable := FALSE;
				status.isSynchronized := TRUE;
				getNextUnitSyncPos(machineMaster := machineMaster, 
								uAxis := axis.ctrl,
								markpoints := markpoints, 
								uData := data, 
								scalePerimeter := scalePerimeter, 
								setCutOffset := setCutOffset, CONST := CONST);
				cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;
				
				state := ST_QUIT;
			ELSIF axis.MC_BR_Phasing_0.Error THEN
				err(set := TRUE, fnc := 'MC_BR_Phasing_0 in FB_CuttingConfig',text := 'MC_BR_Phasing_0', state := ST_SYNC_START_CORRECTION, id := axis.MC_BR_Phasing_0.ErrorID);
				axis.MC_BR_Phasing_0.InitData := FALSE;
				state := ST_ERROR;
			END_IF

		

		ST_ERROR:
			err();
			IF LEN(err.fnc) < 1 THEN
				err.fnc := 'FB_CuttingConfig';
			END_IF
			IF cmd = CONST.CUTTINGUNIT.CMDs.RESET THEN
				axis.cplCam( Execute := FALSE, Master :=  machineMaster.AxisREF, Slave := axis.ctrl.AxisREF);
				axis.MC_BR_Phasing_0.Enable := FALSE;
				axis.MC_BR_Phasing_0.InitData:= FALSE;
				InitAxisSubjectPar(Axis := axis.ctrl.AxisREF, Subject := ncDIG_IN,Execute := FALSE);				
				axis.ctrl(Cmd := CONST.AXIS.RESET);
				err(reset:= TRUE);
				state := ST_ABORT_QUIT;
			END_IF

		ST_ABORT:
			state := ST_ABORT_QUIT;

		ST_ABORT_QUIT:
			IF NOT axis.ctrl.busy THEN
				axis.ctrl(Cmd := CONST.AXIS.NOACTION);
				cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;
				state := ST_QUIT;
			END_IF

		ST_QUIT:
			IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				busy := TRUE;
				state := ST_ABORT;
			ELSE
				busy := FALSE;
				IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
					axis.ctrl.Cmd := CONST.AXIS.NOACTION;
					state := ST_IDLE;
				END_IF
				
			END_IF
	
	END_CASE
	axis.MC_BR_Phasing_0();	
	InitAxisSubjectPar.Axis := axis.ctrl.AxisREF;
	InitAxisSubjectPar();

END_FUNCTION_BLOCK