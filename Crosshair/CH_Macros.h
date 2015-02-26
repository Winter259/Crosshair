#include "Kami_Macros.h"

#ifndef CH_MACROS_H
#define CH_MACROS_H

#define CH_Version			0.3

#define PRECOMPILE(SCRIPT) 		call compile preProcessFileLineNumbers SCRIPT 
#define WAIT(CODE) 				waitUntil {CODE}
#define DEBUG					if (CH_Debug) then
#define ALTITUDE(OBJECT)		((getposATL OBJECT) select 2)
#define HC_NAMES				["HC","HeadlessClient"]
#define isHC(VAR)				((name VAR) in HC_NAMES)

#define BLU			west
#define OPF			east
#define IND			resistance
#define CIV			civilian

#define BLU_STR		"WEST"
#define OPF_STR		"EAST"
#define IND_STR		"GUER"
#define CIV_STR		"CIV"

#define SIDE_ARRAY			[BLU,OPF,IND,CIV]
#define SIDE_ARRAY_STR		[BLU_STR,OPF_STR,IND_STR,CIV_STR]

#define AI_BEHAVIOUR_ARRAY	["AUTOTARGET","TARGET","FSM","MOVE"]

#define SIZE_INF	"Infantry"
#define SIZE_ARM	"Armour"
#define SIZE_HVY	"Heavy Armour"

#define SUBTARGET_TEST				"Suitcase"
#define SUBTARGET_CENTRESUB_PARAM	((_zplane == 0) && (_yplane == 0) && (_xplane == 0))

#define SUBTARGET_BLU_INFANTRY		"ACE_Target_WInf"
#define SUBTARGET_OPF_INFANTRY		"ACE_Target_EInf"
#define SUBTARGET_IND_INFANTRY		"ACE_Target_RInf"
#define SUBTARGET_CIV_INFANTRY		"ACE_Target_CInf"

#define SUBTARGET_BLU_ARMOUR		"ACE_Target_WArm"
#define SUBTARGET_OPF_ARMOUR		"ACE_Target_EArm"
#define SUBTARGET_IND_ARMOUR		"ACE_Target_RArm"
#define SUBTARGET_CIV_ARMOUR		"ACE_Target_CArm"

#define SUBTARGET_BLU_HEAVY			"ACE_Target_WHvy"
#define SUBSUBTARGET_OPF_HEAVY		"ACE_Target_EHvy"
#define SUBTARGET_IND_HEAVY			"ACE_Target_RHvy"
#define SUBTARGET_CIV_HEAVY			"ACE_Target_CHvy"

#define HARASS_CHECKTARGET_DELAY		5
#define HARASS_ALIGNTARGET_DELAY		0.1
#define HARASS_ATTACKTARGET_DELAY		0.0025
#define HARASS_ATTACKCOOLDOWN_DELAY		1

#define DEBUG_INIT		"INIT"
#define DEBUG_LOW		"LOW"
#define DEBUG_ERR		"ERROR"
#define DEBUG_IMP		"IMPORTANT"
#define DEBUG_WARN		"WARNING"

#define DEBUG_TARGET_MARKER_DELAY				0.5
#define DEBUG_UNIT_ALIVE_MARKER_DELAY			5

#define DEBUG_HEADER	format ["%1-[CH]",time]

#endif //CH_MACROS_H