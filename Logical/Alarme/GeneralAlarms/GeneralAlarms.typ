(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Programm: GeneralAlarms
 * Datei: GeneralAlarms.typ
 * Autor: jkappelt
 * Erstellt: 3. Oktober 2012
 ********************************************************************
 * Lokale Datentypen des Programs GeneralAlarms
 ********************************************************************)

TYPE
	emuAlarmsGeneral : 
		(
		ALARM_PRESSURE_LOW := 0,
		ALARM_FUSE_BST := 1,
		ALARM_FUSE_QW258 := 2,
		ALARM_FUSE_QW264 := 3,
		ALARM_LOW_WEBTENSION := 4,
		ALARM_ESTOP_CABINET := 5,
		ALARM_ESTOP_PANEL := 6,
		ALARM_ESTOP_UNWINDER := 7,
		ALARM_ESTOP_MIDDLE := 8,
		ALARM_ESTOP_ENDMODULE := 9,
		ALARM_FUSE_COOLER_UNWINDER := 10,
		ALARM_PLUG1 := 11,
		ALARM_PLUG2 := 12,
		ALARM_PLUGCEE := 13,
		ALARM_HVOLT_ANTISTATIC := 14,
		ALARM_BST_NREADY := 15,
		ALARM_SAFEDOOR_PUNCH1 := 16,
		ALARM_SAFEDOOR_PUNCH2 := 17,
		ALARM_SAFEDOOR_PUNCH3 := 18,
		ALARM_SAFEDOOR_LONGCUT := 19,
		ALARM_FUSE_LAMINATOR := 20,
		ALARM_WEB_BREAK := 21,
		ALARM_ESTOP_BOOKLET := 22,
		ALARM_FUSE_BOOKLET := 23,
		ALARM_SAFEDOOR_BOOKLET := 24,
		ALARM_ESTOP_PULLWIRE := 25
		);
	emuSafetyStatus : 
		(
		STATUS_SAFETY_OK := 0,
		STATUS_SLS := 1,
		STATUS_CONTVOL_OFF := 2
		);
END_TYPE
