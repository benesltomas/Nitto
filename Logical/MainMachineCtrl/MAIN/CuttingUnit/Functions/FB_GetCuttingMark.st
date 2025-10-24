(********************************************************************
 * COPYRIGHT -- Nitto
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_GetCuttingMark.st
 * Autor: s_spilker
 * Erstellt: 9. November 2015
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_GetCuttingMark
	unitPos := uData.machdata.position - usercorrec - uData.recipe.RmOffset -248000;//214000;
	myRefposition := uData.machdata.position + markpoints.RegMarkPosition; // da der Wert negativ ist
	pMasterAxisREF ACCESS machineMaster.AxisREF;
	masterPos := pMasterAxisREF.monitor.s;
	pSlaveAxisREF ACCESS uAxis.AxisREF;
	markBefore();
	markAfter();
	IF unitPos < myRefposition THEN (* Cuttingunit vor dem Markpoint Sensor *)
		configError := TRUE;
	ELSE
		configError := FALSE;
	END_IF
	IF markpoints.markpointlist.valid THEN
		(* Position Masters bzw des Druckmarke stellt die flißende bewegung der Druckmarke zu aufgenommenen Stelle*)
		actMarkDiff:= pMasterAxisREF.monitor.s - markpoints.MC_BR_TouchProbe_0.RecordedValue;
		(* myRefpogen ist die Position des Druckmarkensensors bez zu Einheitosition*)
		absMarkPos := myRefposition + actMarkDiff;(*ab den Nulldurchgang der Stanze wird der Wert positiv*)
		IF absMarkPos < unitPos THEN
//			IF ABS (markpoints.RegMarkPosition)> uData.general.periodLength THEN 
//				diffToUnitBefore := absMarkPos - unitPos;// diffToUnitBefore muss immer negativ sein 
//			ELSE 
				diffToUnitBefore := absMarkPos - unitPos;// - uData.general.periodLength;
		(*	END_IF*)
		ELSE
			diffToUnitAfter := absMarkPos - unitPos;
		END_IF
	END_IF	
END_FUNCTION_BLOCK