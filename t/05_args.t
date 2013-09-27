use strict;
use warnings;

use Test::More;

use Parallel::Async;

my $task = async {
    note $$;
    return (@_, $$);
};

my @res = $task->recv(1, 2, 3);
is_deeply \@res, [1, 2, 3, $task->child_pid];

$task->reset;

@res = $task->recv(4, 5, 6);
is_deeply \@res, [4, 5, 6, $task->child_pid];

done_testing;

