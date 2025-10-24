/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _ASWNDCON_
#define _ASWNDCON_

#include <bur/plctypes.h>

#ifdef _SG4
	#include "brsystem.h"
	#include "Sys_lib.h"
#endif

#ifdef _SG3
	#include "brsystem.h"
	#include "Sys_lib.h"
#endif

#ifdef _SGC
	#include "brsystem.h"
	#include "Sys_lib.h"
#endif

/* Constants */
#ifdef _REPLACE_CONST
 #define WNC_ERR_SYS_PARA_MIN_MAX_DIAM 34350U
 #define WNC_ERR_SYS_PARA_X_DIAM 34351U
 #define WNC_ERR_SYS_PARA_MIN_INERTIA 34352U
 #define WNC_ERR_SYS_PARA_X_INERTIA 34353U
 #define WNC_ERR_SYS_PARA_MAT_THICK 34354U
 #define WNC_ERR_SYS_PARA_WND_WIDTH 34355U
 #define WNC_ERR_SYS_PARA_KV_TRQ 34356U
 #define WNC_ERR_SYS_PARA_POS_TRQ 34357U
 #define WNC_ERR_SYS_PARA_NEG_TRQ 34358U
 #define WNC_ERR_SYS_PARA_LINE_UNITS 34359U
 #define WNC_ERR_SYS_PARA_WND_UNITS 34360U
 #define WNC_ERR_SYS_PARA_REV_MOT 34361U
 #define WNC_ERR_SYS_PARA_GEAR_RATIO 34362U
 #define WNC_ERR_AXIS_TYPE 34363U
 #define WNC_ERR_CYC_EST_WIND_ZERO 34364U
 #define WNC_ERR_CYC_EST_TRIG_ZERO 34365U
 #define WNC_ERR_ILLEGAL_TSYNC 34366U
 #define WNC_ERR_ILLEGAL_LIP_TN 34367U
 #define WNC_ERR_ILLEGAL_LIP_KV 34368U
 #define WNC_ERR_ILLEGAL_INERTIA 34369U
 #define WNC_ERR_ILLEGAL_DIAM 34370U
 #define WNC_ERR_ILLEGAL_SIMPARA 34371U
 #define WNC_ERR_ILLEGAL_SYNC_TIME 34372U
 #define WNC_ERR_ILLEGAL_TRQ_LIMIT 34373U
 #define WNC_ERR_ILLEGAL_LIP_NUM_POINTS 34374U
 #define WNC_ERR_ILLEGAL_LIP_DIAM_VAL 34375U
 #define WNC_ERR_ILLEGAL_ACT_INERTIA 34376U
 #define WNC_ERR_ILLEGAL_RISE_TIME 34377U
 #define WNC_ERR_ILLEGAL_OVERSHOOT 34378U
 #define WNC_ERR_ILLEGAL_VELPROP_FRICT 34379U
 #define WNC_ERR_ILLEGAL_TI_SPEED_FILTER 34380U
 #define WNC_ERR_ILLEGAL_D_PHI 34381U
 #define WNC_ERR_ILLEGAL_MAG_L2 34382U
 #define WNC_ERR_ILLEGAL_MOTPARA 34383U
 #define WNC_ERR_CYC_EST_PT2_T12_NEG 34384U
 #define WNC_ERR_SIM_MAT_BREAK 34385U
 #define WNC_WARN_PIDPARA_TF 34450U
 #define WNC_WARN_PID_Y_LIMITS 34451U
 #define WNC_WARN_PID_Y_MIN 34452U
 #define WNC_WARN_PID_Y_MAX 34453U
 #define WNC_WARN_PID_YI_MIN_MAX 34454U
 #define WNC_WARN_SIM_ACTIVE 34455U
 #define WNC_WARN_STOP_ACTIV 34456U
 #define WNC_ERR_DISABLED 65534U
