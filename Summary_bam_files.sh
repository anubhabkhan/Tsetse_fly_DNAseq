### Using Qualimap for getting summary statistics from bam files (http://qualimap.conesalab.org/doc_html/index.html)

for file in MD_*.bam
do 
qualimap bamqc -bam ${file} --java-mem-size=30G
done
