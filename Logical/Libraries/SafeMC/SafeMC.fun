(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SafeMC
 * File: SafeMC.fun
 ********************************************************************
 * Functions and function blocks of library SafeMC
 ********************************************************************)

FUNCTION SafeMC_action :UINT                (*Process a SafeMC Action*)
    VAR_INPUT
        nc_object      :UDINT;              (*NC object*)
        action         :UDINT;              (*action to be executed*)
        par_ptr        :UDINT;              (*address of the parameter data*)
        par_size       :UDINT;              (*size of the parameter data in bytes*)
    END_VAR
END_FUNCTION

FUNCTION_BLOCK SafeMC_ReadSafeInData        (*Read SafeIN data*)
    VAR_INPUT
        Axis           :UDINT;              (*axis reference*)
        Enable         :BOOL;               (*when set the data is read*)
    END_VAR
    VAR_OUTPUT
        Valid          :BOOL;               (*output of FB is valid*)
        Busy           :BOOL;               (*the function block is not finished*)
        Error          :BOOL;               (*error occurred in FB*)
        ErrorID        :UINT;               (*error number*)
        SafeInData     :ACP10SAFEINDAT_typ; (*SafeIN data*)
    END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SafeMC_ReadSafeOutData       (*Read SafeOUT data*)
    VAR_INPUT
        Axis           :UDINT;              (*axis reference*)
        Enable         :BOOL;               (*when set the data is read*)
    END_VAR
    VAR_OUTPUT
        Valid          :BOOL;               (*output of FB is valid*)
        Busy           :BOOL;               (*the function block is not finished*)
        Error          :BOOL;               (*error occurred in FB*)
        ErrorID        :UINT;               (*error number*)
        SafeOutData    :ACP10SAFEOUTDAT_typ;(*SafeOUT data*)
    END_VAR
END_FUNCTION_BLOCK
