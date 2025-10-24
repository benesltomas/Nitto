(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_saveMachData.st
 * Autor: okrebs
 * Erstellt: 30. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* speichern der Maschinendaten zu MAIN_Variablen *)
ACTION ac_saveMachData: 
		
		// distances	
		machine.cuttingunit2.data.machdata.position := 850000;
		machine.cuttingunit1.data.recipe.tool.gearRatioMotor := 5;(* weil die mit 0 überschrieben werden da der Krebs wieder Misst gebaut hat*)
		machine.cuttingunit1.data.recipe.tool.cogmodul :=3175.0;
		machine.cuttingunit2.data.recipe.tool.gearRatioMotor := 5;
		machine.cuttingunit2.data.recipe.tool.cogmodul :=3175.0;
		machine.cuttingunit2.markpoints.RegMarkPosition := -540000;
	(*	machine.cuttingunit2.data.machdata.position := 540000;*)
		
		// unwinder drive side
		machine.UnwinderUnit.unwinderDrv.data.machData.coreDiam := gMachRecipe.UnwinderDrvSide.coreDiam;
		machine.UnwinderUnit.unwinderDrv.data.machData.frictionCompensation := gMachRecipe.UnwinderDrvSide.frictionCompensation;
		machine.UnwinderUnit.unwinderDrv.data.machData.GEAR_RATIO := 8;(*gMachRecipe.UnwinderDrvSide.GEAR_RATIO;*)
		machine.UnwinderUnit.unwinderDrv.data.machData.velocityOverride := gMachRecipe.UnwinderDrvSide.velocityOverride;
		machine.UnwinderUnit.unwinderDrv.data.machData.axistyp := 1;	(*(-1: winder, +1: unwinder).*)
		// unwinder op side
		machine.UnwinderUnit.unwinderOp.data.machData.coreDiam := gMachRecipe.UnwinderOpSide.coreDiam;
		machine.UnwinderUnit.unwinderOp.data.machData.frictionCompensation := gMachRecipe.UnwinderOpSide.frictionCompensation;
		machine.UnwinderUnit.unwinderOp.data.machData.GEAR_RATIO := 8; (*gMachRecipe.UnwinderOpSide.GEAR_RATIO;*)
		machine.UnwinderUnit.unwinderOp.data.machData.velocityOverride := gMachRecipe.UnwinderOpSide.velocityOverride;
		machine.UnwinderUnit.unwinderOp.data.machData.axistyp := 1;(*(-1: winder, +1: unwinder).*)
		// grid winder left
		machine.turngridwinder.gridwinderleft.data.machData.coreDiam := gMachRecipe.gridwinderleft.coreDiam;
		machine.turngridwinder.gridwinderleft.data.machData.frictionCompensation := gMachRecipe.gridwinderleft.frictionCompensation;
		machine.turngridwinder.gridwinderleft.data.machData.GEAR_RATIO := 3; (*gMachRecipe.gridwinderleft.GEAR_RATIO;*)
		machine.turngridwinder.gridwinderleft.data.machData.velocityOverride := gMachRecipe.gridwinderleft.velocityOverride;
		machine.turngridwinder.gridwinderleft.data.machData.axistyp := - 1;(*(-1: winder, +1: unwinder).*)
		// grid winder right
		machine.turngridwinder.gridwinderright.data.machData.coreDiam := gMachRecipe.gridwinderright.coreDiam;
		machine.turngridwinder.gridwinderright.data.machData.frictionCompensation := gMachRecipe.gridwinderright.frictionCompensation;
		machine.turngridwinder.gridwinderright.data.machData.GEAR_RATIO := 3; (*gMachRecipe.gridwinderright.GEAR_RATIO;*)
		machine.turngridwinder.gridwinderright.data.machData.velocityOverride := gMachRecipe.gridwinderright.velocityOverride;
		machine.turngridwinder.gridwinderright.data.machData.axistyp := - 1;
		// pack belt
		machine.packbelt.data.acceleration	:= gMachRecipe.botTandemWind.WarnDiam;
		machine.packbelt.data.deceleration	:= gMachRecipe.botTandemWind.StopDiam;
		machine.packbelt.data.highSpeed		:= gMachRecipe.botTandemWind.MaxPressure;
		machine.packbelt.data.lowSpeed		:= gMachRecipe.botTandemWind.MinPressure;
	
END_ACTION