init()
{
    level thread novo\_events::addLevelConnectEvent( ::addPlayer );
}

addPlayer()
{
    i = 0;
	while ( isDefined( level.napPlayers[i] ) )
		i++;

	level.napPlayers[i] = self;
}