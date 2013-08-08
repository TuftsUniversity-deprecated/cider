package CIDER::User;

use Moose;
use Carp qw( croak );

extends qw( Catalyst::Authentication::Store::LDAP::User );

has 'db_user' => (
    is => 'rw',
    handles => [qw( id )],
);

has 'context' => (
    is => 'rw',
);

# Overload of C::A::S::L::User's AUTOLOAD. Tries to run the given method against our
# stored db-user object, if we have one.
sub AUTOLOAD {
    my $self = shift;

    ( my $method ) = ( our $AUTOLOAD =~ /([^:]+)$/ );

    if ( $method eq "DESTROY" ) {
        return;
    }
    elsif ( $self->db_user && $self->db_user->can( $method ) ) {
        return $self->db_user->$method( @_ );
    }
    elsif ( my $attribute = $self->has_attribute($method) ) {
        return $attribute;
    }
    else {
        Catalyst::Exception->throw(
            "No attribute $method for User " . $self->stringify );
    }
}

# We modify the constructor method to store the Catalyst context after construction.
around 'new' => sub {
    my $orig = shift;
    my $class = shift;
    my ( $store, $user, $c ) = @_;

    my $self = $class->$orig( @_ );

    if ( $self ) {
        $self->context( $c );
        $self->db_user( $self->_build_db_user );

        return $self;
    }
    else {
        # Special case: if $self is undefined, then we have an out-of-date login.
        # Force a refresh.

        $c->logout;
        $c->response->redirect( $c->uri_for( '/' ) );
    }
};

sub _build_db_user {
    my $self = shift;

    my $db_user =  $self->context->model( 'CIDERDB::User' )
                        ->search( { username => $self } )
                        ->single;

    unless ( $db_user ) {
        croak "DB ERROR: The current user is logged in via LDAP as $self, but there "
              . "doesn't appear to be any such username in the CIDER database.";
    }

    return $db_user;
}

__PACKAGE__->meta->make_immutable;

1;