#else
 #ifndef _GLOBAL_CONST
  #define _GLOBAL_CONST _WEAK const
 #endif
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_MIN_MAX_DIAM;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_X_DIAM;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_MIN_INERTIA;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_X_INERTIA;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_MAT_THICK;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_WND_WIDTH;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_KV_TRQ;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_POS_TRQ;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_NEG_TRQ;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_LINE_UNITS;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_WND_UNITS;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_REV_MOT;
 _GLOBAL_CONST unsigned short WNC_ERR_SYS_PARA_GEAR_RATIO;
 _GLOBAL_CONST unsigned short WNC_ERR_AXIS_TYPE;
 _GLOBAL_CONST unsigned short WNC_ERR_CYC_EST_WIND_ZERO;
 _GLOBAL_CONST unsigned short WNC_ERR_CYC_EST_TRIG_ZERO;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_TSYNC;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_LIP_TN;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_LIP_KV;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_INERTIA;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_DIAM;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_SIMPARA;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_SYNC_TIME;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_TRQ_LIMIT;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_LIP_NUM_POINTS;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_LIP_DIAM_VAL;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_ACT_INERTIA;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_RISE_TIME;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_OVERSHOOT;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_VELPROP_FRICT;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_TI_SPEED_FILTER;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_D_PHI;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_MAG_L2;
 _GLOBAL_CONST unsigned short WNC_ERR_ILLEGAL_MOTPARA;
 _GLOBAL_CONST unsigned short WNC_ERR_CYC_EST_PT2_T12_NEG;
 _GLOBAL_CONST unsigned short WNC_ERR_SIM_MAT_BREAK;
 _GLOBAL_CONST unsigned short WNC_WARN_PIDPARA_TF;
 _GLOBAL_CONST unsigned short WNC_WARN_PID_Y_LIMITS;
 _GLOBAL_CONST unsigned short WNC_WARN_PID_Y_MIN;
 _GLOBAL_CONST unsigned short WNC_WARN_PID_Y_MAX;
 _GLOBAL_CONST unsigned short WNC_WARN_PID_YI_MIN_MAX;
 _GLOBAL_CONST unsigned short WNC_WARN_SIM_ACTIVE;
 _GLOBAL_CONST unsigned short WNC_WARN_STOP_ACTIV;
 _GLOBAL_CONST unsigned short WNC_ERR_DISABLED;
#endif


/* Variables */


/* Datatypes and datatypes of function blocks */
typedef struct wnc_sysPara_typ
{	float wndWidth;
	float matThickness;
	float minDiam;
	float maxDiam;
	float xDiam;
	float minInertia;
	float xInertia;
	float kvTorque;
	float posTorque;
	float negTorque;
	float lineUnits;
	unsigned long wndUnits;
	unsigned long revMotor;
	float gearRatio;
	signed char axisType;
} wnc_sysPara_typ;

typedef struct wnc_pidPara_typ
{	float Kp;
	float Tn;
	float Td;
	float Tf;
	float yi_max;
	float y_min;
	float y_max;
} wnc_pidPara_typ;

typedef struct wnc_filterPara_typ
{	unsigned char filterMode;
	float filterTime;
} wnc_filterPara_typ;

typedef struct wnc_estPara_typ
{	unsigned long cycEstWindow;
	unsigned long cycEstTrig;
	unsigned char filterMode;
	float filterTime;
	unsigned long filterWindow;
} wnc_estPara_typ;

typedef struct wnc_motPara_typ
{	float filterTime;
	float kT;
	float pp;
	float Lr;
	float Lh;
	float I0;
} wnc_motPara_typ;

typedef struct wnc_simPara_typ
{	float wndWidth;
	float matThickness;
	float matLength;
	unsigned char material;
	float minDiam;
	float maxDiam;
	float xDiam;
	float startDiam;
	float minInertia;
	float xInertia;
	float dcrInertia;
	float dcrLength;
	float maxDcrPos;
	float kvTorque;
	float lineUnits;
	unsigned long wndUnits;
	unsigned long revMotor;
	float accLine;
	float decLine;
	float gearRatio;
	float kTWndMot;
	signed char axisType;
	plcbit noise;
} wnc_simPara_typ;

