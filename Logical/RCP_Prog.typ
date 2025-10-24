(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * File: RCP_Prog.typ
 * Author: beutert
 * Created: September 03, 2012
 ********************************************************************
 * Global data types of project csv_bsp
 ********************************************************************)
(*======================================================================================================================================*)
(*APPLICATION RECIPE DATA*)
(*======================================================================================================================================*)

TYPE
	rcp_prog_typ : 	STRUCT  (*Program/recipe parameters*)
		header : rcp_prog_header_typ; (*File header for recipe information*)
		general : rcp_prog_general_typ;
		dancer : rcp_prog_dancer_typ;
		tensionMeas : rcp_prog_tensMeas_typ;
		cutUnit1 : rcp_prog_cutUnit_typ;
		cutUnit2 : rcp_prog_cutUnit_typ;
		cutUnit3 : rcp_prog_cutUnit_typ;
		UnwinderOpSide : rcp_prog_wind_typ;
		UnwinderDrvSide : rcp_prog_wind_typ;
		mainUnwind : rcp_prog_wind_typ;
		grid1 : rcp_prog_wind_typ;
		grid2 : rcp_prog_wind_typ;
		gridwinderleft : rcp_prog_wind_typ;
		gridwinderright : rcp_prog_wind_typ;
		laminator1 : rcp_prog_wind_typ;
		laminator2 : rcp_prog_wind_typ;
		LaminatorRegist : rcp_prog_laminatorReg_typ; (* Struktur für den Laminator bzw. Laminierer*)
		spender1 : rcp_prog_spend_typ;
		spender2 : rcp_prog_spend_typ;
		spender3 : rcp_prog_spend_typ; (*winder: FB_WinderData;*)
		longCut : rcp_prog_conveyor_data_typ;
		conveyor : rcp_prog_conveyor_data_typ;
		longcutter : rcp_prog_conveyor_data_typ;
		pullbelt : rcp_prog_conveyor_data_typ;
		catchbelt : rcp_prog_conveyor_data_typ;
		endModule : rcp_prog_endModule_typ;
	END_STRUCT;
	rcp_prog_header_typ : 	STRUCT  (*Header for program/recipe information*)
		name : ARRAY[0..RCP_PROG_TEXT_FILENAME_MAX]OF UINT; (*Name des Program/Rezept*)
		description : ARRAY[0..RCP_PROG_TEXT_DESCRIPTION_MAX]OF UINT; (*Zusätzliche Beschreibung*)
		changed : USINT; (*Rezept wurde geändert*)
	END_STRUCT;
	rcp_prog_general_typ : 	STRUCT  (*general data*)
		masterDeceleration : REAL; (*deceleration [units/s² = µm/s²] of virtual amster axis*)
		masterAcceleration : REAL; (*acceleration [units/s² = µm/s²] of virtual amster axis*)
		periodLength : REAL; (*Material period [µm]*)
		startVelocity : REAL; (*start velocity [units/s]*)
		maxVelocity : REAL; (*maximum product velocity [units/s]*)
		lenght1 : REAL;
		speedToCycleWebturrit : REAL;
		lenght2 : REAL;
	END_STRUCT;
	rcp_prog_dancer_typ : 	STRUCT  (*dancer settings*)
		radiusCtrlOn : BOOL; (*Radius control On/Off*)
		cylinderTension : BOOL; (*Tension On/Off*)
		force : REAL; (*dancer force via prop ventile [%]*)
	END_STRUCT;
	rcp_prog_wind_typ : 	STRUCT  (*main unwinding unit settings*)
		warnDiam : UDINT;
		stopDiam : UDINT;
		minDiamTension : UDINT;
		maxDiamTension : UDINT;
		mode : UDINT;
		reverse : BOOL;
	END_STRUCT;
	rcp_prog_tensMeas_typ : 	STRUCT  (*web tension measurement unit settings*)
		mode : UDINT; (*Mode*)
		webTension : REAL; (*Web tension *)
	END_STRUCT;
	rcp_prog_cutUnit_typ : 	STRUCT  (*cut unit settings*)
		mode : UDINT; (*Mode*)
		toolfilename : STRING[80]; (*name of tool file*)
		toolNumber : USINT; (*Tool number*)
		markPointNo : USINT; (*number of mark point (index?)*)
		tool : rcp_tool_typ; (*selected tool parameter*)
		RmWindow : REAL; (*Range before / after the expected position in which the trigger signal may occur [Master Units]*)
		RmOffset : REAL; (*Reg mark position relative to cut position [Master Units]*)
		Insetting : REAL; (*Insetting ratio [%] (100% means the velocity in the cam equals the velocity in the compensation gear)*)
		MaxCorr : REAL; (*Insetting ratio [%] (100% means the velocity in the cam equals the velocity in the compensation gear)*)
	END_STRUCT;
	rcp_prog_laminatorReg_typ : 	STRUCT 
		mode : UDINT; (*Mode*)
		Winder : rcp_prog_wind_typ; (*torque setpoint at minimum diameter [Nm]*)
		Unwinder : rcp_prog_wind_typ; (*torque setpoint at maximum diameter [Nm]*)
		reverse : BOOL; (*TRUE = reverse direction*)
		LabelPeriod : REAL; (*Label dispenser period/ Rapportlänge der Spendeetiketten*)
		ProductLenghtMaster : REAL; (*Product lenght on master axis/ Periodenlänge der Spendeetiketten auf der Hauptbahn*)
		RegMarkPos : REAL; (*Abstand zwischen Registermarke und Spendeposition*)
		LabelOffset : REAL; (*Label offset relative to start position/ Offset der Länge zwischen Labelbahnsensor und Spendeposition*)
	END_STRUCT;
	rcp_prog_spend_typ : 	STRUCT  (*spender (unwinder/winder) settings*)
		mode : UDINT; (*Mode*)
		minDiamTorq : REAL; (*torque setpoint at minimum diameter [Nm]*)
		maxDiamTorq : REAL; (*torque setpoint at maximum diameter [Nm]*)
		reverse : BOOL; (*TRUE = reverse direction*)
		LabelPeriod : REAL; (*Label dispenser period/ Rapportlänge der Spendeetiketten*)
		ProductLenghtMaster : REAL; (*Product lenght on master axis/ Periodenlänge der Spendeetiketten auf der Hauptbahn*)
		RegMarkPos : REAL; (*Abstand zwischen Registermarke und Spendeposition*)
		LabelOffset : REAL; (*Label offset relative to start position/ Offset der Länge zwischen Labelbahnsensor und Spendeposition*)
	END_STRUCT;
	rcp_prog_lamin_typ : 	STRUCT  (*spender (unwinder/winder) settings*)
		mode : UDINT; (*Mode*)
		minDiamTorq : REAL; (*torque setpoint at minimum diameter [Nm]*)
		maxDiamTorq : REAL; (*torque setpoint at maximum diameter [Nm]*)
		reverse : BOOL; (*TRUE = reverse direction*)
		LabelPeriod : REAL; (*Label dispenser period/ Rapportlänge der Spendeetiketten*)
		ProductLenghtMaster : REAL; (*Product lenght on master axis/ Periodenlänge der Spendeetiketten auf der Hauptbahn*)
		RegMarkPos : REAL; (*Abstand zwischen Registermarke und Spendeposition*)
		LabelOffset : REAL; (*Label offset relative to start position/ Offset der Länge zwischen Labelbahnsensor und Spendeposition*)
	END_STRUCT;
	rcp_prog_longCut_typ : 	STRUCT  (*long cut unit settings*)
		mode : UDINT; (*Mode*)
		veloRelative : REAL; (*relative velocity to master [%]*)
	END_STRUCT;
	rcp_prog_conveyor_data_typ : 	STRUCT 
		setvaluevisu : REAL;
		offsetOnOff : BOOL;
		mode : UDINT;
		setPieces : UINT;
		validPieces : UINT;
		sensor1 : INT;
		sensor2 : INT;
		sensor3 : INT;
		sensor4 : INT;
		sensor5 : INT;
		sensor6 : INT;
		sensor7 : INT;
		sensor8 : INT;
		sensor9 : INT;
	END_STRUCT;
	rcp_prog_endModule_typ : 	STRUCT  (*settings for end module (belts and tandem winder)*)
		mode : UDINT; (*Mode*)
		minDiamPressureTop : REAL; (*pressure at minimum diameter top winder [%]*)
		maxDiamPressureTop : REAL; (*pressure at maximum diameter top winder [%]*)
		minDiamPressureBot : REAL; (*pressure at minimum diameter bottom winder [%]*)
		maxDiamPressureBot : REAL; (*pressure at maximum diameter bottom winder [%]*)
		minDiamTensionTop : REAL; (*tension force at minimum diameter top winder [N]*)
		maxDiamTensionTop : REAL; (*tension force at maximum diameter top winder [N]*)
		minDiamValueTop : REAL; (*corresponding minimum diameter value top winder [µm]*)
		reverseTopWind : BOOL; (*TRUE = reverse direction of top winder*)
		minDiamTensionBot : REAL; (*tension force at minimum diameter bottom winder [N]*)
		maxDiamTensionBot : REAL; (*tension force at maximum diameter bottom winder [N]*)
		minDiamValueBot : REAL; (*corresponding minimum diameter value bottom winder [µm]*)
		reverseBotWind : BOOL; (*TRUE = reverse direction of bottom winder*)
		veloRelativeTopBelt : REAL; (*relative velocity to master [%]*)
		veloRelativeConvBelt : REAL; (*relative velocity to master [%]*)
		veloBatchConvBelt : REAL; (*Batch velocity to master [%]*)
		batchDistance : REAL; (*relative velocity to master [%]*)
		numberPapers : UDINT; (*number of Papers in batch*)
	END_STRUCT;
