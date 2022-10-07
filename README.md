
# Background
Sharp et al. [@sharpSingleNucleotidePolymorphism2020] created a polygenic risk score (GRS) for Celiac Disease using the results from several large GWAS studies. The GRS multiplies the observed dosage for the risk allele by the logOdds for each locus. When repeated in the HTP cohort, the model results in a lower ROC than was observed by Sharp et al. This analysis explores how to optimize the model to improve this ROC. 


# Datasets

**Data are not curently included in this repository due to HIPAA restrictions** 

metadata = "MEGA_041822_META_CeliacGRS_v0.1_JRS.csv"
sharp results and gene dosage data = "MEGA_041822_AnalysisData_CDGRS_Sharp2022_v0.1_JRS.csv"


HTP genotype principal components pcs = "MEGA_041822_Espinosa_MEGA2_HTP_GS_08132019_updated_callrate_passing_QC_KEEPforHLAvsCeliac_EXCLUDEvariants_mind05_geno0.02_maf0.05_PRUNEDindeppairwise0.2_v0.1_JRS.eigenvec"






# Running the Scripts

These models are run using the notebook /rmarkdown/HTP_Celiac_GRS.Rmd

# Results



