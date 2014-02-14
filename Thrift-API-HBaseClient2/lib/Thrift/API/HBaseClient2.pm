package Thrift::API::HBaseClient2;

use 5.10.0;
use strict;
use warnings FATAL => 'all';

our $VERSION = '0.01';

use Moo;
use Carp;

use Moo;

use Thrift;
use Thrift::Socket;
use Thrift::BufferedTransport;

use Thrift::API::HBaseClient2::THBaseService;

has use_xs  => (
    is      => 'rwp',
    default => sub { 0 },
    lazy    => 1,
);

has host => (
    is      => 'ro',
    default => sub {'localhost'},
);
has port    => (
    is      => 'ro',
    default => sub { 9090 },
);

has timeout => (
    is      => 'rw',
    default => sub { 3_600 },
);


has _socket => ( is => 'rwp' );
has _transport => ( is => 'rwp' );
has _protocol  => ( is => 'rwp' );
has _client    => ( is => 'rwp' );

sub _set_socket { $_[0]->{_socket} = $_[1] }
sub _set_transport { $_[0]->{_transport} = $_[1] }
sub _set_protocol  { $_[0]->{_protocol}  = $_[1] }
sub _set_client { $_[0]->{_client}    = $_[1] }

sub BUILD {
    my $self = shift;

    $self->_set_socket(
            Thrift::Socket->new( $self->host, $self->port )
        ) unless $self->_socket;

    $self->_set_transport(
            Thrift::BufferedTransport->new( $self->_socket )
        ) unless $self->_transport;

    $self->_set_protocol(
            $self->_init_protocol( $self->_transport )
        ) unless $self->_protocol;

    $self->_set_client(
            Thrift::API::HBaseClient2::THBaseServiceClient->new(
                $self->_protocol
            )
        ) unless $self->_client;
}

sub _init_protocol {
    my $self = shift;
    my $err;

    my $protocol = $self->use_xs and eval {
        $self->use_xs
            && require Thrift::XS::BinaryProtocol;
        Thrift::XS::BinaryProtocol->new( $self->_transport );
    } or do { $err = $@; 0 };

    $protocol ||= do {
            $self->_set_use_xs( 0 );
            
            require Thrift::BinaryProtocol;
            Thrift::BinaryProtocol->new( $self->_transport );
        };

    return $protocol;
}

sub connect {
    my ($self) = @_;
    $self->_socket->setRecvTimeout($self->timeout * 1000);
    $self->_transport->open;
}

sub list {
    my $self = shift;

    my $get = Thrift::API::HBaseClient2::TGet->new({row => '880723-88072301'});

    my $res;
    eval { $res = $self->_client->gets('b_roomhotel',$get); 1 } or do {
        $res = $@;
    };
    print STDERR "Not here\n";

    if ( $res->isa('TApplicationException') ) {
        print STDERR "exception: ",$res->getMessage(),"\n";
    } else {
        use Data::Dumper;
        print STDERR Dumper($res);
    }
}

sub scan {
    my $self = shift;

#     my $scan = $self

    my @res = $self->_client->getTableNames();

    print STDERR Dumper(\@res);
}

1; # End of Thrift::API::HBaseClient2

__END__

=head1 NAME

Thrift::API::HBaseClient2 - The great new Thrift::API::HBaseClient2!

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Thrift::API::HBaseClient2;

    my $foo = Thrift::API::HBaseClient2->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head1 AUTHOR

Bosko Devetak C<< bdevetak@cpan.org> >>
Marco Neves C<< <neves at cpan.org >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-thrift-api-hbaseclient2 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Thrift-API-HBaseClient2>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Thrift::API::HBaseClient2


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Thrift-API-HBaseClient2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Thrift-API-HBaseClient2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Thrift-API-HBaseClient2>

=item * Search CPAN

L<http://search.cpan.org/dist/Thrift-API-HBaseClient2/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Bosko Devetak, Marco Neves.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
