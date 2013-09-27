package Parallel::Simple;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use parent qw/Exporter/;
our @EXPORT = qw/async_task/;

use Parallel::Simple::Task;
our $TASK_CLASS = 'Parallel::Simple::Task';

sub async_task (&) {## no critic
    my $code = shift;
    return $TASK_CLASS->new(code => $code);
}

1;
__END__

=encoding utf-8

=head1 NAME

Parallel::Simple - run parallel task with fork to simple.

=head1 SYNOPSIS

    use Parallel::Simple;

    my $task = async_task {
        print "[$$] start!!\n";
        my $msg = "this is run result of pid:$$."; # MSG
        return $msg;
    };

    my $msg = $task->recv;
    say $msg; # same as MSG

=head1 DESCRIPTION

Parallel::Simple is yet another fork tool.
Run parallel task with fork to simple.

See also L<Parallel::Simple::Task> for more usage.

=head1 SEE ALSO

L<Parallel::ForkManager> L<Parallel::Prefork>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut
