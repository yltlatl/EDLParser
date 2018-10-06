#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;


my $file = $ARGV[0] or die "Pass the name of the EDL to process as an argument to the script.\n";
 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my $currentByte;
my @newLineArray;

#with this approach there is a slight chance we will end up thinking non-adjacent crs/lfs are part of a line ending
#hopefully that chance is minimal
while (read($data,$currentByte,1))
{
    if ($currentByte eq chr 0x0D)
    {
        push @newLineArray, $currentByte;
        next;
    }

    if ($currentByte eq chr 0x0A)
    {
        push @newLineArray, $currentByte;
        last;
    }

}

#set the record delimiter to whatever line breaks we have
$/ = join '', @newLineArray;

my $errorCount = 0;
my $lineCount = 0;

while (my $line = <$data>) {
    $lineCount++;
    my $lineSubstr = substr $line, 0, 10;
    print STDOUT "counter: $. - myCounter: $lineCount - line: $lineSubstr\n";

    if ($line =~ m/^\d{3}/)
    {
        if (length $line > 80)
        {
            print STDOUT "Line length exceeded at line $lineCount\n";
            $errorCount++;
        }

        my @elements = split /\s+/, $line;
        my $elementCount = scalar @elements;
        if (($elementCount < 8) || ($elementCount > 9))
        {
            print STDOUT "Element count violation at line $lineCount\n";
            $errorCount++;
        }

        my $timeCodeSubstr = substr $line, 29;
        if (!($timeCodeSubstr =~ m/\d\d:\d\d:\d\d:\d\d\s\d\d:\d\d:\d\d:\d\d\s\d\d:\d\d:\d\d:\d\d\s\d\d:\d\d:\d\d:\d\d\s/))
        {
            print STDOUT "Time code position violation at line $lineCount\n";
            $errorCount++;
        }
    }
}

print STDOUT "Total errors: $errorCount";