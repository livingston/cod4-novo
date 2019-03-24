#include maps\mp\_utility;
#include novo\_utils;

log( logfile, log, mode )
{
    database = undefined;

    if( !isDefined( mode ) || mode == "append" )
        database = FS_FOpen( logfile, "append" );
    else if( mode == "write" )
        database = FS_FOpen( logfile, "write" );

    FS_WriteLine( database, log );
    FS_FClose( database );
}

devPrint( text )
{
    players = getAllPlayers();

    for( i = 0; i < players.size; i++ )
        if( players[ i ] novo\_player::hasPermission( "debug" ) )
            players[ i ] iPrintlnBold( text );
}

warning( error )
{
    log( "warnings.log", "WARNING: " + error + " (" +getDvar("time")+ ").", "append" );
    devPrint( "^3WARNING: " + error );
}

getCvar( dvar )
{
    guid = "level_" + getDvar( "net_port" );

    if( IsPlayer( self ) )
    {
        guid = GetSubStr( self getGuid(), 24, 32 );

        if( !isHex( guid ) || guid.size != 8 )
            return "";
    }
    else if( self != level )
        return "";

    playerDB = novo\_utils::readFile( "players/" +guid+ ".db" );

    if( playerDB == "undefined" )
    {
        novo\_utils::writeFile( "players/" +guid+ ".db", "", "write" );
        return "";
    }

    playerConfigs = strTok( playerDB, "" );

    for( i = 0; i < playerConfigs.size; i++ )
    {
        playerConfig = strTok( playerConfigs[i], "" );

        if( playerConfig[0] == dvar )
            return playerConfig[1];
    }

    return "";
}

getCvarInt( dvar )
{
    return int( getCvar( dvar ) );
}

setCvar( dvar, value )
{
    guid = "level_" + getDvar( "net_port" );

    if( IsPlayer( self ) )
    {
        guid = GetSubStr( self getGuid(), 24, 32 );

        if( !isHex( guid ) || guid.size != 8 )
            return "";
    }
    else if( self != level )
        return "";

    playerDB = novo\_utils::readFile( "players/" +guid+ ".db" );

    database["dvar"] = [];
    database["value"] = [];
    adddvar = true;

    if( playerDB != "undefined" && playerDB != "" )
    {
        playerConfigs = strTok( playerDB, "" );

        for( i = 0; i < playerConfigs.size; i++ )
        {
            playerConfig = strTok( playerConfigs[i], "" );
            database["dvar"][i]  = playerConfig[0];
            database["value"][i] = playerConfig[1];
        }

        for( i = 0; i < database["dvar"].size; i++ ) {
            if( database["dvar"][i] == dvar )
            {
                database["value"][i] = value;
                adddvar = false;
            }
        }
    }

    if( adddvar )
    {
        s = database["dvar"].size;
        database["dvar"][s]  = dvar;
        database["value"][s] = value;
    }

    playerDBContent = "";

    for( i = 0; i < database["dvar"].size; i++ )
    {
        playerDBContent += database["dvar"][i] + "" + database["value"][i] + "";
    }

    novo\_utils::writeFile( "players/" +guid+ ".db", playerDBContent, "write" );
}

getAllPlayers()
{
    return getEntArray( "player", "classname" );
}

getPlayers()
{
    return level.players;
}

getPlayerByNum( pNum )
{
    players = getAllPlayers();

    for( i = 0; i < players.size; i++ )
        if ( players[i] getEntityNumber() == int( pNum ) )
            return players[i];
}

getPlayerByGuid( guid )
{
    if( guid.size > 8 )
        guid = GetSubStr( guid, guid.size - 8, guid.size );

    players = getAllPlayers();

    for( i = 0; i < players.size; i++ )
    {
        if ( GetSubStr( players[i] getGuid(), 24, 32 ) == guid )
            return players[i];
    }
}

useConfig()
{
    waittillframeend;

    // forceLaser = self.pers[ "forceLaser" ];
    // if( forceLaser )
    //    self setClientDvar( "cg_laserForceOn", 1 );
    // else
    //    self setClientDvar( "cg_laserForceOn", 0 );
}

