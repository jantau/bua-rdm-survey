# Source

# Clear workspace
rm(list = ls(all = TRUE))

# Knitr options
knitr::opts_chunk$set(
  echo = FALSE,
  message = FALSE,
  warning = FALSE,
  out.width = "100%"
)

# Load libraries
library(ggtext)
library(ggwordcloud)
library(janitor)
library(kableExtra)
library(plotly)
library(tidyverse)
#For pdf export needed
#https://github.com/thomasp85/ggraph/issues/152
#Problems with pdf and plotly: https://stackoverflow.com/questions/46780101/rmarkdown-bookdown-with-plotly
#library(extrafont)
#extrafont::loadfonts()

# Load data
# Input data is anonymized

load("input/fdm_survey_data_long_format_complete_surveys_anonym.Rdata")
data <- data_anonym


# Color scale

col_lik <- c("#852557", "#B07E9F", "#767676", "#7DAABE", "#21527B")

col_lik_6 <- c("#852557", "#B07E9F", "#F0CFE3", "#7DAABE", "#56869C", "#21527B")

# col_categorical <- c("#502F45", "#655038", "#767676", "#21527B", "#E9A53C")

col_cat <- c("#367BBA", "#A6A6A6", "#D873AB", "#977854", "#E1C047")

col_2_cat <- c("#367BBA", "#A6A6A6")

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Plotly layout function ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Layout bar chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

layout_bar_flip <- function(p,
                            barmode = "group",
                            bargap = 0.15,
                            bargroupgap = 0.05,
                            font = list(family = "Arial"),
                            xaxis = list(
                              title = FALSE,
                              tickformat = ".0%",
                              range = range,
                              zeroline = FALSE,
                              dtick = 0.25,
                              tick0 = 0,
                              tickmode = "linear",
                              gridcolor = "#A0A0A0",
                              tickfont = list(size = 11)
                            ),
                            range = c(-0.01, 1.05),
                            yaxis = list(
                              title = FALSE,
                              # autorange = "reversed",
                              tickfont = list(size = 11),
                              # ticklen = 5),
                              autorange = autorange
                            ),
                            autorange = TRUE,
                            legend_title = NULL,
                            # legend = list(traceorder = "normal",
                            #                 font = list(size = 11)),
                            uniformtext = list(minsize = 10, mode = "hide"),
                            ...) {
  layout(
    p,
    barmode = barmode,
    bargap = bargap,
    bargroupgap = bargroupgap,
    font = font,
    xaxis = xaxis,
    yaxis = yaxis,
    legend = list(
      traceorder = "normal",
      font = list(size = 11),
      title = list(
        text = str_wrap(
          string = legend_title, #paste0("<b>", legend_title, "</b>"),
          width = 20
        ),
        font = list(size = 11)
      )
    ),
    uniformtext = uniformtext,
    ...
  )
}



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Stacked bar chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

