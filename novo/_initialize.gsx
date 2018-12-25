GloballogicInit()
{
    thread novo\_dvars::init();
	thread novo\_events::init();
}

startGameType()
{
    thread novo\_player::init();

    thread setupServerDvars();
}

setupServerDvars()
{
    exec( "seta sv_consayname ^3C^14^2N^7->  ^7" );
    exec( "seta sv_contellname ^3C^14^2N^7->PM  ^7" );

    exec( "sets _mod CoD4:Novo" );
	exec( "sets _modVer 1.0.0-alpha" );
}

load()
{
    level thread novo\_menu::init();
}