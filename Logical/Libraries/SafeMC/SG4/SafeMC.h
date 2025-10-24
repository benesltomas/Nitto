
#ifndef _SAFEMC_
#define _SAFEMC_

#include <bur/plctypes.h>

#ifdef __cplusplus
extern "C"
{
#endif

#include <acp10man.h>

/* Datatypes and datatypes of function blocks */
typedef struct SafeMC_ReadSafeInData
{
    /* VAR_INPUT (analog) */
    unsigned long Axis;
    /* VAR_OUTPUT (analog) */
    unsigned short ErrorID;
    struct ACP10SAFEINDAT_typ SafeInData;
    /* VAR_INPUT (digital) */
    plcbit Enable;
    /* VAR_OUTPUT (digital) */
    plcbit Valid;
    plcbit Busy;
    plcbit Error;
} SafeMC_ReadSafeInData_typ;

typedef struct SafeMC_ReadSafeOutData
{
    /* VAR_INPUT (analog) */
    unsigned long Axis;
    /* VAR_OUTPUT (analog) */
    unsigned short ErrorID;
    struct ACP10SAFEOUTDAT_typ SafeOutData;
    /* VAR_INPUT (digital) */
    plcbit Enable;
    /* VAR_OUTPUT (digital) */
    plcbit Valid;
    plcbit Busy;
    plcbit Error;
} SafeMC_ReadSafeOutData_typ;

/* Prototyping of functions and function blocks */
void SafeMC_ReadSafeInData(struct SafeMC_ReadSafeInData* inst);
void SafeMC_ReadSafeOutData(struct SafeMC_ReadSafeOutData* inst);
UINT SafeMC_action(UDINT nc_object,UDINT action,void *par_ptr,UDINT par_size);

#ifdef __cplusplus
};
#endif

#endif /* _SAFEMC_ */

