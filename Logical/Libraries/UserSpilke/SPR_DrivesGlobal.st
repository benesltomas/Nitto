(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: DrivesGlobal.st
 * Author: knausenbergl
 * Created: December 13, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Monitors the status of all drives </$Description$>*)
FUNCTION_BLOCK SPR_DrivesGlobal
	CASE State OF
		//IDLE, waiting for init command
		0:
			IF (Init AND (MaxNumberAxes <> 0) AND (pAxes <> 0) ) THEN
				AllocStatus	:= TMP_alloc( (SIZEOF(MC_BR_ReadDriveStatus_Dummy[0]) * MaxNumberAxes), ADR(StartAddress) );
				InitDone	:= (AllocStatus = 0);
				IF (InitDone) THEN
					memset(StartAddress, 0, (SIZEOF(MC_BR_ReadDriveStatus_Dummy[0]) * MaxNumberAxes) );
					C_MaxNumberAxes	:= MaxNumberAxes;
					State			:= 1;
				END_IF;
			END_IF;
		
		//INIT COMPLETE, waiting for enable command
		1:
			IF (Enable AND (pAxes <> 0) ) THEN				
				Valid	:= TRUE;
				Busy	:= FALSE;
				Error	:= FALSE;
				ErrorID	:= 0;
				
				DriveStatusAll.AxisError		:= TRUE;
				DriveStatusAll.ControllerReady	:= TRUE;
				DriveStatusAll.ControllerStatus	:= TRUE;
				DriveStatusAll.DriveEnable		:= TRUE;
				DriveStatusAll.HomeSwitch		:= TRUE;
				DriveStatusAll.HomingOk			:= TRUE;
				DriveStatusAll.LagWarning		:= TRUE;
				DriveStatusAll.NegHWSwitch		:= TRUE;
				DriveStatusAll.NetworkInit		:= TRUE;
				DriveStatusAll.PosHWSwitch		:= TRUE;
				DriveStatusAll.ResetDone		:= TRUE;
				DriveStatusAll.Simulation		:= TRUE;
				DriveStatusAll.Trigger1			:= TRUE;
				DriveStatusAll.Trigger2			:= TRUE;
				
				DriveStatusAny.AxisError		:= FALSE;
				DriveStatusAny.ControllerReady	:= FALSE;
				DriveStatusAny.ControllerStatus	:= FALSE;
				DriveStatusAny.DriveEnable		:= FALSE;
				DriveStatusAny.HomeSwitch		:= FALSE;
				DriveStatusAny.HomingOk			:= FALSE;
				DriveStatusAny.LagWarning		:= FALSE;
				DriveStatusAny.NegHWSwitch		:= FALSE;
				DriveStatusAny.NetworkInit		:= FALSE;
				DriveStatusAny.PosHWSwitch		:= FALSE;
				DriveStatusAny.ResetDone		:= FALSE;
				DriveStatusAny.Simulation		:= FALSE;
				DriveStatusAny.Trigger1			:= FALSE;
				DriveStatusAny.Trigger2			:= FALSE;
				
				FOR AxisIndex	:= 0 TO (C_MaxNumberAxes - 1) DO
					pAxis	ACCESS (pAxes + AxisIndex * SIZEOF(UDINT) );
					pMC_BR_ReadDriveStatus	ACCESS (StartAddress + AxisIndex * SIZEOF(MC_BR_ReadDriveStatus_Dummy[0]) );
					
					pMC_BR_ReadDriveStatus.AdrDriveStatus	:= ADR(TempDriveStatus);
					pMC_BR_ReadDriveStatus.Axis				:= pAxis;
					pMC_BR_ReadDriveStatus.Enable			:= (pAxis <> 0);
					pMC_BR_ReadDriveStatus();
					
					IF (pMC_BR_ReadDriveStatus.Enable) THEN
						Valid	:= Valid AND pMC_BR_ReadDriveStatus.Valid;
						Busy	:= Busy OR pMC_BR_ReadDriveStatus.Busy;
						Error	:= Error OR pMC_BR_ReadDriveStatus.Error;
						IF (pMC_BR_ReadDriveStatus.ErrorID <> ERR_OK) THEN
							ErrorID	:= pMC_BR_ReadDriveStatus.ErrorID;
						END_IF;
						
						DriveStatusAll.AxisError		:= DriveStatusAll.AxisError AND TempDriveStatus.AxisError;
						DriveStatusAll.ControllerReady	:= DriveStatusAll.ControllerReady AND TempDriveStatus.ControllerReady;
						DriveStatusAll.ControllerStatus	:= DriveStatusAll.ControllerStatus AND TempDriveStatus.ControllerStatus;
						DriveStatusAll.DriveEnable		:= DriveStatusAll.DriveEnable AND TempDriveStatus.DriveEnable;
						DriveStatusAll.HomeSwitch		:= DriveStatusAll.HomeSwitch AND TempDriveStatus.HomeSwitch;
						DriveStatusAll.HomingOk			:= DriveStatusAll.HomingOk AND TempDriveStatus.HomingOk;
						DriveStatusAll.LagWarning		:= DriveStatusAll.LagWarning AND TempDriveStatus.LagWarning;
						DriveStatusAll.NegHWSwitch		:= DriveStatusAll.NegHWSwitch AND TempDriveStatus.NegHWSwitch;
						DriveStatusAll.NetworkInit		:= DriveStatusAll.NetworkInit AND TempDriveStatus.NetworkInit;
						DriveStatusAll.PosHWSwitch		:= DriveStatusAll.PosHWSwitch AND TempDriveStatus.PosHWSwitch;
						DriveStatusAll.ResetDone		:= DriveStatusAll.ResetDone AND TempDriveStatus.ResetDone;
						DriveStatusAll.Simulation		:= DriveStatusAll.Simulation AND TempDriveStatus.Simulation;
						DriveStatusAll.Trigger1			:= DriveStatusAll.Trigger1 AND TempDriveStatus.Trigger1;
						DriveStatusAll.Trigger2			:= DriveStatusAll.Trigger2 AND TempDriveStatus.Trigger2;
						
						DriveStatusAny.AxisError		:= DriveStatusAny.AxisError OR TempDriveStatus.AxisError;
						DriveStatusAny.ControllerReady	:= DriveStatusAny.ControllerReady OR TempDriveStatus.ControllerReady;
						DriveStatusAny.ControllerStatus	:= DriveStatusAny.ControllerStatus OR TempDriveStatus.ControllerStatus;
						DriveStatusAny.DriveEnable		:= DriveStatusAny.DriveEnable OR TempDriveStatus.DriveEnable;
						DriveStatusAny.HomeSwitch		:= DriveStatusAny.HomeSwitch OR TempDriveStatus.HomeSwitch;
						DriveStatusAny.HomingOk			:= DriveStatusAny.HomingOk OR TempDriveStatus.HomingOk;
						DriveStatusAny.LagWarning		:= DriveStatusAny.LagWarning OR TempDriveStatus.LagWarning;
						DriveStatusAny.NegHWSwitch		:= DriveStatusAny.NegHWSwitch OR TempDriveStatus.NegHWSwitch;
						DriveStatusAny.NetworkInit		:= DriveStatusAny.NetworkInit OR TempDriveStatus.NetworkInit;
						DriveStatusAny.PosHWSwitch		:= DriveStatusAny.PosHWSwitch OR TempDriveStatus.PosHWSwitch;
						DriveStatusAny.ResetDone		:= DriveStatusAny.ResetDone OR TempDriveStatus.ResetDone;
						DriveStatusAny.Simulation		:= DriveStatusAny.Simulation OR TempDriveStatus.Simulation;
						DriveStatusAny.Trigger1			:= DriveStatusAny.Trigger1 OR TempDriveStatus.Trigger1;
						DriveStatusAny.Trigger2			:= DriveStatusAny.Trigger2 OR TempDriveStatus.Trigger2;
					END_IF;
				END_FOR;
			ELSE
				Valid	:= FALSE;
				Busy	:= FALSE;
				Error	:= FALSE;
				ErrorID	:= ERR_FUB_ENABLE_FALSE;
			
				memset(ADR(DriveStatusAll), 0, SIZEOF(DriveStatusAll) );
				memset(ADR(DriveStatusAny), 0, SIZEOF(DriveStatusAny) );
				
				FOR AxisIndex	:= 0 TO (C_MaxNumberAxes - 1) DO
					pMC_BR_ReadDriveStatus	ACCESS (StartAddress + AxisIndex * SIZEOF(MC_BR_ReadDriveStatus_Dummy[0]) );
			
					pMC_BR_ReadDriveStatus.AdrDriveStatus	:= ADR(TempDriveStatus);
					pMC_BR_ReadDriveStatus.Axis				:= 0;
					pMC_BR_ReadDriveStatus.Enable			:= FALSE;
					pMC_BR_ReadDriveStatus();
				END_FOR;	
			END_IF;
								
	END_CASE;	
	
END_FUNCTION_BLOCK