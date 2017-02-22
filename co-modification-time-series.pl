#!/usr/bin/env perl

=head1 NAME

get-author-files.pl - download social graph stats from a github repo

=head1 SYNOPSIS

Creates a series of network files from a repository by extracting information from commits. 

=head1 SEE ALSO

Check out L<http://github.com/JJ/literaturame>, for some results, generated reports, R files for analyzing them, and so on. I would be grateful if you added your results to the L<https://github.com/JJ/literaturame/blob/master/data.md> file via pull request.

=cut

use lib qw( /home/jmerelo/Code/CPAN/perl-git-commit/lib );

use strict;
use warnings;

use v5.20;

use Git::Repo::Commits;
use File::Slurp::Tiny qw(write_file read_file);

my $dir = shift || ".";
my $commits = new Git::Repo::Commits $dir;

my %commits_by_author;
my @number_of_files;
my %commits_per_file;

for my $commit ( @{$commits->commits()} ) {
  my @files = @{$commit->{'files'}};
  for my $f (@files ) {
    $commits_per_file{$f}++;
  }
  push @number_of_files, scalar @files;
  $commits_by_author{$commit->{'author'}}++;
}

my $repo_name = $commits->name();
my $writable = join("\n", ("Number.of.files",@number_of_files));
write_file("$repo_name-files-per-commit.csv", $writable);
my @ranked_authors = sort { $commits_by_author{$b} <=>  $commits_by_author{$a} } keys %commits_by_author;
$writable = "author,commits\n";
for my $a ( @ranked_authors ) {
  $writable .= "$a, $commits_by_author{$a}\n";
}
write_file("$repo_name-commits_per_author.csv", $writable );

my @ranked_files = sort { $commits_per_file{$b} <=>  $commits_per_file{$a} } keys %commits_per_file;
$writable = "file,commits\n";
for my $a ( @ranked_files ) {
  $writable .= "$a, $commits_per_file{$a}\n";
}
write_file("$repo_name-commits_per_file.csv", $writable  );
