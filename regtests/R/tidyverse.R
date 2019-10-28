library(tidyverse)
tbl_simple_dat <- tibble(x = 1:5, y = 1, z = x ^ 2 + y)
tbl_simple_dat %>% filter(x > 3)
tbl_simple_dat %>% mutate(a = 3*z/2 + exp(1))

