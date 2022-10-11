
# Background
Sharp et al. [@sharpSingleNucleotidePolymorphism2020] created a polygenic risk score (GRS) for Celiac Disease using the results from several large GWAS studies. The GRS multiplies the observed dosage for the risk allele by the logOdds for each locus. When repeated in the HTP cohort, the model results in a lower ROC than was observed by Sharp et al. This analysis explores how to optimize the model to improve this ROC. 


# Datasets

**Data are not curently included in this repository due to HIPAA restrictions** 

metadata = "MEGA_041822_META_CeliacGRS_v0.1_JRS.csv"
sharp results and gene dosage data = "MEGA_041822_AnalysisData_CDGRS_Sharp2022_v0.1_JRS.csv"


HTP genotype principal components pcs = "MEGA_041822_Espinosa_MEGA2_HTP_GS_08132019_updated_callrate_passing_QC_KEEPforHLAvsCeliac_EXCLUDEvariants_mind05_geno0.02_maf0.05_PRUNEDindeppairwise0.2_v0.1_JRS.eigenvec"

# Calculating the HTP GRS

To calculate the DS-specific GRS, we reweighted each locus in the Sharp GRS using the genotypes of the HTP cohort. As in the Sharp GRS model, we adjusted for the top 5 principal components calculated from the observed gene dosages to control for genetic ancestry. We developed a robust DS-specific GRS using iterative cross validation. For each locus we trained logistic regression models on a subset of cases and controls. We randomly downsampled controls to create a more balanced case to control ratio of 1:3. We performed 1,000 iterations of random control downsampling to adequately explore the space of the control data for the model. Complete separation of cases and controls by locus genotype in the training data leads to biased model coefficients. In those cases, we set the coefficient for that locus to the corresponding Sharp GRS weight. 

We assessed model performance using the held-out cases and a random sampling of controls with the same case to control ratio (this was also done iteratively to not bias the prediction based on the sampled controls). The performance metric of the model was “balanced accuracy” to address the case imbalance in the training and testing data. We used the log odds for models with greater than 50% accuracy to calculate a “weighted mean” (where the coefficients were weighted by the accuracy) for each locus. These weighted means serve as the coefficients for each in the DS-specific GRS model. 




# Running the Scripts

These models are run using the notebook /rmarkdown/HTP_Celiac_GRS.Rmd




