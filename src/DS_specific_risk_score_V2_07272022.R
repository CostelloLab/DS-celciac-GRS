# DS_specific_risk_score is a program to optimize a genetic risk score developed by Sharp et al. for the general population to individuals with DS.

#Libraries
require(tidyverse)
require(precrec)
require(caret)
require(ggplot2)
require(pROC)
library(data.table)
set.seed(1234)


# Data
meta  <- read.csv("./MEGA_041822_META_CeliacGRS_v0.1_JRS.csv")# Load the metadata
results  <- read.csv('./MEGA_041822_RESULTS_CDGRS2022_VariantDosage_vs_Celiac_v0.2_JRS.csv')# Load the Results
analysis  <- read.csv('./MEGA_041822_AnalysisData_CDGRS_Sharp2022_v0.1_JRS.csv')# Load the Analysis data

# Filtering #
tokeep  <- meta %>% # create a vector of ID's to keep. Some need to be removed based on relatedness.
    filter(EXCLUDE_from_analysis == 0)%>%
    .$MEGA.IID

analysis_data  <- analysis %>% # Filter the data
    filter(MEGA.IID %in% tokeep)

# Create dataset for producing the genetic risk score
Sharp_risk_score <- analysis_data %>%
  select('MEGA.IID', 'GRS') %>% 
  distinct(MEGA.IID, .keep_all = T)%>% 
  left_join(meta[, c("MEGA.IID", "Celiac")], by = "MEGA.IID")


# ROC from SHarp  
sharp_roc <- evalmod(scores = Sharp_risk_score$GRS, labels =Sharp_risk_score$Celiac )
autoplot(sharp_roc)

# Create DS dosage data frame

DS_dosage <- analysis_data %>% 
  select(MEGA.IID, Variant..Sharp.2022.,Dosage_for_GRS) %>% 
  pivot_wider(id_cols = 'MEGA.IID',
              names_from = 'Variant..Sharp.2022.',
              values_from = 'Dosage_for_GRS') %>%
  left_join(meta[, c('MEGA.IID', 'Celiac')], by = 'MEGA.IID') %>% 
  column_to_rownames('MEGA.IID')

#DS_dosage$Celiac <- factor(ifelse(DS_dosage$Celiac == 1, "Celiac", "Control"))

### Create a score based on the DS odds ratio for each SNP
# htpGRS is a function for creating a GRS using the htp gene dosage data. 
# Inputs: dosage_data   is a data frame containing the variant and gene dosage for every subject
#         pseudoCount   numeric pseudoCount to add to the dosage data
#         iterations    numeric number of iterations for bootstapping

