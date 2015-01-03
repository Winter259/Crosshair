#include "CH_Macros.h"

CH_InitMessage =
{
	FUN_ARGS_1(_message);
	diag_log format ['%1-[%2]: %3',DEBUG_HEADER,DEBUG_INIT,format _message];
	if (CH_Debug && CH_Debug_InitLevel) then
	{
		player sideChat format ['%1-[%2]: %3',DEBUG_HEADER,DEBUG_INIT,format _message];
	};
};

CH_Init =
{
	CH_Initialised = false;
	[] call CH_PreInit_Sequence;
	CH_Initialised = true;
	[["Crosshair version %1 has successfully initialised. Running on HC: %2",CH_Version,CH_RunOnHC]] call CH_InitMessage;
};

CH_PreInit_Sequence =
{
	[] call CH_Init_RequiredEventHandlers; // Required on all clients.
	PRECOMPILE("Crosshair\CH_Settings.sqf");
	CH_HC_Checked = false;
	// Server will now decide whether to run on server or on HC
	if (isServer) then
	{
		PRECOMPILE("Crosshair\CH_HC_Functions.sqf");
		[] call CH_Init_HC;
	};
	//WAIT(!isNil "CH_HC_Checked" && CH_HC_Checked);
	WAIT(CH_HC_Checked); // all clients must wait till the server finishes checking for HC
	if (CH_RunOnHC && CH_HC_Present && (isHC(player))) then
	{
		[["I am HC with ID: %1!",CH_HC_ClientID]] call CH_InitMessage;
		[] call CH_Init_Sequence;
	}
	else
	{
		if (isServer) then
		{
			[["I am the server!"]] call CH_InitMessage;
			[] call CH_Init_Sequence;
		};
	};
};

CH_Init_Sequence =
{
	[["Crosshair PreInit successful. HC found: %1.   Crosshair will run on HC: %2",CH_HC_Present,CH_RunOnHC]] call CH_InitMessage;
	[] call CH_Init_RequiredVariables;
	[] call CH_Init_Precompile_Functions;
	[] call CH_Init_ReturnArmaVersion;
	[] call CH_Init_CreateSpawnLocation;
	[] spawn CH_Mission;
};

CH_Init_RequiredVariables =
{
	CH_ArmA = 0;
	CH_DebugMarkers = [];
	CH_Harass_Units = [];
	CH_Harassable_Units = [];
	[["Crosshair Init Variables successfully precompiled."]] call CH_InitMessage;
};

CH_Init_Precompile_Functions =
{
	PRECOMPILE("Crosshair\CH_Debug_Functions.sqf");
	[["Crosshair Debug Functions successfully precompiled."]] call CH_InitMessage;
	PRECOMPILE("Crosshair\CH_General_Functions.sqf");
	[["Crosshair General Functions successfully precompiled."]] call CH_InitMessage;
	PRECOMPILE("Crosshair\CH_Harass_Functions.sqf");
	[["Crosshair Harass Functions successfully precompiled."]] call CH_InitMessage;
	PRECOMPILE("Crosshair\CH_SubTarget_Functions.sqf");
	[["Crosshair Sub Target Arrays successfully precompiled."]] call CH_InitMessage;
	PRECOMPILE("Crosshair\CH_Mission.sqf");
	[["Crosshair Mission File successfully precompiled."]] call CH_InitMessage;
};

// Finds out whether it is running on A2 or A3
CH_Init_ReturnArmaVersion =
{
	if (isNil {call compile "blufor"}) then 
	{
		CH_ArmA = 2;
		if (CH_WaitForHull) then
		{
			WAIT(hull_isInitialized);
		};
	}
	else
	{
		CH_ArmA = 3;
		if (CH_WaitForHull) then
		{
			WAIT(hull3_isInitialized);
		};
	};
	if (CH_WaitForAdmiral) then
	{
		WAIT(adm_isInitialized);
	};
	publicVariable "CH_ArmA";
	[["Crosshair running on ArmA: %1",CH_ArmA],true,true] call CH_LowMessage;
};

CH_Init_CreateSpawnLocation =
{
	// Create a position far out into debug zone for spawning purposes
	CH_Spawn_Location = [10000,10000,0];
	publicVariable "CH_Spawn_Location"; // required?
};

CH_Init_RequiredEventHandlers =
{
	CH_AI_Behaviour_Array = ["AUTOTARGET","TARGET","FSM","MOVE"];
	CH_AIAdjustment = []; // Used in conjunction with the PEH, value is [object,enable/disable]
	"CH_AIAdjustment" addPublicVariableEventHandler 
	{
		// _this select 0: variablename, _this select 1: variable's new value
		// If the variable being used will look like this: [_object,_value]
		private["_object","_value"];
		_object = (_this select 1) select 0;
		_value = (_this select 1) select 1;
		if (_value) then
		{
			{
				_object enableAI _x;
			} forEach CH_AI_Behaviour_Array;
			_object enableSimulation true;
		}
		else
		{
			{
				_object disableAI _x;
			} forEach CH_AI_Behaviour_Array;
			_object enableSimulation false;
		};
	};
};