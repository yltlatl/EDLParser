*************** Fix_EDL.pl *************
Fix_EDL.pl takes an EDL file and modifies it to replace the truncated source file name on the numbered line for each record and replace it with a source file name fitting the pattern XX_XXX0000. Whether the source file name matches the pattern or no, if it is longer than 10 characters it is truncated. If it is shorter than 10 characters it is used as-is. The number of spaces in the line is adjusted to keep the overall line length the same as other lines in the file.

USAGE
./Fix_EDL.pl [name of EDL file]

The output file will be named [name of EDL file]_output.txt.

*************** EDLQC.PL ****************

EDLQC.pl takes the output of Fix_EDL.pl and runs three checks against the modified lines: 1) line lengths greater than 80 characters; 2) an incorrect number of elements in the line; and 3) whether the time codes are in the correct position relative to the overall line.

USAGE
./EDLQC.pl [named of original EDL file]_output.txt

The results are reported in the terminal. Note that source file names containing spaces will generate false positives for test number 2.

*************** Parse_EDL.pl *************

Parse_EDL.pl takes only the lines that begin with a number in each record and throws away the rest. It also calculates the duration of the clip. The output is formatted as CSV rather than EDL.

USAGE
./Parse_EDL.pl [name of EDL file]

The output file will be named [name of EDL file]_output.csv.