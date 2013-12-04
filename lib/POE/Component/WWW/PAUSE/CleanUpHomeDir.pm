package POE::Component::WWW::PAUSE::CleanUpHomeDir;

use warnings;
use strict;

our $VERSION = '0.0101';

use POE;
use base 'POE::Component::NonBlockingWrapper::Base';
use WWW::PAUSE::CleanUpHomeDir;

sub _methods_define {
    return ( run => '_wheel_entry' );
}

sub run {
    $poe_kernel->post( shift->{session_id} => run => @_ );
}

sub _prepare_wheel {
    my $self = shift;
    $self->{obj} = WWW::PAUSE::CleanUpHomeDir->new(
        @{ $self->{obj_args} || [] },
    );
}

sub _process_request {
    my ( $self, $in_ref ) = @_;

    my $obj = $self->{obj};
    $in_ref->{result} = $obj->${\$in_ref->{method}}( @{ $in_ref->{args} || [] } )
        or $in_ref->{error} = $obj->error;
}

1;
__END__

=head1 NAME

POE::Component::WWW::PAUSE::CleanUpHomeDir - non-blocking wrapper around WWW::PAUSE::CleanUpHomeDir

=head1 SYNOPSIS

    use strict;
    use warnings;

    use POE qw/Component::WWW::PAUSE::CleanUpHomeDir/;

    my $poco = POE::Component::WWW::PAUSE::CleanUpHomeDir->spawn(
        obj_args => [ qw/PAUSE_ID password/ ],
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

Using event based interface is also possible of course.

=head1 DESCRIPTION

The module is a non-blocking wrapper around L<WWW::PAUSE::CleanUpHomeDir>
which provides interface to clean up old distributions (among with other things)
from your account on L<http://pause.perl.org/>

=head1 CONSTRUCTOR

=head2 C<spawn>

    my $poco = POE::Component::WWW::PAUSE::CleanUpHomeDir->spawn(
        obj_args => [ qw/Login Pass/ ]
    );

    POE::Component::WWW::PAUSE::CleanUpHomeDir->spawn(
        alias => 'pause',
        obj_args => [
            qw/Login Pass/,
            timeout => 10,
        ],
        options => {
            debug => 1,
            trace => 1,
            # POE::Session arguments for the component
        },
        debug => 1, # output some debug info
    );

The C<spawn> method returns a
POE::Component::WWW::PAUSE::CleanUpHomeDir object. It takes a few arguments,
all of which but C<obj_args> are optional. The possible arguments are as follows:

=head3 C<alias>

    ->spawn( alias => 'pause' );

B<Optional>. Specifies a POE Kernel alias for the component.

=head3 C<obj_args>

    ->spawn( obj_args => [ qw/Login Pass/ ] );

B<Mandatory>. Takes an arrayref as a value, this arrayref will be directly dereferenced into
L<WWW::PAUSE::CleanUpHomeDir>'s C<new()> method; since it requires you to specify your
PAUSE ID and password, the C<obj_args> is a mandatory argument.

=head3 C<options>

    ->spawn(
        options => {
            trace => 1,
            default => 1,
        },
    );

B<Optional>.
A hashref of POE Session options to pass to the component's session.

=head3 C<debug>

    ->spawn(
        debug => 1
    );

When set to a true value turns on output of debug messages. B<Defaults to:>
C<0>.

=head1 METHODS

=head2 C<run>

    $poco->run( {
            event       => 'event_for_output',
            method  => 'clean_up',
            args    => [ [ qw/POE-Component-WWW-DoctypeGrabber-0.0101/ ] ],
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Takes a hashref as an argument, does not return a sensible return value.
See C<run> event's description for more information.

=head2 C<session_id>

    my $poco_id = $poco->session_id;

Takes no arguments. Returns component's session ID.

=head2 C<shutdown>

    $poco->shutdown;

Takes no arguments. Shuts down the component.

=head1 ACCEPTED EVENTS

=head2 C<run>

    $poe_kernel->post( pause => run => {
            event       => 'event_for_output',
            method      => 'clean_up',
            args        => [ [ qw/POE-Component-WWW-DoctypeGrabber-0.0101/ ] ],
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Instructs the component to run a specified method on L<WWW::PAUSE::CleanUpHomeDir>
object. Takes a hashref as an argument, the possible keys/value of that hashref are as follows:

=head3 C<event>

    { event => 'results_event', }

B<Mandatory>. Specifies the name of the event to emit when results are
ready. See OUTPUT section for more information.

=head3 C<method>

    { method => 'clean_up', }

B<Mandatory>. Takes a string as a value that must be the name of a valid method that
a L<WWW::PAUSE::CleanUpHomeDir> object has. See documentation for L<WWW::PAUSE::CleanUpHomeDir>
for more details.

=head3 C<args>

    { args => [ [ qw/POE-Component-WWW-DoctypeGrabber-0.0101/ ] ],}

B<Optional>. Takes an arrayref as a value, this arrayref will be dereferenced directly into
the arguments for the method you specified in as C<method> (see above). B<Defaults to:>
empty list.

=head3 C<session>

    { session => 'other' }

    { session => $other_session_reference }

    { session => $other_session_ID }

B<Optional>. Takes either an alias, reference or an ID of an alternative
session to send output to.

=head3 user defined

    {
        _user    => 'random',
        _another => 'more',
    }

B<Optional>. Any keys starting with C<_> (underscore) will not affect the
component and will be passed back in the result intact.

=head2 C<shutdown>

    $poe_kernel->post( pause => 'shutdown' );

Takes no arguments. Tells the component to shut itself down.

=head1 OUTPUT

    $VAR1 = {
        'args' => [
            [
                'POE-Component-WWW-DoctypeGrabber-0.0101'
            ]
        ],
        'method' => 'clean_up',
        'result' => [
            'POE-Component-WWW-DoctypeGrabber-0.0101.tar.gz',
            'POE-Component-WWW-DoctypeGrabber-0.0101.meta',
            'POE-Component-WWW-DoctypeGrabber-0.0101.readme'
        ],
        '_blah' => 'foos'
    };

The event handler set up to handle the event which you've specified in
the C<event> argument to C<run()> method/event will recieve input
in the C<$_[ARG0]> in a form of a hashref. The possible keys/value of
that hashref are as follows:

=head2 C<result>

    {
        'result' => [
            'POE-Component-WWW-DoctypeGrabber-0.0101.tar.gz',
            'POE-Component-WWW-DoctypeGrabber-0.0101.meta',
            'POE-Component-WWW-DoctypeGrabber-0.0101.readme'
        ],
    }

The C<result> key will contain the return value of whatever method you executed.

=head2 C<error>

    {
        'error' => 'Network error: 500 timeout',
    }

If an error occured the C<error> key will be present and its value will be the error message
describing the failure.

=head2 C<method> and C<args>

    {
        'args' => [
            [
                'POE-Component-WWW-DoctypeGrabber-0.0101'
            ]
        ],
        'method' => 'clean_up',
    }

The C<method> and C<args> keys will contain whatever you set them to in the C<run()>
event/method. Note that if you don't set the C<args> key in the C<run()> event/method, it
won't be present in the result.

=head2 user defined

    { '_blah' => 'foos' }

Any arguments beginning with C<_> (underscore) passed into the C<run()>
event/method will be present intact in the result.

=head1 SEE ALSO

L<POE>, L<WWW::PAUSE::CleanUpHomeDir>

=head1 AUTHOR

'Zoffix, C<< <'zoffix at cpan.org'> >>
(L<http://zoffix.com/>, L<http://haslayout.net/>, L<http://zofdesign.com/>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-poe-component-www-pause-cleanuphomedir at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POE-Component-WWW-PAUSE-CleanUpHomeDir>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POE::Component::WWW::PAUSE::CleanUpHomeDir

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Component-WWW-PAUSE-CleanUpHomeDir>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POE-Component-WWW-PAUSE-CleanUpHomeDir>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POE-Component-WWW-PAUSE-CleanUpHomeDir>

=item * Search CPAN

L<http://search.cpan.org/dist/POE-Component-WWW-PAUSE-CleanUpHomeDir>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 'Zoffix, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

