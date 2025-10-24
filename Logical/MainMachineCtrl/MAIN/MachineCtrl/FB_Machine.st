(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_Machine.st
 * Autor: Awalz
 * Erstellt: 24. März 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(* TODO: Beinhaltet aller Baugrupen der Maschine *)
FUNCTION_BLOCK FB_Machine

	ctrl(masterModul := masterModul,
		UnwinderUnit := UnwinderUnit,
		webbuffer := webbuffer,
		pullbreak := pullbreak ,
		cuttingunit1 := cuttingunit1,
		turngridwinder := turngridwinder,
		longcutter := longcutter,
		pullbreakSt := pullbreakSt, 
		cuttingunit2 :=	cuttingunit2,
		catchbelt := catchbelt,
		conveyor := conveyor,
		webguidingbuffer := webguidingbuffer,
		webguiding := webguiding,
		emcy_inputs := emcy_inputs,summerystartstop := summerystartstop,
		IOs := IOs, panel := panel, safety := safety, gVarMachine := gVarMachine, switchcabinet := switchcabinet,
		packbelt := packbelt);  (**)
	
	
END_FUNCTION_BLOCK