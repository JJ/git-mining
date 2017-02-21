#!/usr/bin/env perl

=head1 NAME

get-author-files.pl - download social graph stats from a github repo

=head1 SYNOPSIS

Creates a series of network files from a repository by extracting information from commits. 

=head1 SEE ALSO

Check out L<http://github.com/JJ/literaturame>, for some results, generated reports, R files for analyzing them, and so on. I would be grateful if you added your results to the L<https://github.com/JJ/literaturame/blob/master/data.md> file via pull request.

=cut

use strict;
use warnings;

use v5.20;

use Git;
use Net::GitHub::V3;
use File::Slurp::Tiny qw(write_file read_file);
use SNA::Network;

my $dir = shift || ".";
my ($repo_name)  = ($dir =~ m{/([^/]+)/?$} );
my $repo = Git->repository (Directory => $dir);
my @these_revs = `cd $dir; git rev-list --all`;

my $commit_net = SNA::Network->new();
my %commit_nodes;
my %extensions;
my $time = 1;
say "id0 id1 time";
for my $commit ( reverse @these_revs ) {
  chop $commit;
  my $commit_info = $repo->command('show', '--pretty=fuller', $commit);
  my @files = ($commit_info =~ /\+\+\+\s+b\/(.+)/g);
  for (my $i = 0; $i <= $#files; $i++ ) {
    my $f = $files[$i];
    my $this_ext = extension( $f );
    if ( !$commit_nodes{$f} ) {
      my $this_node = $commit_net->create_node( name => "\"$f\"" );
      $commit_nodes{$f} = $this_node;
    }
    if ( $i < $#files ) {
      for ( my $j = $i+1; $j<=$#files; $j++ ) {
	my $that_ext = extension( $files[$j]);
	if ( !$commit_nodes{$files[$j]} ) {
	  my $this_node = $commit_net->create_node( name => "\"$files[$j]\"" );
	  $commit_nodes{$files[$j]} = $this_node;
	}
	create_update_edge_extensions( \%extensions, $this_ext, $that_ext );
	$commit_net->create_edge( source_index => $commit_nodes{$f}->{'index'},
				  target_index => $commit_nodes{$files[$j]}->{'index'});
	say "$f $files[$j] $time";
      }
    }
  }
  $time++;
}

write_extension_file( $repo_name, \%extensions);
write_correct_file( $commit_net, "commit", $repo_name  );

# Hack for avoiding errors in Pajek file and writing two files.
sub write_correct_file {
    my ($net, $name, $repo_name) = @_;
    $net->calculate_authorities_and_hubs();
    $net->calculate_betweenness;
    $net->save_to_pajek_net("$name-$repo_name.net");
    my $net_file = read_file( "$name-$repo_name.net" );
    $net_file =~ s/\*Arcs/*arcs/;
    write_file("$name-$repo_name.net", $net_file);
    $net->save_to_gdf(filename => "$name-$repo_name.gdf",  node_fields => ['betweenness','authority','hub'] );
  }

# Work with extensions
sub write_extension_file {
  my $repo = shift;
  my $hash = shift;;
  my %nodes;
  my $extension_net = SNA::Network->new();
  for my $k ( keys %$hash ) {
    if (!$nodes{$k} ) {
      $nodes{$k} = $extension_net->create_node( name => "\"$k\"" );
    }
    for my $j ( keys %{$hash->{$k}} ) {
      if (!$nodes{$j} ) {
	$nodes{$j} = $extension_net->create_node( name => "\"$j\"" );
      }
      $extension_net->create_edge( source_index => $nodes{$k}->{'index'},
				   target_index => $nodes{$j}->{'index'},
				   weight => $hash->{$k}{$j});
    }
  }
  write_correct_file( $extension_net, "extensions", $repo );
}

#Extract extension
sub extension {
  my $f = shift;
  my ($this_ext) = ( $f =~ /\.(\w+)$/ );
  return $this_ext || "Ø";
}

#Create or add to edge
sub create_update_edge_extensions {
  my $network = shift;
  my $this_node = shift;
  my $that_node = shift;
  if ( $this_node gt $that_node ) { #lexicographical order
    my $temp = $this_node;
    $this_node = $that_node;
    $that_node = $temp;
  }
  $network->{$this_node}{$that_node}++;
  
}