typedef struct pid_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	float err_old;
	plcbit yLimAct;
	plcbit reset_old;
	struct wnc_pidPara_typ pidPara;
	plcbit init;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} pid_internal_typ;

typedef struct WNCPidCtrl
{
	/* VAR_INPUT (analog) */
	struct wnc_pidPara_typ* pPidPara;
	float err;
	/* VAR_OUTPUT (analog) */
	float y;
	float yp;
	float yi;
	float ydt1;
	unsigned short status;
	/* VAR (analog) */
	struct pid_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
	plcbit hold_yi;
	plcbit hold_y;
	plcbit reset;
} WNCPidCtrl_typ;

typedef struct pctrl_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	struct WNCPidCtrl PID;
	unsigned char sysParaStatus;
	struct wnc_sysPara_typ sysPara;
	float x[2];
	plcbit init;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} pctrl_internal_typ;

typedef struct wcd_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	struct wnc_sysPara_typ sysPara;
	struct wnc_estPara_typ estPara;
	plcbit updateValid;
	unsigned long actWndPos_old;
	signed long actWndPosDelta;
	unsigned long actWndRev_tmp[2];
	double actWndRev;
	plcbit trigNewMeas;
	float startDcrPos;
	signed long startWndPos;
	signed long startLinePos;
	plcbit MeasInProgress;
	double wndRatio;
	signed long BufCntMax;
	signed long BufCnt;
	signed long BufIdx;
	double xN[100];
	double yN[100];
	double posInt[2];
	double X_tmp[3];
	double X;
	double Y;
	double Y_filt;
	double dY_filt;
	double d_mat;
	double k_avg;
	unsigned long nbRecLQDataVecValid;
	plcbit initRecLQParaVec;
	plcbit resetRecLQParaVec;
	plcbit updateRecLQParaVec;
	float q;
	double cN[2];
	double cN_filt[2];
	double PN[3];
	double a[4];
	signed long b[2];
	double x[2];
	unsigned char mode_old;
	plcbit manEstTrig_old;
	unsigned char filterMode_old;
	float filterTime_PT2_old;
	unsigned char StartDiamSetMode;
	plcbit setStartDiam_old;
	plcbit update;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} wcd_internal_typ;

typedef struct wcff_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	float uLine_old;
	unsigned char sysParaStatus;
	struct wnc_sysPara_typ sysPara;
	float alpha;
	float accLine;
	plcbit init;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} wcff_internal_typ;

typedef struct lsp_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	struct wnc_sysPara_typ sysPara;
	plcbit init;
	unsigned char sysParaStatus;
	unsigned char inParaStatus;
	float vecKV[50];
	float vecTN[50];
	float vecDiam[50];
	unsigned short numPoints;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} lsp_internal_typ;

typedef struct wcsp_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	float kTnom;
	plcbit init;
	float x[3];
	plcbit simStepResponse_old;
	unsigned long count;
	float simTime;
	plcbit simActive;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} wcsp_internal_typ;

typedef struct sim_internal_typ
{	plcstring statusTxt[101];
	float Ts;
	plcbit updateValid;
	struct wnc_simPara_typ simPara;
	double x[22];
	float rho;
	float EA;
	float eps;
	plcbit matBreak;
	plcbit update;
	plcbit update_old;
	plcbit enable_old;
	unsigned long Bootkey;
} sim_internal_typ;

typedef struct WNCProcessCtrl
{
	/* VAR_INPUT (analog) */
	struct wnc_sysPara_typ* pSysPara;
	struct wnc_pidPara_typ* pPidPara;
	float actProcVar;
	float setProcVar;
	float actDiam;
	float filterTime;
	float gain;
	/* VAR_OUTPUT (analog) */
	float actSpeedCorr;
	unsigned short status;
	/* VAR (analog) */
	struct pctrl_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
	plcbit hold;
	plcbit reset;
} WNCProcessCtrl_typ;

