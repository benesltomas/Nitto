(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: TOOL_Hdl
 * File: TOOL_Hdl.st
 * Author: beutert
 * Created: August 28, 2012
 ********************************************************************
 * Implementation of program TOOL_Hdl
 ********************************************************************)

PROGRAM _INIT

	TOOL_Hndl.LayerMessageBoxOverwrite := INVISIBLE;
	TOOL_Hndl.LayerMessageBoxDeleteFile := INVISIBLE;
	TOOL_Hndl.LayerNewFileName := INVISIBLE;
	TOOL_Hndl.LayerMessageBoxSaveFile := INVISIBLE;
	
	HWInfo_0.enable := TRUE;
	HWInfo_0.first := TRUE;
	HWInfo_0.pName := ADR(HWString); 
	HWInfo_0();

	DirCreate_0.pDevice	:= ADR('USERPART');
	DirCreate_0.pName	:= ADR('Tools');
	DirCreate_0.enable	:= TRUE;
	REPEAT
		DirCreate_0();
	UNTIL (DirCreate_0.status <> ERR_FUB_BUSY) END_REPEAT;
	
	strcpy(ADR(szFileDevice), ADR('DIR_TOOL'));
	IF HWString = 'AR000' THEN
		strcpy(ADR(szDevLinkPara), ADR('/DEVICE=C:\\temp\\Tools'));
	ELSE
		strcpy(ADR(szDevLinkPara), ADR('/DEVICE=F:\\Tools'));
	END_IF	

	DevLink_0.enable 	:= 1;
	DevLink_0.pDevice := ADR(szFileDevice);
	DevLink_0.pParam 	:= ADR(szDevLinkPara);
	REPEAT
		DevLink_0();
	UNTIL (DevLink_0.status <> ERR_FUB_BUSY) END_REPEAT;	
	
	strcpy(ADR(CSV_Header.CustomerName),ADR('Spilker'));
	strcpy(ADR(CSV_Header.MachineNumber),ADR('Herpa Print'));
	strcpy(ADR(CSV_Header.SW_Version),ADR('Version V1.00'));
	
	//strcpy(ADR(RecipeEdit.MachineString),ADR('machine1'));
	
	pNames[0] :=  ADR('tool_hdl:tmpTool');		//Name der zu sichernden PV
//	pNames[1] :=  ADR('CSV_SearchData');				//mehrere möglich

	StructSizes[0] := SIZEOF(tmpTool);				//Größe der zu sichernden PV
//	StructSizes[1] := SIZEOF(CSV_SearchData);

	CSV_InitVariable.pStructName := ADR(pNames);
	CSV_InitVariable.NumOfStructs := 1;					//Anzahl der zu sichernden Elemente, wenn CSV_SearchData auch gesichert werden soll, muss hier 2 stehen
	CSV_InitVariable.FullNameLenght := 0;
	CSV_InitVariable.Options := 0;
	CSV_InitVariable();

  IF (CSV_InitVariable.status > 0) AND (CSV_InitVariable.status < ERR_FUB_BUSY) THEN
  	Step := ST_ERROR;
  ELSE
   	Step := ST_COMMAND;
	END_IF;
    
//Speicherplatz allokieren	
	CSVInitCheckFileVersion.enable := 1;
	CSVInitCheckFileVersion.MemCounter := CSV_InitVariable.MemCounter;
	CSVInitCheckFileVersion();

  IF (CSVInitCheckFileVersion.status < 65535) AND (CSVInitCheckFileVersion.status > 0) THEN
    Step := ST_ERROR;
  ELSE
   	Step := ST_COMMAND;
		CSVInitCheckFileVersion.enable := 1;
		CSVInitCheckFileVersion.MemCounter := CSV_InitVariable.MemCounter;
		CSVInitCheckFileVersion();
	END_IF;

  IF (CSVInitCheckFileVersion.status < ERR_FUB_BUSY) AND (CSVInitCheckFileVersion.status > 0) THEN
    Step := ST_ERROR;
  ELSE
    Step := ST_COMMAND;
		TOOL_Hndl.ReqDirRead := TRUE;
		xSorted := TRUE;
		OldListBoxIdx := 16#FFFF;
	END_IF;
	
