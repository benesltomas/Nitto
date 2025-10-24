(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: MAIN.st
 * Autor: Awalz
 * Erstellt: 25. März 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************)
PROGRAM _INIT
	gNewOutputBrake;
	(* Zuweisung der Achsvar*)
	machine.masterModul.axis.AxisREF:= ADR(gMaster1); 
	machine.UnwinderUnit.unwinderDrv.unwinderaxis.AxisREF := ADR (gUnwDrv);
	machine.UnwinderUnit.unwinderOp.unwinderaxis.AxisREF := ADR (gUnwOp);
	
	machine.webbuffer.axis.ctrl.AxisREF := ADR(gBuffer);
	machine.webbuffer.axis.bufferaxis.AxisREF := ADR(gBuffer);
	machine.webbuffer.axis.refSwitchConfig.Axis := ADR(gBuffer);
	
	
	machine.pullbreak.axis.ctrl.AxisREF:= ADR (gPBS1);
	machine.pullbreakSt.axis.ctrl.AxisREF := ADR (gPBS2);
	machine.UnwinderUnit.feederCtrl.axisREF := ADR(gUnwFeeder);
	// neu // OKrebs // 23.11.16
	machine.packbelt.ctrl.axisREF := ADR(gPackBelt);
	// ende neu
	machine.cuttingunit1.axis.ctrl.AxisREF := ADR(gCut1);
	machine.cuttingunit1.axis.refSwitchConfig.Axis := ADR(gCut1);

//	machine.cuttingunit1.markpoints.TriggerInput.Edge			:= ncP_EDGE;
//	machine.cuttingunit1.markpoints.TriggerInput.EventSourceParID:= ACP10PAR_STAT_TRIGGER1;
//	machine.cuttingunit1.markpoints.TriggerInput.MaxWidth		:= 0;
//	machine.cuttingunit1.markpoints.TriggerInput.MinWidth		:= 0;
//	machine.cuttingunit1.markpoints.TriggerInput.ProbeParID		:= ACP10PAR_MA1_CYCLIC_POS;
//	machine.cuttingunit1.markpoints.TriggerInput.SensorDelay	:= -25;

	
	machine.turngridwinder.gridwinderleft.axis.AxisREF := ADR(gGridLeft);
	machine.turngridwinder.gridwinderright.axis.AxisREF := ADR(gGridRight);
	machine.turngridwinder.feeder.AxisREF := ADR(gGridFeeder);
	// neu // OKrebs // 13.04.17
	machine.turngridwinder.ctrl.refSwitchConfig.Axis := ADR(gGridFeeder);
	machine.turngridwinder.ctrl.SwitchConfig.Axis := ADR(gGridFeeder);
	// ende neu
	machine.longcutter.axis.ctrl.AxisREF := ADR(gLongCut);
	
	machine.cuttingunit2.axis.ctrl.AxisREF := ADR (gCut2);
	machine.cuttingunit2.axis.refSwitchConfig.Axis := ADR (gCut2);

	machine.cuttingunit2.markpoints.TriggerInput.Edge			:= ncP_EDGE;
	machine.cuttingunit2.markpoints.TriggerInput.EventSourceParID:= ACP10PAR_STAT_TRIGGER1;
	machine.cuttingunit2.markpoints.TriggerInput.MaxWidth		:= 0;
	machine.cuttingunit2.markpoints.TriggerInput.MinWidth		:= 0;
	machine.cuttingunit2.markpoints.TriggerInput.ProbeParID		:= ACP10PAR_MA1_CYCLIC_POS;
	machine.cuttingunit2.markpoints.TriggerInput.SensorDelay	:= -900;
	
	machine.catchbelt.axis.ctrl.AxisREF := ADR(gCatchBelt);
	
	machine.conveyor.axis.ctrl.AxisREF := ADR (gConvBelt);
	machine.gVarMachine.gMachine := gMachine;
	
	machine.UnwinderUnit.unwinderOp.data.machData.GEAR_RATIO := 8;
	
	machine.UnwinderUnit.unwinderDrv.data.machData.GEAR_RATIO := 8;
	
	machine.turngridwinder.gridwinderleft.data.machData.GEAR_RATIO := 3;
	
	machine.turngridwinder.gridwinderright.data.machData.GEAR_RATIO := 3;
	
	machine.webbuffer.data.machData.GEAR_RATIO := 12;
	
	LayerStatus						:= 1;
	
	machine.cuttingunit2.data.recipe.MaxCorr := 200000;


	// Beim Einschalten wird das aktuelle Rezept und Maschinendaten in die MAIN-Bausteinvariablen geladen //////	
	ac_loadRecipeMain;
	ac_saveMachData;
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	machine.cuttingunit1.data.recipe.tool.gearRatioMotor := 5;
	machine.cuttingunit1.data.recipe.tool.cogmodul :=3175.0;
	machine.cuttingunit2.data.recipe.tool.gearRatioMotor := 5;
	machine.cuttingunit2.data.recipe.tool.cogmodul :=3175.0;
