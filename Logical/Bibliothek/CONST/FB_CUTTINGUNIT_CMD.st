(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_CUTTINGUNIT_CMD.st
 * Autor: Awalz
 * Erstellt: 7. Mai 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CUTTINGUNIT_CMD
	IF set THEN
		IF value < CONST.CUTTINGUNIT.CMDs.NO_CMD OR value > CONST.CUTTINGUNIT.CMDs.ABORT THEN
			text := '******';
		ELSE
			text := CONST.CUTTINGUNIT.CMDs.texts[value];
		END_IF
	END_IF
END_FUNCTION_BLOCK