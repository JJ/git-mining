#!/usr/bin/env perl

use strict;
use warnings;

use v5.20;

use Net::GitHub::V3;

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
  
for my $c ( @contributors ) {
  my $user_info = $users->show($c->{'login'});
  say $user_info;
}
