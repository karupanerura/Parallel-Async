use strict;
use warnings;

use Test::More;

use Parallel::Simple;

sub new_task {
    return async {
        note $$;
        sleep 1 + int rand 3;
        return $$;
    };
}

my $task1 = new_task();
my $task2 = new_task();
my $task3 = new_task();

my @res = $task1->join($task2)->join($task3)->recv;
is_deeply \@res, [
    [ $task1->child_pid ],
    [ $task2->child_pid ],
    [ $task3->child_pid ],
], 'join';

done_testing;

