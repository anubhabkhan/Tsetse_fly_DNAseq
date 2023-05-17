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
