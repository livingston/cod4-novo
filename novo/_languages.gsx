// Author: 	DuffMan

init()
{
    level.callbackiPrintBig = ::iPrintBig;

    thread translations::LoadLanguages();
}

iPrintBig( string, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 )
{
	if( isDefined( self ) && isplayer( self ) )
		self IPrintlnBold( self getLangString( string, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 ) );
	else
    {
		players = novo\_common::getAllPlayers();

		for( i = 0; i < players.size; i++ )
			players[ i ] IPrintlnBold( players[ i ] getLangString( string, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 ) );
	}
}

Replace_Variables( str, what, to )
{
	outstring = "";

	if( !isString( what ) )
    {
		outstring = str;

		for( i = 0; i < what.size; i++ )
        {
			if( isDefined( to[ i ] ) )
				r = to[ i ];
			else
				r = "UNDEFINED[" + what[ i ] + "]";

            outstring = Replace_Variables( outstring, what[ i ], r );
		}
	}
	else
    {
		what = "$$" + what + "$$";
		for( i = 0; i < str.size; i++ )
        {
			if( GetSubStr( str, i, i + what.size ) == what )
            {
				outstring += to;
				i += what.size - 1;
			}
			else
				outstring += GetSubStr( str, i, i + 1 );
		}
	}

	return outstring;
}

getLangString( alias, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 )
{
	if( !isDefined( self.pers[ "country" ] ) )
		self.pers[ "country" ] = "EN";

	if( !isDefined( alias ) || !isDefined( self ) )
        return "";

	if( !isPlayer( self ) )
    {
		array = [];
		players = novo\_common::getAllPlayers();

		for( i = 0; i < players.size; i++ )
        {
			array[ i ] = players[ i ] getLangString( alias, srch0, rep0, srch1, rep1, srch2, rep2, srch3, rep3, srch4, rep4, srch5, rep5, srch6, rep6 );
		}

		return array;
	}

	search = [];
	replace = [];

	if( isDefined( srch0 ) && isDefined( rep0 ) )
    {
		search[ 0 ] = srch0;
        replace[ 0 ] = rep0;

		if( isDefined( srch1 ) && isDefined( rep1 ) )
        {
			search[ 1 ] = srch1;
            replace[ 1 ] = rep1;

            if( isDefined( srch2 ) && isDefined( rep2 ) )
            {
				search[ 2 ] = srch2;
                replace[ 2 ] = rep2;

				if( isDefined( srch3 ) && isDefined( rep3 ) )
                {
					search[ 3 ] = srch3;
                    replace[ 3 ] = rep3;

					if( isDefined( srch4 ) && isDefined( rep4 ) )
                    {
						search[ 4 ] = srch4;
                        replace[ 4 ] = rep4;

						if( isDefined( srch5 ) && isDefined( rep5 ) )
                        {
							search[ 5 ] = srch5;
                            replace[ 5 ] = rep5;

							if( isDefined( srch6 ) && isDefined( rep6 ) )
                            {
								search[ 6 ] = srch6;
                                replace[ 6 ] = rep6;
                            }
                        }
                    }
                }
            }
        }
    }

    currentLang = level.lang[ self.pers[ "country" ] ];
	if( isDefined( currentLang ) )
    {
		if( isDefined( currentLang[ alias ] ) )
        {
			if( !isString( currentLang[ alias ] ) || !isSubStr( currentLang[ alias ], "$$" ) )
				return currentLang[ alias ];
			else
				return Replace_Variables( currentLang[ alias ], search, replace );
		}
		else
            return alias;
	}

    return alias;
}

Lang( lang, alias, string )
{
	level.lang[ lang ][ alias ] = string;
}