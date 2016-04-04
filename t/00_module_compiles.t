use Test::More tests => 2;

use_ok("WWW::ClickSource","Module compiles");

ok(WWW::ClickSource->new(foo => 'bar'),"Dummy object created");
