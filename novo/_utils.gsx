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