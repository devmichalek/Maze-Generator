package Wall;
use strict;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->setType($args{type});
    return $self;
}

sub setType() {
    my ($self, $value) = @_;
    $self->{type} = $value;
    return;
}

sub getType() {
    my ($self) = @_;
    return $self->{type};
}

return 1;