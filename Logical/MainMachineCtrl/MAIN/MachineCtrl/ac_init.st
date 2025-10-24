(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_init.st
 * Autor: Awalz
 * Erstellt: 31. März 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_init: 
		UnwinderUnit.unwinderDrv.status.id := 8;(*Achadresse im POwerlink Doppelkanalregler*)
		UnwinderUnit.unwinderDrv.status.name := 'UNWINDER Drive side';

		UnwinderUnit.unwinderOp.status.id:= 8;(*Achadresse im POwerlink Doppelkanalregler*)
		UnwinderUnit.unwinderOp.status.name := 'UNWINDER Operator side';
		
		masterModul.status.id := 1;
		masterModul.status.name := 'Master_Axis';
		
		pullbreak.status.id := 7;(* in Moment unbekannt*)
		pullbreak.status.name := 'gPBS1 Pullbreak';
		pullbreak.ctrl.mode := CONST.UNITMODEs.ENABLE; (* Da die ZUgstationen immer gekoppelt sein müssen*)
		
		cuttingunit1.status.id := 6;
		cuttingunit1.status.name := 'gCut1'; //Cuttingunit1 CH1

		turngridwinder.gridwinderleft.status.id := 10;
		turngridwinder.gridwinderleft.status.name := 'gGridLeft Gitterwickler NR1 CH1';

		turngridwinder.gridwinderright.status.id := 10;
		turngridwinder.gridwinderright.status.name := 'gGridLeft Gitterwickler NR2 CH2';

//		turngridwinder.feeder.status.id := 11;
//		turngridwinder.feeder.status.name := 'gGridFeeder Wendeachse';

		cuttingunit2.status.id := 6;
		cuttingunit2.status.name := 'gCut2';//Cuttingunit2 CH2
	
		
		pullbreakSt.status.id := 7;
		pullbreakSt.status.name := 'gPBS Pulbreak2';
		pullbreakSt.ctrl.mode := CONST.UNITMODEs.ENABLE;
		pullbreakSt.emcy_inputs.EMCY_Door1 := TRUE;
		pullbreakSt.hubctrl.enable := TRUE;

		conveyor.status.id := 12;
		conveyor.status.name := 'gConvB Conveyor';
		(*conveyor.ctrl.mode := CONST.UNITMODEs.ENABLE;*)

		catchbelt.status.id := 14;
		catchbelt.status.name := 'gCatchBelt Fangband ';
		
//		winder.status.id:= 14;
//		winder.status.name:= 'gTWindTop	Winder';		

		
END_ACTION