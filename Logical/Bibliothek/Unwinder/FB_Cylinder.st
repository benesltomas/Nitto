(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_Cylinder.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_Cylinder
	timer(IN := isDown, PT := T#500ms);
	isdowndelayed := timer.Q;
	IF upVISU AND downVISU OR buttonUP AND buttonDown THEN
		;
	ELSIF upVISU OR buttonUP AND NOT isUp THEN
		up_o := TRUE;
		down_o := FALSE;
	ELSIF downVISU OR buttonDown AND NOT isDown THEN
		up_o := FALSE;
		down_o := TRUE;
	ELSE
		up_o := FALSE;
		down_o := FALSE;;
	END_IF
END_FUNCTION_BLOCK