library("tidyverse")
library("effsize")
options(digits=4)
Sys.setenv(LANG = "en")

releases <- read.csv("./data/releases.csv")

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

releases_bproj_melted <- releases_bproj %>% 
  gather(variable, value, -project) %>%
  mutate(variable = factor(variable, levels = c(
    "time_expert_precision",
    "time_expert_recall",
    "time_expert_fmeasure",
    "time_naive_precision",
    "time_naive_recall",
    "time_naive_fmeasure",
    "range_precision",
    "range_recall",
    "range_fmeasure",
    "time_precision",
    "time_recall",
    "time_fmeasure"
  )))

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

wilcox.test(releases_bproj$time_fmeasure, releases_bproj$time_expert_fmeasure, paired = TRUE)$p.value
cliff.delta(releases_bproj$time_fmeasure, releases_bproj$time_expert_fmeasure)

releases_bproj_melted %>%
  filter(variable == "time_precision" | variable == "time_expert_precision") %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() + coord_flip() +
    ggtitle("Precision - time-based strategy: base release vs first commit") +
    xlab("") + scale_x_discrete(labels=c(
      "time_precision" = "Base release",
      "time_expert_precision" =  "First commit"
    ), position = "top") +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0.5,1)) +
    theme_bw(base_size = 14)
ggsave("../paper/figs/rq_expert_bp_precision.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(variable == "time_recall" | variable == "time_expert_recall") %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() + coord_flip() +
    ggtitle("Recall - time-based strategy: base release vs first commit") +
    xlab("") + scale_x_discrete(labels=c(
      "time_recall" = "Base release",
      "time_expert_recall" =  "First commit"
    ), position="top") +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0.5,1)) +
    theme_bw(base_size = 14) +
    theme(plot.title.position = "plot")
ggsave("../paper/figs/rq_expert_bp_recall.png", width = 8, height = 2)
    
