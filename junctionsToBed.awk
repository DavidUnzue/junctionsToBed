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
  
  donor_cigar_match = match($12, /[0-9]+M/);
  donor_cigar_length = substr($12, RSTART, RLENGTH - 1);
  acceptor_cigar_match = match($14, /[0-9]+M/);
  acceptor_cigar_length = substr($14, RSTART, RLENGTH - 1);

  if (donor_cigar_match > 0 && acceptor_cigar_match > 0) {
    
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