END_PROGRAM

	
PROGRAM _CYCLIC
(*machine.cuttingunit1.axis.ctrl.ACP10AXIS := gCut1;*)
//machine.IOs.aIn := gMachine.IO.AIn;
//machine.IOs.aOut := gMachine.IO.AOut;
//machine.IOs.dIn := gMachine.IO.DIn;
//machine.IOs.dOut := gMachine.IO.DOut;
//machine.cuttingunit1.data.recipe := gApplRecipe.cutUnit1; (*Rezepte sind noch nicht bereit*)
	machine.UnwinderUnit.feederCtrl.UnwFeeder_DiDoIf := gUnwFeeder_DiDoIf;	
	machine.UnwinderUnit.feederCtrl.UnwFeeder_DrvIf := gUnwFeeder_DrvIf; 
// 24.7.2024 - Change braking DO logic ---	gUnwFeeder_DrvIf.oBrake := machine.UnwinderUnit.feederCtrl.UnwFeeder_DrvIf.oBrake;
	machine.UnwinderUnit.feederCtrl.UnwFeeder_HW  := gUnwFeeder_HW;  
	machine.UnwinderUnit.feederCtrl.UnwFeeder_ModuleOk := gUnwFeeder_ModuleOk;

	/// neu // OKrebs // 23.11.16
	machine.packbelt.ctrl.PackBelt_DiDoIf := gPackBelt_DiDoIf;
	machine.packbelt.ctrl.PackBelt_DrvIf := gPackBelt_DrvIf;
	machine.packbelt.ctrl.PackBelt_HW := gPackBelt_HW;
	machine.packbelt.ctrl.PackBelt_ModuleOk := gPackBelt_ModuleOk;
