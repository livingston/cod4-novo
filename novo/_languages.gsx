// Author: 	DuffMan

init()
{
    thread translations::LoadLanguages();
}

Lang( lang, alias, string )
{
	level.lang[ lang ][ alias ] = string;
}