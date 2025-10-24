(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_ErrorHdl.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ErrorHdl
	IF reset THEN
		id := 0;
		state := 0;
		text :='';
		fnc :='';
		flag := FALSE;
		reset := FALSE;
	END_IF
	IF set THEN
		flag := TRUE;
		set := FALSE;
	END_IF
END_FUNCTION_BLOCK