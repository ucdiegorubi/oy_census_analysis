pums_df <- load_data$load_clean_pums()

# every serial number has one value of NOC
pums_vars <- function(var){
  
  tidycensus::pums_variables %>% 
    filter(var_code == var) %>% 
    distinct(var_code, var_label)
  
  
}

pums_def <- function(def){
  
  tidycensus::pums_variables %>% 
    filter(str_detect(var_label, pattern = def)) %>% 
    distinct(var_code, var_label)
}

pums_counter <- function(x){
  
  pums_df %>% 
    count(SERIALNO, sort = TRUE) %>% 
    filter(n <= x) %>% 
    pull(SERIALNO)
  
}

rec_fil <- function(rec){
  
  pums_df %>% 
    filter(SERIALNO == rec) %>% 
    select(SERIALNO, SPORDER, RELP_label, NOC, AGEP, oy_flag, ESR_label, SCH_label)
}

view_oy <- function(){
  
  pums_df %>% 
    group_by(SERIALNO) %>% 
    filter(any(oy_flag == "opp_youth")) %>% 
    select(SERIALNO, SPORDER,oy_flag, RELP_label, NOC, AGEP, ESR_label, SCH_label, PWGTP) %>% 
    filter(NOC > 1) %>% 
    group_by(SERIALNO) %>% 
    arrange(SERIALNO, -AGEP)
  
}

view_oy() %>% View()
rec_fil("2018HU1396696") %>% View()
pums_vars("SPORDER")
two <- pums_counter(2)

select_vars <- c("SERIALNO", 
                 "SPORDER",
                 "oy_flag", 
                 "RELP_label","NOC", "OC_label", "AGEP", "FER_label", "ESR_label", "SCH_label", "PWGTP")


pums_df %>%
  filter(NOC >= 0, OC != "b") %>% 
  mutate(OC = as.double(OC)) %>% 
  group_by(SERIALNO,NOC) %>% 
  summarize(n = sum(OC)) %>% 
  filter(NOC != n)
