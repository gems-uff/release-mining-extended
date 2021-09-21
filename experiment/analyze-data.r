library("tidyverse")
library("effsize")
options(digits=4)

releases <- read.csv("../data/releases.csv")

releases_bproj <- releases %>% group_by(project) %>%
  summarize(
    time_precision = mean(time_precision),
    time_recall = mean(time_recall),
    time_fmeasure = mean(time_fmeasure),
    range_precision = mean(range_precision),
    range_recall = mean(range_recall),
    range_fmeasure = mean(range_fmeasure),
    time_naive_precision = mean(time_naive_precision),
    time_naive_recall = mean(time_naive_recall),
    time_naive_fmeasure = mean(time_naive_fmeasure),
    time_expert_precision = mean(time_expert_precision),
    time_expert_recall = mean(time_expert_recall),
    time_expert_fmeasure = mean(time_expert_fmeasure),
  ) 

releases_bproj %>% 
  summarize(
    time_precision = mean(time_precision),
    time_recall = mean(time_recall),
    time_fmeasure = mean(time_fmeasure),
    range_precision = mean(range_precision),
    range_recall = mean(range_recall),
    range_fmeasure = mean(range_fmeasure),
    time_naive_precision = mean(time_naive_precision),
    time_naive_recall = mean(time_naive_recall),
    time_naive_fmeasure = mean(time_naive_fmeasure),
    time_expert_precision = mean(time_expert_precision),
    time_expert_recall = mean(time_expert_recall),
    time_expert_fmeasure = mean(time_expert_fmeasure),
  ) *1 %>% print()


# Time vs Range
wilcox.test(releases_bproj$time_precision, releases_bproj$range_precision, paired = TRUE)$p.value %>% round(4)
wilcox.test(releases_bproj$time_recall, releases_bproj$range_recall, paired = TRUE)
wilcox.test(releases_bproj$time_fmeasure, releases_bproj$range_fmeasure, paired = TRUE)

# Time vs Naive
wilcox.test(releases_bproj$time_precision, releases_bproj$time_naive_precision, paired = TRUE)
wilcox.test(releases_bproj$time_recall, releases_bproj$time_naive_recall, paired = TRUE)
wilcox.test(releases_bproj$time_fmeasure, releases_bproj$time_naive_fmeasure, paired = TRUE)


# Time vs Expert
shapiro.test(releases_bproj$time_expert_precision)
shapiro.test(releases_bproj$time_expert_recall)
shapiro.test(releases_bproj$time_expert_fmeasure)

wilcox.test(releases_bproj$time_precision, releases_bproj$time_expert_precision, paired = TRUE)
cliff.delta(releases_bproj$time_precision, releases_bproj$time_expert_precision)

wilcox.test(releases_bproj$time_recall, releases_bproj$time_expert_recall, paired = TRUE)
cliff.delta(releases_bproj$time_recall, releases_bproj$time_expert_recall)

wilcox.test(releases_bproj$time_fmeasure, releases_bproj$time_expert_fmeasure, paired = TRUE)
cliff.delta(releases_bproj$time_fmeasure, releases_bproj$time_expert_fmeasure)

