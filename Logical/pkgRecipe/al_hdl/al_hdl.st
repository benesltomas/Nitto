(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: al_hndl
 * File: al_hndl.st
 * Author: beutert
 * Created: August 28, 2012
 ********************************************************************
 * Implementation of program al_hndl
 *
 * History:
 * 2012-08-28 /beutert/
 *		Task created
 * 2012-10-30 /schoenefeldr/
 *		Use global diameter status variable for alarms
 ********************************************************************)

PROGRAM _INIT


AlarmBit_a[0] := AlarmBit_a[0];
QuitBit_a[0] := QuitBit_a[0];
WarningBit_a[0] := WarningBit_a[0];


END_PROGRAM


PROGRAM _CYCLIC

	
	// Erzeugung von Alarme, 
	// Fehler 0
	IF FALSE THEN
	AlarmBit_a[0] := 1;
	END_IF;
	// Fehler 1
	IF FALSE THEN
		AlarmBit_a[1] := 1;
	END_IF;
	// Fehler 2
	IF FALSE THEN
		AlarmBit_a[2] := 1;
	END_IF;
	// Fehler 3
	IF FALSE THEN
		AlarmBit_a[3] := 1;
	END_IF;
	// Fehler 4
	IF FALSE THEN
		AlarmBit_a[4] := 1;
	END_IF;
	// Fehler 5
	IF FALSE THEN
		AlarmBit_a[5] := 1;
	END_IF;

	
	
	// Erzeugung von Warnungen, 
	// Warnung 0 
	IF FALSE THEN
		WarningBit_a[0] := 1;
	END_IF;

	// Warnung 1 UnWinder
	IF gMachine.Status.Diam.MainUnwind < gMachRecipe.mainUnwind.WarnDiam  THEN
		WarningBit_a[1] := 1;
	END_IF;
	// Warnung 2 Spender 1
//	IF gMachine.Status.Diam.Spend1 > gMachRecipe.spender1.WarnDiam  AND  (gApplRecipe.spender1.mode = 1) THEN
//		WarningBit_a[2] := 1;
//	END_IF;
	// Warnung 3 Gridwinder 1
	IF gMachine.Status.Diam.Grid1 > gMachRecipe.grid1.WarnDiam AND  (gApplRecipe.grid1.mode = OPM_WIND_WINDER) THEN
		WarningBit_a[3] := 1;
	END_IF;
	// Warnung 4 Spender 2
//	IF gMachine.Status.Diam.Spend2 > gMachRecipe.spender2.WarnDiam  AND  (gApplRecipe.spender2.mode = OPM_WIND_WINDER) THEN
//		WarningBit_a[4] := 1;
//	END_IF;
	// Warnung 5 Gridwinder 2
	IF gMachine.Status.Diam.Grid2 > gMachRecipe.grid2.StopDiam  AND  (gApplRecipe.grid2.mode = OPM_WIND_WINDER) THEN
		WarningBit_a[5] := 1;
	END_IF;
	
		// Warnung 6 Spender 3
//		IF gMachine.Status.Diam.Spend3 > gMachRecipe.spender3.WarnDiam  AND  (gApplRecipe.spender3.mode= OPM_WIND_WINDER) THEN
//			WarningBit_a[6] := 1;
//		END_IF;
	
		// Warnung 7 Top Winder 2  
//			IF gMachine.Status.Diam.TUnwindTop	 > gMachRecipe.topTandemWind.WarnDiam AND ((gApplRecipe.endModule.mode =OPM_END_MODULE_TANDEM_WINDER) OR (gApplRecipe.endModule.mode =OPM_END_MODULE_TOP_WINDER))  THEN
//			WarningBit_a[7] := 1;
//		END_IF;
//	
		// Warnung 8 Button Winder 2
//		IF gMachine.Status.Diam.TUnwindBot	 > gMachRecipe.botTandemWind.WarnDiam AND  ((gApplRecipe.endModule.mode = OPM_END_MODULE_TANDEM_WINDER) OR (gApplRecipe.endModule.mode = OPM_END_MODULE_BOT_WINDER)) THEN
//			WarningBit_a[8] := 1;
//		END_IF;
	
		
		// Warnung 9
		IF FALSE THEN
			WarningBit_a[9] := 1;
		END_IF;
		
END_PROGRAM
