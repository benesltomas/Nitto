(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_UnitChkStatus.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_UnitChkStatus
	IF enable THEN
		IF setMode = status.mode THEN
			IF setMode = CONST.UNITMODEs.DISABLE THEN
				ready := NOT status.isCoupled;
			ELSIF setMode = CONST.UNITMODEs.ENABLE THEN
				ready := status.isCoupled;
			ELSE
				ready := FALSE;
			END_IF
		ELSE
			ready := FALSE;
		END_IF
	END_IF

	status.ready := ready;
END_FUNCTION_BLOCK