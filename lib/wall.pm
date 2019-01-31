package Wall;
use strict;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->setX($args{x});
    $self->setY($args{y});
    $self->setType($args{type});
    return $self;
}

sub setX() {
    my ($self, $value) = @_;
    $self->{x} = $value;
    return;
}

sub setY() {
    my ($self, $value) = @_;
    $self->{y} = $value;
    return;
}

sub getY() {
    my ($self) = @_;
    return $self->{y};
}

sub getX() {
    my ($self) = @_;
    return $self->{x};
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