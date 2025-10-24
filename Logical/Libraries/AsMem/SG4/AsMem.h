/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _ASMEM_
#define _ASMEM_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#include <runtime.h>

#ifndef _IEC_CONST
#define _IEC_CONST _WEAK const
#endif

/* Constants */
#ifdef _REPLACE_CONST
 #define asmemERR_DESTROY 30501U
 #define asmemERR_CREATE 30500U
 #define asmemERR_NOMEM 30502U
 #define asmemERR_INFO 30504U
 #define asmemERR_FREE 30503U
#else
 _IEC_CONST unsigned short asmemERR_DESTROY = 30501U;
 _IEC_CONST unsigned short asmemERR_CREATE = 30500U;
 _IEC_CONST unsigned short asmemERR_NOMEM = 30502U;
 _IEC_CONST unsigned short asmemERR_INFO = 30504U;
 _IEC_CONST unsigned short asmemERR_FREE = 30503U;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct AsMemPartCreate
{
	/* VAR_INPUT (analog) */
	unsigned long len;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned long ident;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartCreate_typ;

typedef struct AsMemPartDestroy
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartDestroy_typ;

typedef struct AsMemPartAlloc
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long len;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned long mem;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartAlloc_typ;

typedef struct AsMemPartAllocClear
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long len;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned long mem;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartAllocClear_typ;

typedef struct AsMemPartRealloc
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long memOld;
	unsigned long len;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned long mem;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartRealloc_typ;

typedef struct AsMemPartFree
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long mem;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartFree_typ;

typedef struct AsMemPartInfo
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned long numBytesFree;
	unsigned long maxBlockSizeFree;
	/* VAR_INPUT (digital) */
	plcbit enable;
} AsMemPartInfo_typ;



/* Prototyping of functions and function blocks */
void AsMemPartCreate(struct AsMemPartCreate* inst);
void AsMemPartDestroy(struct AsMemPartDestroy* inst);
void AsMemPartAlloc(struct AsMemPartAlloc* inst);
void AsMemPartAllocClear(struct AsMemPartAllocClear* inst);
void AsMemPartRealloc(struct AsMemPartRealloc* inst);
void AsMemPartFree(struct AsMemPartFree* inst);
void AsMemPartInfo(struct AsMemPartInfo* inst);


#ifdef __cplusplus
};
#endif
#endif /* _ASMEM_ */

                                                           
