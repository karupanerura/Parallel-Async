# NAME

Parallel::Async - It's new $module

# SYNOPSIS

    use Parallel::Async;

    my $task = async {
        print "[$$] start!!\n";
        my $msg = "this is run result of pid:$$."; # MSG
        return $msg;
    };

    my $msg = $task->recv;
    say $msg; # same as MSG

# DESCRIPTION

Parallel::Async is ...

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