typedef struct WNCCalcFFCtrl
{
	/* VAR_INPUT (analog) */
	struct wnc_sysPara_typ* pSysPara;
	float syncTime;
	float setLineSpeed;
	float actDiam;
	float actDiamCngRate;
	float actInertia;
	float actInertiaCngRate;
	float setMatTension;
	float uppTrqLimit;
	float lowTrqLimit;
	/* VAR_OUTPUT (analog) */
	float setWndSpeed;
	float setMotorTrq;
	unsigned short status;
	/* VAR (analog) */
	struct wcff_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
	plcbit sync;
} WNCCalcFFCtrl_typ;

typedef struct WNCLipSctrlPara
{
	/* VAR_INPUT (analog) */
	struct wnc_sysPara_typ* pSysPara;
	float actDiam;
	float* pVecSctrlKV;
	float* pVecSctrlTN;
	float* pVecDiam;
	unsigned short numPoints;
	/* VAR_OUTPUT (analog) */
	float actSctrlKV;
	float actSctrlTN;
	unsigned short status;
	/* VAR (analog) */
	struct lsp_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
} WNCLipSctrlPara_typ;

typedef struct WNCCalcSctrlPara
{
	/* VAR_INPUT (analog) */
	struct wnc_motPara_typ* pMotPara;
	float actInertia;
	float kvTorque;
	float TiFilter;
	float riseTime;
	float overshoot;
	/* VAR_OUTPUT (analog) */
	float SctrlKV;
	float SctrlTN;
	float stepResponse;
	unsigned short status;
	/* VAR (analog) */
	struct wcsp_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
	plcbit simStepResponse;
} WNCCalcSctrlPara_typ;

typedef struct WNCSimModel
{
	/* VAR_INPUT (analog) */
	struct wnc_simPara_typ* pSimPara;
	float lineSpeed;
	float cyclicVelocity;
	float cyclicVelocityCorrection;
	float cyclicTorque;
	float sctrlKV;
	float sctrlTN;
	float dcrTorque;
	/* VAR_OUTPUT (analog) */
	float setLineSpeed;
	float actMatTension;
	float actDcrPos;
	signed long actWndPos;
	float actWndSpeed;
	signed long actLinePos;
	float actLineSpeed;
	float actMotorTrq;
	float actDiam;
	unsigned short status;
	/* VAR (analog) */
	struct sim_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit matBreak;
} WNCSimModel_typ;

typedef struct WNCCalcDiam
{
	/* VAR_INPUT (analog) */
	struct wnc_sysPara_typ* pSysPara;
	struct wnc_estPara_typ* pEstPara;
	unsigned char mode;
	signed long actLinePos;
	float actLineSpeed;
	signed long actWndPos;
	float actWndSpeed;
	float actDcrPos;
	float startDiam;
	/* VAR_OUTPUT (analog) */
	float actDiam;
	float actDiamCngRate;
	float avgMatThickness;
	float actInertia;
	float actInertiaCngRate;
	float avgMatDensity;
	unsigned short status;
	/* VAR (analog) */
	struct wcd_internal_typ internal;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit update;
	plcbit setStartDiam;
	plcbit manEstTrig;
	plcbit hold;
} WNCCalcDiam_typ;



/* Prototyping of functions and function blocks */
void WNCProcessCtrl(struct WNCProcessCtrl* inst);
void WNCPidCtrl(struct WNCPidCtrl* inst);
void WNCCalcFFCtrl(struct WNCCalcFFCtrl* inst);
void WNCLipSctrlPara(struct WNCLipSctrlPara* inst);
void WNCCalcSctrlPara(struct WNCCalcSctrlPara* inst);
void WNCSimModel(struct WNCSimModel* inst);
void WNCCalcDiam(struct WNCCalcDiam* inst);


__asm__(".section \".plc\"");

__asm__(".previous");


#endif /* _ASWNDCON_ */

