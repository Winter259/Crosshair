#include "CH_Macros.h"

CH_Mission =
{
	PVT_1(_harasser1);
	[test_unit] call CH_HarassThisUnit;
	[test_unit,(side test_unit),SIZE_INF,5] call CH_General_AttachSubTargets;
	_harasser1 = ["RU_Soldier",east,Harass_Static,600] call CH_CreateHarassmentUnit;
};

CH_RunDebug =
{
	[Harass_Guy,test_unit,0.01] spawn CH_Debug_CompareTargetVsEyePos;
	[test_unit,0.01] spawn CH_Debug_TrackAltitude;
	[test_unit,0.01] spawn CH_Debug_CheckHarassableStatus;
	[Harass_Guy,test_unit,0.01] spawn CH_Debug_TrackKnowsAbout;
	[Harass_Guy,0.01] spawn CH_Debug_CreateObjectOnEyePos;
	[Harass_Guy,0.01] spawn CH_Debug_CreateObjectOnAimPos;
	[Harass_Guy,0.01] spawn CH_Debug_TrackEyePos;
	[Harass_Guy,0.01] spawn CH_Debug_TrackAimPos;
	[Harass_Guy,0.1] spawn CH_Debug_TrackHarasserAmmo;
	[Harass_Guy,test_unit,0.01] spawn CH_Debug_TrackRelativeDirection;
};