END_TYPE

(*======================================================================================================================================*)
(*CSV FILE HANDLING DATA TYPES*)
(*======================================================================================================================================*)

TYPE
	CSVHndl_typ : 	STRUCT 
		ReqParaRead : BOOL;
		ReqParaWrite : BOOL;
		ReqParaWriteAfterValueChanged : BOOL;
		ReqDirRead : BOOL;
		ReqCreateNew : BOOL;
		ReqNewRecipe : BOOL;
		ReqDelRecipe : BOOL;
		ReqSaveAs : BOOL;
		ReqSaveRecipeAs : BOOL;
		BtnNew : BOOL;
		BtnSaveAs : BOOL;
		SetListBoxIdxToZero : BOOL;
		ListBoxRecipeChanged : BOOL; (*when another recipe was selected*)
		ListboxMaxLines : UINT;
		ListboxFileNames : ARRAY[0..99]OF STRING[46];
		ListboxIdx : UINT;
		LayerMessageBoxOverwrite : USINT; (*switches the layer on or off*)
		LayerMessageBoxDeleteFile : USINT; (*switches the layer on or off*)
		LayerNewFileName : USINT; (*switches the layer on or off*)
		LayerMessageBoxSaveFile : USINT; (*switches the layer on or off*)
		LayersProgPara : ARRAY[0..20]OF USINT; (*switches the layer on or off*)
		ListboxProgParaIdx : UINT;
		ListboxProgParaMaxLines : UINT := 15;
		StatusNewFileName : UINT;
		NewFileNameEntered : BOOL; (*completion datapoint for filename*)
		FileOverWrite : USINT; (*answer from messagebox*)
		FileDelete : USINT; (*answer from messagebox*)
		FileNameNew : STRING[80];
		FileNameSave : STRING[80];
		FileNameDelete : STRING[80];
		FileNameSelected : STRING[80];
		ListBoxMaxIdx : UINT;
		OverwriteFile : BOOL; (*when save was selected, don't ask for overwrite, do it*)
		ValueChanged : BOOL; (*true if any value displayed on the page was changed*)
		ToolSelectedCutU1 : BOOL; (*a tool file was selected from the list*)
		ToolSelectedCutU2 : BOOL; (*a tool file was selected from the list*)
		ToolSelectedCutU3 : BOOL; (*a tool file was selected from the list*)
		ScrollUpLbo1 : USINT;
		ScrollDownLbo1 : USINT;
		ScrollHomeLbo1 : USINT;
		ScrollEndLbo1 : USINT;
		ScrollUpLbo2 : USINT;
		ScrollDownLbo2 : USINT;
		ScrollHomeLbo2 : USINT;
		ScrollEndLbo2 : USINT;
		ScrollUpLbo3 : USINT;
		ScrollDownLbo3 : USINT;
		ScrollHomeLbo3 : USINT;
		ScrollEndLbo3 : USINT;
		DeleteFileYes : USINT;
		DeleteFileNo : USINT;
		SaveFileYes : USINT;
		SaveFileNo : USINT;
		OverwriteFileYes : USINT;
		OverwriteFileNo : USINT;
		StatusBmpRadiusCtrlOnOff : UINT;
		StatusBmpTensionOnOff : UINT;
		StatusBmpReverseGeneral : UINT;
		StatusBmpReverseUnwinder : UINT;
		StatusBmpReverseTensMeas : UINT;
		StatusBmpReverseLongCut : UINT;
		StatusBmpReverseSpender1 : UINT;
		StatusBmpReverseGrid1 : UINT;
		StatusBmpReverseSpender2 : UINT;
		StatusBmpReverseGrid2 : UINT;
		StatusBmpReverseWindTop : UINT;
		StatusBmpReverseWindBot : UINT;
		StatusBmpReverseConvey : UINT;
		StatusBmpFoundFileCutU1 : UINT;
		StatusBtnRefreshCutU1 : UINT;
		StatusBmpFoundFileCutU2 : UINT;
		StatusBtnRefreshCutU2 : UINT;
		StatusBmpFoundFileCutU3 : UINT;
		StatusBtnRefreshCutU3 : UINT;
	END_STRUCT;
END_TYPE
