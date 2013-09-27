use strict;
use warnings;

use Test::More;
use Test::SharedFork;

use Parallel::Simple;

sub new_task {
    return async_task {
        note $$;
        return wantarray ? ($$, $$) : [$$, $$, $$];
    };
}

subtest 'scalar context' => sub {
    my $task = new_task;
    my $ret = $task->recv();
    is_deeply $ret, [$task->child_pid, $task->child_pid, $task->child_pid];
};

subtest 'list context' => sub {
    my $task = new_task;
    my @ret = $task->recv();
    is_deeply \@ret, [$task->child_pid, $task->child_pid];
};

done_testing;
