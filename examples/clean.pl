#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(lib ../lib);
use POE qw/Component::WWW::PAUSE::CleanUpHomeDir/;

@ARGV == 2
    or die "Usage: perl $0 login pass\n";

my $poco = POE::Component::WWW::PAUSE::CleanUpHomeDir->spawn(
    obj_args => [ @ARGV[0,1] ],
);

POE::Session->create( package_states => [ main => [qw(_start results)] ], );

$poe_kernel->run;

sub _start {
    $poco->run( {
            event   => 'results',
            method  => 'clean_up',
            args    => [ [ qw/POE-Component-WWW-DoctypeGrabber-0.0101/ ] ],
        }
    );
}

sub results {
    my $in_ref = $_[ARG0];

    if ( $in_ref->{error} ) {
        print "Error: $in_ref->{error}\n";
    }
    else {
        print "Deleted:\n", join "\n", @{ $in_ref->{result} };
    }

    $poco->shutdown;
}

