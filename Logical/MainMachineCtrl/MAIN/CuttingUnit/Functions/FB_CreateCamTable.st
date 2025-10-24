(********************************************************************
 * COPYRIGHT -- Nitto
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CreateCamTable.st
 * Autor: s_spilker
 * Erstellt: 9. November 2015
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_CreateCamTable
	CASE state OF

		STATE_READY://0
			IF createCam THEN
				(*	createCam:=FALSE;*)
				err(reset := TRUE);	
				IF  data.recipe.tool.numberToolSegments = 1 OR data.recipe.tool.numberToolSegments = 0 OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN
					idx := 0;
					state:=STATE_CALCULATE_CAM1;
				ELSIF data.recipe.tool.numberToolSegments > 1 AND data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
					idx := 0;
					jdx := 0;
					state:=STATE_CALCULATE_CAM2;
				END_IF
			ELSE 
				done:=FALSE;
			END_IF
		(*********************************************)
		STATE_CALCULATE_CAM1://1  (*calculate cam from sections*)
			(*bestimmung der Eigenschaften der Stützpunkte. Es können bis zu 64 Stützpunkte angelegt werden*)
			IF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN // beim Freilauf wird Insetting auf ganzen Umfang bezogen
				CamSections.Section[0].MasterPosition	:=0;
				CamSections.Section[0].SlavePosition	:=0;
				CamSections.Section[0].FirstDerivative 	:= 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
				CamSections.Section[0].SecondDerivative := 0;
				CamSections.Section[0].Mode 			:= mcABSOLUTE;(*mcRELATIVE;*)
				CamSections.Section[0].Type 			:= mc5TH_ORDER_POLYNOMIAL;
	
				CamSections.Section[1].MasterPosition 	:= scalePerimeter.realperimeter;// da das Werkzeug 1 zu 1 laufen soll
				CamSections.Section[1].SlavePosition 	:= scalePerimeter.realperimeter;
				CamSections.Section[1].FirstDerivative 	:= 1;
				CamSections.Section[1].SecondDerivative	:= 0;
				CamSections.Section[1].Mode 			:= mcABSOLUTE;  (*mcRELATIVE;*)
				CamSections.Section[1].Type 			:= mcLAST_POINT;(* mc5TH_ORDER_POLYNOMIAL;*)
				idx := 2;
				maxIdx := 64;
				WHILE idx < maxIdx -1 DO // falls bereits Stützpunkte vorhanden, alle löschen
					CamSections.Section[idx].MasterPosition		:= 0;
					CamSections.Section[idx].SlavePosition 		:= 0;
					CamSections.Section[idx].FirstDerivative 	:= 0; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
					CamSections.Section[idx].SecondDerivative 	:= 0;
					CamSections.Section[idx].Mode 				:= 0;
					CamSections.Section[idx].Type 				:= 0;///mc5TH_ORDER_POLYNOMIAL;
					idx := idx +1;
				END_WHILE
			
				state:= STATE_CALC_CAM_FROM_SECTIONS;

			ELSIF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN OR data.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT THEN

				IF   data.recipe.tool.cutEndPosition > data.recipe.tool.cutStartPosition AND data.recipe.tool.cutEndPosition > 0 THEN
					//Kurvenscheibe mit einer synchnoner Strecke 
					CamSections.Section[0].MasterPosition:=0;
					CamSections.Section[0].SlavePosition:=0;
					CamSections.Section[0].FirstDerivative := 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
					CamSections.Section[0].SecondDerivative := 0;
					CamSections.Section[0].Mode := mcABSOLUTE;(*mcRELATIVE;*)
					CamSections.Section[0].Type := mcSTRAIGHT_LINE;///mc5TH_ORDER_POLYNOMIAL;
					// Ende der Kurvenscheibenstrecke mit einem automatischen Ausgleich und Anfang des Ausgleichs
					CamSections.Section[1].MasterPosition:= data.recipe.tool.cutEndPosition;
					CamSections.Section[1].SlavePosition:=data.recipe.tool.cutEndPosition;
					CamSections.Section[1].FirstDerivative := 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
					CamSections.Section[1].SecondDerivative := 0;
					CamSections.Section[1].Mode := mcABSOLUTE;(*mcRELATIVE;*)
					CamSections.Section[1].Type := mc5TH_ORDER_POLYNOMIAL;//mcHARMONIC_COMBINATION ;
					//
					CamSections.Section[2].MasterPosition :=data.general.periodLength;
					CamSections.Section[2].SlavePosition := scalePerimeter.realperimeter;
					CamSections.Section[2].FirstDerivative := 1;
					CamSections.Section[2].SecondDerivative:= 0;
					CamSections.Section[2].Mode := mcABSOLUTE;  (*mcRELATIVE;*)
					CamSections.Section[2].Type := mcLAST_POINT;(* mc5TH_ORDER_POLYNOMIAL;*)
					
					idx := 3;
					maxIdx := 64;
					WHILE idx < maxIdx -1 DO // falls bereits Stützpunkte vorhanden, alle löschen
					
						CamSections.Section[idx].MasterPosition		:= 0;
						CamSections.Section[idx].SlavePosition 		:= 0;
						CamSections.Section[idx].FirstDerivative 	:= 0; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
						CamSections.Section[idx].SecondDerivative 	:= 0;
						CamSections.Section[idx].Mode 				:= 0;
						CamSections.Section[idx].Type 				:= 0;///mc5TH_ORDER_POLYNOMIAL;
						idx := idx +1;
					END_WHILE
					state:= STATE_CALC_CAM_FROM_SECTIONS;
		
				ELSIF  data.recipe.tool.cutEndPosition = 0 OR data.recipe.tool.cutEndPosition = scalePerimeter.realperimeter THEN
					CamSections.Section[0].MasterPosition:=0;
					CamSections.Section[0].SlavePosition:=0;
					CamSections.Section[0].FirstDerivative := 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
					CamSections.Section[0].SecondDerivative := 0;
					CamSections.Section[0].Mode := mcABSOLUTE;(*mcRELATIVE;*)
					CamSections.Section[0].Type := mc5TH_ORDER_POLYNOMIAL;
		
					CamSections.Section[1].MasterPosition :=data.general.periodLength;
					CamSections.Section[1].SlavePosition := scalePerimeter.realperimeter;
					CamSections.Section[1].FirstDerivative := 1;
					CamSections.Section[1].SecondDerivative:= 0;
					CamSections.Section[1].Mode := mcABSOLUTE;  (*mcRELATIVE;*)
					CamSections.Section[1].Type := mcLAST_POINT;(* mc5TH_ORDER_POLYNOMIAL;*)
					idx := 2;
					maxIdx := 64;
					WHILE idx < maxIdx -1 DO // falls bereits Stützpunkte vorhanden, alle löschen
						CamSections.Section[idx].MasterPosition		:= 0;
						CamSections.Section[idx].SlavePosition 		:= 0;
						CamSections.Section[idx].FirstDerivative 	:= 0; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
						CamSections.Section[idx].SecondDerivative 	:= 0;
						CamSections.Section[idx].Mode 				:= 0;
						CamSections.Section[idx].Type 				:= 0;///mc5TH_ORDER_POLYNOMIAL;
						idx := idx +1;
					END_WHILE
					state:= STATE_CALC_CAM_FROM_SECTIONS;
				END_IF
			ELSIF data.recipe.tool.cutEndPosition < data.recipe.tool.cutStartPosition THEN
				err.set := TRUE;
				err.state := state;
				err.text := 'Synchronerbereich ist größer als Nutzen';
				err.fnc := 'FB_Camtable';
				err.id := MC_BR_CalcCamFromSections_0.ErrorID; 
				state:=STATE_ERROR;
			END_IF 

		STATE_CALCULATE_CAM2://1  (*calculate cam from sections*)
			(*Bestimmung der Eigenschaften der Stützpunkte. Es können bis zu 64 Stützpunkte angelegt werden*)
			IF data.recipe.tool.numberToolSegments > 1 AND  data.recipe.tool.numberToolSegments <= 12 THEN
				partOfPerimeter := scalePerimeter.realperimeter/data.recipe.tool.numberToolSegments;  //Anzahl der Kurvenstücken 
				maxIdx			:= data.recipe.tool.numberToolSegments *2;
			ELSE 
				partOfPerimeter := scalePerimeter.realperimeter;
			END_IF

			IF data.recipe.tool.cutEndPosition < partOfPerimeter  THEN
				CamSections.Section[maxIdx].MasterPosition	:= scalePerimeter.realperimeter;
				CamSections.Section[maxIdx].SlavePosition	:= scalePerimeter.realperimeter;
				CamSections.Section[maxIdx].FirstDerivative := 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
				CamSections.Section[maxIdx].SecondDerivative:= 0;
				CamSections.Section[maxIdx].Mode 			:= mcABSOLUTE;
				CamSections.Section[maxIdx].Type 			:= mcLAST_POINT;
				WHILE idx < maxIdx -1 DO //jeden zweiten Stützpunkt, gerade Zahl	
					CamSections.Section[idx].MasterPosition		:= partOfPerimeter * jdx;
					CamSections.Section[idx].SlavePosition 		:= partOfPerimeter * jdx;
					CamSections.Section[idx].FirstDerivative 	:= 1;
					CamSections.Section[idx].SecondDerivative 	:= 0;
					CamSections.Section[idx].Mode 				:= mcABSOLUTE;
					CamSections.Section[idx].Type 				:= mcSTRAIGHT_LINE; //mc5TH_ORDER_POLYNOMIAL;
					idx := idx + 2;
					jdx := jdx + 1;
				END_WHILE

				idx := 1;
				jdx := 0;
				WHILE idx < maxIdx DO//jede ungeraden Stützpuknt
					CamSections.Section[idx].MasterPosition		:= partOfPerimeter * jdx + data.recipe.tool.cutEndPosition;
					CamSections.Section[idx].SlavePosition 		:= partOfPerimeter * jdx + data.recipe.tool.cutEndPosition;
					CamSections.Section[idx].FirstDerivative 	:= 1; (* Laut Ronny bei 1 wird die Geschwind. vom Master übernommen'*)
					CamSections.Section[idx].SecondDerivative 	:= 0;
					CamSections.Section[idx].Mode 				:= mcABSOLUTE;
					CamSections.Section[idx].Type 				:= mc5TH_ORDER_POLYNOMIAL;///
					idx := idx + 2;
					jdx := jdx + 1;
				END_WHILE
				state:= STATE_CALC_CAM_FROM_SECTIONS;
			ELSE
				err.set := TRUE;
				err.state := state;
				err.text := 'Synchronerbereich ist größer als Nutzen';
				err.fnc := 'FB_Camtable';
				err.id := MC_BR_CalcCamFromSections_0.ErrorID;
				state:=STATE_ERROR;
			END_IF 

		STATE_CALC_CAM_FROM_SECTIONS://2 //hier werden einzelne Punkte die in STATE_CALCULATE_CAM angelegt wurden sind als eine Stätige Kurve zusammen gesetzt
			idx := 0;
			MC_BR_CalcCamFromSections_0.Execute:= TRUE;
			MC_BR_CalcCamFromSections_0.DataAddress:=ADR(CamSections);
			MC_BR_CalcCamFromSections_0.CamProfileAddress:=ADR(MC_CAMPROFILE_TYP_0);
			MC_BR_CalcCamFromSections_0();
    
			IF MC_BR_CalcCamFromSections_0.Done THEN
				MC_BR_CalcCamFromSections_0.Execute:= FALSE;
				(*state:=STATE_READY;*)
				state := STATE_SAVE_CAM_PROFILE;
			ELSIF MC_BR_CalcCamFromSections_0.Error THEN
				err.set := TRUE; 
				err.state:= state;
				err.text :='MC_BR_CalcCamFromSections_0'; 
				err.fnc := 'FB_Camtable'; 
				err.id := MC_BR_CalcCamFromSections_0.ErrorID;
				axis1ErrorID:= MC_BR_CalcCamFromSections_0.ErrorID;
				MC_BR_CalcCamFromSections_0.Execute:=0;
				state:=STATE_ERROR;
			END_IF

		STATE_SAVE_CAM_PROFILE:  //3 schreibe die Kurvenscheibe in das NC-Kurvenscheiben-Datenmodul
			MC_BR_CalcCamFromSections_0(); //noch einen Zyklus aufrufen

			MC_BR_SaveCamProfileObj_0.Execute			:= TRUE;
			MC_BR_SaveCamProfileObj_0.DataObjectName	:= Name; //'TestCam'; //Sehr wichtig der Name darf nicht größer als 12 Zeichen sein
			// Wie es bei B&R üblich ist, steht es explizit nirgendswo geschrieben. Nach mühsamen Test hat sich es gezeigt.
			MC_BR_SaveCamProfileObj_0.DataAddress		:= ADR(MC_CAMPROFILE_TYP_0);
			MC_BR_SaveCamProfileObj_0.DataObjectVersion	:= 1000;
			
			MC_BR_SaveCamProfileObj_0();
		
			IF MC_BR_SaveCamProfileObj_0.Done  THEN
				MC_BR_SaveCamProfileObj_0.Execute	:= FALSE;
				state:=STATE_DOWNLOAD_CAMPROFILEDATA;
			ELSIF MC_BR_SaveCamProfileObj_0.Error THEN
				err.set := TRUE;
				err.state := state;
				err.text := 'MC_BR_SaveCamProfileObj_0'; 
				err.fnc := 'FB_Camtable'; 
				err.id := MC_BR_SaveCamProfileObj_0.ErrorID;
				state := STATE_ERROR;
			END_IF


		STATE_DOWNLOAD_CAMPROFILEDATA://4 übertrage die Daten vom NC-Kurvenscheiben-Datenmodul auf den Antrieb
			(* zulässiger  an index for cam (1-14)*)
			MC_BR_SaveCamProfileObj_0();

			MC_BR_DownloadCamProfileObj_0.Execute 		:= TRUE;
			MC_BR_DownloadCamProfileObj_0.DataObjectName:= Name;
			MC_BR_DownloadCamProfileObj_0.Index			:= index;
			MC_BR_DownloadCamProfileObj_0.Periodic		:= mcPERIODIC;

			MC_BR_DownloadCamProfileObj_0(Axis := AxisREF);

			IF MC_BR_DownloadCamProfileObj_0.Done THEN
				MC_BR_DownloadCamProfileObj_0.Execute := FALSE;
				state :=  STATE_CAMTABLE_SEL;
			ELSIF MC_BR_DownloadCamProfileObj_0.Error THEN
				err.set := TRUE;
				err.state :=  state;
				err.text := 'MC_BR_DownloadCamProfileObj_0'; 
				err.fnc := 'FB_Camtable'; 
				err.id := MC_BR_DownloadCamProfileObj_0.ErrorID;
				state := STATE_ERROR;
			END_IF

		STATE_CAMTABLE_SEL: //5 wählt eine vordefinierte Kurvensscheibe ausfür den FB MC_CamIn.
			MC_BR_DownloadCamProfileObj_0(Axis := AxisREF);

			MC_CamTableSelect_0.CamTable := Name;
			MC_CamTableSelect_0.Periodic := mcPERIODIC; //periodische Achse
			MC_CamTableSelect_0.Execute := TRUE;
			MC_CamTableSelect_0(Master := MasterAxisREF, Slave := AxisREF);
			IF MC_CamTableSelect_0.Done AND MC_CamTableSelect_0.CamTableID > 0 THEN
				camTableID := MC_CamTableSelect_0.CamTableID; //zwischenspeichern weil beim nächsten Aufruf die CamTableID auf 0 gesetzt wird
				MC_CamTableSelect_0.Execute := FALSE;
				(*	done:=TRUE;*)
				//	createCam:=FALSE;//16.04.15 wird aus dem Config auf rückgesetzt.
				state := STATE_COMPLETED;
			ELSIF MC_CamTableSelect_0.Error THEN
				err(set := TRUE, text := 'MC_CamTableSelect_0', fnc := 'FB_Camtable', id := MC_CamTableSelect_0.ErrorID);
				state := STATE_ERROR;
			END_IF

		STATE_COMPLETED://10 FB werden noch mal aufgerufen um den Ausgang Done auf false zu setzten
			MC_BR_CalcCamFromSections_0(Execute := FALSE);
			MC_BR_SaveCamProfileObj_0(Execute := FALSE);
			MC_BR_DownloadCamProfileObj_0(Execute := FALSE);
			MC_CamTableSelect_0(Master := MasterAxisREF, Slave := AxisREF, Execute := FALSE);
			IF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN
				IF MC_CAMPROFILE_TYP_0.MasterPeriod = REAL_TO_DINT(scalePerimeter.realperimeter) AND MC_CAMPROFILE_TYP_0.SlavePeriod = REAL_TO_DINT (scalePerimeter.realperimeter) THEN
					done:=TRUE;
					state := STATE_READY;
				END_IF
			ELSIF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
				IF (*MC_CAMPROFILE_TYP_0.MasterPeriod >= REAL_TO_DINT(scalePerimeter.realperimeter) AND *)MC_CAMPROFILE_TYP_0.SlavePeriod = REAL_TO_DINT (scalePerimeter.realperimeter) THEN
					done:=TRUE;
					state := STATE_READY;
				END_IF
			END_IF
	
		STATE_ERROR:
			createCam:=FALSE;
			err();	
			state:=STATE_READY;


	END_CASE
END_FUNCTION_BLOCK