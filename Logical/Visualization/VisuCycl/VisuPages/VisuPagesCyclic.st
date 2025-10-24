(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuPages
 * File: VisuPagesCyclic.st
 * Author: schoenefeldr
 * Created: July 18, 2012
 ********************************************************************
 * Implementation of program VisuPages
 ********************************************************************)

PROGRAM _CYCLIC

	// PAGE SELECTION
	// ===================
//	gVisu.Cmd.pageSel.reqPage := gVisu.Cmd.pageSel.selPage;
//
//	// If no page change is running any more then process the next change of a page
//	IF 	(gVisu.Cmd.pageSel.newPage = CHANGE_PAGE_COMPLETE) AND
//		(gVisu.Cmd.pageSel.reqPage <> gVisu.Cmd.pageSel.oldPage) THEN
//		// Hand over new page number to page changer
//		gVisu.Cmd.pageSel.newPage := gVisu.Cmd.pageSel.reqPage;
//		gVisu.Cmd.pageSel.oldPage := gVisu.Cmd.pageSel.reqPage;
//	END_IF

	
	
	IF gApplRecipe.endModule.mode>= 41 AND  gApplRecipe.endModule.mode   <=43 THEN
		Winder_activ  := 0;
	ELSE
		Winder_activ  := 1; //nicht sichtbar
	END_IF;
	
	IF gApplRecipe.endModule.mode = 44  THEN
		Conveyor_activ := 0; 
	ELSE
		Conveyor_activ := 1;   //nicht sichtbar
	END_IF;
		
//	IF 	gMachine.Command.JogGeneral.Value.InVal	THEN
//		MenueJogSpeed := 0;
//	ELSE
		MenueJogSpeed := 1;
//	END_IF;
	
	// Maschine fährt über 5 Meter/min. dann ist die Geschwindigkeit per Button zu in(de)crementieren	
//	IF 	(AxisHandle[AXIS_MASTER1].AxisState.ContinuousMotion OR AxisHandle[AXIS_MASTER1].AxisState.DiscreteMotion)THEN
//		MenueAutoSpeed  := 0;
//	ELSE
//		MenueAutoSpeed := 1;
//	END_IF;
		
	strcpy(ADR(Name_recipe), ADR(gApplRecipe.header.name) );
	
	// ***************************** Verzögerung der Taste Booklet on ************************
	
	BookletOnTimer.PT := T#15s;
	BookletOnTimer.IN := NOT gMachine.IO.DOut.BookletFeederON.Value.ActOut;
	BookletOnTimer();
	IF (BookletOnTimer.Q) THEN
		BookletOnLock := 1;
	ELSE
		BookletOnLock := 0;
	END_IF
	
	//***************************************************************************************
	
END_PROGRAM
