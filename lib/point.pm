package Point;
use strict;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->setX($args{x});
    $self->setY($args{y});
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

return 1;