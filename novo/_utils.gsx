#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;


readFile( fileName )
{
    testFileHandle = FS_TestFile( fileName );
    if( testFileHandle )
        FS_FClose( testFileHandle );
    else
        return "";

    fileHandle = FS_FOpen( fileName, "read" );
    fileContents = FS_ReadLine( fileHandle );

    FS_FClose( fileHandle );

    if( isDefined( fileContents ) )
        return fileContents;

    return "undefined";
}

writeFile( fileName, content, writeMode )
{
    fileHandle = undefined;

    if( !isDefined( writeMode ) || writeMode == "append" )
        fileHandle = FS_FOpen(fileName, "append");

    else if( writeMode == "write" )
        fileHandle = FS_FOpen( fileName, "write" );

    FS_WriteLine( fileHandle, content );

    FS_FClose( fileHandle );
}

cleanScreen()
{
    for( i = 0; i < 6; i++ )
    {
        if( isDefined( self ) && isPlayer( self ))
        {
            self iPrintlnBold( " " );
            self iPrintln( " " );
        } else {
            iPrintlnBold( " " );
            iPrintln( " " );
        }
    }
}

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

StrReplace( str, what, to )
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

            outstring = StrReplace( outstring, what[ i ], r );
        }
    }
    else
    {
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

array( a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20 )
{
    r=[];
    r[0] = a1;
    r[1] = a2;
    r[2] = a3;
    r[3] = a4;
    r[4] = a5;
    r[5] = a6;
    r[6] = a7;
    r[7] = a8;
    r[8] = a9;
    r[9] = a10;
    r[10] = a11;
    r[11] = a12;
    r[12] = a13;
    r[13] = a14;
    r[14] = a15;
    r[15] = a16;
    r[16] = a17;
    r[17] = a18;
    r[18] = a19;
    r[19] = a20;

    return r;
}

removeColor( string )
{
    inputString = CopyStr( string );

    return StrColorStrip( inputString );
}

isArray( v )
{
    return ( isDefined( v ) && v.size && !isString( v ) );
}


// Note: getArrayKeys() returns the list of keys in reverse order, so looping in reverse

forEach( array, func, arg )
{
    keys = getArrayKeys( array );
    if( isDefined( arg ) )
    {
        for( i = keys.size - 1; i >= 0; i-- )
        {
            self [[ func ]]( array[ keys[i] ], arg, keys[i] );
        }
    }
    else
    {
        for( i = keys.size - 1; i >= 0; i-- )
        {
            self [[ func ]]( array[ keys[i] ], keys[i] );
        }
    }
}

filter( array, evaluator )
{
    results = [];
    keys = getArrayKeys( array );

    for( i = keys.size - 1; i >= 0; i-- )
    {
        if([[ evaluator ]]( array[ keys[i] ], keys[i] ))
            results[ results.size ] = results[ keys[i] ];
    }

    return results;
}

find( array, evaluator, arg )
{
    keys = getArrayKeys( array );

    for( i = keys.size - 1; i >= 0; i-- )
    {
        if([[ evaluator ]]( array[ keys[i] ], arg, keys[i] ))
            return array[ keys[i] ];
    }

    return undefined;
}

toUpper( string )
{
    switch( string )
    {
        case "0": return "§";
        case "1": return "'";
        case "2": return "+";
        case "3": return "^";
        case "4": return "!";
        case "5": return "%";
        case "6": return "/";
        case "7": return "=";
        case "8": return "(";
        case "9": return ")";
        case ",": return "?";
        case ".": return ":";
        case "-": return "_";
        default:
            result = "";
            from = "abcdefghijklmnopqrstuvwxyzíöüóőúéáű";
            to   = "ABCDEFGHIJKLMNOPQRSTUVWXYZÍÖÜÓŐÚÉÁŰ";

            for( i = 0; i < string.size; i++ )
            {
                for( j = 0; j < from.size; j++ )
                {
                    if( string[i] == from[j] )
                    {
                        result += to[j];
                        break;
                    }
                }
            }

            return result;
    }

    return string;
}

fact(x)
{
	if( x == 0 ) return 1;
	c = 1;

    for( i = 1; i <= x; i++ )
		c = c * i;

    return c;
}

coeff(x,y)
{
	return (fact(y) / (fact(x) * fact(y - x)));
}

pow(a, b)
{
	x = 1;

	if( b!= 0 )
    {
		for( i = 1; i <= b; i++ )
			x = x * a;
	}

	return x;
}
