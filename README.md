



# Background
Sharp et al. created a polygenic risk score (GRS) for Celiac Disease using the results from several large GWAS studies. The GRS multiplies the observed dosage for the risk allele by the logOdds for each locus. When repeated in the HTP cohort, the model results in a lower ROC than was observed by Sharp et al. This analysis explores how to optimize the model to improve this ROC. 

# Recreating the GRS
In this analysis I attempted to recreate the GRS from the Sharp et al. study. An issue with the smaller HTP data is the case imbalance. There are 19 observed Celiac cases with 185 controls. This imbalance can cause bias in the models from outliers in the small sample of cases. To overcome this bias I repeatedly subsampled from the data, preserving the case/control ratio. At each iteation I calculated the logOdds and after 1000 iterations chose the best performing model to be included in the score. I then calculated the AUC for the GRS using the HTP weights and compared that to the AUC using the Sharp et al. weights (using the HTP dosages as input). 
