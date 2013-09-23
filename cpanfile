requires 'AnyEvent';
requires 'Class::Accessor::Lite';
requires 'Try::Tiny';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::More';
    requires 'Test::Requires';
    requires 'Test::SharedFork';
};
