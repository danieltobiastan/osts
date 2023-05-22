#!/bin/bash
# Done by: Daniel Tan (22684196)

if [[ -z $1 ]]
then 
	1>&2 echo "Filename is missing, check inputs"
	exit 2

elif [[ ! -f $1 ]] # check if the file exists in the directory given
then
    1>&2 echo "The tsv/csv file is not found, check inputs"
    exit 1

elif [[ $# -ne 1 ]] # check if exactly 1 input given
then
	1>&2 echo "Please only input 1 argument"
	exit 1

else
	file=$1

	# take in the relevant columns from the file, discard the headers, in this case, month number 
	months=$(awk -F "\t" '{print $6}' $file)
	# sort the months, then count the number of occurances in each unique month, take out any numbers that are not in range of 1-12 and regex out any non-integers
	sorted_months=$(echo "$months" | awk '/^[0-9]*$/, $1 >= 1 && $1 < 13 {print $1}' | tail -n+2 | sort -n | uniq -c)

	# take the months with counts, sort for median and MAD calculations
	sorted_counts=$(echo "$sorted_months" | awk '{print $1}' | sort -n)
	# median calculation
	median=$(echo "$sorted_counts" | awk '{a[NR]=$1}
	END {if (NR % 2) 
		{print a[(NR+1)/2]} 
		else 
		{print (a[NR/2] + a[NR/2+1])/2}}')
	# using the median to calculate median deviation
	med_dev=$(echo "$sorted_months" | awk -v med=$median '{print sqrt(($1-med)^2)}' | sort -n)
	# calculate the MAD
	mad=$(echo "$med_dev" | awk '{a[NR]=$1}
	END {if (NR % 2) 
		{print a[(NR+1)/2]} 
		else 
		{print (a[NR/2] + a[NR/2+1])/2}}')

	# main program to output months (create array and upper lower median bounds)
	# also creates a dictionary to map month number to abbreviation
	# also adds the upper median and lower median variable that we have calculated to check against the values
	main=$(echo "$sorted_months" | awk -v median=$median -v mad=$mad 'BEGIN{months[1]="Jan"; months[2]="Feb"; months[3]="Mar";months[4]="Apr";months[5]="May";months[6]="Jun";months[7]="Jul";months[8]="Aug";months[9]="Sep";months[10]="Oct";months[11]="Nov";months[12]="Dec";upper_median=median+mad; lower_median=median-mad}

{if ($1 > upper_median)
	{print months[$2]"\t"$1"\t""++"}
else if ($1 < lower_median)
	{print months[$2]"\t"$1"\t""--"}
else 
	{print months[$2]"\t"$1}}')	
	echo "$main"
fi

