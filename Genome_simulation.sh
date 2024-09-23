### create 100bp long fragments of the genome from the assembly
## use seqkit (https://bioinf.shenwei.me/seqkit/) and bbmap suite (https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/)

for species in Bos_taurus Can_lupus_familiaris Cap_hircus Cro_crocutta Glo_pallidipes Hya_hyaena Lox_africana Pha_africanus Hom_sapiens Gir_camelopardalis Syn_caffer
do
seqkit sliding -s 100 -W 100 ${species}.fna -o ${species}_100bp.fa
reformat.sh in=${species}_100bp.fa out=${species}_100bp.fq qfake=40
done

## use bbsplit to assign reads to various genomes

for species in Bos_taurus Can_lupus_familiaris Cap_hircus Cro_crocutta Glo_pallidipes Hya_hyaena Lox_africana Pha_africanus Hom_sapiens Gir_camelopardalis Syn_caffer
do
bbsplit.sh in=${species}_100bp.fq ref=Bos_taurus.fna,Can_lupus_familiaris.fna,Cap_hircus.fna,Cro_crocutta.fna,Gir_camelopardalis.fna,Glo_pallidipes.fna,Hom_sapiens.fna,Hya_hyaena.fna,Lox_africana.fna,Pha_africanus.fna,Syn_caffer.fna basename=simulation/${species}_100bp%.fq
done
