(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: VisuRange
 * File: VisuRange.st
 * Author: schoenefeldr
 * Created: July 16, 2012
 ********************************************************************
 * Implementation of program VisuRange
 *
 * History:
 * 2012-07-16 /schoenefeldr/
 *		Task created
 * 2012-10-12 /schoenefeldr/
 *		Support of movement over distance or number of packages
 ********************************************************************)

PROGRAM _INIT


	ReleaseSafeOut 		:= FALSE;
	LogicOutOn			:= FALSE;
	LogicDrivesPowerOn	:= FALSE;
	jogFwd				:= FALSE;
	jogBack				:= FALSE;
	ResetError			:= FALSE;
	StatusLED			:= 0;
	driveSelect			:= 255;
	jogOverride			:= 80.0;

	// 2012-11-01 /schoenefeldr/
	// Default settings: axis are coupled
	But_cut1_koppeln 	:= TRUE;
	But_cut2_koppeln 	:= TRUE;
	But_cut1_entkoppeln := FALSE;
	But_cut2_entkoppeln := FALSE;
	
END_PROGRAM


PROGRAM _CYCLIC


	// Release Outputs on SafeDOUT modules
	IF ReleaseSafeOut THEN
		gVisu.RelSafeOut	:= TRUE;
	ELSE
		gVisu.RelSafeOut	:= FALSE;
	END_IF;	
	
	// Directly set the operating mode
	gMachine.Command.OpModeSet		:= OpModeSet;
	OpModeAct						:= gMachine.Status.OpModeAct;


	// =============================
	// Handling registration marks
	// =============================

	// First copy pointers. They point onto the next entry to be written to. So the value of
	// the variable has to be increased as the array is filled bottom-up.
	RmArrayPtr1		:= RegMarkControl[AXIS_RM_CUTTING_UNIT1].Data.actRmArrIndex;
	IF (RmArrayPtr1 >= MAX_RM_DATA_ARRAY_INDEX) THEN
		RmArrayPtr1		:= 0;
	ELSE
		RmArrayPtr1		:= RmArrayPtr1 + 1;
	END_IF
	RmArrayPtr2		:= RegMarkControl[AXIS_RM_CUTTING_UNIT2].Data.actRmArrIndex;
	IF (RmArrayPtr2 >= MAX_RM_DATA_ARRAY_INDEX) THEN
		RmArrayPtr2		:= 0;
	ELSE
		RmArrayPtr2		:= RmArrayPtr2 + 1;
	END_IF
	
	// Copy arrays (unsorted) into temporary array
	memcpy(ADR(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT1]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT1]), SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT1]));
	memcpy(ADR(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT2]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT2]), SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT2]));
	// Sort array, current entry into the first element
	// size = size of array - current index
	// Example:
	// size of array = 20
	// current index = 18    => first copy entries at indices 18 and 19
	//   First copy step:    =>   size = 20 - 18 = 2
	//   Second copy step:   =>   size = 20 - size = 20 - 2 = 18
	sizeStep1 := SIZE_OF_RM_DATA_ARRAY - RmArrayPtr1;
	sizeStep2 := SIZE_OF_RM_DATA_ARRAY - sizeStep1;
	memcpy(ADR(VisuRegMarkArray[AXIS_RM_CUTTING_UNIT1].RegMark[0]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT1].RegMark[RmArrayPtr1]), (sizeStep1 * SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT1].RegMark[0])) );
	// Copy entries from the start of the source array behind the previous block beginning at the index "size step 1"
	memcpy(ADR(VisuRegMarkArray[AXIS_RM_CUTTING_UNIT1].RegMark[sizeStep1]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT1].RegMark[0]), (sizeStep2 * SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT1].RegMark[0])) );

	sizeStep1 := SIZE_OF_RM_DATA_ARRAY - RmArrayPtr2;
	sizeStep2 := SIZE_OF_RM_DATA_ARRAY - sizeStep1;
	memcpy(ADR(VisuRegMarkArray[AXIS_RM_CUTTING_UNIT2].RegMark[0]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT2].RegMark[RmArrayPtr2]), (sizeStep1 * SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT2].RegMark[0])) );
	memcpy(ADR(VisuRegMarkArray[AXIS_RM_CUTTING_UNIT2].RegMark[sizeStep1]),ADR(RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT2].RegMark[0]), (sizeStep2 * SIZEOF(VisuTempRegMarkArray[AXIS_RM_CUTTING_UNIT2].RegMark[0])) );

	ActRegMarkPosError1				:= RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT1].RegMark[RmArrayPtr1].SetpointError;
	ActRegMarkPosError2				:= RegMarkIf.Status.ActData[AXIS_RM_CUTTING_UNIT2].RegMark[RmArrayPtr2].SetpointError;


	// ==========================
	// Handling analogue inputs
	// ==========================

	// Copy analogue input values
	DiamAct	:= gMachine.Status.Diam;

	// ==========================
	// Handling analogue outputs
	// ==========================
	IF gMachine.Status.OpModeAct = OPMODE_SERVICE THEN
		IF VentAbort THEN
			VentVoltSet.VentDancer					:= 0.0;
			VentVoltSet.VentClutchSpend1			:= 0.0;
			VentVoltSet.VentClutchSpend2			:= 0.0;
			VentVoltSet.VentClutchSpend3			:= 0.0;
			VentVoltSet.VentClutchGrid1				:= 0.0;
			VentVoltSet.VentClutchGrid2				:= 0.0;
			VentVoltSet.VentOptClutchTUnwindTop		:= 0.0;
			VentVoltSet.VentOptClutchTUnwindBot		:= 0.0;
		END_IF

		gMachine.IO.AOut.VentDancer.Value.Scaled				:= VentVoltSet.VentDancer;
		gMachine.IO.AOut.VentClutchSpend1.Value.Scaled			:= VentVoltSet.VentClutchSpend1;
		gMachine.IO.AOut.VentClutchSpend2.Value.Scaled			:= VentVoltSet.VentClutchSpend2;
		gMachine.IO.AOut.VentClutchSpend3.Value.Scaled			:= VentVoltSet.VentClutchSpend3;
		gMachine.IO.AOut.VentClutchGrid1.Value.Scaled			:= VentVoltSet.VentClutchGrid1;
		gMachine.IO.AOut.VentClutchGrid2.Value.Scaled			:= VentVoltSet.VentClutchGrid2;
		gMachine.IO.AOut.VentOptClutchTUnwindTop.Value.Scaled	:= VentVoltSet.VentOptClutchTUnwindTop;
		gMachine.IO.AOut.VentOptClutchTUnwindBot.Value.Scaled	:= VentVoltSet.VentOptClutchTUnwindBot;
	END_IF

	// ==========================
	// Handling texts
	// ==========================
	// 2012-12-19 /schoenefeldr/
	// Display message if cut unit is not referenced
	IF gMachine.Status.ReferencedOK THEN
		MessageReferenceControl := CTRL_INVISIBLE;
	ELSE
		MessageReferenceControl := CTRL_VISIBLE;
	END_IF
	// 2012-12-19 /schoenefeldr/
	// Display message if supports of enabled winders are not closed
	IF gMachine.Status.SupportSpikesOK THEN
		MessageSupportSpikesControl	:= CTRL_INVISIBLE;
	ELSE
		MessageSupportSpikesControl := CTRL_VISIBLE;
	END_IF
	
	// Display message for Batch Control