htpGRS <- function(dosage_data = DS_dosage, pseudoCount = 0, iterations = 10 ){
  
  # identify subjects
  celiac_subjects <- which(dosage_data$Celiac == 1)
  control_subjects <- seq(1:204)[-celiac_subjects]
  
  #create a list for results
  grs_results <- list()
  
  for(snp in names(dosage_data)[-50]){
    # test for differences in Celiac's disease by dosage
    print(snp)
    print(table(dosage_data[[snp]], dosage_data$Celiac))
    
    # print(paste0(round(which(names(dosage_data)==snp)/49,2)*100,"% complete"))
    # 
    # 
    # tmp_results <- data.frame(weight = numeric(), 
    #                           low = numeric(),
    #                           high = numeric(), 
    #                           AIC = numeric(),
    #                           pvalue = numeric())
    # 
    # 
    # for(i in 1:iterations){
    #   
    #   # Sample from cases and controls, maintaining case/control ratio
    #   tmp_data <- dosage_data[c(sample(celiac_subjects,15),sample(control_subjects, 146)),]
    #   
    #   tmp_data[,1:49] <- tmp_data[,1:49] + pseudoCount
    # 
    #   tmp_model <- glm(tmp_data$Celiac ~ tmp_data[[snp]],family= binomial(link = "logit")) 
    #   weight <- coef(tmp_model)[2]
    #   weight <- ifelse(is.finite(weight), weight, NA)
    #   tmp_results[i,] = c(weight,  suppressMessages(confint(tmp_model)[2,]),  tmp_model$aic, ifelse(is.na(weight), NA, summary(tmp_model)$coefficients[2,4]))
    #   
    # }
    # # tmp_means <- colMeans(tmp_results, na.rm = TRUE )
    # # results[[snp]] <- tmp_means
    # 
    # # Select the best performing results
    # tmp_results <- tmp_results %>%
    #   arrange(pvalue)
    # #print(tmp_results)
    # grs_results[[snp]] <- tmp_results[1,]
  }
  
  grs_results <- data.frame(do.call(rbind,grs_results))
  rownames(grs_results) <- names(dosage_data)[-50]
  
  # create GRS
  GRS <- colSums(apply(dosage_data[,-50], 1, function(x) x* grs_results$weight))

  # plot the roc curves
  rocs <- list()
  rocs[["HTP"]] <- roc(response = dosage_data$Celiac, predictor= GRS )
  rocs[["Sharp"]] <- roc(Sharp_risk_score$Celiac, Sharp_risk_score$GRS)
  
  # p1 <- ggroc(rocs) +
  #   theme_classic()
  # pdf("HTP_Sharp_ROC_072722.pdf")
  # p1
  # dev.off()
  
  #results$weight
  sharp_scores <- analysis %>% 
    select(Score_Weight..logOR., Variant..Sharp.2022.) %>% 
    distinct(.keep_all = TRUE)
  

  scores <- cbind(sharp_scores, grs_results$weight)
  names(scores) <- c("Sharp", "Variant", "HTP")
  scores <- scores %>% 
    pivot_longer(cols = c(Sharp, HTP))
  
  
  
  p2 <- ggplot(scores, aes(y= value, x=Variant, fill = name)) +
    geom_bar(stat = "identity", alpha = .6, position = "dodge") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90))
    
  # pdf("HTP_Sharp_weights_072722.pdf")
  # p2
  # dev.off()
  
  return(list(GRS = GRS, ROC_plot = p1, weights_plot = p2))
  
} 

# No pseudo counts
no_pseudo = htpGRS(pseudoCount = 0, iterations = 10)
no_pseudo$ROC_plot
no_pseudo$weights_plot

pseudo = htpGRS(pseudoCount = 10, iterations = 10)
pseudo$ROC_plot
pseudo$weights_plot



# 
# 
# 
# trControl <- trainControl(method = "repeatedcv", 
#                           number = 10,
#                           repeats = 5,
#                           summaryFunction = twoClassSummary,
#                           classProbs = T,
#                           sampling = "down"
#                           
# )
# 
# results <- list()
# 
# for(snp in names(DS_dosage)[-50]){
# 
#   model <- train(y = DS_dosage$Celiac,
#                x = DS_dosage[snp],
#                method = "glm", 
#                family = "binomial",
#                metric = "ROC", 
#                trControl = trControl
#     )
#   
#   scores <- summary(model)$coefficients[2,1] + 
#                  +     qnorm(c(0.025,0.5,0.975)) * summary(model)$coefficients[2,2]
#   pvalue <- summary(model)$coefficients[2,4]
#   ROC <- model$results[1,2]
#   
#   results[[snp]] <- data.frame(low = scores[1],
#                       high = scores[3],
#                       or = scores[2],
#                       pvalue = pvalue, 
#                       ROC = ROC)
#   
# }
# 
# 
# results <- as.data.frame(rbindlist(results))
# 
# rownames(results) <- names(DS_dosage)[-50]
# 
# GRS <- colSums(apply(DS_dosage[,-50], 1, function(x) x* results$or))
# evalmod(scores = GRS, labels =DS_dosage$Celiac )
