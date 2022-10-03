# Background
Sharp et al. created a polygenic risk score (GRS) for Celiac Disease using the results from several large GWAS studies. The GRS multiplies the observed dosage for the risk allele by the logOdds for each locus. When repeated in the HTP cohort, the model results in a lower ROC than was observed by Sharp et al. This analysis explores how to optimize the model to improve this ROC. 


# Datasets

**Data are not curently included in this repository due to HIPAA restrictions**

In this analysis I attempted to recreate the GRS from the Sharp et al. study. An issue with the smaller HTP data is the case imbalance. There are 19 observed Celiac cases with 185 controls. This imbalance can cause bias in the models from outliers in the small sample of cases. To address this, the models are built by downsampling the control samples (i.e., those without Celiac disease). One can set the ratio ofcontrols to cases with the 'control_to_cases_ratio' parameter. The default is 3 (i.e., 3 cases for every control, still unbalanced but far less than the original 185:19). 

Also, models fit specifically to this data will be overfit to predict new samples out of distribution. Cross validation was used to address this limitation and build high confidence models. The cross validation approach depends on the parameter 'k', which is the number of cases to remove from the training data and use for testing. If k = 1, one sample is removed from training for testing. For k=2, one can either choose to iterate through all possible combinations of removing k cases or through a set list of groups of k cases. 

The logistic regression model developed on the training data (which consists of cases - k subjects and a randomly sampled set of controls based on the set 'control_to_case_ratio') is tested for accuracy against several sampled test datasets. The test datasets include the k held out cases as well as a number of controls, again determined the 'control_to_case_ratio'. To ensure effective sampling when determining accuracy, the testing is repated for several iterations in which the casese are randomly sampled from the population, determined by the parameter 'test_iterations'. This results in a distribution of weights and accuracies. 

Using the logOdds coefficients from models with accuracies > .5, a weighted mean coefficient is calculated. To effectively sample the control population, this process is repeated for a number of iterations (defined by the 'sampling_iterations' parameter) in which separate random samples of the control population are used in the training data. Again, the results are used to create a weighted coefficient using the models with accuracies > .5. 

Finally, as this process is repeated for each group of k length, the resulting model coefficients and accuracies are used to create a weighted coefficient using models with accuracies > .5. 


# Running the Scripts

These models are run using the notebook /rmarkdown/HTP_Celiac_GRS.Rmd

# Results