//	
//	IF (AxisIf.Status.BatchComplete) THEN
//		BatchStatus	:= BATCH_COMPLETE;
//		MessageBatchControl	:= CTRL_VISIBLE;
//	ELSIF (AxisIf.Status.BatchAlmostComplete) THEN
//		BatchStatus	:= BATCH_ALMOST_COMPLETE;
//		MessageBatchControl := CTRL_VISIBLE; 	
//	ELSE
//		MessageBatchControl := CTRL_INVISIBLE;
//	END_IF
//	
//	// Handling Drives
//	// ========================
//	IF AxisIf.Status.error THEN
//		StatusLED	:= 3;
//	ELSIF AxisIf.Status.drivesReady THEN
//		StatusLED	:= 1;
//	ELSIF AxisIf.Status.initDone THEN
//		StatusLED	:= 2;
//	ELSE
//		StatusLED	:= 0;
//	END_IF
//
//	IF AxisIf.Status.drivesEnabled THEN
//		DriveEnableLED	:= 1;
//	ELSE
//		DriveEnableLED	:= 0;
//	END_IF
//	
//	masterActVelo				:= AxisIf.Status.ActMasterVelocity;
//	masterActPos				:= AxisIf.Status.ActPosition;
//	gVisu.Status.ActVelocity	:= masterActVelo;
//	gVisu.Status.ActPosition	:= masterActPos;
//
//	newMasterActPos := AxisIf.Status.ActPosition -	offsetMasterActPos;	
//	masterActPos := masterActPos + (newMasterActPos -oldMasterActPos);
//	oldMasterActPos := newMasterActPos;
//	
	
	
	gVisu.Cmd.resetError	:= ResetError;

	// Start referencing
	IF DoReference THEN
		gVisu.Cmd.DoReference	:= TRUE;
	ELSE
		gVisu.Cmd.DoReference	:= FALSE;
	END_IF;	

