/*
*********************************************************************************************************
*                                  Embedded Systems Building Blocks
*                               Complete and Ready-to-Use Modules in C
*
*                                             Timer Manager
*
*                            (c) Copyright 1999, Jean J. Labrosse, Weston, FL
*                                           All Rights Reserved
*
* Filename   : TMR.H
* Programmer : Jean J. Labrosse
* Translated by : Won-Ho, Sung
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                                 ���
*********************************************************************************************************
*/
//#include "def28x_define.h"
#define     FALSE	0
#define     TRUE	!FALSE
#define     false	0
#define     true	!false
#define		NULL	(void *)0
#define 	HIGH	1
#define 	LOW		0
#define 	LF		0x0A	// Line feed
#define 	CR		0x0D	// Carrage return

typedef	unsigned char	BOOLEAN;
typedef	unsigned char	INT8U;
typedef	unsigned int	INT16U;

#define  NUL				0		
#define  TMR_MAX_TMR        6
#define  TIMERSCALE			1000
#define  TIMER_FREQUENCY     1000   // 1000us timer

#ifdef  TMR_GLOBALS
#define TMR_EXT
#else
#define TMR_EXT  extern
#endif

/*
*********************************************************************************************************
*                                              ������ Ÿ��
*********************************************************************************************************
*/

typedef struct tmr {                             /* Ÿ�̸� ������ ����ü                               */
    BOOLEAN   TmrEn;                             /* Ÿ�̸Ӱ� Ȱ��ȭ �Ǿ������� �˷��ִ� ������         */
    unsigned long    TmrCtr;                            /* Ÿ�̸��� ���� �� (ī��Ʈ �ٿ�)                     */
    unsigned long    TmrInit;                           /* Ÿ�̸��� �ʱ� �� (Ÿ�̸Ӱ� ��Ʈ�� ��)              */
    void    (*TmrFnct)(void *);                  /* ����� �� ����� �Լ�                              */
    void     *TmrFnctArg;                        /* ����� ���� �Լ��� ���޵Ǵ� ����                   */
} TMR;

/*
*********************************************************************************************************
*                                                ��������
*********************************************************************************************************
*/

TMR_EXT  TMR       TmrTbl[TMR_MAX_TMR];          /* �� ��⿡�� �����Ǵ� Ÿ�̸� ���̺�                 */

/*
*********************************************************************************************************
*                                                �Լ�����
*********************************************************************************************************
*/

void    TmrCfgFnct(INT8U n, void (*fnct)(void *), void *arg);
INT16U  TmrChk(INT8U n);

void    TmrInit(void);

void    TmrReset(INT8U n);

void    TmrSetMST(INT8U n, INT8U min, INT8U sec, INT8U tenths);
void    TmrSetT(INT8U n, INT16U tenths);
void    TmrStart(INT8U n);
void    TmrStop(INT8U n);