layout_bar_flip_stack <- function(p,
                                  barmode = "stack",
                                  font = list(family = "Arial"),
                                  margin = list(t = 80),
                                  xaxis = list(
                                    title = FALSE,
                                    tickformat = ".0%",
                                    range = c(-0.01, 1.05),
                                    zeroline = TRUE,
                                    dtick = 0.25,
                                    tick0 = 0,
                                    tickmode = "linear",
                                    gridcolor = "#A0A0A0",
                                    tickfont = list(size = 11)
                                  ),
                                  yaxis = list(
                                    title = FALSE,
                                    #  autorange = "reversed",
                                    tickfont = list(size = 11)
                                    # ticklen = 5
                                  ),
                                  legend = list(traceorder = "normal", font = list(size = 11)),
                                  uniformtext = list(minsize = 10, mode = "hide"),
                                  ...) {
  layout(
    p,
    barmode = barmode,
    font = font,
    margin = margin,
    xaxis = xaxis,
    yaxis = yaxis,
    legend = legend,
    uniformtext = uniformtext,
    ...
  )
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Grouped bar chart ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

layout_bar_flip_group <- function(p,
                                  barmode = "group",
                                  font = list(family = "Arial"),
                                  xaxis = list(
                                    title = FALSE,
                                    tickformat = ".0%",
                                    range = c(-0.01, 1.05),
                                    zeroline = TRUE,
                                    dtick = 0.25,
                                    tick0 = 0,
                                    tickmode = "linear",
                                    gridcolor = "#A0A0A0",
                                    tickfont = list(size = 11)
                                  ),
                                  yaxis = list(
                                    title = FALSE,
                                    # autorange = "reversed",
                                    tickfont = list(size = 11)
                                    # ticklen = 5
                                  ),
                                  autorange = NULL,
                                  legend = list(traceorder = "normal", font = list(size = 11)),
                                  uniformtext = list(minsize = 10, mode = "hide"),
                                  ...) {
  layout(
    p,
    barmode = barmode,
    font = font,
    xaxis = xaxis,
    yaxis = list(
      title = FALSE,
      autorange = autorange,
      tickfont = list(size = 11)
    ),
    legend = legend,
    uniformtext = uniformtext,
    ...
  )
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Annotation caption ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


layout_caption <- function(p,
                           # Caption
                           x = 1,
                           y = 0,
                           # Best example of how to work with variable inside variable
                           text = ~ glue::glue("FDM-Bedarfserhebung an der Charité 2021/22, {bua_text}n={nn}",
                             bua_text = ifelse(bua == TRUE, "BUA-weit gestellte Frage, ", ""),
                             nn = max(nn)
                           ),
                           hovertext = NULL, #"Diff. zu allen gültigen Antworten (n=471): nicht gestellt, nicht beantwortet o. Antwort entfernt",
                           align = "right",
                           bua = FALSE,
                           nn = NULL,
                           showarrow = FALSE,
                           xref = "paper",
                           yref = "paper",
                           xanchor = "right",
                           yanchor = "auto",
                           xshift = 0,
                           yshift = -35,
                           font = list(size = 11),
                           ...) {
  add_annotations(
    p,
    x = x,
    y = y,
    # Best example of how to work with variable inside variable
    text = text,
    hovertext = hovertext,
    # nn = nn,
    #BUA = BUA,
   # bua2 = ifelse(bua2 == TRUE, "BUA-weite Frage, ", ""),
    align = align,
    showarrow = showarrow,
    xref = xref,
    yref = xref,
    xanchor = xanchor,
    yanchor = yanchor,
    xshift = xshift,
    yshift = yshift,
    font = font,
    ...
  )
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Mode bar ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

layout_mode_bar <- function(p,
                            displaylogo = FALSE,
                            modeBarButtonsToRemove = c(
                              "zoom",
                              "pan",
                              "select",
                              "lasso2d",
                              "zoomIn",
                              "zoomOut",
                              "autoScale",
                              "resetScale",
                              "toggleSpikelines",
                              "hoverClosest",
                              "hoverCompare"
                            ),
                            toImageButtonOptions = list(
                              format = "png",
                              # one of png, svg, jpeg, webp
                              scale = 3
                            ),
                            ...) {
  config(
    p,
    displaylogo = displaylogo,
    modeBarButtonsToRemove = modeBarButtonsToRemove,
    toImageButtonOptions = toImageButtonOptions,
    ...
  )
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Layout title ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

layout_title <- function(p,
                         font = list(family = "Arial"),
                         margin = list(t = 80),
                         text = NULL,
                         x = 0.5,
                         y = 0.95,
                         xref = "container",
                         yref = "container",
                         paper_bgcolor = "#F2F2F2",
                         plot_bgcolor = "#F2F2F2",
                         ...) {
  layout(
    p,
    font = font,
    margin = margin,
    title = list(
      text = paste0("<b>", text, "</b>"),
      font = list(size = 15),
      x = x,
      y = y,
      xref = xref,
      yref = yref
    ),
    paper_bgcolor = paper_bgcolor,
    plot_bgcolor = plot_bgcolor,
    ...
  )
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Add bar plot and standard text ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

add_bars_text <- function(p,
                          text = ~ paste0(round(perc * 100, 0), "% (", n, ")"),
                          textposition = "inside",
                          insidetextanchor = "middle",
                          textangle = 0,
                          textfont = list(color = "white", size = 11),
                          ...){
  add_bars(p,
           text = text,
           textangle = textangle,
           textfont = textfont,
           textposition = textposition,
           insidetextanchor = insidetextanchor,
           ...)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create function to serve book ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

render_book <- function() {
  bookdown::clean_book(TRUE)
  bookdown::render_book(new_session = TRUE)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# How many questions were asked to the survey participants ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Filtersprung
# c("-998", "-997", "-996", "-995", "-994", "-993", "-992", "-991", "-990", "-989", "-988")

# number_questions <- data |>
#   # head(n = 221) |>
#   # filter(data_id == 581) |>
#   filter(!value %in% c("-998")) |>
#   mutate(question_id_sep = str_remove(question_id, "_.*")) |>
#   select(data_id, question_id, question_id_sep, question, question_type, value) |>
#   drop_na(question) |>
#   group_by(data_id) |>
#   distinct(question_id_sep, .keep_all = TRUE) |>
#   ungroup() |>
#   count(data_id)
# 
# summary(number_questions$n)
# 
# Mode <- function(x) {
#   ux <- unique(x)
#   ux[which.max(tabulate(match(x, ux)))]
# }
# 
# Mode(number_questions$n)
# 
# hist(number_questions$n, breaks = 46)

# Controll results
# controll <- data |>
#   filter(value == "-998") |>
#   count(data_id)
# 
# summary(controll$n)
# hist(controll$n, breaks = 177)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# End ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
