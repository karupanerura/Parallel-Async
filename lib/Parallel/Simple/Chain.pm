package Parallel::Simple::Chain;
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
    local $Parallel::Simple::Task::WANTARRAY = 1;
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

=head1 METHODS

=over

=item my @results = $chain->recv(@args)

Execute tasks on child processes and wait for receive return values.

    # create new task
    my $task_add = async_task {
        my ($x, $y) = @_;
        return $x + $y;
    };
    my $task_sub = async_task {
        my ($x, $y) = @_;
        return $x - $y;
    };
    my $task_times = async_task {
        my ($x, $y) = @_;
        return $x * $y;
    };

    my $chain = $task_add->join($task_sub)->join($task_times);
    my ($res_add, $res_sub, $res_times) = $chain->recv(10, 20);
    say $res_add->[0];   ##  30
    say $res_sub->[0];   ## -10
    say $res_times->[0]; ## 200

=item my @pids = $chain->run(@args)

Execute tasks on child processes.

    # create new task
    my $task_add = async_task {
        my ($x, $y) = @_;
        return $x + $y;
    };
    my $task_sub = async_task {
        my ($x, $y) = @_;
        return $x - $y;
    };
    my $task_times = async_task {
        my ($x, $y) = @_;
        return $x * $y;
    };

    my @pids = $task->run(10, 20);

=item $chain->join($task1, ...);

Join multiple tasks, like L<Parallel::Simple::Task>#join.

=item $task->reset;

Reset the execution status of all tasks, like L<Parallel::Simple::Task>#reset.

=item $task->clone;

Clone and reset the execution status of all tasks, like L<Parallel::Simple::Task>#clone.

=back

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

