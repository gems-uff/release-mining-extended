library("tidyverse")
options(digits=4)
Sys.setenv(LANG = "en")

perf_df <- read.csv("./experiment_perf.csv", sep = ";")

# Faster
perf_df %>% filter(elapsed_time == min(elapsed_time))

# Slower
perf_df %>% filter(elapsed_time == max(elapsed_time))

perf_df %>% summary()


perf_df %>% ggplot(aes(elapsed_time)) + 
  geom_histogram(binwidth = 0.1) +
  ggtitle("Baseline algorithm execution time histogram") +
  scale_x_continuous(name = "Elapsed time in seconds", n.breaks = 15, limits=c(0, 3)) +
  theme_bw(base_size = 14)
ggsave("../paper/figs/perf_histogram.png", width = 8, height = 4)


# Mais rapido que 1 sec.
perf_df %>% filter(elapsed_time < 1) %>% count() / 1000


perf_df %>% ggplot(aes(elapsed_time)) + 
  geom_boxplot()

theme(plot.title.position = "plot")
  
  
  scale_y_continuous(limits = c(0,1)) 
  
  xlab("") + scale_x_discrete(labels=c(
    "time_recall" = "Base release",
    "time_expert_recall" =  "First commit"
  ), position="top") +
  ylab("") + scale_y_continuous(labels = scales::percent, limits = c(0.5,1)) +
