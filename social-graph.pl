#!/usr/bin/env perl

=head1 NAME

social-graph.pl - Download social graph stats from a github repo and store them in Elastic Search

=head1 SEE ALSO

Check out L<http://github.com/JJ/literaturame>, for some results, generated reports, R files for analyzing them, and so on. I would be grateful if you added your results to the L<https://github.com/JJ/literaturame/blob/master/data.md> file via pull request.

=cut
use strict;
use warnings;

use v5.20;

use Net::GitHub::V3;
use Search::Elasticsearch;

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
my $es_indices = $es->indices();
my $index = $repo;
$index =~ s!/!-!;

if ( !$es_indices->exists( index=> $index ) ) {
  $es->indices->create(index=> $index);
}
if ( !$es_indices->exists( index=> "all-users" ) ) {
  $es->indices->create(index=> "all-users");
}

for my $c ( @contributors ) {

  my %this_user = ( index => 'all-users',
		    type => 'user',
		    id => $c->{'login'} );
  # Check global index
  my $user_info;
  if ( $es->exists( %this_user ) ) {
    $user_info = $es->get( %this_user );
  }  else {
    $user_info = $users->show($c->{'login'});
    $es->index(
	       index   => "all_users",
	       type    => 'user',
	       id      => $c->{'login'},
	       body    => $user_info
	      );
  }
  
  $es->index(
	     index   => $index,
	     type    => 'user',
	     id      => $c->{'login'},
	     body    => $user_info
	    );
  
  say $user_info;
}
