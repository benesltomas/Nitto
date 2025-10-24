(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuTasks
 * File: VisuTasks.fun
 * Author: schoenefeldr
 * Created: August 01, 2012
 ********************************************************************
 * Functions and function blocks of program VisuTasks
 ********************************************************************)

FUNCTION CalibrDiam : USINT (*Calibrate diameter sensor offset for machine recipe*)
	VAR_INPUT
		adr_diamRecipe : REFERENCE TO rcp_machine_Wind_Type; (*Diameter limitations from machine recipe*)
		adr_diamOffs : REFERENCE TO REAL; (*adress to diameter in machine recipe*)
		adr_AinData : REFERENCE TO AiAo_Type; (*adress to analogue input structure*)
	END_VAR
END_FUNCTION
