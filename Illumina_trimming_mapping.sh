### Trim paired end sequencing reads from Illumina using Trimgalore (https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
parallel --xapply trim_galore --illumina --paired --fastqc -o trim_galore/ ::: *_R1.fastq.gz ::: *_R2.fastq.gz

### Bin reads into respective hosts using bbsplit.sh (https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/)
for indv in pool1 pool2 pool3
do
bbsplit.sh in1=${indv}_1_val_1.fq.gz in2=${indv}_2_val_2.fq.gz ref=Bos_taurus.fna,Can_lupus_familiaris.fna,Cap_hircus.fna,Cro_crocutta.fasta,Gir_camelopardalis.fasta,Glo_pallidipes.fna,Hom_sapiens.fna,Hya_hyaena.fna,Lox_africana.fna,Pha_africanus.fna,Syn_caffer.fna basename=${indv}%.fq outu1=clean1.fq outu2=clean2.fq
done

### Map binned reads to respective genomes using minimap2 (https://github.com/lh3/minimap2)
for species in Bos_taurus Can_lupus_familiaris Cap_hircus Cro_crocutta Gir_camelopardalis Glo_pallidipes Hom_sapiens Hya_hyaena Lox_africana Pha_africanus Syn_caffer
do 
minimap2 -a ${species}.fna pool1_${species}.fq > pool1_${species}.sam
done

### convert sam to bam file and sort reads using samtools v1.9
for file in *.sam
do
base=$(basename ${file} .sam)
samtools view -q 30 -u ${base}.sam | samtools sort -o ${base}.bam &
done

### for merging files from mutliple sequencing runs of the same library
for species in Bos_taurus Can_lupus_familiaris Cap_hircus Cro_crocutta Gir_camelopardalis Glo_pallidipes Hom_sapiens Hya_hyaena Lox_africana Pha_africanus Syn_caffer
do 
samtools merge Tsetse_P4_${species}_merged.bam Tsetse_P4_L1_${species}.bam Tsetse_P4_L4_${species}.bam & 
done

### markduplicates
for file in *_merged.bam
do
samtools markdup ${file} MD_${file} &
done