// 24.7.2024 - Change braking DO logic ---	gUnwFeeder_DrvIf.oBrake := machine.packbelt.ctrl.PackBelt_DrvIf.oBrake;
	// ende neu	
	
	// 24.7.2024 - Change braking DO logic
	IF machine.packbelt.ctrl.PackBelt_DrvIf.oBrake OR machine.UnwinderUnit.feederCtrl.UnwFeeder_DrvIf.oBrake THEN
		gUnwFeeder_DrvIf.oBrake := TRUE;
		LocalNewOutputBrake := TRUE;
		gNewOutputBrake := TRUE;
		
	ELSIF  machine.packbelt.ctrl.PackBelt_DrvIf.oBrake = 0 AND machine.UnwinderUnit.feederCtrl.UnwFeeder_DrvIf.oBrake = 0 THEN
		gUnwFeeder_DrvIf.oBrake := FALSE;
		LocalNewOutputBrake := FALSE;
		gNewOutputBrake := FALSE;
	END_IF;
	

	
	
	
	// neu // OKrebs // 26.04.17
	TOF_OutputGrinderON(IN := machine.masterModul.axis.MC_ReadStatus_0.ContinuousMotion, PT := T#60s);
	OutputGrinderON := TOF_OutputGrinderON.Q;
	// ende neu
	// neu // OKrebs // 27.04.17
	machine.conveyor.counters.manualButton := machine.packbelt.ctrl.buttonStart;
	// neu ende
	//	machine.cuttingunit1.data.machdata := gMachRecipe.cut1; 
	//
	//	machine.cuttingunit1.data.recipe.mode := 1 ;
	//	machine.cuttingunit1.data.recipe.markPointNo := 1;
	//	machine.cuttingunit1.data.recipe.MaxCorr := 300000;
	//	machine.cuttingunit1.data.recipe.tool.numberToolSegments := 1;
	//	machine.cuttingunit1.data.recipe.toolNumber :=1;
	//	machine.cuttingunit1.data.recipe.tool.cogCutting := 145;(*Werkzeug*)
	//	machine.cuttingunit1.data.recipe.tool.cogSupportSpindle := 160;(*Stützwelle*)
	//	machine.cuttingunit1.data.recipe.tool.cutEndPosition := 300000; (*Umfang = 460,375*)
	//	machine.cuttingunit1.data.recipe.tool.cutStartPosition := 0;
	//	machine.cuttingunit1.data.general.periodLength := 460000; (* 460000 *)
	//	machine.cuttingunit1.data.general.startVelocity := 10000;
	//	machine.cuttingunit1.data.general.maxVelocity := 40000;
	//	machine.cuttingunit1.data.general.masterAcceleration := 60000;
	//	machine.cuttingunit1.data.general.masterDeceleration := 60000;
	
	//machine.cuttingunit2.data.recipe := gApplRecipe.cutUnit2;
	//machine.cuttingunit2.data.machdata := gMachRecipe.cut2; 
	//
	//	machine.cuttingunit2.data.recipe.mode := 3;
	//	//machine.cuttingunit2.data.recipe.MaxCorr := 30000;
	//	machine.cuttingunit2.data.recipe.tool.numberToolSegments := 1;
	//	machine.cuttingunit2.data.recipe.toolNumber :=1;
	//	machine.cuttingunit2.data.recipe.tool.cogCutting := 189;(*Werkzeug*)
	//	machine.cuttingunit2.data.recipe.tool.cogSupportSpindle := 160;(*Stützwelle*)
	//	machine.cuttingunit2.data.recipe.tool.cutEndPosition := 550000; (*Umfang = 460,375*)
	//	machine.cuttingunit2.data.recipe.tool.cutStartPosition := 50000;(*20000*)
	//	
	//	machine.cuttingunit2.data.general.periodLength := 430000; (*410000; TEst*)
	//	machine.cuttingunit2.data.recipe.RmWindow := 30000;
	//	machine.cuttingunit2.data.machdata.position := 540000;
	
	///////////////////  Rezept aktivieren ////////////////////////////////////////////////////////////////////////////////////	
	IF gMachine.Command.UpdateRecipe AND (machine.ctrl.mode.ctrl.value = CONST.MACHINEMODES.MANUAL OR machine.ctrl.mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP) THEN
		gMachine.Command.UpdateRecipe := FALSE;
		ac_loadRecipeMain;
	END_IF
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/////////////  Kopieren der Rezeptdaten aus MAIN zu RecipeEdit (Laden aus Maschine Button) ////////////////////////////
	IF Button.F3 = 1 AND machine.ctrl.mode.ctrl.value = CONST.MACHINEMODES.MANUAL THEN
		Button.F3 := 0;
		ac_loadMach_toRecipeMain;
	END_IF
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	///////////// Speichern der Maschienendaten von gMachData zu MAIN-Variablen	///////////////////////////////////////////
	IF SaveMachData AND (machine.ctrl.mode.ctrl.value = CONST.MACHINEMODES.MANUAL OR machine.ctrl.mode.ctrl.value = CONST.MACHINEMODES.EMERGENCYSTOP) THEN
		SaveMachData := FALSE;
		ac_saveMachData;
	END_IF
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	machine.cuttingunit2.markpoints();
	machine(); (* Aufruf der Machine bzw. des FB_Machine*)
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	IF machine.UnwinderUnit.unwinderDrv.data.recipeData.mode = 1 THEN
		machine.IOs.Unwinder_Drv_Led := TRUE;
	ELSE
		machine.IOs.Unwinder_Drv_Led := FALSE;
	END_IF
	
	IF machine.UnwinderUnit.unwinderOp.data.recipeData.mode = 1 THEN
		machine.IOs.Unwinder_OP_Led := TRUE;
	ELSE
		machine.IOs.Unwinder_OP_Led := FALSE;
	END_IF
	
	UnwinderOPModeTrig(CLK :=machine.IOs.Unwinder_OP_Button );
	
	IF UnwinderOPModeTrig.Q = TRUE AND machine.UnwinderUnit.unwinderOp.data.recipeData.mode = 2 THEN
		machine.UnwinderUnit.unwinderOp.data.recipeData.mode := 1;
	ELSE
		IF UnwinderOPModeTrig.Q = TRUE AND machine.UnwinderUnit.unwinderOp.data.recipeData.mode = 1 THEN
			machine.UnwinderUnit.unwinderOp.data.recipeData.mode :=2;
		ELSE
		END_IF
	END_IF
	
	UnwinderDRVModeTrig(CLK:=machine.IOs.Unwinder_Drv_Button );
	
	IF UnwinderDRVModeTrig.Q = TRUE AND machine.UnwinderUnit.unwinderDrv.data.recipeData.mode = 2 THEN
		machine.UnwinderUnit.unwinderDrv.data.recipeData.mode := 1;
	ELSE
		IF UnwinderDRVModeTrig.Q = TRUE AND machine.UnwinderUnit.unwinderDrv.data.recipeData.mode = 1 THEN
			machine.UnwinderUnit.unwinderDrv.data.recipeData.mode :=2;
		ELSE
		END_IF
	END_IF
	machine.IOs.aIn.Dancer_position.Config.ScaleGain := 0.03357;
	machine.IOs.aIn.Dancer_position.Config.ScaleOffset := 200;
	machine.IOs.aIn.Dancer_position.Value.Scaled := machine.IOs.aIn.Dancer_position.Value.RawInt*machine.IOs.aIn.Dancer_position.Config.ScaleGain-machine.IOs.aIn.Dancer_position.Config.ScaleOffset;
	
	IF EDGENEG(gMachine.IO.DIn.Liner_detekce.Value.State)AND machine.masterModul.axis.MC_ReadActualVelocity_0.Velocity > 0.0 THEN
		machine.ctrl.alarms.alarmlist[49] := TRUE;
	END_IF
	
	
	IF gMachine.IO.DIn.LDT_FaultReset.Value.InVal OR machine.masterModul.axis.MC_ReadActualVelocity_0.Velocity = 0.0 THEN
		machine.ctrl.alarms.alarmlist[49] := FALSE;
	END_IF
	

END_PROGRAM