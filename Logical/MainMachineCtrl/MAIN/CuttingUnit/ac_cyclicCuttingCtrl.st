(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_cyclicCuttingCtrl.st
 * Autor: awalz
 * Erstellt: 25. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_cyclicCuttingCtrl: 
	markpoints.TriggerInput.Edge			:= ncP_EDGE;
	markpoints.TriggerInput.EventSourceParID:= ACP10PAR_STAT_TRIGGER1;
	markpoints.TriggerInput.MaxWidth		:= 0;
	markpoints.TriggerInput.MinWidth		:= 0;
	markpoints.TriggerInput.ProbeParID		:= ACP10PAR_MA1_CYCLIC_POS;
	markpoints.TriggerInput.SensorDelay	:= -900;
//	getNextCuttPos.setCutOffset.maxcorrection :=  REAL_TO_UDINT(data.general.periodLength /2);
//	getNextCuttPos.ProductLength := REAL_TO_UDINT(data.general.periodLength);
//	getNextCuttPos.DistanceToSensor := data.machdata.position; (*540000;*)
//	axis.ctrl();
//	cmdCtrl();
//	emcy_inputs();
//	status.isCoupled := axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;
//	status(dataOk := data.loaded, recipeMode := data.recipe.mode, axisState := axis.ctrl.MC_ReadStatus_0);
//	scalePerimeter.realperimeter := UINT_TO_REAL (data.recipe.tool.cogCutting )* data.recipe.tool.cogmodul;
//	scalePerimeter.NumberToolSegments := MAX (1, data.recipe.tool.numberToolSegments);
//	scalePerimeter();
//
//	IF ABS (getNextCuttPos.PositionError) < 5000 THEN
//		status.isSynchronized := TRUE;
//	ELSE 
//		status.isSynchronized := FALSE;
//	END_IF
//	IF powerbridge.movebutton.LDT.button THEN 
//		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.MOVEFW;
//	ELSIF  powerbridge.movebutton.LDT.ftrig.Q THEN
//		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
//	END_IF
//	status.errorstop := axis.ctrl.MC_ReadStatus_0.Errorstop; 
//	IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET AND axis.ctrl.MC_ReadStatus_0.Errorstop THEN
//		axis.ctrl.cmd := CONST.AXIS.RESET;
//	ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET AND axis.ctrl.MC_ReadStatus_0.Disabled THEN
//		axis.ctrl.cmd := CONST.AXIS.POWER_ON;
//	END_IF
////////////////////////////////////////////TRIGGER füür den Touchprobe/////////////////////
//	Trigger.Axis						:= axis.ctrl.AxisREF; (*machineMaster.AxisREF;*)
//	Trigger.PositionSensor				:= data.machdata.position;
//	Trigger.TriggerInput.Edge			:= ncP_EDGE;
//	Trigger.TriggerInput.EventSourceParID:= ACP10PAR_STAT_TRIGGER1;
//	Trigger.TriggerInput.MaxWidth		:= 0; (*data.recipe.RmWindow;*)
//	Trigger.TriggerInput.MinWidth		:= 0;(*-data.recipe.RmWindow;*)
//	Trigger.TriggerInput.ProbeParID		:= ACP10PAR_MA1_CYCLIC_POS;
//	Trigger.TriggerInput.SensorDelay	:= -900;
//	markpoints.Axis    					:= axis.ctrl.AxisREF; (*machineMaster.AxisREF;*)
////	markpoints.DistanceToSensor			:= data.machdata.position; (* Distanz zum zwischen Schneidposition und dem Sensor*)
//	markpoints.ProductLength			:= data.general.periodLength;
//	markpoints.TriggerInput				:= Trigger.TriggerInput;(*wird in der Main bereits zugewiesen*)
//	markpoints.WindowNegative			:= data.recipe.RmWindow;(*- data.recipe.RmWindow;*)
//	markpoints.WindowPositive			:= data.recipe.RmWindow;
//	(*markpoints.RegMarkPosition  := usercorrection; (* Offset des Schnitts von der VISU*)
//	markpoints.Enable			:= TRUE;
//	markpoints();
//
//
////	data.check(general := data.general, machdata := data.machdata, modeCtrl := modeCtrl, recipe := data.recipe);
//	powerbridge (clk := clk);


	scalePerimeter.realperimeter := UINT_TO_REAL (data.recipe.tool.cogCutting )* data.recipe.tool.cogmodul;
	scalePerimeter.NumberToolSegments := MAX (1, data.recipe.tool.numberToolSegments);
	scalePerimeter();
	setCutOffset( enable := TRUE, maxcorrection := data.recipe.MaxCorr, limitvisupos := data.general.periodLength/1000, limitvisuneg := -data.general.periodLength/1000);
	axis.ctrl();
	cmdCtrl();
	emcy_inputs();
	//	status.isCoupled := axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;
	status(dataOk := data.loaded, recipeMode := data.recipe.mode, 
	axisState := axis.ctrl.MC_ReadStatus_0);
	scalePerimeter(realperimeter := UINT_TO_REAL (data.recipe.tool.cogCutting) * data.recipe.tool.cogmodul,
	NumberToolSegments := MAX (1,data.recipe.tool.numberToolSegments));
	IF emcy_inputs.EMCY_Door1 AND emcy_inputs.EMCY_Door2 THEN
		emcy_inputs.EMCY_DoorsClosed := TRUE;
	ELSE
		emcy_inputs.EMCY_DoorsClosed := FALSE;
	END_IF

	IF  status.isCalibrated AND NOT config.busy AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
		modeCtrl(machineMaster := machineMaster, mode := data.recipe.mode, axis := axis, getNextUnitSyncPos := getNextUnitSyncPos, data:= data, status := status, scalePerimeter := scalePerimeter, 
		markpoints := markpoints, syncData := getNextUnitSyncPos.syncDataBefore, camCtrl := camCtrl , setCutOffset := setCutOffset);
	ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN
		modeCtrl(machineMaster := machineMaster, mode := CONST.CUTTINGUNIT.MODEs.DISABLE, axis := axis, getNextUnitSyncPos := getNextUnitSyncPos, data:= data, status := status, scalePerimeter := scalePerimeter, 
		markpoints := markpoints, syncData := getNextUnitSyncPos.syncDataBefore, camCtrl := camCtrl , setCutOffset := setCutOffset);
	ELSE 
		modeCtrl(machineMaster := machineMaster, mode := CONST.CUTTINGUNIT.MODEs.DISABLE, axis := axis, getNextUnitSyncPos := getNextUnitSyncPos, data:= data, status := status, scalePerimeter := scalePerimeter, 
		markpoints := markpoints, syncData := getNextUnitSyncPos.syncDataBefore, camCtrl := camCtrl , setCutOffset := setCutOffset);
	END_IF
//
//	IF ABS (getNextCuttPos.PositionError) < 5000 THEN
//		status.isSynchronized := TRUE;
//	ELSE 
//		status.isSynchronized := FALSE;
//	END_IF    

	IF powerbridge.movebutton.LDT.button THEN 
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.MOVEFW;
	ELSIF  powerbridge.movebutton.LDT.ftrig.Q THEN
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
	END_IF
	status.errorstop := axis.ctrl.MC_ReadStatus_0.Errorstop; 
	IF (cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET OR panel.LDTRESET.LDT.button) AND axis.ctrl.MC_ReadStatus_0.Errorstop THEN
		axis.ctrl.Cmd := CONST.AXIS.RESET;
	ELSIF (cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET OR panel.LDTRESET.LDT.button)AND axis.ctrl.MC_ReadStatus_0.Disabled THEN
		axis.ctrl.Cmd := CONST.AXIS.POWER_ON;
	END_IF

	//	(*markpoints.RegMarkPosition  := usercorrection; (* Offset des Schnitts von der VISU*)
	markpoints(Axis	:= axis.ctrl.AxisREF, Enable:= TRUE,
	ProductLength 	:= data.general.periodLength, 
	WindowNegative 	:= data.recipe.RmWindow,
	WindowPositive	:= data.recipe.RmWindow);
	powerbridge ((*enable := TRUE,*) clk := clk);
END_ACTION