#!/usr/bin/env perl

use strict;
use warnings;

use v5.20;

use Net::GitHub::V3;
use Search::Elascticsearch;


# Process args
my $repo = shift || die "Need a repository author/repo-name";
my $dir = shift || "/home/jmerelo/Code/literaturame"; # Repo for download

my ($user, $repo_name) = split("/", $repo);

# Connect to API
my $gh = Net::GitHub::V3->new( access_token => $ENV{'GH_TOKEN'} );
my $repos = $gh->repos;
my $users = $gh->user;

my @contributors =  $repos->contributors($user,$repo_name);

while ( $repos->has_next_page ) {
  push @contributors, $repos->next_page;
}


my $es = Search::Elasticsearch->new();
for my $c ( @contributors ) {
  my $user_info = $users->show($c->{'login'});
  $es->index(
	     index   => "repo-$repo",
	     type    => 'user',
	     id      => $c->{'login'},
	     body    => $user_info
	    );
  say $user_info;
}
