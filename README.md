# NAME

Parallel::Simple - run parallel task with fork to simple.

# SYNOPSIS

    use Parallel::Simple;

    my $task = async_task {
        print "[$$] start!!\n";
        my $msg = "this is run result of pid:$$."; # MSG
        return $msg;
    };

    my $msg = $task->recv;
    say $msg; # same as MSG

# DESCRIPTION

Parallel::Simple is yet another fork tool.
Run parallel task with fork to simple.

See also [Parallel::Simple::Task](http://search.cpan.org/perldoc?Parallel::Simple::Task) for more usage.

# SEE ALSO

[Parallel::ForkManager](http://search.cpan.org/perldoc?Parallel::ForkManager) [Parallel::Prefork](http://search.cpan.org/perldoc?Parallel::Prefork)

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
