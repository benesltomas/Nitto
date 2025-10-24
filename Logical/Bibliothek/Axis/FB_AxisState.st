(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_AxisState.st
 * Autor: awalz
 * Erstellt: 26. August 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_AxisState
//		Error:				INT:=1;
//		Errorstop:			INT:=2;
//		Disabled:			INT:=3;
//		Stopping:			INT:=4; 
//		StandStill:			INT:=5;
//		DiscreteMotion:		INT:=6;
//		ContinuousMotion: 	INT:=7;
//		SynchronizedMotion:	INT:=8;
//		Homing:				INT:=9;	
	stati[CONST.Error] := readstatus.Error;
	stati[CONST.Errorstop] :=	readstatus.Errorstop;
	stati[CONST.Disabled] :=	readstatus.Disabled;
	stati[3] :=	readstatus.Stopping; 
	stati[4] := readstatus.StandStill;
	stati[5] := readstatus.DiscreteMotion;
	stati[6] :=	readstatus.ContinuousMotion;
	stati[7] :=	readstatus.SynchronizedMotion;
//	CONST.texts[CONST.Error] := stati[0];
//		
//		
//		readstatus.SynchronizedMotion
END_FUNCTION_BLOCK