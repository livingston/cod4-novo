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
	// 	self setClientDvar( "cg_laserForceOn", 1 );
	// else
	// 	self setClientDvar( "cg_laserForceOn", 0 );
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