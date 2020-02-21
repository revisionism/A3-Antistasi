/*  Updates the preferences of markers when tierWar changes. Handles the update of every marker
*   Params:
*       Nothing
*
*   Returns:
*       Nothing
*/

private _fileName = "updatePreference";

if(!canSuspend) exitWith
{
    [] spawn A3A_fnc_updatePreference;
};

[2, format ["tierWar has changed, is now %1, checking for preference update", tierWar], _fileName] call A3A_fnc_log;

//No need to update the preferences
if(tierPreference >= tierWar) exitWith
{
    [2, "Update of preference aborted as this war level was already reached before", _fileName] call A3A_fnc_log;
};

private _preference = [];
private _patrols = [];

for "_i" from (tierPreference + 1) to tierWar do
{
    if(_i in airportUpdateTiers) then
    {
        _preference = garrison getVariable "Airport_preference";
        _patrols = garrison getVariable "Airport_patrolPref";
        //Update vehicle types
        [_preference] call A3A_fnc_updateVehicles;

        //Add new vehicles
        _index = airportUpdateTiers findIf {_x == _i};
        if(_index % 2 == 0) then
        {
            _preference pushBack ["LAND_LIGHT", -1, "SQUAD"];
            _preference pushBack ["HELI_LIGHT", -1, "GROUP"];
            _patrols pushBack "PATROL_SNIPER";
        }
        else
        {
            _preference pushBack ["LAND_AIR", -1, "AA"];
            _preference pushBack ["AIR_GENERIC", -1, "EMPTY"];
            _patrols pushBack "PATROL_SPECOPS";
        };

        [2, format ["Airport_preference hit level %1", _i], _fileName] call A3A_fnc_log;
        [_preference, "Airport_preference"] call A3A_fnc_logArray;
        diag_log format ["Airport patrols: %1", _patrols];

        garrison setVariable ["Airport_preference", _preference, true];
        garrison setVariable ["Airport_patrolPref", _patrols, true];
        garrison setVariable ["Airport_staticPerc", (airportStaticsTiers select _index), true];

        //Update all the airports
        {
            ["Airport", _x] spawn A3A_fnc_updateGarrison;
            ["Airport", _x] spawn A3A_fnc_updateStatics;
        } forEach airportsX;
    };

    if(_i in outpostUpdateTiers) then
    {
        _preference = garrison getVariable "Outpost_preference";
        _patrols = garrison getVariable "Outpost_patrolPref";
        //Update vehicle types
        [_preference] call A3A_fnc_updateVehicles;

        //Add new vehicles
        _index = outpostUpdateTiers findIf {_x == _i};
        if(_index % 2 == 0) then
        {
            _preference pushBack ["LAND_LIGHT", -1, "SQUAD"];
            _patrols pushBack "PATROL_ATTACK";
        }
        else
        {
            _preference pushBack ["HELI_LIGHT", -1, "GROUP"];
            _patrols pushBack "PATROL_SNIPER";
        };

        [2, format ["Outpost_preference hit level %1", _i], _fileName] call A3A_fnc_log;
        [_preference, "Outpost_preference"] call A3A_fnc_logArray;
        diag_log format ["Outpost patrols: %1", _patrols];

        garrison setVariable ["Outpost_preference", _preference, true];
        garrison setVariable ["Outpost_patrolPref", _patrols, true];
        garrison setVariable ["Outpost_staticPerc", (outpostStaticsTiers select _index), true];

        {
            ["Outpost", _x] spawn A3A_fnc_updateGarrison;
            ["Outpost", _x] spawn A3A_fnc_updateStatics;
        } forEach outposts;
    };

  if(_i in cityUpdateTiers) then
  {
      //Update preferences of cities
      _preference = garrison getVariable "City_preference";
      _patrols = garrison getVariable "City_patrolPref";

      _preference pushBack ["LAND_LIGHT", -1, "GROUP"];
      _patrols pushBack "PATROL_DEFENSE";

      [2, format ["City_preference hit level %1", _i], _fileName] call A3A_fnc_log;
      [_preference, "City_preference"] call A3A_fnc_logArray;
      diag_log format ["City patrols: %1", _patrols];

      garrison setVariable ["City_preference", _preference, true];
      garrison setVariable ["City_patrolPref", _patrols, true];

      //Update statics percentage
      _index = cityUpdateTiers findIf {_x == _i};
      garrison setVariable ["City_staticPerc", (cityStaticsTiers select _index), true];

      {
          ["City", _x] spawn A3A_fnc_updateGarrison;
          ["City", _x] spawn A3A_fnc_updateStatics;
      } forEach citiesX;
  };

  if(_i in otherUpdateTiers) then
  {
      //Update preferences of other sites
      _preference = garrison getVariable "Other_preference";
      _patrols = garrison getVariable "Other_patrolPref";
      //Update vehicle types
      [_preference] call A3A_fnc_updateVehicles;

      _preference pushBack ["EMPTY", 0, "SQUAD"];
      _patrols pushBack "PATROL_ATTACK";

      [2, format ["Other_preference hit level %1", _i], _fileName] call A3A_fnc_log;
      [_preference, "Other_preference"] call A3A_fnc_logArray;
      diag_log format ["Other patrols: %1", _patrols];

      garrison setVariable ["Other_preference", _preference, true];
      garrison setVariable ["Other_patrolPref", _patrols, true];

      //Update statics percentage
      _index = otherUpdateTiers findIf {_x == _i};
      garrison setVariable ["Other_staticPerc", (otherStaticsTiers select _index), true];

      {
          ["Other", _x] spawn A3A_fnc_updateGarrison;
          ["Other", _x] spawn A3A_fnc_updateStatics;
      } forEach resourcesX + factories + seaports;
  };
  sleep 0.1;
};

tierPreference = tierWar;
publicVariable "tierPreference";
