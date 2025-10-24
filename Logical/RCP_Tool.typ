(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * File: RCP_Tool.typ
 * Author: beutert
 * Created: September 03, 2012
 ********************************************************************
 * Global data types of project csv_bsp
 ********************************************************************)

TYPE
	rcp_tool_typ : 	STRUCT 
		description : STRING[80]; (*Beschreibung*)
		addSupportSpindle : BOOL; (*Zusätzliche Stützwelle*)
		cogCutting : UINT; (*Zahnrad Stanzwerkzeug*)
		cogSupportSpindle : UINT; (*Zahnrad Stützwelle*)
		numberToolSegments : USINT; (*Anzahl der Nutzen / Werkzeugumfang*)
		cutStartPosition : DINT; (*Anfangsposition Schnitt innerhalb einer Nutzenperiode [um]*)
		cutEndPosition : DINT; (*Endposition Schnitt innerhalb einer Nutzenperiode [um]*)
		homePosition : REAL; (*Referenzposition der Achse [um]*)
		cogmodul:REAL := 3175.0; (* in mikrometer *)
		gearRatioMotor :UINT := 5;
	END_STRUCT;
	TOOL_Hndl_typ : 	STRUCT 
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
		ListboxMaxLines : UINT;
		ListboxFileNames : ARRAY[0..99]OF STRING[46];
		ListboxIdx : UINT;
		LayerMessageBoxOverwrite : USINT; (*switches the layer on or off*)
		LayerMessageBoxDeleteFile : USINT; (*switches the layer on or off*)
		LayerNewFileName : USINT; (*switches the layer on or off*)
		LayerMessageBoxSaveFile : USINT; (*switches the layer on or off*)
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
		ScrollUpLbo1 : USINT;
		ScrollDownLbo1 : USINT;
		ScrollHomeLbo1 : USINT;
		ScrollEndLbo1 : USINT;
		ScrollUpLbo2 : USINT;
		ScrollDownLbo2 : USINT;
		ScrollHomeLbo2 : USINT;
		ScrollEndLbo2 : USINT;
		StatusBmp : UINT;
		DeleteFileYes : USINT;
		DeleteFileNo : USINT;
		SaveFileYes : USINT;
		SaveFileNo : USINT;
		OverwriteFileYes : USINT;
		OverwriteFileNo : USINT;
	END_STRUCT;
END_TYPE
