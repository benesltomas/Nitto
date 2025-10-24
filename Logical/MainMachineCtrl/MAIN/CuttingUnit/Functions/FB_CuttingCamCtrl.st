(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CuttingCamCtrl.st
 * Autor: awalz
 * Erstellt: 20. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_CuttingCamCtrl
	getNextUnitSyncPos (uData := data, machineMaster := machineMaster,  markpoints := markpoints, uAxis := axis.ctrl, scalePerimeter := scalePerimeter, setCutOffset := setCutOffset, CONST := CONST);
	syncData := getNextUnitSyncPos.syncDataBefore;
	
	CASE state OF
		0:
			IF enable THEN
				IF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
					axis.MC_BR_Phasing_0(Enable := FALSE,Slave:=axis.ctrl.AxisREF);
					IF syncData.markIndx <> actSyncPosIdent THEN 
						axis.MC_BR_Phasing_0.Enable 		:= TRUE;
						axis.MC_BR_Phasing_0.Velocity		:= LIMIT (30000, (machineMaster.MC_ReadActualVelocity_0.Velocity ), 1000000);
						axis.MC_BR_Phasing_0.Acceleration 	:= 2500000; (*150000;*)
						IF ABS (syncData.correctionNoLimit) < 1000 THEN // wenn die Abweichung kleiner als 1mm dann synchronisiert melden
							status.isSynchronized := TRUE;
						ELSE 
							status.isSynchronized := FALSE;
						END_IF
						////					(*DAs Phasing geschieht in scalePerimeter.ToolSegmentPeriod - 120000 | -120000 um dem System zeit zu gebne das Erfolgreiche Phasen zu erfassen und für ein erneutes bereit zu sein *)
						axis.MC_BR_Phasing_0.ApplicationDistance :=  data.general.periodLength -30000;//   scalePerimeter.ToolSegmentPeriod - 20000; 
						axis.MC_BR_Phasing_0.ApplicationMode	:= mcMASTER_DISTANCE_BASED (*mcMASTER_POSITION_BASED*);
						axis.MC_BR_Phasing_0.ShiftMode		:= mcRELATIVE(*mcABSOLUTE*);
						axis.MC_BR_Phasing_0.Shift 			:= LIMIT (-data.recipe.MaxCorr, syncData.correctionNoLimit,data.recipe.MaxCorr);
						axis.MC_BR_Phasing_0.InitData 		:= TRUE;				
						(*	IF axis.MC_BR_Offset_0.DataInitialized THEN*)
						actSyncPosIdent := syncData.markIndx;
						usercorrtemp	:= 	usercorrection;
						counter := counter + 1;
						state := 1;
						(*END_IF*)
					END_IF
				END_IF
		
			END_IF


		1:	IF enable THEN
				IF 	axis.MC_BR_Phasing_0.ShiftAttained THEN
					donecounter := donecounter + 1;
					axis.MC_BR_Phasing_0.InitData := FALSE;
					axis.MC_BR_Phasing_0.Enable := FALSE;
					shiftValuetmp := axis.MC_BR_Phasing_0.ActualShiftValue;
					state := 0;
				ELSIF axis.MC_BR_Phasing_0.Error THEN 
					axis.MC_BR_Phasing_0.InitData := FALSE;
					axis.MC_BR_Phasing_0.Enable 	:= FALSE;
					errorcounter := errorcounter + 1;
					state := 0;
				END_IF
			ELSE 
				axis.MC_BR_Phasing_0.InitData := FALSE;
				axis.MC_BR_Phasing_0.Enable := FALSE;
				shiftValuetmp := axis.MC_BR_Phasing_0.ActualShiftValue;
				errorcounter := errorcounter + 1;
				state := 0;
			END_IF
	

	END_CASE
	axis.MC_BR_Phasing_0();
END_FUNCTION_BLOCK