#!/usr/bin/perl 
#
# Copyright (c) 2014 Genome Research Ltd.
#
# Author: Joshua C. Randall <jcrandall@alum.mit.edu>
#
# This file is part of HGI-RT.
#
# HGI-RT is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use warnings;

use AppConfig;

use Data::Dumper;


my $config = AppConfig->new( 
    {
	CASE => 0, # conf variables not case sensitive
	CREATE => 0, # don't create undefined variables automatically
	PEDANTIC => 1, # exit immediately on error
	GLOBAL => {
	    DEFAULT => "<undef>",
	    ARGCOUNT => AppConfig::ARGCOUNT_ONE,
	    EXPAND => AppConfig::EXPAND_VAR,
	},
    },
    "rt_url" => {
	DEFAULT => 'http://rt.example.com/',
    },
    "rt_username",
    "rt_password", 
    "rt_query" => {
	ARGCOUNT => AppConfig::ARGCOUNT_LIST, 
	DEFAULT => "Owner='Nobody' AND ( Status = 'new' OR Status = 'open' )", 
    },
    "debug" => {
	ARGCOUNT => AppConfig::ARGCOUNT_NONE,
	DEFAULT => "0",
    },
    );

my @try_config_files = ( "/etc/rt_agent.cfg", "$ENV{HOME}/.rt_agent" );
my @config_files = grep { -r $_ } @try_config_files;
foreach my $config_file (@config_files) {
    $config->file($config_file);
}
$config->getopt();

my $debugp = sub { };
if($config->debug() != 0) {
    $debugp = sub {
	my $msg = shift;
	print STDERR $msg."\n";
    };
    $debugp->("debug printing enabled");
}

$debugp->("loaded config from: ".join(',',@config_files));

use Error qw(:try);

use RT::Client::REST;

my $url = $config->rt_url();
$debugp->("creating RT REST Client for $url");
my $rt = RT::Client::REST->new(
    server => $url,
    timeout => 30,
    );

$debugp->("logging in to RT");
try {
    $rt->login(username => $config->rt_username(), password => $config->rt_password());
} catch Exception::Class::Base with {
    die "Problem logging in to ", $rt->server(), " as user ", $config->rt_username(), ": ", shift->message;
};

my $queries = $config->rt_query();
$debugp->("have ".scalar(@{$queries})." queries");
my %idp;
foreach my $query (@{$queries}) {
    my @ids;
    $debugp->("searching for: [".$query."]");
    try {
	@ids = $rt->search(
	    type => 'ticket',
	    query => $query,
	    );
    } catch RT::Client::REST::UnauthorizedActionException with {
	print "You are not authorized to perform the ticket search\n";
    } catch RT::Client::REST::Exception with {
	# something went wrong.
    };
    $debugp->("have ".scalar(@ids)." results: ".join(',',@ids));
    foreach my $id (@ids) {
	$idp{$id} = 1;
    }
}

my @ticket_ids = sort {$a cmp $b} keys %idp;
$debugp->("have ".scalar(@ticket_ids)." unique tickets: ".join(',',@ticket_ids));
foreach my $id (@ticket_ids) {
    my $ticket;
    $debugp->("getting information for id $id");
    try {
	($ticket) = $rt->show(type => 'ticket', id => $id);
    } catch RT::Client::REST::UnauthorizedActionException with {
	print "You are not authorized to view ticket #$id\n";
    } catch RT::Client::REST::Exception with {
	# something went wrong.
    };
    print Dumper($ticket);
}

    
