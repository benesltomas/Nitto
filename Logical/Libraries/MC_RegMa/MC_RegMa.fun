FUNCTION_BLOCK MC_BR_RegMarkCapture001
	VAR_INPUT
		Master : UDINT; (*axis reference for interval basis*)
		Axis : UDINT; (*axis reference to the axis on which registration mark detection is running*)
		Enable : BOOL; (*enable registration mark detection*)
		SearchTrigger : BOOL; (*start the search for a registration mark manually*)
		InitData : BOOL; (*initialize input data at rising edge (online update)*)
		TriggerInput : MC_BR_RMTRIGGER_REF; (*trigger input parameters*)
		ProductParameters : MC_BR_PRODUCT_REF; (*description of product and search parameters*)
		Mode : UINT; (*operation mode*)
		MasterParID : UINT; (*use this master ParID instead of the set position*)
	END_VAR
	VAR_OUTPUT
		Active : BOOL; (*registration mark detection is running*)
		Valid : BOOL; (*valid registration mark found (set for one cycle)*)
		Busy : BOOL; (*function block is not finished*)
		Error : BOOL; (*error occurred in FB*)
		ErrorID : UINT; (*error number*)
		DataInitialized : BOOL; (*input data is initialized*)
		SearchActive : BOOL; (*search for a registration mark is active*)
		SearchDone : BOOL; (*search for a registration mark is finished*)
		ValidTriggers : UDINT; (*number of valid registration marks*)
		MissedTriggers : UINT; (*number of missed triggers*)
		ActLength : REAL; (*currently measured length*)
		ActIntervalLength : REAL; (*currently measured length of the interval*)
		ActPosition : REAL; (*currently measured position of the registration mark*)
		LengthError : REAL; (*deviation between set length and measured length*)
		PositionError : REAL; (*deviation between expected position and measured position*)
		AverageProductLength : REAL; (*average value of the last 50 measured product lengths*)
	END_VAR
	VAR
		C_Master : UDINT; (*internal variable*)
		C_Axis : UDINT; (*internal variable*)
		IS : MC_0066_IS_TYP; (*internal variable*)
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK MC_BR_RegMarkCalc001
	VAR_INPUT
		Axis : UDINT; (*axis reference to the axis on which registration mark detection is running*)
		Enable : BOOL; (*enable registration mark calculation*)
		InitData : BOOL; (*initialize input data at rising edge (online update)*)
		Reset : BOOL; (*reset internal values: queues, filters, integrators*)
		Calculate : BOOL; (*calulate correction values at rising edge*)
		LengthError : REAL; (*measured length error (output of MC_BR_RegMarkCapture001)*)
		PositionError : REAL; (*measured position error (output of MC_BR_RegMarkCapture001)*)
		ControllerParameters : MC_RMCALC001_REF; (*parameters for registration mark control*)
	END_VAR
	VAR_OUTPUT
		Valid : BOOL; (*calculation of correction values finished (set for one cycle)*)
		Busy : BOOL; (*function block is not finished*)
		Error : BOOL; (*error occurred in FB*)
		ErrorID : UINT; (*error number*)
		DataInitialized : BOOL; (*input data is initialized*)
		ResetDone : BOOL; (*reset of internal data finished*)
		ValidCorrections : UDINT; (*number of calculated corrections*)
		Distance : REAL; (*calculated distance*)
		Shift : REAL; (*calculated shift*)
		DistanceLimiterActive : BOOL; (*distance limitation is active*)
		ShiftLimiterActive : BOOL; (*shift limitation is active*)
		AdditionalInfo : MC_ADDINFO001_REF; (*output of internally calculated and measured values*)
	END_VAR
	VAR
		C_Axis	:UDINT; (*internal variable*)
		IS	:MC_0091_IS_TYP; (*internal variable*)
	END_VAR
END_FUNCTION_BLOCK
