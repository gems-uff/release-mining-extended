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

releases_summary <- releases_bproj %>% 
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
releases_summary *1 %>% print()


# RQ1. Time vs Range
wilcox.test(releases_bproj$time_precision, releases_bproj$range_precision, paired = TRUE)$p.value %>% round(4)
wilcox.test(releases_bproj$time_recall, releases_bproj$range_recall, paired = TRUE)
wilcox.test(releases_bproj$time_fmeasure, releases_bproj$range_fmeasure, paired = TRUE)

releases_bproj_melted %>%
  filter(variable == "time_precision" | variable == "range_precision") %>%
  ggplot(aes(x = variable, y = value)) +
    coord_flip() +
    geom_boxplot() + 
    ggtitle("Precision - time-based vs range-based strategy") +
    xlab("") + 
    scale_x_discrete(position = "top", labels = c(
      "time_precision" = "time-based",
      "range_precision" =  "range-based"
    )) +
    ylab("precision") +
    scale_y_continuous(labels = scales::percent, limits = c(0.7,1)) +
    theme_bw(base_size = 12) 
ggsave("../paper/figs/rq_best_bp_precision.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(variable == "time_recall" | variable == "range_recall") %>%
  ggplot(aes(x = variable, y = value)) +
    coord_flip() +
    geom_boxplot() + 
    ggtitle("Recall - time-based vs range-based strategy") +
    xlab("") + 
    scale_x_discrete(position = "top", labels = c(
      "time_recall" = "time-based",
      "range_recall" =  "range-based"
    )) +
    ylab("recall") +
    scale_y_continuous(labels = scales::percent, limits = c(0.7,1)) +
    theme_bw(base_size = 12) 
ggsave("../paper/figs/rq_best_bp_recall.png", width = 8, height = 2)

# RQ2.a

releases$pwork <- 100 * releases$committers / releases$commits
pwork_treshold <- mean(releases$pwork)


releases_few_committers_bproj <- releases %>% 
  filter(pwork < pwork_treshold) %>%
  group_by(project) %>%
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases = n())

releases_many_committers_bproj <- releases %>% 
  filter(pwork >= pwork_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases = n())

releases_committers_bproj <- releases_few_committers_bproj %>% 
  inner_join(releases_many_committers_bproj, by = "project",
             suffix = c(".few", ".many"))


releases_committers_bproj_melted <- releases_committers_bproj %>% 
  select(-releases.few, -releases.many) %>%
  gather(variable, value, -project) %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time",
                              grepl("range", variable) ~ "range",
                              TRUE ~ "fmeasure"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  mutate(strategy = factor(strategy, levels = c("time",
                                                "range")),
         group = factor(group, levels = c("many", "few")),
         variable = factor(variable, levels=c("time_precision.many",
                                              "time_precision.few",
                                              "time_recall.many",
                                              "time_recall.few",
                                              "range_precision.many",
                                              "range_precision.few",
                                              "range_recall.many",
                                              "range_recall.few")))

100 * releases_committers_bproj %>%
  summarise(
    time_precision.few = mean(time_precision.few),
    time_precision.many = mean(time_precision.many),
    range_precision.few = mean(range_precision.few),
    range_precision.many = mean(range_precision.many),
    time_recall.few = mean(time_recall.few),
    time_recall.many = mean(time_recall.many),
    range_recall.few = mean(range_recall.few),
    range_recall.many = mean(range_recall.many),
    time_fmeasure.few = mean(time_fmeasure.few),
    time_fmeasure.many = mean(time_fmeasure.many),
    range_fmeasure.few = mean(range_fmeasure.few),
    range_fmeasure.many = mean(range_fmeasure.many)
  ) %>% round(4)

releases_committers_bproj_melted %>%
  filter(
    variable == "time_precision.few" | variable == "time_precision.many" |
    variable == "range_precision.few" | variable == "range_precision.many"
  ) %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Precision - few vs many developers") +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c(
      "time_precision.many" = "many",
      "time_precision.few" =  "few",
      "range_precision.many" = "many",
      "range_precision.few" =  "few"
    ), position = "top") +
    facet_grid(rows = vars(strategy), scales = "free",
        switch = "y", labeller = as_labeller(c(
      "time" = "time-based",
      "range" = "range-based"
    ))) +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0.75, 1)) +
    xlab("") +
    theme_bw(base_size = 12)
