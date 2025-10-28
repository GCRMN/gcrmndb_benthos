load("data/09_gcrmndb_benthos.RData")

library(tidyverse)

test <- synthetic_data %>% 
  select(-datasetID) %>% 
  group_by(across(everything())) %>% 
  count() %>% 
  ungroup() %>% 
  filter(n > 1) %>% 
  mutate(dupl = row_number())


testdeu <- left_join(test, synthetic_data)

testtroi <- testdeu %>% 
  select(dupl, datasetID, n)


B <- tibble(dataset_a = c("0012", "0013", "0025"),
            dataset_b = c("0013", "0025", "0012"),
            n = c(12, 2, 6))


ggplot(data = B, aes(x = dataset_a, y = dataset_b, fill = n, label = n)) +
  geom_tile() +
  geom_text(color = "white", size = 5)
