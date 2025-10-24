(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SwitchConf
 * File: SwitchConfiguration.st
 * Author: hagera
 * Created: March 01, 2010
 ********************************************************************
 * Implementation of library SwitchConf
 * 
 * History:
 * 2012-07-25 /schoenefeldr/
 * 		Change IPL-mode of ACP10PAR_MAx_CYCLIC_POS only if it is used
 * 
 * 
 * 
 * 
 ********************************************************************) 

(* FUB to configure end-switches and ref-switch for ACOPOSmulti *)
FUNCTION_BLOCK SwitchConfiguration

CASE Step OF
	WAIT:
		IF (EDGEPOS(Execute) = 1) THEN
			Done := 0;
			Busy := 1;
			Error := 0;
			ErrorID := 0;
			Step := CHECK_INPUT_DATA;
		END_IF
			
	CHECK_INPUT_DATA :
		IF (Axis = 0) THEN
			Busy := 0;
			Error := 1;
			ErrorID := INVALID_AXIS_REFERENCE;
			Step := WAIT;
		ELSIF (posEndSwitchDeviceName = 0 AND negEndSwitchDeviceName = 0 AND refSwitchDeviceName = 0) OR
			(posEndSwitchDeviceName = 0 AND posEndSwitchChannelName <> 0) OR
   			(negEndSwitchDeviceName = 0 AND negEndSwitchChannelName <> 0) OR
   			(refSwitchDeviceName = 0 AND refSwitchChannelName <> 0)	THEN
			Busy := 0;
			Error := 1;
			ErrorID := INVALID_DEVICE_NAME;
			Step := WAIT;
		ELSIF (posEndSwitchDeviceName <> 0 AND posEndSwitchChannelName = 0) OR
			(negEndSwitchDeviceName <> 0 AND negEndSwitchChannelName = 0) OR
			(refSwitchDeviceName <> 0 AND refSwitchChannelName = 0) THEN
   			Busy := 0;
			Error := 1;
			ErrorID := INVALID_CHANNEL_NAME;
			Step := WAIT;
		ELSE				
			Step := GET_OFFSET_POS_END_SWITCH;
		END_IF
		
	GET_OFFSET_POS_END_SWITCH :
		IF (posEndSwitchDeviceName = 0) THEN
			Step := GET_OFFSET_NEG_END_SWITCH;
		ELSE
			Switches.posEndSwitch.ioInformation.DeviceName := posEndSwitchDeviceName;
			Switches.posEndSwitch.ioInformation.ChannelName := posEndSwitchChannelName;
			
			Switches.posEndSwitch.Status := plAction(0, plACTION_GET_CROSSLINK_INFO, ADR(Switches.posEndSwitch.ioInformation), SIZEOF(Switches.posEndSwitch.ioInformation));
		
			IF (Switches.posEndSwitch.Status = 0) THEN
				Switches.posEndSwitch.Offset := (Switches.posEndSwitch.ioInformation.Offset / 32) * 32;
				Switches.posEndSwitch.shiftBits := Switches.posEndSwitch.ioInformation.Offset MOD 32;
				Step := GET_OFFSET_NEG_END_SWITCH;
			ELSE
				Busy := 0;
				Error := 1;
				ErrorID := ERROR_GET_OFFSET_FOR_SWITCH;
				Step := WAIT;
   			END_IF
		END_IF
		
	GET_OFFSET_NEG_END_SWITCH :
		IF (negEndSwitchDeviceName = 0) THEN
			Step := GET_OFFSET_REF_SWITCH;
		ELSE
			Switches.negEndSwitch.ioInformation.DeviceName := negEndSwitchDeviceName;
			Switches.negEndSwitch.ioInformation.ChannelName := negEndSwitchChannelName;
		
			Switches.negEndSwitch.Status := plAction(0, plACTION_GET_CROSSLINK_INFO, ADR(Switches.negEndSwitch.ioInformation), SIZEOF(Switches.negEndSwitch.ioInformation));
		
			IF (Switches.negEndSwitch.Status = 0) THEN
				Switches.negEndSwitch.Offset := (Switches.negEndSwitch.ioInformation.Offset / 32) * 32;
				Switches.negEndSwitch.shiftBits := Switches.negEndSwitch.ioInformation.Offset MOD 32;
				Step := GET_OFFSET_REF_SWITCH;
			ELSE
				Busy := 0;
				Error := 1;
				ErrorID := ERROR_GET_OFFSET_FOR_SWITCH;
				Step := WAIT;
   			END_IF
		END_IF
		
	GET_OFFSET_REF_SWITCH  :
		IF (refSwitchDeviceName = 0) THEN
			Step := DEFINE_PARAMETER_LIST;
		ELSE
			Switches.refSwitch.ioInformation.DeviceName := refSwitchDeviceName;
			Switches.refSwitch.ioInformation.ChannelName := refSwitchChannelName;
		
			Switches.refSwitch.Status := plAction(0, plACTION_GET_CROSSLINK_INFO, ADR(Switches.refSwitch.ioInformation), SIZEOF(Switches.refSwitch.ioInformation));
		
			IF (Switches.refSwitch.Status = 0) THEN
				Switches.refSwitch.Offset := (Switches.refSwitch.ioInformation.Offset / 32) * 32;
				Switches.refSwitch.shiftBits := Switches.refSwitch.ioInformation.Offset MOD 32;
				Step := DEFINE_PARAMETER_LIST;
			ELSE
				Busy := 0;
				Error := 1;
				ErrorID := ERROR_GET_OFFSET_FOR_SWITCH;
				Step := WAIT;
   			END_IF
		END_IF
		
	DEFINE_PARAMETER_LIST :
		Parameter.List[0].par_id := ACP10PAR_FUNCTION_BLOCK_CREATE;
		Parameter.ui2 := ACP10PAR_BIT_MODE;
		memcpy(ADR(Parameter.List[0].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_A1;
		Parameter.ui4 := 1;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_A2;
		Parameter.ui4 := 1;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_A3;
		Parameter.ui4 := 1;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_IN1_PARID;
		Parameter.ui2 := ACP10PAR_MA1_CYCLIC_POS;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
		Parameter.Counter := Parameter.Counter + 1;

		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_IN2_PARID;
		Parameter.ui2 := ACP10PAR_MA2_CYCLIC_POS;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_IN3_PARID;
		Parameter.ui2 := ACP10PAR_MA3_CYCLIC_POS;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
		Parameter.Counter := Parameter.Counter + 1;
		
		Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_MODE;
		Parameter.ui2 := 10;
		memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
		Parameter.Counter := Parameter.Counter + 1;
		
		IF (posEndSwitchDeviceName <> 0) THEN			
			// 2012-07-25 /schoenefeldr/
			// Moved here into configuration dependent section
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_MA1_CYCLIC_IPL_MODE;
			Parameter.List[Parameter.Counter].data_byte[0] := 0;
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
			Parameter.ui2 := Switches.posEndSwitch.Offset;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_TYPE;
			Parameter.ui2 := 7;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.configMaCyclicPos[0] := Switches.posEndSwitch.ioInformation.NodeId;
			Parameter.configMaCyclicPos[1] := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CONFIG_MA1_CYCLIC_POS;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.configMaCyclicPos), SIZEOF(Parameter.configMaCyclicPos));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_B1+0;
			Parameter.ui4 := Switches.posEndSwitch.shiftBits;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));			
			Parameter.Counter := Parameter.Counter + 1;
			
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_POS_LIMIT_SWITCH_PARID;
			Parameter.ui2 := ACP10PAR_BIT_VALUE1;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		END_IF
		
		IF (negEndSwitchDeviceName <> 0) THEN			
			// 2012-07-25 /schoenefeldr/
			// Moved here into configuration dependent section
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_MA2_CYCLIC_IPL_MODE;
			Parameter.List[Parameter.Counter].data_byte[0] := 0;
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
			Parameter.ui2 := Switches.negEndSwitch.Offset;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_TYPE;
			Parameter.ui2 := 7;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.configMaCyclicPos[0] := Switches.negEndSwitch.ioInformation.NodeId;
			Parameter.configMaCyclicPos[1] := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CONFIG_MA2_CYCLIC_POS;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.configMaCyclicPos), SIZEOF(Parameter.configMaCyclicPos));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_B2+0;
			Parameter.ui4 := Switches.negEndSwitch.shiftBits;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));			
			Parameter.Counter := Parameter.Counter + 1;
			
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_NEG_LIMIT_SWITCH_PARID;
			Parameter.ui2 := ACP10PAR_BIT_VALUE2;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		END_IF
		
		IF (refSwitchDeviceName <> 0) THEN			
			// 2012-07-25 /schoenefeldr/
			// Moved here into configuration dependent section
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_MA3_CYCLIC_IPL_MODE;
			Parameter.List[Parameter.Counter].data_byte[0] := 0;
			Parameter.Counter := Parameter.Counter + 1;
					
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
			Parameter.ui2 := Switches.refSwitch.Offset;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CYCLIC_DP_DATA_TYPE;
			Parameter.ui2 := 7;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.configMaCyclicPos[0] := Switches.refSwitch.ioInformation.NodeId;
			Parameter.configMaCyclicPos[1] := ACP10PAR_CYCLIC_DP_DATA_OFFSET;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_CONFIG_MA3_CYCLIC_POS;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.configMaCyclicPos), SIZEOF(Parameter.configMaCyclicPos));			
			Parameter.Counter := Parameter.Counter + 1;
		
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_BIT_B3+0;
			Parameter.ui4 := Switches.refSwitch.shiftBits;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui4), SIZEOF(Parameter.ui4));			
			Parameter.Counter := Parameter.Counter + 1;
			
			Parameter.List[Parameter.Counter].par_id := ACP10PAR_REFERENCE_SWITCH_PARID;
			Parameter.ui2 := ACP10PAR_BIT_VALUE3;
			memcpy(ADR(Parameter.List[Parameter.Counter].data_byte[0]), ADR(Parameter.ui2), SIZEOF(Parameter.ui2));			
			Parameter.Counter := Parameter.Counter + 1;
		END_IF
		
		Step := WRITE_PARAMETER_LIST;
		
	WRITE_PARAMETER_LIST :
		Parameter.listInfo.parameter.data_adr := ADR(Parameter.List);
		Parameter.listInfo.parameter.format := ncFORMAT_B06;
		Parameter.listInfo.parameter.data_len := Parameter.Counter * SIZEOF(ACP10PRB06_typ);
		Parameter.Execute := 1;
						
		IF (MC_BR_InitParList_Switch.Done = 1) THEN
			Parameter.Execute := 0;
			Busy := 0;
			Done := 1;
			Step := WAIT;
		ELSIF (MC_BR_InitParList_Switch.Error = 1) THEN
			Parameter.Execute := 0;
			Busy := 0;
			ErrorInitparalist := MC_BR_InitParList_Switch.ErrorID; 
			Error := 1;
			ErrorID := ERROR_WRITE_PARAMETER_LIST;
			Step := WAIT;
		END_IF		
		
		MC_BR_InitParList_Switch(Axis := Axis, Execute := Parameter.Execute, DataAddress := ADR(Parameter.listInfo));
		
END_CASE

END_FUNCTION_BLOCK