ggsave("../paper/figs/rq_factors_bp_collaborators_precision.png", width = 8, height = 3)

releases_committers_bproj_melted %>%
  filter(variable == "time_recall.few" | variable == "time_recall.many") %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Recall - few vs many developers") +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c(
      "time_recall.many" = "many",
      "time_recall.few" =  "few"
    ), position = "top") +
    facet_grid(rows = vars(strategy), scales = "free",
        switch = "y", labeller = as_labeller(c(
      "time" = "time-based",
      "range" = "range-based"
    ))) +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0.4, 1)) +
    xlab("") +
    theme_bw(base_size = 12)
ggsave("../paper/figs/rq_factors_bp_collaborators_recall.png", width = 8, height = 2)

# RQ2.b

base_treshold <- mean(releases$base_releases_qnt)

releases_few_bases_bproj <- releases %>% 
  filter(base_releases_qnt < base_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases = n())

releases_many_bases_bproj <- releases %>% 
  filter(base_releases_qnt > base_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases = n())

releases_bases_bproj <- releases_few_bases_bproj %>% 
  inner_join(releases_many_bases_bproj, by = "project",
      suffix = c(".few", ".many"))

View(releases_bases_bproj_melted)

releases_bases_bproj_melted <- releases_bases_bproj %>% 
  select(-releases.few, -releases.many) %>%
  gather(variable, value, -project) %>%
  mutate(
    group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many"),
    strategy = case_when(grepl("time", variable) ~ "time",
                               grepl("range", variable) ~ "range",
                               TRUE ~ "fmeasure"),
    variable = factor(variable, levels = c(
      "time_precision.many",
      "time_recall.many",
      "time_fmeasure.many",
      "range_precision.many",
      "range_recall.many",
      "range_fmeasure.many",
      "time_precision.few",
      "time_recall.few",
      "time_fmeasure.few",
      "range_precision.few",
      "range_recall.few",
      "range_fmeasure.few"
    ))
  )

100 * releases_bases_bproj %>%
  summarise(
    time_precision.few = mean(time_precision.few),
    time_precision.many = mean(time_precision.many),
    range_precision.few = mean(range_precision.few),
    range_precision.many = mean(range_precision.many),
    time_recall.few = mean(time_recall.few),
    time_recall.many = mean(time_recall.many),
    range_recall.few = mean(range_recall.few),
    range_recall.many = mean(range_recall.many),
    time_fmeasure.few = mean(time_fmeasure.few),
    time_fmeasure.many = mean(time_fmeasure.many),
    range_fmeasure.few = mean(range_fmeasure.few),
    range_fmeasure.many = mean(range_fmeasure.many),
  ) %>% round(4)

releases_bases_bproj_melted %>%
  filter(variable == "time_recall.few" | variable == "time_recall.many") %>%
  ggplot(aes(x = variable, y = value)) +
    ggtitle("Recall - time-based strategy: single vs multiple base releases") +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels = c(
      "time_recall.many" = "multiple",
      "time_recall.few" =  "single"
    ), position = "top") +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    xlab("") +
    theme_bw(base_size = 12)
ggsave("../paper/figs/rq_factors_base_bp_recall.png", width = 8, height = 2)

# RQ3. Time vs Naive
wilcox.test(releases_bproj$time_precision, releases_bproj$time_naive_precision, paired = TRUE)
wilcox.test(releases_bproj$time_recall, releases_bproj$time_naive_recall, paired = TRUE)
wilcox.test(releases_bproj$time_fmeasure, releases_bproj$time_naive_fmeasure, paired = TRUE)

releases_bproj_melted %>%
  filter(variable == "time_precision" | variable == "time_naive_precision") %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() + coord_flip() +
    ggtitle("Precision - time-based strategy: reachable vs all commits") +
    xlab("") + scale_x_discrete(labels = c(
      "time_precision" = "reachable",
      "time_naive_precision" = "all"
    ), position = "top") +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    theme_bw(base_size = 12)
