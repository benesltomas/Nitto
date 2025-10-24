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
	TriggerParameters_typ : 	STRUCT 
		Axis : UDINT; (*Reference to axis that is physically connected to trigger*)
		TriggerInput : MC_BR_TRIGGER_REF; (*Input that is used as event source*)
		PositionSensor : DINT; (*Machine position sensor [Master Units]*)
	END_STRUCT;
	VTriggerParameters_typ : 	STRUCT 
		RecordedPosition : DINT; (*Position recorded by virtual sensor*)
		PositionVSensor : DINT; (*Machine position of virtual sensor [Master Units]*)
	END_STRUCT;
	mCommand_typ : 	STRUCT 
		SearchRM : BOOL; (*Initiate search of new RM on positive edge*)
		Sync : BOOL; (*Execute a synchronization movement (only possible when coupling is active)*)
	END_STRUCT;
	mStatusOutput_typ : 	STRUCT 
		SearchRMCmdStatus : UINT; (*status datapoint for visualization*)
		SyncCmdStatus : UINT; (*status datapoint for visualization*)
		Active : BOOL; (*punch cam automat active*)
		CutMasterPosition : DINT; (*cut master position [Master Units]*)
		MoveUpRequest : BOOL; (*request to move up punch*)
		ProbeCounter : UDINT; (*registration mark counter*)
		MissedTriggers : UDINT; (*missed trigger counter*)
		ActPositionError : DINT; (*actual position error [Master Units]*)
	END_STRUCT;
	mStatusInput_typ : 	STRUCT 
		AutoModeActive : BOOL;
		InMesh : BOOL; (*punch in mesh with material*)
		PowerOffRequest : BOOL;
	END_STRUCT;
END_TYPE
