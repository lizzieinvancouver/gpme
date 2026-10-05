## Started 4 October 2026 ##
## Sort of started by Lizzie ##

# housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

if(length(grep("lizzie", getwd()) > 0)) {
  setwd("/Users/lizzie/Documents/git/projects/grephon/gpme/exercices/")
} else if(length(grep("Xiaomao", getwd()) > 0)) {
  setwd("boomboom")
}

library(rstan)
source("mcmc_analysis_tools_rstan.R")
source("mcmc_visualization_tools.R")


d <- read.csv("input/piedtree30.csv")
d2 <- d[which(d$core==2),]

plot(rw_mm~year, d2, pch=16, cex=0.25)
lines(rw_mm~year, d2)

x <- d2$year-1000
y <- d2$rw_mm*10

data <- list(
  N_obs = length(x),
  x_obs = x,
  y_obs = y,
  
  N_pred = 100,
  x_pred = seq(1, 10, length.out = 100)
)

# I have not edited this file at all, I just copied Victor's ...
modelhere <- stan_model('stan/onetreegp.stan')
fit <- sampling(modelhere, data = data, chains = 4, cores = 4)

diagnostics <- util$extract_hmc_diagnostics(fit)
util$check_all_hmc_diagnostics(diagnostics)

samples <- util$extract_expectand_vals(fit)
base_samples <- util$filter_expectands(samples, c('rho', 'gamma', 'sigma'))
util$check_all_expectand_diagnostics(base_samples)

names <- paste0('y_pred[',1:data$N_pred,']')
# error below ...
util$plot_conn_pushforward_quantiles(samples, names, data$x_pred)
points(data$x_obs, data$y_obs, pch=16, cex=1, col="white")
points(data$x_obs, data$y_obs, pch=16, cex=0.5, col="black")