use Test::More;

use strict;
use warnings;

use_ok('WWW::ClickSource');

my $click_source = WWW::ClickSource->new();

{
    my %source = $click_source->detect_source({
        'referer' => 'http://m.facebook.com',
        'params' => {},
        'host' => 'mysite.com'
    });
    
    is_deeply(\%source, {
          'source' => 'facebook.com',
          'category' => 'referer',
          'campaign' => '',
          'medium' => '',
        },'Facebook posts, no URL params');      
}

done_testing();