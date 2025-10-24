(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: MAIN.typ
 * Autor: Awalz
 * Erstellt: 28. März 2014
 ********************************************************************
 * Lokale Datentypen des Programs MAIN
 ********************************************************************)

TYPE
CONST_MACHINE_MODE_Type: STRUCT
	MANUAL:			INT := 0;
	AUTOMATIC:		INT := 1;
	PRODUCTION:		INT := 2;
	SAFETYSTOP:		INT := 7;
	RESET:			INT := 8;
	EMERGENCYSTOP:	INT := 9;
	END_STRUCT;
END_TYPE
