(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: tool_hndl
 * File: DefTool.st
 * Author: beutert
 * Created: August 24, 2012
 ********************************************************************
 * Implementation of program tool_hndl
 ********************************************************************) 

 (* sets default values to tool struct *)
ACTION DefTool: 
	memset(ADR(tmpTool), 0, SIZEOF(tmpTool));

	// 2012-09-19 /schoenefeldr/
	// Default values for some parameters
	tmpTool.cogCutting			:= DEFAULT_COG_CUTTING;
	tmpTool.cogSupportSpindle	:= DEFAULT_COG_SUPP_SPINDLE;
	tmpTool.numberToolSegments	:= DEFAULT_COG_TOOL_SEGMENTS;

END_ACTION