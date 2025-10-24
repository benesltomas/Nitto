(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: tool_Hdl
 * File: NewTool.st
 * Author: beutert
 * Created: August 21, 2012
 ********************************************************************
 * Implementation of program tool_Hdl
 ********************************************************************) 

 (* Add a new action to your IEC program or library *)
ACTION NewTool:
	TOOL_Hndl.FileNameNew := '';
	TOOL_Hndl.LayerNewFileName := VISIBLE;	//show layer
	TOOL_Hndl.StatusNewFileName := TOOL_Hndl.StatusNewFileName  OR 2#0000000000001000; //show alphapad
END_ACTION