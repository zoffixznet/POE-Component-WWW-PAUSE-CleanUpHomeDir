#!/usr/bin/env perl

use Test::More tests => 4;

BEGIN {
    use_ok('POE');
    use_ok('POE::Component::NonBlockingWrapper::Base');
    use_ok('WWW::PAUSE::CleanUpHomeDir');
	use_ok( 'POE::Component::WWW::PAUSE::CleanUpHomeDir' );
}

diag( "Testing POE::Component::WWW::PAUSE::CleanUpHomeDir $POE::Component::WWW::PAUSE::CleanUpHomeDir::VERSION, Perl $], $^X" );
