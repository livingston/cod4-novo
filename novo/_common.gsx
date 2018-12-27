isHex( value )
{
	if( isDefined( value ) && value.size == 1 )
    {
		return (
            value == "a"
            || value == "b"
            || value == "c"
            || value == "d"
            || value == "e"
            || value == "f"
            || value == "0"
            || value == "1"
            || value == "2"
            || value == "3"
            || value == "4"
            || value == "5"
            || value == "6"
            || value == "7"
            || value == "8"
            || value == "9"
        );
    }
	else if( isDefined( value ) )
    {
		for( i = 0; i < value.size; i++ )
        {
			if( !isHex( value[i] ) )
				return false;
        }
    }

	return true;
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

getAllPlayers() {
	return getEntArray( "player", "classname" );
}

getPlayerByNum( pNum ) {
	players = getAllPlayers();

	for( i = 0; i < players.size; i++ )
		if ( players[i] getEntityNumber() == int( pNum ) )
			return players[i];
}

useConfig() {
	waittillframeend;

	if(self.pers["forceLaser"])
		self setClientDvar("cg_laserforceon",1);
	else
		self setClientDvar("cg_laserforceon",0);
}

hasPermission( permission )
{
	return false;
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

FadeIn( time ) {
	alpha = self.alpha;

	self.alpha = 0;
	self fadeOverTime( time );
	self.alpha = alpha;
}