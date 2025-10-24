(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_setMode1.st
 * Autor: okrebs
 * Erstellt: 10. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_setMode: 
//	UnwinderUnit.unwinderOp.ctrl.BetrCtrl.set := TRUE;
//	UnwinderUnit.unwinderOp.ctrl.BetrCtrl(value := tmpMode);
	masterModul.ctrl.BetrCtrl.set := TRUE;
	masterModul.ctrl.BetrCtrl(value := tmpMode);

	UnwinderUnit.ctrl.BetrCtrl.set := TRUE;
	UnwinderUnit.ctrl.BetrCtrl(value := tmpMode);
		


	webbuffer.ctrl.BetrCtrl(set := TRUE, value := tmpMode);
	
	pullbreak.ctrl.BetrCtrl.set := TRUE;
	pullbreak.ctrl.BetrCtrl(value := tmpMode);
		
	cuttingunit1.ctrl.BetrCtrl.set := TRUE;
	cuttingunit1.ctrl.BetrCtrl(value := tmpMode);
	
	turngridwinder.ctrl.BetrCtrl(set := TRUE, value := tmpMode);

	longcutter.ctrl.BetrCtrl(set := TRUE, value := tmpMode);

	cuttingunit2.ctrl.BetrCtrl.set := TRUE;
	cuttingunit2.ctrl.BetrCtrl(value := tmpMode);
		
	pullbreakSt.ctrl.BetrCtrl(set :=TRUE, value := tmpMode); 
	
	catchbelt.ctrl.BetrCtrl(set	:= TRUE, value := tmpMode);

	conveyor.ctrl.BetrCtrl(set := TRUE, value := tmpMode);
	
		
//	winder.ctrl.BetrCtrl.set:= TRUE;
//	winder.ctrl.BetrCtrl(value := tmpMode);
END_ACTION