ggsave("../paper/figs/rq_naive_bp_precision.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(variable == "time_recall" | variable == "time_naive_recall") %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() + coord_flip() +
    ggtitle("Recall - time-based strategy: reachable vs all commits") +
    xlab("") + scale_x_discrete(labels = c(
      "time_recall" = "reachable",
      "time_naive_recall" = "all"
    ), position = "top") +
    ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    theme_bw(base_size = 12)
ggsave("../paper/figs/rq_naive_bp_recall.png", width = 8, height = 2)


# RQ4. Time vs Expert
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
    theme_bw(base_size = 12)
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
    theme_bw(base_size = 12) +
    theme(plot.title.position = "plot")
ggsave("../paper/figs/rq_expert_bp_recall.png", width = 8, height = 2)


releases_bproj %>% summarize(mean(time_precision))

releases_summary$time_precision[1]

releases %>%
  #filter(time_precision < releases_summary$time_precision | time_recall < releases_summary$time_recall) %>%
  ggplot(aes(x=time_precision, y=time_recall)) + #, size = commits)) +
    ggtitle("Time-based strategy", subtitle = "Precision vs recall") +
    xlab("precision") + scale_x_continuous(labels = scales::percent, limits = c(0,1)) +
    ylab("recall") + scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
    geom_point(
      data = subset(
        releases, 
        time_precision < 1 & time_precision > 0 & time_recall < 1 & time_recall > 0
      ), alpha = 0.1, fill = "white", size = 5, stroke = 1, pch = 21
    ) +
    geom_point(alpha = 0.01, size = 5) +
    theme_bw(base_size = 14)
ggsave("../paper/figs/wa_time_scatter.png", width = 4, height = 4)


releases %>%
  #filter(range_precision < releases_summary$range_precision) %>%
  ggplot(aes(x=range_precision, y=range_recall)) + #, size = commits)) +
  ggtitle("Range-based strategy", subtitle = "Precision vs recall") +
  xlab("precision") + scale_x_continuous(labels = scales::percent, limits = c(0,1)) +
  ylab("recall") + scale_y_continuous(labels = scales::percent, limits = c(0,1)) +
  #geom_point(alpha = 0.2, fill = "white", size = 5, stroke = 1, pch = 21) +
  geom_point(alpha = 0.01, size = 5) +
  theme_bw(base_size = 14)
ggsave("../paper/figs/wa_range_scatter.png", width = 4, height = 4)


# Investigate releases

## time-based zero
releases_lpr <- releases %>% filter(time_precision == 0 & time_recall == 0) %>% 
  select(
    project, name, 
    base_releases, time_base_releases,
    commits, time_commits, 
    time_precision, time_recall,
    range_precision, range_recall
  )
#, base_releases, time_base_releases) # %>% count

releases_lpr %>% View()

releases_lpr %>% filter(project == "sebastianbergmann/phpunit") %>%
  select(project, name)

releases_lpr %>% filter(project == "sebastianbergmann/phpunit") %>% View()
  

releases_lpr %>% select(project) %>% distinct()

47 / releases %>% count()

## low precision, high recall

releases %>%
  filter((time_precision < 0.1 & time_recall == 1) | range_precision < 0.1) %>%
  select(
    project, name,
    commits, time_commits, range_commits,
    time_precision, time_recall,
    range_precision, range_recall,
    base_releases, time_base_releases
  ) %>%
  View()

releases %>%
  filter((time_precision < 0.1 & time_recall == 1) | range_precision < 0.1) %>%
  select(
    project, name,
    base_releases, time_base_releases, range_base_releases
  ) %>%
  # View()
  write.csv2("low_precision.csv")


## high precision, low recall

releases_hp_lr <- releases %>%
  filter(time_precision == 1 & time_recall < 0.1) %>%
  select(
    project, name,
    base_releases, time_base_releases,
    commits, time_commits, range_commits,
    time_precision, time_recall,
    range_precision, range_recall
  )

releases_hp_lr %>% View()

releases_hp_lr %>% group_by(project) %>% summarise(project = first(project))