//	IF (CmdAutoSpeed_pos) THEN
//		AxisIf.Command.incMasterVeloCmd := TRUE;
//		CmdAutoSpeed_pos := 0;
//	END_IF;		
//	IF (CmdAutoSpeed_neg) THEN
//		AxisIf.Command.decMasterVeloCmd := TRUE;
//		CmdAutoSpeed_neg :=0;
//	END_IF;
//	
	UmfangCut1 	:= gApplRecipe.cutUnit1.tool.cogCutting * MACHINE_LENGTH_PER_TOOTH / 1000.0;
	UmfangCut2 	:= gApplRecipe.cutUnit2.tool.cogCutting * MACHINE_LENGTH_PER_TOOTH / 1000.0;
	UmfangCut3	:= gApplRecipe.cutUnit3.tool.cogCutting * MACHINE_LENGTH_PER_TOOTH / 1000.0;	
	
	// Write commands

	// 2012-10-12 /schoenefeldr/
	// Added commands 
	// 2012-10-15 /schoenefeldr/
	// Start/stop command deactivated
//	gVisu.Cmd.StopGen						:= stopGen;
//	gVisu.Cmd.StartGen						:= startGen;
//	gVisu.Cmd.StartAddPos					:= startAdd;
//	IF startAdd THEN
//		gVisu.Cmd.masterPos						:= masterCmdPos;
//		gVisu.Cmd.numPkg						:= numPkg;
//	END_IF	

//	IF ResetInputs THEN
//		ResetInputs								:= FALSE;
		masterCmdPos							:= 0.0;
		numPkg									:= 0;
//		gVisu.Cmd.masterPos						:= masterCmdPos;
//		gVisu.Cmd.numPkg						:= numPkg;
	//	END_IF	
	
//	IF ResetInputs THEN
//		//		ResetInputs								:= FALSE;
//		masterActPos := 0.0;
//		newMasterActPos  := 0.0 ;
//		oldMasterActPos  := 0.0;
//		offsetMasterActPos				:= AxisIf.Status.ActPosition;
//		gMeterCounter  := 0;
//		gProductCounter  := 0;
//		masterCmdPos							:= 0.0;
//		numPkg									:= 0;
//		gVisu.Cmd.masterPos						:= masterCmdPos;
//		gVisu.Cmd.numPkg						:= numPkg;
//	END_IF	
	
		//		ResetTotalMeterCounter
	IF ResetTotalMeter THEN
	
		gMeterCounterTotal	:= 0;
		
	END_IF
	
	
	
	
	
	gVisu.Cmd.masterPos						:= masterCmdPos;
	gVisu.Cmd.numPkg						:= numPkg;

	gVisu.Cmd.masterVelo	:= masterCmdVelo;

	
//	AxisIf.Para.axisNumber		:= driveSelect;
	gVisu.Cmd.jogOverride		:= jogOverride;


END_PROGRAM
