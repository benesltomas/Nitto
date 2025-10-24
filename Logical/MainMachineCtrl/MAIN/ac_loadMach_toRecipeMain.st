(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_loadMach_toRecipeMain.st
 * Autor: awalz
 * Erstellt: 29. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_loadMach_toRecipeMain: 

		// 2012-12-19 /schoenefeldr/
		// Copy recipe data from application recipe (actually active in the machine) into the selected recipe
		memcpy(ADR(RecipeEdit.cutUnit1),ADR(machine.cuttingunit1.data.recipe),SIZEOF(RecipeEdit.cutUnit1));
		memcpy(ADR(RecipeEdit.cutUnit2),ADR(machine.cuttingunit2.data.recipe),SIZEOF(RecipeEdit.cutUnit2));
		
//		RecipeEdit.cutUnit1.RmOffset := machine.cuttingunit1.ctrl.getNextCuttPos.setCutOffset.setvalueVisu;	 // OKrebs 15.09.14 //Damit der richtige Offsetwert in die perm Daten geschrieben wird
//		RecipeEdit.cutUnit2.RmOffset := machine.cuttingunit2.ctrl.getNextCuttPos.setCutOffset.setvalueVisu;  // OKrebs 15.09.14 //Damit der richtige Offsetwert in die perm Daten geschrieben wird
		RecipeEdit.general.lenght1 := machine.masterModul.data.lenght1; // OKrebs 17.09.14 
		RecipeEdit.general.lenght2 := machine.masterModul.data.lenght2; // OKrebs 17.09.14 
		RecipeEdit.general.speedToCycleWebturrit := machine.masterModul.data.speedToCycleWebturrit;
	
		machine.cuttingunit1.data.recipe.tool.gearRatioMotor := 5;(* weil die mit 0 überschrieben werden da der Krebs wieder Misst gebaut hat*)
		machine.cuttingunit1.data.recipe.tool.cogmodul :=3175.0;
		machine.cuttingunit2.data.recipe.tool.gearRatioMotor := 5;
		machine.cuttingunit2.data.recipe.tool.cogmodul :=3175.0;
		machine.cuttingunit2.markpoints.RegMarkPosition := -540000;
		machine.cuttingunit2.data.machdata.position := 850000;
		machine.cuttingunit2.data.general.periodLength := gApplRecipe.general.periodLength; //460000;
		(*machine.cuttingunit2.data.recipe.RmOffset*); (* muss noch irgendwie zu ende gebracht werden*)
		
		// unwinder drive side
		RecipeEdit.UnwinderDrvSide.maxDiamTension := machine.UnwinderUnit.unwinderDrv.data.recipeData.maxDiamTension;
		RecipeEdit.UnwinderDrvSide.minDiamTension := machine.UnwinderUnit.unwinderDrv.data.recipeData.minDiamTension;
		RecipeEdit.UnwinderDrvSide.mode := machine.UnwinderUnit.unwinderDrv.data.recipeData.mode;
		RecipeEdit.UnwinderDrvSide.reverse := machine.UnwinderUnit.unwinderDrv.data.recipeData.reverse;
		RecipeEdit.UnwinderDrvSide.warnDiam := machine.UnwinderUnit.unwinderDrv.data.recipeData.warnDiam;
		RecipeEdit.UnwinderDrvSide.stopDiam := machine.UnwinderUnit.unwinderDrv.data.recipeData.stopDiam;
//		RecipeEdit.UnwinderDrvSide.data.machData.GEAR_RATIO := 8;(*gMachRecipe.UnwinderDrvSide.GEAR_RATIO;*)
//		RecipeEdit.UnwinderDrvSide.machData.axistyp := 1;	(*(-1: winder, +1: unwinder).*)
		// unwinder op side
		RecipeEdit.UnwinderOpSide.maxDiamTension := machine.UnwinderUnit.unwinderOp.data.recipeData.maxDiamTension;
		RecipeEdit.UnwinderOpSide.minDiamTension := machine.UnwinderUnit.unwinderOp.data.recipeData.minDiamTension;
		RecipeEdit.UnwinderOpSide.mode := machine.UnwinderUnit.unwinderOp.data.recipeData.mode;
		RecipeEdit.UnwinderOpSide.reverse := machine.UnwinderUnit.unwinderOp.data.recipeData.reverse;
		RecipeEdit.UnwinderOpSide.warnDiam := machine.UnwinderUnit.unwinderOp.data.recipeData.warnDiam;
		RecipeEdit.UnwinderOpSide.stopDiam := machine.UnwinderUnit.unwinderOp.data.recipeData.stopDiam;
//		RecipeEdit.unwinderOp.data.machData.GEAR_RATIO := 8; (*gMachRecipe.UnwinderOpSide.GEAR_RATIO;*)
//		RecipeEdit.unwinderOp.data.machData.axistyp := 1;(*(-1: winder, +1: unwinder).*)
		// grid winder left
		RecipeEdit.gridwinderleft.maxDiamTension := machine.turngridwinder.gridwinderleft.data.recipeData.maxDiamTension;
		RecipeEdit.gridwinderleft.minDiamTension := machine.turngridwinder.gridwinderleft.data.recipeData.minDiamTension;
		RecipeEdit.gridwinderleft.mode := machine.turngridwinder.gridwinderleft.data.recipeData.mode;
		RecipeEdit.gridwinderleft.reverse := machine.turngridwinder.gridwinderleft.data.recipeData.reverse;
		RecipeEdit.gridwinderleft.warnDiam := machine.turngridwinder.gridwinderleft.data.recipeData.warnDiam;
		RecipeEdit.gridwinderleft.stopDiam := machine.turngridwinder.gridwinderleft.data.recipeData.stopDiam;
//		RecipeEdit.gridwinderleft.data.machData.GEAR_RATIO := 3; (*gMachRecipe.gridwinderleft.GEAR_RATIO;*)
//		RecipeEdit.gridwinderleft.data.machData.axistyp := - 1;(*(-1: winder, +1: unwinder).*)
		// grid winder right
		RecipeEdit.gridwinderright.maxDiamTension := machine.turngridwinder.gridwinderright.data.recipeData.maxDiamTension;
		RecipeEdit.gridwinderright.minDiamTension := machine.turngridwinder.gridwinderright.data.recipeData.minDiamTension;
		RecipeEdit.gridwinderright.mode := machine.turngridwinder.gridwinderright.data.recipeData.mode;
		RecipeEdit.gridwinderright.reverse := machine.turngridwinder.gridwinderright.data.recipeData.reverse;
		RecipeEdit.gridwinderright.warnDiam := machine.turngridwinder.gridwinderright.data.recipeData.warnDiam;
		RecipeEdit.gridwinderright.stopDiam := machine.turngridwinder.gridwinderright.data.recipeData.stopDiam;
//		RecipeEdit.gridwinderright.data.machData.GEAR_RATIO := 3; (*gMachRecipe.gridwinderleft.GEAR_RATIO;*)
//		RecipeEdit.gridwinderright.data.machData.axistyp := - 1;(*(-1: winder, +1: unwinder).*)
		// catch belt
		RecipeEdit.catchbelt.mode := machine.catchbelt.ctrl.mode;
		RecipeEdit.catchbelt.offsetOnOff := machine.catchbelt.axis.setGearRatio.enable;
		RecipeEdit.catchbelt.setvaluevisu := machine.catchbelt.axis.setGearRatio.setvalueVisu;
		
		// conveyor
		RecipeEdit.conveyor.mode := machine.conveyor.ctrl.mode;
		RecipeEdit.conveyor.offsetOnOff := machine.conveyor.axis.setGearRatio.enable;
		RecipeEdit.conveyor.setvaluevisu := machine.conveyor.axis.setGearRatio.setvalueVisu;
		
		// long cuttter
		RecipeEdit.longcutter.mode := machine.longcutter.ctrl.mode;
		RecipeEdit.longcutter.offsetOnOff := machine.longcutter.axis.setGearRatio.enable;
		RecipeEdit.longcutter.setvaluevisu := machine.longcutter.axis.setGearRatio.setvalueVisu;
		
		// pull break station (pull belt)
		RecipeEdit.pullbelt.offsetOnOff := machine.pullbreakSt.axis.setGearRatio.enable;
		RecipeEdit.pullbelt.setvaluevisu := machine.pullbreakSt.axis.setGearRatio.setvalueVisu;

		// Webbuffer Tension
		RecipeEdit.tensionMeas.mode := machine.webbuffer.data.recipe.mode;
		RecipeEdit.tensionMeas.webTension := machine.webbuffer.data.recipe.SetTension;
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

END_ACTION