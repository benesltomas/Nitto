(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_ModulStatus.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ModulStatus
	IF axisState.ContinuousMotion THEN
		AxisState_status := 'ContinuousMotion';
	ELSIF axisState.Disabled THEN
		AxisState_status := 'Disabled';
	ELSIF axisState.DiscreteMotion THEN
		AxisState_status := 'DiscreteMotion';
	ELSIF axisState.Error THEN
		AxisState_status := 'Error';
	ELSIF axisState.Errorstop THEN
		AxisState_status := 'Errorstop';
	ELSIF axisState.StandStill THEN
		AxisState_status := 'StandStill';
	ELSIF axisState.Stopping THEN
		AxisState_status := 'Stopping';
	ELSIF axisState.SynchronizedMotion THEN
		AxisState_status := 'SynchronizedMotion';
	END_IF
END_FUNCTION_BLOCK
