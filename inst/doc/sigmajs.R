## ----setup, echo=FALSE--------------------------------------------------------
knitr::opts_chunk$set(comment = "#>")

## ----simple-graph-------------------------------------------------------------
library(rgexf)

# Node and edge tables
nodes <- data.frame(
  id    = 1:3,
  label = c("Alice", "Bob", "Carol")
)
edges <- data.frame(
  source = c(1L, 2L, 1L),
  target = c(2L, 3L, 3L)
)

# Visual attributes
node_colors <- data.frame(
  r = c(220L,  66L,  40L),
  g = c( 50L, 133L, 167L),
  b = c( 47L, 244L, 240L),
  a = c(  1,    1,    1)
)
node_positions <- data.frame(
  x = c(-1,  1,  0),
  y = c( 0,  0,  1.5),
  z = c( 0,  0,  0)
)
node_sizes <- c(8, 8, 8)

g <- gexf(
  nodes        = nodes,
  edges        = edges,
  nodesVizAtt  = list(
    color    = node_colors,
    position = node_positions,
    size     = node_sizes
  )
)

## ----simple-plot--------------------------------------------------------------
plot(g)

## ----simple-plot-border, eval=FALSE-------------------------------------------
# # White border ring (15 % of the node radius)
# plot(g, borderColor = "#ffffff", borderSize = 0.15)
# 
# # Dark charcoal border, slightly thicker
# plot(g, borderColor = "#333333", borderSize = 0.2)

## ----read-lesmi---------------------------------------------------------------
lesmi_path <- system.file("gexf-graphs/lesmiserables.gexf", package = "rgexf")
lesmi      <- read.gexf(lesmi_path)
lesmi

## ----lesmi-plot-default-------------------------------------------------------
plot(lesmi)

## ----lesmi-plot-border--------------------------------------------------------
plot(lesmi, borderColor = "#ffffff", borderSize = 0.15)

## ----lesmi-plot-dark, eval=TRUE-----------------------------------------------
plot(lesmi, borderColor = "#222222", borderSize = 0.1)

## ----gexfjs-legacy, eval=TRUE-------------------------------------------------
plot_gexfjs(lesmi, copy.only = TRUE)

## ----gexfjs-embed, eval=TRUE--------------------------------------------------
gexfjs(lesmi)

## ----session-info-------------------------------------------------------------
sessionInfo()

