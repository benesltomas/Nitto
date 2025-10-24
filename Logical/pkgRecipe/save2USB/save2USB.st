(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: USB_Test
 * File: USB_Test.st
 * Author: beutert
 * Created: February 10, 2012
 ********************************************************************
 * Implementation of program USB_Test
 ********************************************************************)

PROGRAM _INIT


LayerMessageBoxErrorUSB := INVISIBLE;
LayerMessageBoxCopyOkUSB := INVISIBLE;
strcpy(ADR(szRecipeDirName), ADR('Recipes'));
strcpy(ADR(szToolDirName), ADR('Tools'));

strcpy(ADR(szDirName), ADR(szRecipeDirName));

END_PROGRAM


PROGRAM _CYCLIC

IF (BackupRecipes2USB = TRUE) THEN
	BackupRecipes2USB := FALSE;
	strcpy(ADR(szDirName), ADR(szRecipeDirName));
	StartBackup2USB := TRUE;
END_IF;
IF (BackupTools2USB = TRUE) THEN
	BackupTools2USB := FALSE;
	strcpy(ADR(szDirName), ADR(szToolDirName));
	StartBackup2USB := TRUE;
END_IF;


CASE bStep OF
	ST_WAIT:
		IF (StartBackup2USB = TRUE) THEN
			bStep := CREATE_NODE_ID_LIST;
		END_IF;
		
	CREATE_NODE_ID_LIST:
		bStepOld := bStep;
		UsbNodeListGet_0.enable 									:= 1;
		UsbNodeListGet_0.pBuffer 									:= ADR(lNodeIdBuffer);
		UsbNodeListGet_0.bufferSize 							:= SIZEOF(lNodeIdBuffer);
		UsbNodeListGet_0.filterInterfaceClass 		:= asusb_CLASS_MASS_STORAGE;  (*set filter on mass storage devices*)
		UsbNodeListGet_0.filterInterfaceSubClass 	:= 0;	(*no filter is set *)
		UsbNodeListGet_0();
		
		wStatus := UsbNodeListGet_0.status;
		IF (wStatus = 0) THEN
    	bStep := READ_DEVICE_DATA;  
		ELSIF UsbNodeListGet_0.status = ERR_FUB_BUSY THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;
		
	READ_DEVICE_DATA:
		bStepOld := bStep;
		UsbNodeGet_0.enable 		:= 1;
		UsbNodeGet_0.nodeId 		:= lNodeIdBuffer[bNode];  				(*specific node is read out of node_id_buffer*)
		UsbNodeGet_0.pBuffer 		:= ADR(UsbDataBuffer[bNode]);  		(*data of specific node get stored in usb_data_buffer*)
		UsbNodeGet_0.bufferSize := SIZEOF(UsbDataBuffer[bNode]);  (*size of specific node is read out usb_data_buffer*)
		UsbNodeGet_0();
		
		wStatus := UsbNodeGet_0.status;
			
		IF (wStatus = 0) THEN
			bNode := bNode + 1;  (*next node to be read out of buffer*)
			IF (bNode = UsbNodeListGet_0.listNodes) THEN  (*last existing node is reached*)
				bNode := 0;
				bStep := GET_DESCRIPTOR;  (*all nodes are read out of buffer*)
			END_IF;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;
			
	GET_DESCRIPTOR:
		bStepOld := bStep;
		UsbDescriptorGet_0.enable 				:= 1;
		UsbDescriptorGet_0.nodeId 				:= lNodeIdBuffer[bNode];  (*specific node is read out of node_id_buffer*) 
		UsbDescriptorGet_0.requestType 		:= 0;  (*Request for device*)
    UsbDescriptorGet_0.descriptorType := 1;  (*Determines the device descriptor*)
		UsbDescriptorGet_0.languageId 		:= 0;  (*for device and configuration descriptors*)
		UsbDescriptorGet_0.pBuffer 				:= ADR(DeviceDescriptor[bNode]);  (*descriptor-data of specific node get stored in device_descriptor-buffer*) 
		UsbDescriptorGet_0.bufferSize 		:= SIZEOF(DeviceDescriptor[bNode]);  (*size of specific node is read out device_descriptor-buffer*)
		UsbDescriptorGet_0();
		
		wStatus := UsbDescriptorGet_0.status;
	
		IF (wStatus = 0) THEN 
			bNode := bNode + 1;  (*next node to be read out of buffer*)
			IF (bNode = UsbNodeListGet_0.listNodes) THEN  (*last existing node is reached*)
				bNode := 0;
				bStep := CREATE_FILE_DEVICE;  (*all nodes are read out of buffer*)
			END_IF;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;

	CREATE_FILE_DEVICE:
		bStepOld := bStep;
		strcpy(ADR(szDeviceName), ADR('USBSTICK'));  (*fixed Device-Name get copied to device_name-Variable*)															
		
		strcpy(ADR(szDeviceParam), ADR('/DEVICE='));  (*first part of parameter get copied to device_param-Variable*)		
		strcat(ADR(szDeviceParam), ADR(UsbDataBuffer[0].ifName));  (*second part get added to device_param-Variable*) 																												
	
		DevLink_0.enable  := 1;
		DevLink_0.pDevice := ADR(szDeviceName);  (*Devicename is assigned*)
		DevLink_0.pParam  := ADR(szDeviceParam);  (*the path of the Device is assigned*)
		DevLink_0();
		
		wStatus := DevLink_0.status;
	
		IF (wStatus = 0) THEN
			xDevLinkDone := TRUE;
			bStep := DIRECTORY_INFO;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;

	DIRECTORY_INFO:
		bStepOld := bStep;
		DirInfo_0.enable 	:= 1;
		DirInfo_0.pDevice := ADR(szDeviceName);
		DirInfo_0.pPath 	:= ADR(szDirName);	// ADR('Recipes');
		DirInfo_0();
		
		wStatus := DirInfo_0.status;

		IF (wStatus = 0) THEN
			bStep := DIRECTORY_COPY;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSIF  (wStatus = fiERR_DIR_NOT_EXIST) THEN
			bStep := DIRECTORY_CREATE;
		ELSE
			bStep := ERROR_STEP;
		END_IF;
		
	DIRECTORY_CREATE:
		bStepOld := bStep;
		DirCreate_0.enable 	:= 1;
		DirCreate_0.pDevice := ADR(szDeviceName);
		DirCreate_0.pName 	:= ADR(szDirName);	//ADR('Recipes');
		DirCreate_0();
		
		wStatus := DirCreate_0.status;
		
		IF (wStatus = 0) THEN
			bStep := DIRECTORY_COPY;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;
		
	DIRECTORY_COPY:
		DirCopy_0.enable 		:= 1;
		DirCopy_0.pSrcDev 	:= ADR('USERPART');
		DirCopy_0.pSrcDir 	:= ADR(szDirName);	//ADR('Recipes');;
		DirCopy_0.pDestDev 	:= ADR(szDeviceName);
		DirCopy_0.pDestDir 	:= ADR(szDirName);	//ADR('Recipes');
		DirCopy_0.option 		:= fiOVERWRITE;
		DirCopy_0();
		
		wStatus := DirCopy_0.status;

		IF (wStatus = 0) THEN
			bStep := UNLINK_DEVICE;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;
		
	UNLINK_DEVICE:
		bStepOld := bStep;
		DevUnlink_0.enable := 1;
		DevUnlink_0.handle := DevLink_0.handle;  (*handle from DevLink is assigned to cut the connection to specific file-device*)
		DevUnlink_0();
		
		wStatus := DevUnlink_0.status;

		IF (wStatus = 0) THEN
			xDevLinkDone := FALSE;
			bStep := FINISH;
		ELSIF (wStatus = ERR_FUB_BUSY) THEN
			(* call FUB again *)
		ELSE
			bStep := ERROR_STEP;
		END_IF;
		
	FINISH:  (*successfully finished*)
		bStepOld := bStep;
		StartBackup2USB := FALSE;
		LayerMessageBoxCopyOkUSB := VISIBLE;
		bStep := ST_WAIT;  (*back to beginning - wait for start_reading_usb_data to be set*)

	ERROR_STEP:	(*tbd: error-handling*)												
		StartBackup2USB := FALSE;
		IF (xDevLinkDone = TRUE) THEN
			bStep := UNLINK_DEVICE;
		ELSE
			LayerMessageBoxErrorUSB := VISIBLE;
			bStep := ST_WAIT;  (*back to beginning - wait for start_reading_usb_data to be set*)
		END_IF;

END_CASE;



END_PROGRAM
