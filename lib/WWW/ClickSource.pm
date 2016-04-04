package WWW::ClickSource;

use strict;
use warnings;

use URI;
use WWW::ClickSource::Request;

our $VERSION = 0.1;

=head1 NAME

WWW::ClickSource - Determine the source of a visit on your website : organic, adwords, facebook, referer site

=head1 VERSION

Version 0.1

=head1 DESCRIPTION

Help determine the source of the traffic on your website.

This module tries to do what GoogleAnalytics, Piwik and other monitoring tools do, but it's something you can
use on the backend of your application.

This module can be used together with HTTP::BrowserDetect to get an even deeper understanding of where your 
traffic is generated from.

=head1 METHODS

=head2 new

Creates a new WWW::ClickSource object

=cut
sub new {
    my ($class,%options) = @_;
    
    my $self = \%options;
    
    bless $self, $class;
    
    return $self;
}

=head2 detect_source

Determine where the user came from based on a request object

=cut
sub detect_source {
    my ($self,$user_request) = @_;
    
    my $request = WWW::ClickSource::Request->new($user_request);
    
    my %click_info;
        
    if ( my $params = $request->{params} ) {
        if ( $params->{utm_source} || $params->{utm_campaign} || $params->{utm_medium} ) {
            %click_info = (
                    source => $params->{utm_source} // '',
                    campaign => $params->{utm_campaign} // '',
                    medium => $params->{utm_medium} // '',
            );
            
            if (! $click_info{source} ) {
                if ( $request->{referer} ) {
                    $click_info{source} = $request->{referer}->host;
                }
            }
            
            if ( $click_info{medium} =~ /cpc|cpm|facebook_ads/ ) {
                $click_info{category} = 'paid';
            }
            elsif ( $request->{referer} ){
                $click_info{category} = 'referer';
            }
            else {
                $click_info{category} = 'other';
            }
        }
        elsif ( $request->{referer} && $params->{gclid} && $request->{referer}->host =~ /(?:google\.(?:co\.)?\w{2,3}|googleadservices\.com)$/ ) {
            
            %click_info = (
                    source => 'google',
                    campaign =>  '',
                    medium => 'cpc',
                    category => 'paid',
            );
        }
    }
    
    if (! $click_info{medium} ) {
        if ( $request->{referer} ) {
            
            my $referer_base_url = $request->{referer}->host . $request->{referer}->path;
            
            if ( $referer_base_url =~ /(?:google\.(?:co\.)?\w{2,3}|googleadservices\.com).*?\/aclk/ ) {
            
                %click_info = (
                        source => 'google',
                        campaign =>  '',
                        medium => 'cpc',
                        category => 'paid',
                );
            }
            else {
                %click_info = (
                    source => $request->{referer}->host,
                    category => 'referer',
                );
            }
        }
        else {
            %click_info = (
                medium => '',
                category => 'direct',
            );
        }
    }
    
    if ( $click_info{source} && $click_info{category} eq "referer" && $click_info{source} =~ /(?:www|search\.)?(google|yahoo|bing)\.(?:co\.)?\w{2,3}$/ ) {
        $click_info{source} = $1;
        $click_info{category} = 'organic';
        $click_info{medium} = 'organic';
    }
    
    if ( $click_info{source} && $click_info{source} =~ /(m|www)\.facebook\.com/ ) {
        $click_info{source} = 'facebook.com';
    }
    
    #default to empty strings to avoid undefined value warnings in string comparisons
    $click_info{source} //= '';
    $click_info{campaign} //= '';
    $click_info{medium} //= '';
    $click_info{category} //= '';
    
    return %click_info if wantarray;
    
    return \%click_info;
}

1;

=head1 AUTHOR

Gligan Calin Horea, C<< <gliganh at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-session at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-ClickSource>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::ClickSource


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-ClickSource>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-ClickSource>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-ClickSource>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-ClickSource/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Gligan Calin Horea.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut