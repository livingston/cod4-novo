GloballogicInit()
{
    thread novo\_dvars::init();
    thread novo\_events::init();

    level thread novo\_languages::init();
    level thread novo\_prestige::init();
    level thread novo\_permissions::init();

    level thread novo\_kdratio::init();
    level thread novo\_killcard::init();

    level thread novo\hardpoints\_carepackage::setup();
}

startGameType()
{
    thread novo\_player::init();

    thread setupServerDvars();
}

setupServerDvars()
{
    exec( "seta sv_consayname ^2C^14^2N^7->  ^7" );
    exec( "seta sv_contellname ^2C^14^2N^7->PM  ^7" );

    exec( "sets _mod CoD4:Novo" );
    exec( "sets _modVer 1.0.2-alpha" );
}

load()
{
    level thread novo\_menu::init();
}