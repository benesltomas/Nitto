(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_UnitsStatus.st
 * Autor: Awalz
 * Erstellt: 1. April 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_UnitsStatus
//	pullbreak();21.09.15
//	pullbreakSt();
//	longcutter();
//	conveyor();
//	catchbelt();
//	UnwinderUnit();
	ready := (longcutter.axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND pullbreak.status.ready AND pullbreakSt.status.ready AND pullbreakSt.hubctrl.isdown AND conveyor.status.ready AND catchbelt.status.ready AND cuttingunit1.status.isCalibrated AND cuttingunit2.status.isCalibrated AND webbuffer.axis.ctrl.BasicControl.AxisState.Homed AND turngridwinder.feeder.BasicControl.AxisState.Homed); // OKrebs 09.12.15
	diameterStop:= UnwinderUnit.unwinderDrv.ctrl.diameterStop OR UnwinderUnit.unwinderOp.ctrl.diameterStop; 
	diameterwarning:= UnwinderUnit.unwinderDrv.ctrl.diameterWarning OR UnwinderUnit.unwinderOp.ctrl.diameterWarning;
	clampingfront:=  UnwinderUnit.clamp.toDown_o OR UnwinderUnit.unwinderDrv.clamp.toDown_o OR UnwinderUnit.unwinderOp.clamp.toDown_o;
	clampingsplicetable := UnwinderUnit.splicetable.clampAfter.toDown_o OR UnwinderUnit.splicetable.clampBefore.toDown_o;
	clampingback:= longcutter.webclamp.toDown_o;

END_FUNCTION_BLOCK