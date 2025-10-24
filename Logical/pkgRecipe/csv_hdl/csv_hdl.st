(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: csv_hdl
 * File: csv_hdl.st
 * Author: beutert
 * Created: August 28, 2012
 ********************************************************************
 * Implementation of program csv_hdl
 ********************************************************************)

PROGRAM _INIT

	REPEAT
		VCHandle	:= VA_Setup(TRUE, 'Visu');
	UNTIL (VCHandle <> 0) END_REPEAT;
	
	CSV_Hndl.LayerMessageBoxOverwrite := INVISIBLE;
	CSV_Hndl.LayerMessageBoxDeleteFile := INVISIBLE;
	CSV_Hndl.LayerNewFileName := INVISIBLE;
	CSV_Hndl.LayerMessageBoxSaveFile := INVISIBLE;
	
	HWInfo_0.enable := TRUE;
	HWInfo_0.first := TRUE;
	HWInfo_0.pName := ADR(HWString); 
	HWInfo_0();
	
	DirCreate_0.pDevice	:= ADR('USERPART');
	DirCreate_0.pName	:= ADR('Recipes');
	DirCreate_0.enable	:= TRUE;
	REPEAT
		DirCreate_0();
	UNTIL (DirCreate_0.status <> ERR_FUB_BUSY) END_REPEAT;
	
//	strcpy(ADR(szFileDevice), "USBSTICK");
//	strcpy(ADR(szFileDevice), "FLASH");
	strcpy(ADR(szFileDevice), ADR('DIR_RCP'));
	IF HWString = 'AR000' THEN
		strcpy(ADR(szDevLinkPara), ADR('/DEVICE=C:\\temp\\Recipes'));
		// 2012-12-13 /schoenefeldr/
		// In simulations mode: Always on highest password level
		Level_Passwort := 10;
	ELSE
		strcpy(ADR(szDevLinkPara), ADR('/DEVICE=F:\\Recipes'));
	END_IF	
	
	DevLink_0.enable 	:= 1;
	DevLink_0.pDevice := ADR(szFileDevice);
	DevLink_0.pParam 	:= ADR(szDevLinkPara);
	DevLink_0();
		
	strcpy(ADR(CSV_Header.CustomerName),ADR('Spilker'));
	strcpy(ADR(CSV_Header.MachineNumber),ADR('Herpa Print'));
	strcpy(ADR(CSV_Header.SW_Version),ADR('Version V1.00'));
	
	//strcpy(ADR(RecipeEdit.MachineString),ADR('machine1'));
	
	pNames[0] :=  ADR('csv_hdl:tmpRecipe');		//Name der zu sichernden PV
//	pNames[1] :=  ADR('CSV_SearchData');				//mehrere möglich

	StructSizes[0] := SIZEOF(tmpRecipe);				//Größe der zu sichernden PV
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
		CSV_Hndl.ReqDirRead := TRUE;
		xSorted := TRUE;
		OldListBoxIdx := 16#FFFF;
	END_IF;
	
END_PROGRAM


PROGRAM _CYCLIC

	IF Layer_Password THEN
		Show_Layer_password := 0;
		
		IF InputPassword =('1234') THEN
			Level_Passwort := 10;
		ELSE
				Level_Passwort := 0;
		END_IF;
	ELSE
		Show_Layer_password := 1;
		InputPassword :='****';
//		reset Passwort über Timer fehlt noch
//		Level_Passwort := 0 ;
	END_IF;	
	
	
