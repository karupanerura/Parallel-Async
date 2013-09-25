package Parallel::Async::Chain;
use 5.008005;
use strict;
use warnings;

use Class::Accessor::Lite rw => [qw/tasks/];
use POSIX ":sys_wait_h";

sub join :method {
    my $self = shift;
    $self = bless +{ tasks => [] } => $self unless ref $self;

    push @{ $self->{tasks} } => @_;

    return $self;
}

sub recv :method {
    my $self = shift;

    no warnings 'once';
    local $Parallel::Async::Task::WANTARRAY = 1;
    use warnings 'once';

    my @pids = map { $_->run } @{ $self->{tasks} };

    $self->_wait(@pids);

    return map { $_->read_child_result() } @{ $self->{tasks} };
}

sub _wait {
    my $self = shift;
    my %pids = map { $_ => 1 } @_;

    while (%pids) {
        my $pid = waitpid(-1, WNOHANG);
        last if $pid == -1;

        delete $pids{$pid} if exists $pids{$pid};
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Parallel::Async::Chain - task chain tool for Parallel::Async

=head1 SYNOPSIS

    use Parallel::Async;
    use Parallel::Async::Chain;

    my $task1 = async {
        print "[$$] start!!\n";
        my $msg = "this is run result of pid:$$. (task1)"; # MSG1
        return $msg;
    };

    my $task2 = async {
        print "[$$] start!!\n";
        my $msg = "this is run result of pid:$$. (task2)"; # MSG1
        return $msg;
    };

    my $chain = Parallel::Async::Chain->join($task1, $task2);

    my ($msg1, $msg2) = $chain->recv;
    say $msg1->[0]; # same as MSG1
    say $msg2->[0]; # same as MSG2

or

    my ($msg1, $msg2) = $task1->join($task2)->recv;
    say $msg1->[0]; # same as MSG1
    say $msg2->[0]; # same as MSG2


=head1 DESCRIPTION

Parallel::Async::Chain is task chain tool for L<Parallel::Async>;

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

