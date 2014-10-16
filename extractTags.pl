#!/usr/bin/perl
#From http://www.unix.com/shell-programming-and-scripting/159513-how-get-all-xml-tags-perl.html#post302521394

use XML::Simple;

use strict;
use warnings;


$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: extractTags.pl $fileName\n";
    exit;
}

my $xml_src=XMLin($ARGV[0]);
my @tags = extract_tags($xml_src);
print "@tags\n";


sub extract_tags{
    my $xml_src=shift;
    my (@tags, %tags);
    for my $key (keys %{$xml_src}){
        $tags{$key}++;
        if (ref($xml_src->{$key}) eq 'HASH'){
            map {$_++;} @tags{extract_tags($xml_src->{$key})}
        }
    }
    push @tags , keys %tags;
    return @tags;
}