CASE Step OF
	
	(****************************************/
	/* command interface                    */
	/****************************************)
		ST_COMMAND:	(*0*)
			IF (CSV_Hndl.ReqDirRead) THEN
				IF (xSorted = TRUE) THEN
				Step := ST_LIST_FILE_SORT;
			ELSE
				Step := ST_LIST_FILE;
			END_IF;
			
		ELSIF (CSV_Hndl.ReqDelRecipe) THEN
			CSV_Hndl.ReqDelRecipe := FALSE;
			strcpy(ADR(CSV_Hndl.FileNameDelete),ADR(CSV_Hndl.ListboxFileNames[CSV_Hndl.ListboxIdx]));
			strcat(ADR(CSV_Hndl.FileNameDelete),ADR('.csv'));
			CSV_Hndl.LayerMessageBoxDeleteFile := VISIBLE;	//Message einblenden
		  CSV_Hndl.FileDelete := 0;
			Step := ST_ASK_FOR_DELETE_FILE;
			
		ELSIF (CSV_Hndl.ReqCreateNew) THEN
			CSV_Hndl.ReqCreateNew := FALSE;
//			memcpy(ADR(tmpRecipe), ADR(RecipeNew), SIZEOF(tmpRecipe));	//copy data structure
			Step := ST_SEARCH_DATA;
			
		ELSIF (CSV_Hndl.ReqParaWrite) THEN
			memcpy(ADR(tmpRecipe), ADR(RecipeEdit), SIZEOF(tmpRecipe)); 	//copy data structure global to local
			strcpy(ADR(CSV_Hndl.FileNameNew),ADR(CSV_Hndl.ListboxFileNames[CSV_Hndl.ListboxIdx]));
			strcat(ADR(CSV_Hndl.FileNameNew),ADR('.csv'));
			CSV_Hndl.OverwriteFile := TRUE;
			Step := ST_SEARCH_DATA;
			
		ELSIF (CSV_Hndl.ReqParaWriteAfterValueChanged) THEN
			CSV_Hndl.ReqParaWriteAfterValueChanged := FALSE;
			memcpy(ADR(tmpRecipe), ADR(tmpRecipeOld), SIZEOF(tmpRecipe)); 	//copy data structure 
			strcpy(ADR(CSV_Hndl.FileNameNew),ADR(FileNameOld));
			strcat(ADR(CSV_Hndl.FileNameNew),ADR('.csv'));
			CSV_Hndl.OverwriteFile := TRUE;
			Step := ST_SEARCH_DATA;

		ELSIF (CSV_Hndl.ReqSaveRecipeAs) THEN
			CSV_Hndl.ReqSaveRecipeAs := FALSE;
			memcpy(ADR(tmpRecipe), ADR(RecipeEdit), SIZEOF(tmpRecipe));	//copy data structure
			Step := ST_SEARCH_DATA;
			
		ELSIF (CSV_Hndl.ReqParaRead) THEN
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
   	CSV_ListCSVFile.pStringArray := ADR(CSV_Hndl.ListboxFileNames[0]);
   	CSV_ListCSVFile.SizeStringArray := SIZEOF(CSV_Hndl.ListboxFileNames);
   	CSV_ListCSVFile.ArrayNum := SIZEOF(CSV_Hndl.ListboxFileNames) / SIZEOF(CSV_Hndl.ListboxFileNames[0]);
   	CSV_ListCSVFile.NumListboxLines := 10;
		CSV_ListCSVFile.pFileDevice := ADR(szFileDevice);
   	CSV_ListCSVFile.MaxNameLenght := 28;
   	CSV_ListCSVFile.command := FiJOB_CREATE_FILE_LIST; //2
   	CSV_ListCSVFile();
		
		IF (CSV_ListCSVFile.CSV_FileNum > 0) THEN
	    CSV_Hndl.ListboxMaxLines := CSV_ListCSVFile.CSV_FileNum  - 1;
	  ELSE
	  	CSV_Hndl.ListboxMaxLines := 0;
	  END_IF;
		
		//no error
	  IF (CSV_ListCSVFile.status = 0) THEN
			CSV_Hndl.ReqDirRead := 0;
			
			IF (CSV_Hndl.SetListBoxIdxToZero) THEN
				CSV_Hndl.SetListBoxIdxToZero := FALSE;
				CSV_Hndl.ListboxIdx := 0;
				CSV_Hndl.ListboxProgParaIdx := 0;
				CSV_Hndl.ReqParaRead := TRUE;
			END_IF;
			
	  	Step := ST_COMMAND;
		END_IF;

	   //error
	   IF ( (CSV_ListCSVFile.status <> 0) AND (CSV_ListCSVFile.status <> 65535) ) THEN
	      CSV_Hndl.ReqDirRead := 0;
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
	    CSV_Hndl.ListboxMaxLines := CSV_ListCSVFile.CSV_FileNum  - 1;
	  ELSE
	  	CSV_Hndl.ListboxMaxLines := 0;
	  END_IF;

	  //no error
	  IF (CSV_ListCSVFile.status = 0) THEN
  		Step := ST_SORT_FILE_NAMES;
		END_IF;

	   //error
	   IF ( (CSV_ListCSVFile.status <> 0) AND (CSV_ListCSVFile.status <> 65535) ) THEN
	      CSV_Hndl.ReqDirRead := 0;
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
	  	CSV_Hndl.ReqDirRead := 0;
			memcpy(ADR(CSV_Hndl.ListboxFileNames), ADR(FileNamesRead), SIZEOF(FileNamesRead));

			IF (CSV_Hndl.SetListBoxIdxToZero) THEN
				CSV_Hndl.SetListBoxIdxToZero := FALSE;
				CSV_Hndl.ListboxIdx := 0;
				CSV_Hndl.ListboxProgParaIdx := 0;
				CSV_Hndl.ReqParaRead := TRUE;
			END_IF;
			
	   	Step := ST_COMMAND;
	  END_IF;

	(*****************************************/
	/* search for the data from the variable */
	/*****************************************)
	ST_SEARCH_DATA:	(*3*)
		StepOld := Step;
//		memcpy(ADR(tmpRecipe), ADR(RecipeEdit), SIZEOF(tmpRecipe)); globale Datenstruktur auf lokale umkopieren
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
			strcpy(ADR(CSV_Hndl.FileNameSave), ADR(CSV_Hndl.FileNameNew));
			CSV_Hndl.ReqParaWrite := FALSE;
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
		IF (strlen(ADR(CSV_Hndl.FileNameSave)) <> 0) THEN
			//control, if the filename has the right extension
			strcpy(ADR(tmpString), ADR(''));

			FOR i:=0 TO strlen(ADR(CSV_Hndl.FileNameSave))-1 DO
				Dyn_Usint ACCESS (ADR(CSV_Hndl.FileNameSave) + i);
				strcpy(ADR(tmpChar), ADR(''));
				memcpy(ADR(tmpChar), ADR(CSV_Hndl.FileNameSave) + i, 1);
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
		END_IF;	//(strlen(ADR(CSV_Hndl.FileNameSave)) <> 0)
		
		Step := ST_SEARCH_FILE_ON_USB;
		strcpy (ADR(CSV_Hndl.FileNameSave),ADR(tmpString)); 

	(****************************************/
	/* search filenames                    */
	/****************************************)
	ST_SEARCH_FILE_ON_USB:	(*12*)
		StepOld := Step;
	  CSV_SearchFile.pFileName := ADR(CSV_Hndl.FileNameSave);
		CSV_SearchFile.pDevice := ADR(szFileDevice);
 		CSV_SearchFile();

	  //no error No file Found
	  IF (CSV_SearchFile.status = 0) THEN
	  	Step := ST_WRITE_FILE;
		END_IF;
	  //no error File Found
	  IF (CSV_SearchFile.status = 1) THEN
			IF (CSV_Hndl.OverwriteFile) THEN
				CSV_Hndl.OverwriteFile := FALSE;
				Step := ST_WRITE_FILE;
			ELSE
				CSV_Hndl.LayerMessageBoxOverwrite := VISIBLE;	//Message einblenden
			  CSV_Hndl.FileOverWrite := 0;
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
		IF (CSV_Hndl.LayerMessageBoxOverwrite = INVISIBLE) THEN
			IF (CSV_Hndl.FileOverWrite = 0) THEN
				CSV_Hndl.ReqNewRecipe := 1;	//start dialogue again
				Step := ST_COMMAND;
			ELSE
   			Step := ST_WRITE_FILE;
				CSV_Hndl.FileOverWrite := 0;
	    END_IF;
		END_IF;

	(*****************************************/
	/* write the searched data in a CSV-file */
	/*****************************************)
	ST_WRITE_FILE:	(*4*)
		StepOld := Step;
	 	CSV_WriteCSVFile.pFileName := ADR(CSV_Hndl.FileNameSave);      ///  HIER !!!!!!
	  CSV_WriteCSVFile.pDevice := ADR(szFileDevice);
	 	CSV_WriteCSVFile.pStructMem := CSV_InitVariable.pStructMem;
	 	CSV_WriteCSVFile.MemLen := CSV_SearchData.FileLen;
	 	CSV_WriteCSVFile.Mode := FILE_OW;
	 	CSV_WriteCSVFile();

	  //no error
	  IF (CSV_WriteCSVFile.status = 0) THEN
	  	CSV_Hndl.ReqParaWrite := FALSE;
			CSV_Hndl.ReqDirRead := TRUE;		//read directory again after writing a (new) file
	    Step := ST_COMMAND;
	  END_IF;
	  //error
	  IF ((CSV_WriteCSVFile.status <> 0) AND (CSV_WriteCSVFile.status <> 65535)) THEN
			CSV_Hndl.ReqParaWrite := FALSE;
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
	  CSV_ReadCSVFile.pFileName := ADR(CSV_Hndl.ListboxFileNames[CSV_Hndl.ListboxIdx]);
   	CSV_ReadCSVFile.pDevice := ADR(szFileDevice);
   	CSV_ReadCSVFile.No_DatatypControl := 1;
//   	CSV_ReadCSVFile.Options := 0;
   	CSV_ReadCSVFile.IgnoreError := 1;
   	CSV_ReadCSVFile.Separator := 59;	//';';
   	CSV_ReadCSVFile();

   	//no error
   	IF (CSV_ReadCSVFile.status = 0) THEN
     	CSV_Hndl.ReqParaRead := 0;
			memcpy(ADR(RecipeEdit), ADR(tmpRecipe), SIZEOF(RecipeEdit));
			CSV_Hndl.ListBoxRecipeChanged := 1;	//another recipe was selected
			SaveUserData := 1;
      Step := ST_COMMAND;
   	END_IF;

   	//error
   	IF ((CSV_ReadCSVFile.status <> 0) AND (CSV_ReadCSVFile.status <> 65535)) THEN
      CSV_Hndl.ReqParaRead := 0;
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
		IF (CSV_Hndl.LayerMessageBoxDeleteFile = INVISIBLE) THEN
			IF (CSV_Hndl.FileDelete = 0) THEN
				Step := ST_COMMAND;
			ELSE
				CSV_Hndl.FileDelete := 0;
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
		FileDelete_0.pName 		:= ADR(CSV_Hndl.FileNameDelete);
		FileDelete_0();
	
	  //no error
	 	IF (FileDelete_0.status = 0) THEN
			CSV_Hndl.ReqDirRead := TRUE;		//read directory again after deleting a file
			CSV_Hndl.SetListBoxIdxToZero := TRUE;
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
			CSV_Hndl.SetListBoxIdxToZero := TRUE;
			CSV_Hndl.ReqDirRead := TRUE;
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
IF ((CSV_Hndl.ListboxIdx >= 0) AND (CSV_Hndl.ListboxIdx < 100)) THEN
	strcpy(ADR(CSV_Hndl.FileNameSelected), ADR(CSV_Hndl.ListboxFileNames[CSV_Hndl.ListboxIdx]));
ELSE
	strcpy(ADR(CSV_Hndl.FileNameSelected),ADR('index out of range'));
END_IF;

//another recipe was selected in the list
IF (OldListBoxIdx <> CSV_Hndl.ListboxIdx) THEN
	IF (CSV_Hndl.ValueChanged) THEN			//a value was changed
		CSV_Hndl.ValueChanged := FALSE;
		memcpy(ADR(tmpRecipeOld), ADR(RecipeEdit), SIZEOF(tmpRecipeOld)); 	//copy data structure global to local
		strcpy(ADR(FileNameOld),  ADR(CSV_Hndl.ListboxFileNames[OldListBoxIdx]));
		CSV_Hndl.LayerMessageBoxSaveFile := VISIBLE;	//show messagebox
	END_IF;
	IF (CSV_Hndl.LayerMessageBoxSaveFile = INVISIBLE) THEN
		OldListBoxIdx := CSV_Hndl.ListboxIdx;
		CSV_Hndl.ReqParaRead := TRUE;
		
		CSV_Hndl.ListboxProgParaIdx := 0;	//set index of second listbox to 0
	END_IF;	
END_IF;

//---------------------------------
//create a new recipe
IF(CSV_Hndl.BtnNew) THEN
	IF (CSV_Hndl.ReqNewRecipe = 1) THEN
		CSV_Hndl.ReqNewRecipe := 0;
		NewRecipe;	//call action: show layer and alpha pad
	END_IF;
	IF ((CSV_Hndl.NewFileNameEntered = TRUE) OR (CSV_Hndl.StatusNewFileName = 16384)) THEN
		CSV_Hndl.LayerNewFileName := INVISIBLE;
		//Name entered or escaped function ?
		IF (CSV_Hndl.NewFileNameEntered = TRUE) THEN
			//create structure with default values and write to file 
			DefRecipe;																		   ///  HIER !!!!!!
			CSV_Hndl.ReqCreateNew := TRUE;
			CSV_Hndl.SetListBoxIdxToZero := TRUE;
		END_IF;
		
		CSV_Hndl.NewFileNameEntered := FALSE;
	END_IF;
END_IF;

//---------------------------------
//save a recipe under a new name
IF (CSV_Hndl.BtnSaveAs) THEN
	IF (CSV_Hndl.ReqSaveAs = 1) THEN
		CSV_Hndl.ReqSaveAs := 0;
		NewRecipe;	//call action: show layer and alpha pad
	END_IF;
	IF ((CSV_Hndl.NewFileNameEntered = TRUE) OR (CSV_Hndl.StatusNewFileName = 16384)) THEN
		CSV_Hndl.LayerNewFileName := INVISIBLE;
		//Name entered or escaped function ?
		IF (CSV_Hndl.NewFileNameEntered = TRUE) THEN
			//write to file
			CSV_Hndl.ReqSaveRecipeAs := TRUE;
			CSV_Hndl.SetListBoxIdxToZero := TRUE;                                        ///  HIER !!!!!!
			CSV_Hndl.ValueChanged := FALSE;
		END_IF;
		
		CSV_Hndl.NewFileNameEntered := FALSE;
	END_IF;
END_IF;

//---------------------------------
//navigation throught listbox 1 (recipe files)
IF (CSV_Hndl.ScrollHomeLbo1 = 1) THEN
	CSV_Hndl.ScrollHomeLbo1 := 0;
	CSV_Hndl.ListboxIdx := 0;
END_IF;

IF (CSV_Hndl.ScrollUpLbo1 = 1) THEN
	CSV_Hndl.ScrollUpLbo1 := 0;
		IF (CSV_Hndl.ListboxIdx > 0) THEN
		CSV_Hndl.ListboxIdx := CSV_Hndl.ListboxIdx - 1;
	END_IF;
END_IF;

IF (CSV_Hndl.ScrollDownLbo1 = 1) THEN
	CSV_Hndl.ScrollDownLbo1 := 0;
	IF (CSV_Hndl.ListboxIdx < CSV_Hndl.ListboxMaxLines) THEN
		CSV_Hndl.ListboxIdx := CSV_Hndl.ListboxIdx + 1;
	END_IF;
END_IF;

IF (CSV_Hndl.ScrollEndLbo1 = 1) THEN
	CSV_Hndl.ScrollEndLbo1 := 0;
	CSV_Hndl.ListboxIdx := CSV_Hndl.ListboxMaxLines;
END_IF;

	//---------------------------------
	//navigation throught listbox 2 (sections in recipe structure)
	IF (CSV_Hndl.ScrollHomeLbo2 = 1) THEN
		ProgParaIndexSearchDirection	:= mcPOSITIVE_DIR;
		CSV_Hndl.ScrollHomeLbo2 := 0;
		CSV_Hndl.ListboxProgParaIdx := 0;
	END_IF;
	
	IF (CSV_Hndl.ScrollUpLbo2 = 1) THEN
		ProgParaIndexSearchDirection	:= mcNEGATIVE_DIR;
		CSV_Hndl.ScrollUpLbo2 := 0;
			IF (CSV_Hndl.ListboxProgParaIdx > 0) THEN
			CSV_Hndl.ListboxProgParaIdx := CSV_Hndl.ListboxProgParaIdx - 1;
		END_IF;
	END_IF;
	
	IF (CSV_Hndl.ScrollDownLbo2 = 1) THEN
		ProgParaIndexSearchDirection	:= mcPOSITIVE_DIR;
		CSV_Hndl.ScrollDownLbo2 := 0;
		IF (CSV_Hndl.ListboxProgParaIdx  < CSV_Hndl.ListboxProgParaMaxLines) THEN
			CSV_Hndl.ListboxProgParaIdx  := CSV_Hndl.ListboxProgParaIdx  + 1;
		END_IF;
	END_IF;

	IF (CSV_Hndl.ScrollEndLbo2 = 1) THEN
		ProgParaIndexSearchDirection	:= mcNEGATIVE_DIR;
		CSV_Hndl.ScrollEndLbo2 := 0;
		CSV_Hndl.ListboxProgParaIdx := CSV_Hndl.ListboxProgParaMaxLines;
	END_IF;
	
	//check if the text at the current listbox index exists
	SPR_CheckTextIndexValid_0.Enable	:= TRUE;
	SPR_CheckTextIndexValid_0.TG_id		:= TXT_GRP_PROGPARASECTIONS;
	SPR_CheckTextIndexValid_0.TGT_id	:= CSV_Hndl.ListboxProgParaIdx;
	SPR_CheckTextIndexValid_0.VCHandle	:= VCHandle;
	SPR_CheckTextIndexValid_0();
	
	IF ( (SPR_CheckTextIndexValid_0.Status <> vaERR_BUSY) AND NOT SPR_CheckTextIndexValid_0.Valid) THEN
		IF (ProgParaIndexSearchDirection = mcPOSITIVE_DIR) THEN
			IF (CSV_Hndl.ListboxProgParaIdx  < CSV_Hndl.ListboxProgParaMaxLines) THEN
				CSV_Hndl.ListboxProgParaIdx		:= CSV_Hndl.ListboxProgParaIdx + 1;
			ELSE
				CSV_Hndl.ListboxProgParaIdx		:= CSV_Hndl.ListboxProgParaIdx - 1;
				ProgParaIndexSearchDirection	:= mcNEGATIVE_DIR;
			END_IF;
		ELSE
			IF (CSV_Hndl.ListboxProgParaIdx > 0) THEN
				CSV_Hndl.ListboxProgParaIdx		:= CSV_Hndl.ListboxProgParaIdx - 1;
			ELSE
				CSV_Hndl.ListboxProgParaIdx		:= CSV_Hndl.ListboxProgParaIdx + 1;
				ProgParaIndexSearchDirection	:= mcPOSITIVE_DIR;
			END_IF;
		END_IF;
	END_IF;	

FOR ii := 0 TO 20 DO
	CSV_Hndl.LayersProgPara[ii] := INVISIBLE;
END_FOR;
CSV_Hndl.LayersProgPara[CSV_Hndl.ListboxProgParaIdx] := VISIBLE;

//---------------------------------
//copy all recipes from CF to USB Stick
//-> task save2USB

//---------------------------------
//CSV_Hndl.StatusBmpTensionOnOff := BOOL_TO_UINT(NOT(RecipeEdit.dancer.cylinderTension));
//CSV_Hndl.StatusBmpRadiusCtrlOnOff := BOOL_TO_UINT(NOT(RecipeEdit.dancer.radiusCtrlOn));
//CSV_Hndl.StatusBmpReverseGrid1 := BOOL_TO_UINT(NOT(RecipeEdit.grid1.reverse));
//CSV_Hndl.StatusBmpReverseGrid2 := BOOL_TO_UINT(NOT(RecipeEdit.grid2.reverse));
//CSV_Hndl.StatusBmpReverseSpender1 := BOOL_TO_UINT(NOT(RecipeEdit.spender1.reverse));
//CSV_Hndl.StatusBmpReverseSpender2 := BOOL_TO_UINT(NOT(RecipeEdit.spender2.reverse));


END_PROGRAM
