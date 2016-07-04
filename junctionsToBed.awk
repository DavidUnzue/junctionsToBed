#!/bin/sh

#########
# Converts STAR Chimeric alignments from a Chimeric.out.junction file into a BED12 file.
# Author: David Unzué, david.unzue@brain.mpg.de
#########

awk '
BEGIN {
  OFS="\t";
};
{
  donor_cigar_length = 0;
  i = 0;
  shift = 1;
  # use gsub to count occurrences of Ms in cigar string
  # for each occurrence, get the length and add to total
  while(i < gsub("M","M",$12)) {
    # subsequently shift the string in order to match the next M occurrence
    cigar_string = substr($12, shift);
    match(cigar_string, /[0-9]+M/);
    # get the values before the M using RSTART and RLENGTH set by match function before
    donor_cigar_length += substr(cigar_string, RSTART, RLENGTH - 1);
    # update shifting value
    shift += RSTART+RLENGTH-1;
    # increase loop index by one
    i++;
  }

  acceptor_cigar_length = 0;
  i = 0;
  shift = 1;
  while(i < gsub("M","M",$14)) {
    cigar_string = substr($14, shift);
    match(cigar_string, /[0-9]+M/);
    acceptor_cigar_length += substr(cigar_string, RSTART, RLENGTH - 1);
    shift += RSTART+RLENGTH-1;
    i++;
  }

  if (donor_cigar_length > 0 && acceptor_cigar_length > 0) {

    if ($1 != "chrM" && $1 != "chrX") {
	    if ($3 == "+" && $6 == "+" && $2 > $5) {

	      chrom_start = $13-1; # -1 in order to transform STAR positions (1-based) into BED positions (0-based)
	      chrom_end = $11-1+donor_cigar_length;

	      print $1, chrom_start, chrom_end , $10, 0, $3, chrom_start, chrom_end, 0, 2, acceptor_cigar_length","donor_cigar_length, 0","$11-1-chrom_start;

	    } else if ($3 == "-" && $6 == "-" && $2 < $5) {

	      chrom_start = $11-1;
	      chrom_end = $13-1+acceptor_cigar_length;

	      print $1, chrom_start, chrom_end, $10, 0, $3, chrom_start, chrom_end, 0, 2, donor_cigar_length","acceptor_cigar_length, 0","$13-1-chrom_start;

	    }
    }

  } else {
    print "Error on CIGAR search";
  }

};
' "$@"