translate( alias )
{
    if( !isDefined( self.pers[ "country" ] ) )
        self.pers[ "country" ] = "EN";

    if( !isDefined( alias ) || !isDefined( self ))
        return "";

    if( isDefined( level.lang[ "EN" ][ alias ] ) )
    {
        return level.lang[ "EN" ][ alias ];
    }

    return alias;
}

FadeOut( time )
{
    if( !isDefined( self ) )
        return;

    self fadeOverTime( time );
    self.alpha = 0;
    wait time;

    if( !isDefined( self ) )
        return;

    self destroy();
}

FadeIn( time )
{
    alpha = self.alpha;

    self.alpha = 0;
    self fadeOverTime( time );
    self.alpha = alpha;
}

iPrintBig( string, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 )
{
    if( isDefined( level.callbackiPrintBig ) )
        self thread [[ level.callbackiPrintBig ]]( string, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 );
    else
        warning( "'level.callbackiPrintBig' is not defined" );
}

hasPermission( permission )
{
    if( isDefined( level.callbackPermission ) )
        return self [[ level.callbackPermission ]]( permission );

    return false;
}

isRealyAlive()
{
    return ( self.pers["team"] != "spectator" && self.health && self.sessionstate == "playing" );
}

setHealth( health )
{
    self notify( "end_healthregen" );
    self.maxhealth = health;
    self.health = self.maxhealth;
    self setnormalhealth( self.health );

    self thread maps\mp\gametypes\_healthoverlay::playerHealthRegen();
}

