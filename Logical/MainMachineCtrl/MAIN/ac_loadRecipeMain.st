(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_loadRecipeMain.st
 * Autor: awalz
 * Erstellt: 29. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_loadRecipeMain: 

		// cutting units
		memcpy(ADR(machine.cuttingunit1.data.recipe),ADR(gApplRecipe.cutUnit1),SIZEOF(machine.cuttingunit1.data.recipe));
		memcpy(ADR(machine.cuttingunit2.data.recipe),ADR(gApplRecipe.cutUnit2),SIZEOF(machine.cuttingunit2.data.recipe));
		memcpy(ADR(machine.cuttingunit1.data.general),ADR(gApplRecipe.general),SIZEOF(machine.cuttingunit1.data.general));
		memcpy(ADR(machine.cuttingunit2.data.general),ADR(gApplRecipe.general),SIZEOF(machine.cuttingunit2.data.general));
		memcpy(ADR(machine.cuttingunit1.data.machdata),ADR(gMachRecipe.cut1),SIZEOF(machine.cuttingunit1.data.machdata));
		memcpy(ADR(machine.cuttingunit2.data.machdata),ADR(gMachRecipe.cut2),SIZEOF(machine.cuttingunit2.data.machdata));
//		machine.cuttingunit2.ctrl.getNextCuttPos.setCutOffset.UpdateRecipe := TRUE;
//		machine.cuttingunit2.ctrl.getNextCuttPos.setCutOffset.setvalueVisuRecipe := gApplRecipe.cutUnit2.RmOffset;
	(*	machine.cuttingunit1.data.machdata.position := 1000000;*)
		machine.cuttingunit1.data.general.periodLength := gApplRecipe.general.periodLength;
		machine.cuttingunit1.data.recipe.tool.gearRatioMotor := 5;(* weil die mit 0 überschrieben werden da der Krebs wieder Misst gebaut hat*)
		machine.cuttingunit1.data.recipe.tool.cogmodul :=3175.0;
		machine.cuttingunit1.data.newRecipe := TRUE;
		machine.cuttingunit2.data.recipe.tool.gearRatioMotor := 5;
		machine.cuttingunit2.data.recipe.tool.cogmodul :=3175.0;
	(*	machine.cuttingunit2.data.machdata.position := 3400000;*)
		machine.cuttingunit2.data.general.periodLength := gApplRecipe.general.periodLength;
		machine.cuttingunit2.markpoints.RegMarkPosition := -540000;
		machine.cuttingunit2.data.machdata.position := 850000;
		machine.cuttingunit2.data.newRecipe := TRUE;
//		machine.cuttingunit2.markpoints.RegMarkPosition := -540000; //Abstand vom Sensor zu Stanzmitte


		machine.masterModul.data.lenght1 := gApplRecipe.general.lenght1;
		machine.masterModul.data.lenght1 := gApplRecipe.general.lenght1;
	
		// master // general
		machine.masterModul.data.maxSpeed := gApplRecipe.general.maxVelocity;
		machine.masterModul.data.periodLength := gApplRecipe.general.periodLength;
		machine.masterModul.data.startSpeed := gApplRecipe.general.startVelocity;
		machine.masterModul.data.lenght1 := gApplRecipe.general.lenght1;
		machine.masterModul.data.lenght2 := gApplRecipe.general.lenght2;
		machine.masterModul.data.speedToCycleWebturrit := gApplRecipe.general.speedToCycleWebturrit;
	
		// unwinder drive side
		machine.UnwinderUnit.unwinderDrv.data.recipeData.maxDiamTension := gApplRecipe.UnwinderDrvSide.maxDiamTension;
		machine.UnwinderUnit.unwinderDrv.data.recipeData.minDiamTension := gApplRecipe.UnwinderDrvSide.minDiamTension;
		machine.UnwinderUnit.unwinderDrv.data.recipeData.mode := gApplRecipe.UnwinderDrvSide.mode;
		machine.UnwinderUnit.unwinderDrv.data.recipeData.reverse := gApplRecipe.UnwinderDrvSide.reverse;
		machine.UnwinderUnit.unwinderDrv.data.recipeData.warnDiam := gApplRecipe.UnwinderDrvSide.warnDiam;
		machine.UnwinderUnit.unwinderDrv.data.recipeData.stopDiam := gApplRecipe.UnwinderDrvSide.stopDiam;
		machine.UnwinderUnit.unwinderDrv.data.machData.axistyp := 1;	(*(-1: winder, +1: unwinder).*)
		// unwinder op side
		machine.UnwinderUnit.unwinderOp.data.recipeData.maxDiamTension := gApplRecipe.UnwinderOpSide.maxDiamTension;
		machine.UnwinderUnit.unwinderOp.data.recipeData.minDiamTension := gApplRecipe.UnwinderOpSide.minDiamTension;
		machine.UnwinderUnit.unwinderOp.data.recipeData.mode := gApplRecipe.UnwinderOpSide.mode;
		machine.UnwinderUnit.unwinderOp.data.recipeData.reverse := gApplRecipe.UnwinderOpSide.reverse;
		machine.UnwinderUnit.unwinderOp.data.recipeData.warnDiam := gApplRecipe.UnwinderOpSide.warnDiam;
		machine.UnwinderUnit.unwinderOp.data.recipeData.stopDiam := gApplRecipe.UnwinderOpSide.stopDiam;
		machine.UnwinderUnit.unwinderOp.data.machData.axistyp := 1;(*(-1: winder, +1: unwinder).*)
		// grid winder left
		machine.turngridwinder.gridwinderleft.data.recipeData.maxDiamTension := gApplRecipe.gridwinderleft.maxDiamTension;
		machine.turngridwinder.gridwinderleft.data.recipeData.minDiamTension := gApplRecipe.gridwinderleft.minDiamTension;
		machine.turngridwinder.gridwinderleft.data.recipeData.mode := gApplRecipe.gridwinderleft.mode;
		machine.turngridwinder.gridwinderleft.data.recipeData.reverse := gApplRecipe.gridwinderleft.reverse;
		machine.turngridwinder.gridwinderleft.data.recipeData.warnDiam := gApplRecipe.gridwinderleft.warnDiam;
		machine.turngridwinder.gridwinderleft.data.recipeData.stopDiam := gApplRecipe.gridwinderleft.stopDiam;
		machine.turngridwinder.gridwinderleft.data.machData.axistyp := - 1;(*(-1: winder, +1: unwinder).*)
		
		// grid winder right
		machine.turngridwinder.gridwinderright.data.recipeData.maxDiamTension := gApplRecipe.gridwinderright.maxDiamTension;
		machine.turngridwinder.gridwinderright.data.recipeData.minDiamTension := gApplRecipe.gridwinderright.minDiamTension;
		machine.turngridwinder.gridwinderright.data.recipeData.mode := gApplRecipe.gridwinderright.mode;
		machine.turngridwinder.gridwinderright.data.recipeData.reverse := gApplRecipe.gridwinderright.reverse;
		machine.turngridwinder.gridwinderright.data.recipeData.warnDiam := gApplRecipe.gridwinderright.warnDiam;
		machine.turngridwinder.gridwinderright.data.recipeData.stopDiam := gApplRecipe.gridwinderright.stopDiam;
		machine.turngridwinder.gridwinderright.data.machData.axistyp := - 1;
		// catch belt
		machine.catchbelt.ctrl.mode := gApplRecipe.catchbelt.mode;
		machine.catchbelt.axis.setGearRatio.enable := gApplRecipe.catchbelt.offsetOnOff;
		machine.catchbelt.axis.setGearRatio.UpdateRecipe := TRUE;
		machine.catchbelt.axis.setGearRatio.setvalueVisuRecipe := gApplRecipe.catchbelt.setvaluevisu;
		
		// conveyor
		machine.conveyor.ctrl.mode := gApplRecipe.conveyor.mode;
		machine.conveyor.axis.setGearRatio.enable := gApplRecipe.conveyor.offsetOnOff;
		machine.conveyor.axis.setGearRatio.UpdateRecipe := TRUE;
		machine.conveyor.axis.setGearRatio.setvalueVisuRecipe := gApplRecipe.conveyor.setvaluevisu;
		machine.conveyor.counters.setPieces := gApplRecipe.conveyor.setPieces;
		machine.conveyor.counters.validpieces := gApplRecipe.conveyor.validPieces;
		// long cuttter
		machine.longcutter.ctrl.mode := gApplRecipe.longcutter.mode;
		machine.longcutter.axis.setGearRatio.enable := gApplRecipe.longcutter.offsetOnOff;
		machine.longcutter.axis.setGearRatio.UpdateRecipe := TRUE;
		machine.longcutter.axis.setGearRatio.setvalueVisuRecipe := gApplRecipe.longcutter.setvaluevisu;
		
		// pull break station (pull belt)
		machine.pullbreakSt.axis.setGearRatio.enable := gApplRecipe.pullbelt.offsetOnOff;
		machine.pullbreakSt.axis.setGearRatio.UpdateRecipe := TRUE;
		machine.pullbreakSt.axis.setGearRatio.setvalueVisuRecipe := gApplRecipe.pullbelt.setvaluevisu;
		
		// Webbuffer
		machine.webbuffer.data.recipe.mode := gApplRecipe.tensionMeas.mode;
		machine.webbuffer.data.recipe.SetTension := gApplRecipe.tensionMeas.webTension;
END_ACTION