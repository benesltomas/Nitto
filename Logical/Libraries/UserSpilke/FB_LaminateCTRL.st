(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_LaminateCTRL.st
 * Autor: Awalz
 * Erstellt: 9. Januar 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_LaminateCTRL
	CASE StateCtrl OF
	(*	CTRL_FIRST_START:	
			unitAxis.AxisStep := STATE_POWER_ON;
			unitAxis.MC_ReadStatus_0.Enable := TRUE;
		(*	IF (NOT Enable) THEN	
				Error		:= FALSE;
				ErrorID		:= 0;
				IS.State	:= SPR_STATE_DISABLED;
			ELSIF (IS.SPR_RmCapture_0.Error) THEN
				ErrorID		:= IS.SPR_RmCapture_0.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
			ELSIF (IS.MC_BR_CrossCutterControl_0.Error) THEN	
				ErrorID		:= IS.MC_BR_CrossCutterControl_0.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
			ELSIF (IS.MC_BR_Phasing_0.Error) THEN
				ErrorID		:= IS.MC_BR_Phasing_0.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
			ELSIF (IS.MC_BR_ReadAutPosition_0.Error) THEN
				ErrorID		:= IS.MC_BR_ReadAutPosition_0.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
			ELSIF (IS.MC_MoveAbsolute_0.Error) THEN	
				ErrorID		:= IS.MC_MoveAbsolute_0.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
			ELSIF (IS.MC_ReadParameter_AxisPeriod.Error) THEN
				ErrorID		:= IS.MC_ReadParameter_AxisPeriod.ErrorID;
				Error		:= TRUE;
				IS.State	:= SPR_STATE_ERROR;
		(*	status := unitAxis.MC_ReadStatus_0.ErrorID ;*)
		
	(*	CTRL_MANUAL_BEFORE: ;
		(*unitAxis.BasicControl.*)
			
	(*	CTRL_MANUAL: ;
			unitAxis.MC_GearIn_0.Execute := TRUE;
			unitAxis.MC_GearIn_0.Master := machineMaster;
			(*unitAxis.MC_GearIn_0.Slave := 
			(*IF unitAxis.MC_ReadAxisError_0 = AxisCMD
		CTRL_MANUAL_BEFORE:
			unitAxis.AxisStep := AxisCMD
			
		(*	unitAxis.Axis1Obj 	:= 
			(*cutterAxis.drvCtrl.ncError(InstanceId := status.id, StationName := status.name, ErrorId := CONST.CUTTINGUNIT.ERRORS.AXISERROR);
			cutterAxis.drvCtrl.safetySpeedMessage(InstanceId := status.id, StationName := status.name, ErrorId := CONST.CUTTINGUNIT.ERRORS.SAFETY_SPEED);
			schutzhauben.vorn.err(InstanceId := status.id, StationName := status.name, ErrorId := CONST.CUTTINGUNIT.ERRORS.HAUBE1_VORN_OFFEN );
			schutzhauben.hinten.err(InstanceId := status.id, StationName := status.name, ErrorId := CONST.CUTTINGUNIT.ERRORS.HAUBE2_HINTEN_OFFEN );
			data.tool.calcPerimeters();

			status.Init(recipeMode := data.recipe.mode);
			busy := TRUE;
			StateCtrl := CTRL_EMERGENCYSTOP_BEFORE;*)

	END_CASE
		
	
	
END_FUNCTION_BLOCK