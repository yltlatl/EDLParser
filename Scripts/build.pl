#!/bin/bash
pwd
cp Fix_EDL.pl bin
cp EDLQC.pl bin
cp Parse_EDL.pl bin
cp ReadMe.txt bin
cd bin
pwd
zip EDL_utils.zip Fix_EDL.pl EDLQC.pl Parse_EDL.pl ReadMe.txt
rm Fix_EDL.pl
rm EDLQC.pl
rm Parse_EDL.pl
rm ReadMe.txt