END_PROGRAM


PROGRAM _CYCLIC

CASE Step OF

	(****************************************/
	/* command interface                    */
	/****************************************)
	ST_COMMAND:	(*0*)
		IF (TOOL_Hndl.ReqDirRead) THEN
			IF (xSorted = TRUE) THEN
				Step := ST_LIST_FILE_SORT;
			ELSE
				Step := ST_LIST_FILE;
			END_IF;
			
		ELSIF (TOOL_Hndl.ReqDelRecipe) THEN
			TOOL_Hndl.ReqDelRecipe := FALSE;
			strcpy(ADR(TOOL_Hndl.FileNameDelete),ADR(TOOL_Hndl.ListboxFileNames[TOOL_Hndl.ListboxIdx]));
			strcat(ADR(TOOL_Hndl.FileNameDelete),ADR('.csv'));
			TOOL_Hndl.LayerMessageBoxDeleteFile := VISIBLE;	//Message einblenden
		  TOOL_Hndl.FileDelete := 0;
			Step := ST_ASK_FOR_DELETE_FILE;
			
		ELSIF (TOOL_Hndl.ReqCreateNew) THEN
			TOOL_Hndl.ReqCreateNew := FALSE;
//			memcpy(ADR(tmpTool), ADR(RecipeNew), SIZEOF(tmpTool));	//copy data structure
			Step := ST_SEARCH_DATA;
			
		ELSIF (TOOL_Hndl.ReqParaWrite) THEN
			memcpy(ADR(tmpTool), ADR(ToolEdit), SIZEOF(tmpTool)); 	//copy data structure global to local
			strcpy(ADR(TOOL_Hndl.FileNameNew),ADR(TOOL_Hndl.ListboxFileNames[TOOL_Hndl.ListboxIdx]));
			strcat(ADR(TOOL_Hndl.FileNameNew),ADR('.csv'));
			TOOL_Hndl.OverwriteFile := TRUE;
			Step := ST_SEARCH_DATA;
			
		ELSIF (TOOL_Hndl.ReqParaWriteAfterValueChanged) THEN
			TOOL_Hndl.ReqParaWriteAfterValueChanged := FALSE;
			memcpy(ADR(tmpTool), ADR(tmpToolOld), SIZEOF(tmpTool)); 	//copy data structure 
			strcpy(ADR(TOOL_Hndl.FileNameNew),ADR(FileNameOld));
			strcat(ADR(TOOL_Hndl.FileNameNew),ADR('.csv'));
			TOOL_Hndl.OverwriteFile := TRUE;
			Step := ST_SEARCH_DATA;

		ELSIF (TOOL_Hndl.ReqSaveRecipeAs) THEN
			TOOL_Hndl.ReqSaveRecipeAs := FALSE;
			memcpy(ADR(tmpTool), ADR(ToolEdit), SIZEOF(tmpTool));	//copy data structure
			Step := ST_SEARCH_DATA;
			
		ELSIF (TOOL_Hndl.ReqParaRead) THEN
			Step := ST_READ_FILE;
			
//		ELSIF(Start_CheckVersion)THEN
//			Step:= ST_CHECK_VERSION;
		END_IF;
	
	(****************************************/
	/* list all CSV-files in a array-string */
	/****************************************)
	
	(*OHNE SORTIERUNG:*)
	(*csv-Dateien auf Device auflisten*)
	ST_LIST_FILE:	(*1*)
		StepOld := Step;
   	CSV_ListCSVFile.pStringArray := ADR(TOOL_Hndl.ListboxFileNames[0]);
   	CSV_ListCSVFile.SizeStringArray := SIZEOF(TOOL_Hndl.ListboxFileNames);
   	CSV_ListCSVFile.ArrayNum := SIZEOF(TOOL_Hndl.ListboxFileNames) / SIZEOF(TOOL_Hndl.ListboxFileNames[0]);
   	CSV_ListCSVFile.NumListboxLines := 10;
		CSV_ListCSVFile.pFileDevice := ADR(szFileDevice);
   	CSV_ListCSVFile.MaxNameLenght := 28;
   	CSV_ListCSVFile.command := FiJOB_CREATE_FILE_LIST; //2
   	CSV_ListCSVFile();
		
		IF (CSV_ListCSVFile.CSV_FileNum > 0) THEN
	    TOOL_Hndl.ListboxMaxLines := CSV_ListCSVFile.CSV_FileNum  - 1;
	  ELSE
	  	TOOL_Hndl.ListboxMaxLines := 0;
	  END_IF;
		
		//no error
	  IF (CSV_ListCSVFile.status = 0) THEN
			TOOL_Hndl.ReqDirRead := 0;
			
			IF (TOOL_Hndl.SetListBoxIdxToZero) THEN
				TOOL_Hndl.SetListBoxIdxToZero := FALSE;
				TOOL_Hndl.ListboxIdx := 0;
//				TOOL_Hndl.ListboxProgParaIdx := 0;
				TOOL_Hndl.ReqParaRead := TRUE;
			END_IF;
			
	  	Step := ST_COMMAND;
		END_IF;

	   //error
	   IF ( (CSV_ListCSVFile.status <> 0) AND (CSV_ListCSVFile.status <> 65535) ) THEN
	      TOOL_Hndl.ReqDirRead := 0;
	      Step := ST_ERROR;
	   END_IF;

	(*MIT SORTIERUNG:*)
	(*csv-Dateien auf Device auflisten*)
	ST_LIST_FILE_SORT:	(*2*)
		StepOld := Step;
   	CSV_ListCSVFile.pStringArray := ADR(FileNamesRead);
   	CSV_ListCSVFile.SizeStringArray := SIZEOF(FileNamesRead);
   	CSV_ListCSVFile.ArrayNum := SIZEOF(FileNamesRead) / SIZEOF(FileNamesRead[0]);
   	CSV_ListCSVFile.NumListboxLines := 10;
		CSV_ListCSVFile.pFileDevice := ADR(szFileDevice);
   	CSV_ListCSVFile.MaxNameLenght := 28;
   	CSV_ListCSVFile.command := 2;
   	CSV_ListCSVFile();
		
		IF (CSV_ListCSVFile.CSV_FileNum > 0) THEN
	    TOOL_Hndl.ListboxMaxLines := CSV_ListCSVFile.CSV_FileNum  - 1;
	  ELSE
	  	TOOL_Hndl.ListboxMaxLines := 0;
	  END_IF;

	  //no error
	  IF (CSV_ListCSVFile.status = 0) THEN
  		Step := ST_SORT_FILE_NAMES;
		END_IF;

	   //error
	   IF ( (CSV_ListCSVFile.status <> 0) AND (CSV_ListCSVFile.status <> 65535) ) THEN
	      TOOL_Hndl.ReqDirRead := 0;
	      Step := ST_ERROR;
	   END_IF;

	(****************************************/
	/* sort FileNames                    */
	/****************************************)
	ST_SORT_FILE_NAMES:	(*9*)
		StepOld := Step;
    Sort_0.enable := TRUE;
		Sort_0.pStringArray := ADR(FileNamesRead);
		Sort_0.StringLen := SIZEOF(FileNamesRead[0]);
		Sort_0.ArrayLen := SIZEOF(FileNamesRead);
		Sort_0();
		
	  IF (Sort_0.Status = 0) THEN
	  	TOOL_Hndl.ReqDirRead := 0;
			memcpy(ADR(TOOL_Hndl.ListboxFileNames), ADR(FileNamesRead), SIZEOF(FileNamesRead));

			IF (TOOL_Hndl.SetListBoxIdxToZero) THEN
				TOOL_Hndl.SetListBoxIdxToZero := FALSE;
				TOOL_Hndl.ListboxIdx := 0;
//				TOOL_Hndl.ListboxProgParaIdx := 0;
				TOOL_Hndl.ReqParaRead := TRUE;
			END_IF;
			
	   	Step := ST_COMMAND;
	  END_IF;

	(*****************************************/
	/* search for the data from the variable */
	/*****************************************)
	ST_SEARCH_DATA:	(*3*)
		StepOld := Step;
//		memcpy(ADR(tmpTool), ADR(ToolEdit), SIZEOF(tmpTool)); globale Datenstruktur auf lokale umkopieren
   	CSV_SearchData.pStructName := CSV_InitVariable.pStructName;
   	CSV_SearchData.NumOfStructs := CSV_InitVariable.NumOfStructs;
   	CSV_SearchData.pStructMem := CSV_InitVariable.pStructMem;
   	CSV_SearchData.MemLen := CSV_InitVariable.MemCounter;
   	CSV_SearchData.FullNameLenght := 0;
   	CSV_SearchData.Separator := 59;	//';';
   	CSV_SearchData.Options := 0;
   	CSV_SearchData.FileHeader := HEADER;
   	CSV_SearchData.pMaschineNo := ADR(CSV_Header.CustomerName);
   	CSV_SearchData.pComment := ADR(CSV_Header.MachineNumber);
   	CSV_SearchData.pVersion := ADR(CSV_Header.SW_Version);
   	CSV_SearchData();

   	//no error
   	IF (CSV_SearchData.status = 0) THEN
			strcpy(ADR(TOOL_Hndl.FileNameSave), ADR(TOOL_Hndl.FileNameNew));
			TOOL_Hndl.ReqParaWrite := FALSE;
			Step := ST_REPLACE_WRONG_CHARS;
   	END_IF;

   	//error
	  IF ( (CSV_SearchData.status <> 0) AND (CSV_SearchData.status <> 65535) ) THEN
	  	Step := ST_ERROR;
		END_IF;

	(****************************************/
	/* Replace Wrong Signs                  */
	/****************************************)
	ST_REPLACE_WRONG_CHARS:	(*13*)
		StepOld := Step;
		IF (strlen(ADR(TOOL_Hndl.FileNameSave)) <> 0) THEN
			//control, if the filename has the right extension
			strcpy(ADR(tmpString), ADR(''));

			FOR i:=0 TO strlen(ADR(TOOL_Hndl.FileNameSave))-1 DO
				Dyn_Usint ACCESS (ADR(TOOL_Hndl.FileNameSave) + i);
				strcpy(ADR(tmpChar), ADR(''));
				memcpy(ADR(tmpChar), ADR(TOOL_Hndl.FileNameSave) + i, 1);
//				IF ( ((Dyn_Usint >= ADR('0') ) AND (Dyn_Usint <= ADR('9') )) OR 
//				     ((Dyn_Usint >= ADR('A') ) AND (Dyn_Usint <= ADR('Z') )) OR  
//						 ((Dyn_Usint >= ADR('a') ) AND (Dyn_Usint <= ADR('z') )) OR 
//						 ( Dyn_Usint  = ADR('_') ) OR  (Dyn_Usint = ADR('-')   ) OR
//						 ( Dyn_Usint  = ADR('.') ) OR  (Dyn_Usint = 0) ) THEN
					IF (((Dyn_Usint >= 48) AND (Dyn_Usint <= 57)) OR 
						  ((Dyn_Usint >= 65) AND (Dyn_Usint <= 90)) OR 
						  ((Dyn_Usint >= 97) AND (Dyn_Usint <= 122)) OR 
						   (Dyn_Usint  = 95) OR (Dyn_Usint = 45) OR 
						   (Dyn_Usint  = 46) OR (Dyn_Usint = 0)) THEN
					//valid chars
					tmpString := CONCAT(tmpString, tmpChar);
				ELSE
					//non valid chars
					tmpString := CONCAT(tmpString, '-');
				END_IF;
			END_FOR;
		END_IF;	//(strlen(ADR(TOOL_Hndl.FileNameSave)) <> 0)
		
		Step := ST_SEARCH_FILE_ON_USB;
		strcpy (ADR(TOOL_Hndl.FileNameSave),ADR(tmpString)); 

	(****************************************/
	/* search filenames                    */
	/****************************************)
	ST_SEARCH_FILE_ON_USB:	(*12*)
		StepOld := Step;
	  CSV_SearchFile.pFileName := ADR(TOOL_Hndl.FileNameSave);
		CSV_SearchFile.pDevice := ADR(szFileDevice);
 		CSV_SearchFile();

	  //no error No file Found
	  IF (CSV_SearchFile.status = 0) THEN
	  	Step := ST_WRITE_FILE;
		END_IF;
	  //no error File Found
	  IF (CSV_SearchFile.status = 1) THEN
			IF (TOOL_Hndl.OverwriteFile) THEN
				TOOL_Hndl.OverwriteFile := FALSE;
				Step := ST_WRITE_FILE;
			ELSE
				TOOL_Hndl.LayerMessageBoxOverwrite := VISIBLE;	//Message einblenden
			  TOOL_Hndl.FileOverWrite := 0;
		  	Step := ST_ASK_FOR_OVERWRITE_FILE;
			END_IF;
		END_IF;
	  //error
	  IF ((CSV_SearchFile.status > 1) AND (CSV_SearchFile.status <> ERR_FUB_BUSY)) THEN
	  	Step := ST_ERROR;
	  END_IF;

	(****************************************/
	/* ask for overwrite file               */
	/****************************************)
	ST_ASK_FOR_OVERWRITE_FILE:	(*11*)
		StepOld := Step;
		IF (TOOL_Hndl.LayerMessageBoxOverwrite = INVISIBLE) THEN
			IF (TOOL_Hndl.FileOverWrite = 0) THEN
				TOOL_Hndl.ReqNewRecipe := 1;	//start dialogue again
				Step := ST_COMMAND;
			ELSE
   			Step := ST_WRITE_FILE;
				TOOL_Hndl.FileOverWrite := 0;
	    END_IF;
		END_IF;

	(*****************************************/
	/* write the searched data in a CSV-file */
	/*****************************************)
	ST_WRITE_FILE:	(*4*)
		StepOld := Step;
	 	CSV_WriteCSVFile.pFileName := ADR(TOOL_Hndl.FileNameSave);
	  CSV_WriteCSVFile.pDevice := ADR(szFileDevice);
	 	CSV_WriteCSVFile.pStructMem := CSV_InitVariable.pStructMem;
	 	CSV_WriteCSVFile.MemLen := CSV_SearchData.FileLen;
	 	CSV_WriteCSVFile.Mode := FILE_OW;
	 	CSV_WriteCSVFile();

	  //no error
	  IF (CSV_WriteCSVFile.status = 0) THEN
	  	TOOL_Hndl.ReqParaWrite := FALSE;
			TOOL_Hndl.ReqDirRead := TRUE;		//read directory again after writing a (new) file
	    Step := ST_COMMAND;
	  END_IF;
	  //error
	  IF ((CSV_WriteCSVFile.status <> 0) AND (CSV_WriteCSVFile.status <> 65535)) THEN
			TOOL_Hndl.ReqParaWrite := FALSE;
    	//Es sind nur Zeichen und Zahlen erlaubt
			IF (CSV_WriteCSVFile.status = 5004) THEN
				Step :=  ST_ERROR;
			END_IF;
			Step := ST_ERROR;
	 	END_IF;

	(*****************************************/
	/* read a CSV-file                       */
	/*****************************************)
	ST_READ_FILE:	(*5*)
		StepOld := Step;
	  CSV_ReadCSVFile.pFileName := ADR(TOOL_Hndl.ListboxFileNames[TOOL_Hndl.ListboxIdx]);
   	CSV_ReadCSVFile.pDevice := ADR(szFileDevice);
   	CSV_ReadCSVFile.No_DatatypControl := 1;
//   	CSV_ReadCSVFile.Options := 0;
   	CSV_ReadCSVFile.IgnoreError := 1;
   	CSV_ReadCSVFile.Separator := 59;	//';';
   	CSV_ReadCSVFile();

   	//no error
   	IF (CSV_ReadCSVFile.status = 0) THEN
     	TOOL_Hndl.ReqParaRead := 0;
			memcpy(ADR(ToolEdit), ADR(tmpTool), SIZEOF(ToolEdit));
			SaveUserData := 1;
      Step := ST_COMMAND;
   	END_IF;

   	//error
   	IF ((CSV_ReadCSVFile.status <> 0) AND (CSV_ReadCSVFile.status <> 65535)) THEN
      TOOL_Hndl.ReqParaRead := 0;
      Step := ST_ERROR;
	 END_IF;

	(*****************************************/
	/* read a CSV-file                       */
	/*****************************************)
	ST_CHECK_VERSION:	(*6*)
		StepOld := Step;
		CSVCheckFileVersion.enable := 1;
		CSVCheckFileVersion.pFileName := ADR('csv1.CSV');
		CSVCheckFileVersion.pDevice := ADR(szFileDevice);
		CSVCheckFileVersion.pStructSizes := ADR(StructSizes);
		CSVCheckFileVersion.NumOfStruct := CSV_InitVariable.NumOfStructs;
		CSVCheckFileVersion.pVersion := ADR('V0.02.2');
		CSVCheckFileVersion.pFileBuffer := CSVInitCheckFileVersion.pFileBuffer;
		CSVCheckFileVersion.FileBufferSize := CSVInitCheckFileVersion.FileBufferSize;
		CSVCheckFileVersion();

	  //no error
	 	IF (CSVCheckFileVersion.status = 0) THEN
	   	Step := ST_COMMAND;
	 	END_IF;

	  //error
	  IF ((CSVCheckFileVersion.status <> 0) AND (CSVCheckFileVersion.status <> 65535)) THEN
			Step := ST_ERROR;
   	END_IF;

	(****************************************/
	/* ask for delete file                  */
	/****************************************)
	ST_ASK_FOR_DELETE_FILE:	(*7*)
		StepOld := Step;
		IF (TOOL_Hndl.LayerMessageBoxDeleteFile = INVISIBLE) THEN
			IF (TOOL_Hndl.FileDelete = 0) THEN
				Step := ST_COMMAND;
			ELSE
				TOOL_Hndl.FileDelete := 0;
   			Step := ST_DELETE_FILE;
	    END_IF;
		END_IF;
	
	(*****************************************/
	/* delete a CSV-file                       */
	/*****************************************)
	ST_DELETE_FILE:	(*8*)
		StepOld := Step;
		FileDelete_0.enable 	:= 1;
		FileDelete_0.pDevice 	:= ADR(szFileDevice);
		FileDelete_0.pName 		:= ADR(TOOL_Hndl.FileNameDelete);
		FileDelete_0();
	
	  //no error
	 	IF (FileDelete_0.status = 0) THEN
			TOOL_Hndl.ReqDirRead := TRUE;		//read directory again after deleting a file
			TOOL_Hndl.SetListBoxIdxToZero := TRUE;
	   	Step := ST_COMMAND;
	 	END_IF;

	  //error
	  IF ((FileDelete_0.status <> 0) AND (FileDelete_0.status <> ERR_FUB_BUSY)) THEN
			Step := ST_ERROR;
   	END_IF;

	(****************************************/
	/* change the file device               */
	/****************************************)
	ST_UNLINK_DEVICE:	(*15*)
		StepOld := Step;
		DevUnlink_0.enable := 1;
		DevUnlink_0.handle := DevLink_0.handle;
		DevUnlink_0();

	  //no error
		IF (DevUnlink_0.status = 0) THEN
			Step := ST_LINK_DEVICE;
		ELSIF (DevUnlink_0.status = ERR_FUB_BUSY) THEN
			//
		ELSE
			Step := ST_ERROR;
		END_IF;
	
	ST_LINK_DEVICE:	(*16*)
		StepOld := Step;
		DevLink_0.enable 	:= 1;
		DevLink_0.pDevice := ADR(szFileDevice);
		DevLink_0.pParam 	:= ADR(szDevLinkPara);
		DevLink_0();

	  //no error
		IF (DevLink_0.status = 0) THEN
			TOOL_Hndl.SetListBoxIdxToZero := TRUE;
			TOOL_Hndl.ReqDirRead := TRUE;
			Step := ST_COMMAND;
		ELSIF (DevLink_0.status = ERR_FUB_BUSY) THEN
			//
		ELSE
			Step := ST_ERROR;
		END_IF;
	
	(****************************************/
	/* error counter                        */
	/****************************************)
	ST_ERROR:	(*255*)
	   Error := Error + 1;
	   Step := ST_COMMAND;

END_CASE;

(*************************************************************************
 ************************************************************************)
//copy the name of the selected csv file into a variable
IF ((TOOL_Hndl.ListboxIdx >= 0) AND (TOOL_Hndl.ListboxIdx < 100)) THEN
	strcpy(ADR(TOOL_Hndl.FileNameSelected), ADR(TOOL_Hndl.ListboxFileNames[TOOL_Hndl.ListboxIdx]));
ELSE
	strcpy(ADR(TOOL_Hndl.FileNameSelected),ADR('index out of range'));
END_IF;

//another recipe was selected in the list
IF (OldListBoxIdx <> TOOL_Hndl.ListboxIdx) THEN
	IF (TOOL_Hndl.ValueChanged) THEN			//a value was changed
		TOOL_Hndl.ValueChanged := FALSE;
		memcpy(ADR(tmpToolOld), ADR(ToolEdit), SIZEOF(tmpToolOld)); 	//copy data structure global to local
		strcpy(ADR(FileNameOld),  ADR(TOOL_Hndl.ListboxFileNames[OldListBoxIdx]));
		TOOL_Hndl.LayerMessageBoxSaveFile := VISIBLE;	//show messagebox
	END_IF;
	IF (TOOL_Hndl.LayerMessageBoxSaveFile = INVISIBLE) THEN
		OldListBoxIdx := TOOL_Hndl.ListboxIdx;
		TOOL_Hndl.ReqParaRead := TRUE;
		
//		TOOL_Hndl.ListboxProgParaIdx := 0;	//set index of second listbox to 0
	END_IF;	
END_IF;

//---------------------------------
//create a new recipe
IF(TOOL_Hndl.BtnNew) THEN
	IF (TOOL_Hndl.ReqNewRecipe = 1) THEN
		TOOL_Hndl.ReqNewRecipe := 0;
		NewTool;	//call action: show layer and alpha pad
	END_IF;
	IF ((TOOL_Hndl.NewFileNameEntered = TRUE) OR (TOOL_Hndl.StatusNewFileName = 16384)) THEN
		TOOL_Hndl.LayerNewFileName := INVISIBLE;
		//Name entered or escaped function ?
		IF (TOOL_Hndl.NewFileNameEntered = TRUE) THEN
			//create structure with default values and write to file
			DefTool;
			TOOL_Hndl.ReqCreateNew := TRUE;
			TOOL_Hndl.SetListBoxIdxToZero := TRUE;
		END_IF;
		
		TOOL_Hndl.NewFileNameEntered := FALSE;
	END_IF;
END_IF;

//---------------------------------
//save a recipe under a new name
IF (TOOL_Hndl.BtnSaveAs) THEN
	IF (TOOL_Hndl.ReqSaveAs = 1) THEN
		TOOL_Hndl.ReqSaveAs := 0;
		NewTool;	//call action: show layer and alpha pad
	END_IF;
	IF ((TOOL_Hndl.NewFileNameEntered = TRUE) OR (TOOL_Hndl.StatusNewFileName = 16384)) THEN
		TOOL_Hndl.LayerNewFileName := INVISIBLE;
		//Name entered or escaped function ?
		IF (TOOL_Hndl.NewFileNameEntered = TRUE) THEN
			//write to file
			TOOL_Hndl.ReqSaveRecipeAs := TRUE;
			TOOL_Hndl.SetListBoxIdxToZero := TRUE;
			TOOL_Hndl.ValueChanged := FALSE;
		END_IF;
		
		TOOL_Hndl.NewFileNameEntered := FALSE;
	END_IF;
END_IF;

	//---------------------------------
	//navigation throught listbox 1 (tool files)
	IF (TOOL_Hndl.ScrollHomeLbo1 = 1) THEN
		TOOL_Hndl.ScrollHomeLbo1 := 0;
		TOOL_Hndl.ListboxIdx := 0;
	END_IF;
	
	IF (TOOL_Hndl.ScrollUpLbo1 = 1) THEN
		TOOL_Hndl.ScrollUpLbo1 := 0;
			IF (TOOL_Hndl.ListboxIdx > 0) THEN
			TOOL_Hndl.ListboxIdx := TOOL_Hndl.ListboxIdx - 1;
		END_IF;
	END_IF;
	
	IF (TOOL_Hndl.ScrollDownLbo1 = 1) THEN
		TOOL_Hndl.ScrollDownLbo1 := 0;
		IF (TOOL_Hndl.ListboxIdx < TOOL_Hndl.ListboxMaxLines) THEN
			TOOL_Hndl.ListboxIdx := TOOL_Hndl.ListboxIdx + 1;
		END_IF;
	END_IF;
	
	IF (TOOL_Hndl.ScrollEndLbo1 = 1) THEN
		TOOL_Hndl.ScrollEndLbo1 := 0;
		TOOL_Hndl.ListboxIdx := TOOL_Hndl.ListboxMaxLines;
	END_IF;

//---------------------------------
////navigation throught listbox 2 (sections in recipe structure)
//IF (TOOL_Hndl.ScrollHomeLbo2 = 1) THEN
//	TOOL_Hndl.ScrollHomeLbo2 := 0;
//	TOOL_Hndl.ListboxProgParaIdx := 0;
//END_IF;
//
//IF (TOOL_Hndl.ScrollUpLbo2 = 1) THEN
//	TOOL_Hndl.ScrollUpLbo2 := 0;
//		IF (TOOL_Hndl.ListboxProgParaIdx > 0) THEN
//		TOOL_Hndl.ListboxProgParaIdx := TOOL_Hndl.ListboxProgParaIdx - 1;
//	END_IF;
//END_IF;
//
//IF (TOOL_Hndl.ScrollDownLbo2 = 1) THEN
//	TOOL_Hndl.ScrollDownLbo2 := 0;
//	IF (TOOL_Hndl.ListboxProgParaIdx  < TOOL_Hndl.ListboxProgParaMaxLines) THEN
//		TOOL_Hndl.ListboxProgParaIdx  := TOOL_Hndl.ListboxProgParaIdx  + 1;
//	END_IF;
//END_IF;
//
//IF (TOOL_Hndl.ScrollEndLbo2 = 1) THEN
//	TOOL_Hndl.ScrollEndLbo2 := 0;
//	TOOL_Hndl.ListboxProgParaIdx := TOOL_Hndl.ListboxProgParaMaxLines;
//END_IF;

//FOR ii := 0 TO 20 DO
//	TOOL_Hndl.LayersProgPara[ii] := INVISIBLE;
//END_FOR;
//TOOL_Hndl.LayersProgPara[TOOL_Hndl.ListboxProgParaIdx] := VISIBLE;

//---------------------------------
//copy all tools from CF to USB Stick
//-> task save2USB

//---------------------------------
//TOOL_Hndl.StatusBmp := BOOL_TO_UINT(NOT(ToolEdit.toolingLayout));


END_PROGRAM
