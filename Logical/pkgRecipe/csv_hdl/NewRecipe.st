(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: csv_hndl
 * File: NewRecipe.st
 * Author: beutert
 * Created: August 21, 2012
 ********************************************************************
 * Implementation of program csv_hndl
 ********************************************************************) 

 (* Add a new action to your IEC program or library *)
ACTION NewRecipe: 
	CSV_Hndl.FileNameNew := '';
	CSV_Hndl.LayerNewFileName := VISIBLE;	//show layer
	CSV_Hndl.StatusNewFileName := CSV_Hndl.StatusNewFileName  OR 2#0000000000001000; //show alphapad
END_ACTION