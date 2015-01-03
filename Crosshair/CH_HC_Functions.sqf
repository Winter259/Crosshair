#include "CH_Macros.h"

// HC related functions
CH_Init_HC =
{
	CH_HC_Present = false;
	CH_HC_ClientID = 0;
	[] call CH_Init_IsHCPresent;
};

CH_Init_IsHCPresent =
{
	PVT_2(_i,_all_units);
	WAIT(!((isNil "CH_HC_Checked") && (isNil "CH_HC_Present")));
	_all_units = playableUnits;
	[["Starting search for HC with name/s: %1",HC_NAMES]] call CH_InitMessage;
	for "_i" from 0 to ((count _all_units) - 1) do
	{
		if (isHC((_all_units select _i))) then
		{
			CH_HC_Present = true;
			publicVariable "CH_HC_Present";
			CH_HC_ClientID = (owner (_all_units select _i));
			publicVariable "CH_HC_ClientID";
			[["HC has been found! HC Client ID: %1",CH_HC_ClientID]] call CH_InitMessage;
		};
	};
	[["HC check complete. HC found: %1",CH_HC_Present]] call CH_InitMessage;
	CH_HC_Checked = true;
	sleep 0.1;
	publicVariable "CH_HC_Checked";
};