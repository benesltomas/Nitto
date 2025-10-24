(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuTasks
 * File: VisuTasksCyclic.st
 * Author: schoenefeldr
 * Created: August 01, 2012
 *
 *
 * History:
 * 
 * 
 *
 ********************************************************************
 * Implementation of program VisuTasks
 ********************************************************************)

PROGRAM _CYCLIC


CASE calibrateDiam OF
	CALIB_MAIN_UNWIND:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsMainUnw), ADR(gMachine.IO.AIn.DiamMainUnwind) );

	CALIB_GRID1:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsGrid1), ADR(gMachine.IO.AIn.DiamGrid1) );

	CALIB_GRID2:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsGrid2), ADR(gMachine.IO.AIn.DiamGrid2) );

	CALIB_SPEND1:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend1), ADR(gMachine.IO.AIn.DiamSpend1) );

	CALIB_SPEND2:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend2), ADR(gMachine.IO.AIn.DiamSpend2) );

	CALIB_SPEND3:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend3), ADR(gMachine.IO.AIn.DiamLaminator1) );
		
	CALIB_SPEND4:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend4), ADR(gMachine.IO.AIn.DiamLaminator2) );

	CALIB_TOP_TWIND:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsTopTWind), ADR(gMachine.IO.AIn.DiamTUnwindTop) );

	CALIB_BOT_TWIND:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsBotTWind), ADR(gMachine.IO.AIn.DiamTUnwindBot) );

	CALIB_ALL:
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsMainUnw), ADR(gMachine.IO.AIn.DiamMainUnwind) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsGrid1), ADR(gMachine.IO.AIn.DiamGrid1) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsGrid2), ADR(gMachine.IO.AIn.DiamGrid2) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend1), ADR(gMachine.IO.AIn.DiamSpend1) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend2), ADR(gMachine.IO.AIn.DiamSpend2) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend3), ADR(gMachine.IO.AIn.DiamLaminator1) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsSpend4), ADR(gMachine.IO.AIn.DiamLaminator2) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsTopTWind), ADR(gMachine.IO.AIn.DiamTUnwindTop) );
		calibrateDiam := CalibrDiam(ADR(gMachRecipe.Winders), ADR(gMachRecipe.Winders.DiamOffsBotTWind), ADR(gMachine.IO.AIn.DiamTUnwindBot) );

	ELSE
		IF NOT ( (calibrateDiam = CALIB_OK) OR (calibrateDiam = CALIB_UNDEFINED) ) THEN
			calibrateDiam := CALIB_ERROR;
		END_IF
END_CASE

END_PROGRAM