NotifyMsg(text)
{
    notifyData = spawnStruct();
    notifyData.notifyText = text;
    self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

streakWarning( ownermsg, teammsg, enemymsg )
{
    players = getAllPlayers();

    for( i = 0; i < players.size; i++ )
    {
        if( players[i] == self )
            players[i] iPrintln( players[i] translate( ownermsg ) );
        else if( players[i].pers["team"] == self.pers["team"] && level.teambased )
            players[i] iPrintln( players[i] translate( teammsg ) );
        else if( players[i].pers["team"] != "spectator" )
            players[i] iPrintln( players[i] translate( enemymsg ) );
    }
}

isCustomMap()
{
    switch(level.script)
    {
        case "mp_backlot":
        case "mp_bloc":
        case "mp_bog":
        case "mp_broadcast":
        case "mp_carentan":
        case "mp_cargoship":
        case "mp_citystreets":
        case "mp_convoy":
        case "mp_countdown":
        case "mp_crash":
        case "mp_crash_snow":
        case "mp_creek":
        case "mp_crossfire":
        case "mp_farm":
        case "mp_killhouse":
        case "mp_overgrown":
        case "mp_pipeline":
        case "mp_shipment":
        case "mp_showdown":
        case "mp_strike":
        case "mp_vacant":
            return false;
    }

    return true;
}

getConfig( property, value )
{
    fallDamageMinHeight = level.dvar[ "scr_novo_falldamage_minheight" ];
    fallDamageMaxHeight = level.dvar[ "scr_novo_falldamage_maxheight" ];
    jumpHeight = level.dvar[ "scr_novo_jump_height" ];

    novo_server_config["highJump"][0] = "scr_novo_highjump=0;scr_fallDamageMinHeight=128;scr_fallDamageMaxHeight=300;scr_jump_height=39;scr_jump_slowdown_enable=1";
    novo_server_config["highJump"][1] = "scr_novo_highjump=1;scr_fallDamageMinHeight="+ fallDamageMinHeight +";scr_fallDamageMaxHeight="+ fallDamageMaxHeight +";scr_jump_height="+ jumpHeight +";scr_jump_slowdown_enable=0";

    if( isDefined( novo_server_config[ property ] ) && isDefined( novo_server_config[ property ][ value ] ))
        return novo_server_config[ property ][ value ];

    return "";
}

setServerConfig( property, value )
{
    if( IsPlayer( self ) && !(self novo\_player::hasPermission( "admin" )) )
    {
        self IPrintLnBold( "YOU DO NOT HAVE PERMISSION" );
        return "";
    }

    serverSettingData = novo\_utils::readFile( "novo_settings.cfg" );

    settings = [];

    if( serverSettingData != "undefined" && serverSettingData != "" )
    {
        serverSettings = strTok( serverSettingData, "\n" );

        for( i = 0; i < serverSettings.size; i++ )
        {
            serverSetting = strTok( serverSettings[i], " " );
            settings[ serverSetting[1] ]  = serverSetting[2];
        }
    }

    configs = getConfig( property, value );
    configs = strTok( configs, ";" );

    for( i = 0; i < configs.size; i++ ) {
        config = strTok( configs[i], "=" );

        settings[ config[0] ] = config[1];
    }

    serverSettingData = "";
    updatedSettings = GetArrayKeys( settings );

    for( i = 0; i < updatedSettings.size; i++ )
    {
        serverSettingData += "set " + updatedSettings[i] + " " + settings[ updatedSettings[i] ] + "\n";
    }

    novo\_utils::writeFile( "novo_settings.cfg", serverSettingData, "write" );
}

notifyTeam( string, glow, duration )
{
    if( !level.teambased )
        return;

    players = getPlayers();

    for( i = 0; i < players.size; i++ )
    {
        player = players[ i ];

        if( player.pers[ "team" ] == self.pers[ "team" ] )
            player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( undefined, string, undefined, glow, undefined, duration );
    }
}

notifyTeamLn( string )
{
    if( !level.teambased )
        return;

    players = getPlayers();

    for( i = 0; i < players.size; i++ )
    {
        player = players[ i ];

        if( player.pers[ "team" ] == self.pers[ "team" ] )
            player iPrintLn( string );
    }
}

notifyTeamBig( string, glow, duration )
{
    if( !level.teambased )
        return;

    players = getPlayers();

    for( i = 0; i < players.size; i++ )
    {
        player = players[ i ];

        if( player.pers[ "team" ] == self.pers[ "team" ] )
            player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( string, undefined, undefined, glow, undefined, duration );
    }
}

clearNotify()
{
    players = getPlayers();

    for( i = 0; i < players.size; i++ )
    {
        if( isDefined( players[ i ].notifyQueue ) )
        {
            for( a = 0; a < players[ i ].notifyQueue.size; a++ )
                if( isDefined( players[ i ].notifyQueue[ a ] ) )
                    players[ i ].notifyQueue[ a ] = undefined;
        }

        if( isDefined( players[ i ].doingNotify ) && players[ i ].doingNotify )
            players[ i ] thread maps\mp\gametypes\_hud_message::resetNotify();
    }
}

removeInfoHUD()
{
    if( isDefined( self.info ) )
    {
        for( i = 0; i < self.info.size; i++ )
            self.info[ i ] destroy();
    }

    self.info = undefined;
}

restoreHP()
{
	if( level.hardcoreMode )
		self.maxhealth = 30;

	else if( level.oldschool )
		self.maxhealth = 200;

	else
		self.maxhealth = 100;

	self.health = self.maxhealth;

	self setClientDvar( "ui_hud_hardcore", level.hardcoreMode );
}

restoreVisionSettings()
{
    self endon( "disconnect" );

    self setClientDvar( "waypointiconheight", 36 );
    self setClientDvar( "waypointiconwidth", 36 );

    self thread novo\_player::userSettings();

    wait .05; // Let the onPlayerKilled code catch up

    self.hardpointVision = undefined;
}

// Game FX
SoundOnOrigin( alias, origin )
{
    soundPlayer = spawn( "script_origin", origin );
    soundPlayer playsound( alias );

    wait 10;

    soundPlayer delete();
}

TriggerEarthquake( a, duration, origin, radius)
{
    if( !isDefined( level.earthquake ) )
        level.earthquake = [];

    index = level.earthquake.size;

    level.earthquake[index] = spawnStruct();
    level.earthquake[index].duration = duration;
    level.earthquake[index].origin = origin;
    level.earthquake[index].radius = radius;

    Earthquake( a, duration, origin, radius );

    level thread DeleteEarthquake( level.earthquake[index] );
}


DeleteEarthquake( trigger )
{
    wait trigger.duration;

    array = [];
    for( i = 0; i < level.earthquake.size; i++ )
        if( level.earthquake[i] != trigger )
            array[array.size] = level.earthquake[i];

    level.earthquake = array;
}

godMod()
{
    self.maxHealth = 120000;
    self.health = self.maxHealth;
}

BeginFlight(pos, mul)
{
	id = RandomInt(99999);

	if( !isDefined( pos[1] ) || !isDefined( pos[0] ) )
		return;

	if( isPlayer( self ) )
    {
		self endon( "disconnect" );
		object[0] = self;
	}
	else
		object = self;

    if( !isDefined( mul ) )
        mul = 20;

	for( i = pos.size; i > 0; i-- )
    {
		pos[ i ][ "origin" ] = pos[ i-1 ][ "origin" ];
		pos[ i ][ "angles" ] = pos[ i-1 ][ "angles" ];
	}

	pos[ 0 ][ "origin" ] = pos[ 1 ][ "origin" ];
	pos[ 0 ][ "angles" ] = pos[ 1 ][ "angles" ];
	pos[ pos.size - 1 ][ "angles" ] = (pos[ pos.size - 1 ][ "angles" ][0], pos[ pos.size - 1 ][ "angles" ][1], 0);

	alldist = 0;
	multiplier = getDvarint( "sv_fps" ) / 100;
	parts = pos.size - 1;

	for( k = 1; k < parts; k++ )
    {
		if( pos[ k+1 ][ "angles" ][1] - pos[ k ][ "angles" ][1] >=180 )
			pos[ k ][ "angles" ] += (0,360,0);
		else if( pos[ k+1 ][ "angles" ][1] - pos[ k ][ "angles" ][1] <= -180)
			pos[ k+1 ][ "angles" ] += (0,360,0);

		alldist += (distance(pos[ k ][ "origin" ], pos[ k+1 ][ "origin" ]) + distance(pos[ k ][ "angles" ], pos[ k+1 ][ "angles" ]));
	}

	link = spawn( "script_origin", pos[ 1 ][ "origin" ]);

	for( i = 0; i < object.size; i++ )
    {
		object[i] unlink();
		object[i] clearlowerMessage();
		object[i] freezecontrols( true );
		object[i] setOrigin( pos[ 1 ][ "origin" ] );
		object[i] setPlayerAngles( pos[ 1 ][ "angles" ] );
		object[i] linkto( link );
		object[i].flightID = id;
	}

	origin = (0,0,0);
	angles = (0,0,0);
	t = 0;

	for( i = 0; i <= (alldist * 10 * multiplier / mul); i++ )
    {
		origin = (0,0,0);
		angles = (0,0,0);
		t=(i * mul / (alldist * 10 * multiplier ) );

		for( z = 1; z <= parts; z++ )
        {
			origin += (coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["origin"][0],coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["origin"][1],coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["origin"][2]);
			angles += (coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["angles"][0],coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["angles"][1],coeff(z-1,parts-1)*pow((1-t),parts-z)*pow(t,z-1)*pos[z]["angles"][2]);
		}

		link MoveTo( origin, .1 );

		for( j = 0; j < object.size; j++ )
			if(IsDefined(object[j]) && object[j].flightID == id)
				object[j] setPlayerAngles(angles);

		wait .05;
	}

	wait .05;
	for( i = 0; i < object.size; i++ )
    {
		if(isDefined(object[i]) && object[i].flightID == id) {
			object[i] unlink();
			object[i] freezecontrols(false);
			if(!object[i].health)
				object[i] setOrigin(object[i].origin+(0,0,60));
			object[i] notify("flight_done");
		}
	}

	link delete();
}
