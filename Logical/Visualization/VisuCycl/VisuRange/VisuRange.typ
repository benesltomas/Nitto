(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuRange
 * File: VisuRange.typ
 * Author: schoenefeldr
 * Created: July 16, 2012
 ********************************************************************
 * Local data types of program VisuRange
 ********************************************************************)

TYPE
	VentAout_Type : 	STRUCT 
		VentDancer : REAL; (*Proportionalventil Tänzerspannung (Festo)*)
		VentClutchSpend1 : REAL; (*Proportionalventil Rutschkupplung Abwickler 1*)
		VentClutchSpend2 : REAL; (*Proportionalventil Rutschkupplung Abwickler 2*)
		VentClutchSpend3 : REAL; (*Proportionalventil Rutschkupplung Abwickler 3*)
		VentClutchGrid1 : REAL; (*Proportionalventil Rutschkupplung Gitteraufwickler 1*)
		VentClutchGrid2 : REAL; (*Proportionalventil Rutschkupplung Gitteraufwickler 2*)
		VentOptClutchTUnwindTop : REAL; (*Option Proportionalventil Rutschkupplung Tandemwickler oben*)
		VentOptClutchTUnwindBot : REAL; (*Option Proportionalventil Rutschkupplung Tandemwickler unten*)
	END_STRUCT;
	emu_Batch_Acknowledge : 
		( (*Meldetext für Auftrag*)
		BATCH_ALMOST_COMPLETE := 0,
		BATCH_COMPLETE := 1
		);
END_TYPE
