### Analysis based on scripts presented in https://www.biorxiv.org/content/10.1101/2021.05.28.445945v1.full
### SNPs called using Varscan

### STEP1 create mpileup file to be input to varscan

samtools mpileup --reference reference.fna -q 20 -Q20 -o \
Output.mpileup \
input1.bam \
input2.bam \
input3.bam \
input4.bam \

### STEP2 input the mpileup file to varscan

varscan mpileup2snp Output.mpileup --min-coverage 10 --min-avg-qual 25 --min-var-freq 0.005 --p-value 0.5 --output-vcf 1 --vcf-sample-list vcf_sample_list.txt > Output.vcf

### STEP3 filter for minGQ 30 

less -S BC02_nanopore_illumina.vcf | grep -e "Lox" | awk -F"\t|:" 'NF>39 {print $0}' | awk -F"\t|:" '$24>29 && $38>29 {print $0}' | \

## print allele FREQ and differences in allele FREQ

awk '{print $1"\t"$2"\t"$10"\t"$11}' | awk -F"\t|:" '{print $1"\t"$2"\t"$9"\t"$23}' | sed 's/%//g' | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$3-$4}' | \

## count number of sites differing in allele FREQ estimation of 0.1

awk '$5>-10 && $5<10 {print $0}' | wc -l
