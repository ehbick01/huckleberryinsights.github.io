---
title: Into the Tidyverse
author: 'Eric Bickel'
date: '2017-04-11'
slug: ''
categories: [Tutorials]
tags: [r, tidyverse, manipulation, visualization]
draft: no
---

### Today's purpose
To walk through the `tidyverse` and become familiar with the functions that it provides the user and how it can make your life _so much better_ to use.

### What the heck even is a `tidyverse`?
[tidyverse](http://tidyverse.org/) is a collection of R packages providing an all-inclusive resource for data science (well, _almost_). When you `library(tidyverse)` the following packages are loaded up as dependencies:

|          **Package**       | 							**Description**
|----------------------------|------------------------------------------------------------------------------------------------|
|`ggplot2`                   | Graphics-building package based on The Grammar of Graphics mapping aesthetics to data visually |
|`tibble`                    | Wrapper on traditional dataframes allowing for better printing and viewing data                |
|`tidyr`                     | Package to easily and quickly get your data into a rectangular format (if not already in one)  |
|`readr`                     | Super fast package for reading in rectangular data (like csv, tsv, and fwf)                    |
|`purrr`                     | A set of tools for working with functions and vectors for functional programming techniques    |
|`dplyr`                     | Quickly and efficiently manipulate data with a Grammar of Manipulation (just made that up)     |

Within each of these there are a handful of other dependencies - not all of which I am going to talk through. However, one package that **is** important to know about is `magrittr`. It is a dependency loaded with `dplyr` and allows for the use of pipes (the `%>%` character) - which is an extremely strong character and provides the user the ability to "pipe through" elements into functions for manipulation/modeling/visualizing. That probably makes no sense right now, but I promise it will when we walk through an example or two.

### Let's jump into some examples
Probably the best way to learn a thing in R is to do a thing in R - so let's do that. I made a promise years ago not to ever use `iris` or `mtcars` in my examples, so instead we are going to mess around with the `babynames` dataset (another gem from Hadley Wickham) for this first example.

**Let's load in our packages and set a theme for plotting**

Aside from our `tidyverse` package, we are also going to load in the `babynames` package that houses baby names for the US from 1880 to 2014 for all names used by at least five children of either sex for every year. It also has cohort life tables, which is pretty interesting to mess around with as well. The data is provided by the Social Security Administration - so you _know_ it's legit.

We're also loading in `extrafont` to access fonts that exist on my local machine and `ggthemes` to church up plots in ggplot a bit. I've added descriptors next to each line of `ggthemes::theme_set` to help understand what each does.

```{r, load packages and set themes, message = FALSE, warning = FALSE}

# Load packages
library(tidyverse)
library(babynames)
library(extrafont)
library(ggthemes)

# Set plot theme
theme_set(
  theme_bw(base_family = 'Segoe UI', base_size = 12) +
                                      # Set initial theme ('theme_bw') and set base text family
                                      # and base text size
    theme(
      plot.title = element_text(face = 'bold', hjust = 0),
                                      # Set the font-face and horizontal adjustment of the plot title  

      text = element_text(colour = '#4e5c65'),
                                      # Set the font text color for the whole plot

      panel.background = element_rect('white'),
                                      # Set the background of the plotting panel to white

      plot.background = element_rect('white'),
                                      # Set the background of the plot to white

      panel.border = element_rect(colour = 'white'),
                                      # Sets the panel border (border around the actual plotting area)
                                      # to white

      panel.grid.major.x = element_blank(),
                                      # Removes major X-axis grid lines

      panel.grid.major.y = element_blank(),
                                      # Remote major Y-axis grid lines

      panel.grid.minor.y = element_blank(),
                                      # Removes minor Y-axis grid lines

      legend.background = element_rect('white'),
                                      # Sets the background of the legend to white

      legend.title = element_blank(),
                                      # Removes legend title

      legend.position = 'right',      # Aligns the legend to the right of the plot

      legend.direction = 'vertical',  # Aligns the legend vertically

      legend.key = element_blank(),   # Removes background of legend keys

      strip.background = element_rect('#f0f2f3', colour = 'white'),
                                      # Only relevant for facet plots - this sets the background
                                      # of the title of faceted plots

      strip.text = element_text(face = 'bold', size = 10),
                                      # Only relevant for facet plots - this sets the font-face
                                      # and size of the title of faceted plots

      axis.text = element_text(face = 'bold', size = 9),
                                      # Set font-face and size of axis text

      axis.title = element_blank(),   # Remove axis titles (be careful with removing titles
                                      # - YOU NEED TO BE CLEAR WHAT THE PLOT IS SHOWING
                                      # IN THE SUBTITLE IF YOU DO THIS!!!!!)

      axis.ticks = element_blank()    # Remove axis tick marks
    )
)

```

**Peek into some of the data**

Honing in first on the lifetales, we have a number of options in R to get a feel for what the data looks like. In base R, we can use `str` to identify the class of each variable (assuming your data is rectangular) as well as the first few rows of each.

However, in `tidyverse` we have `tibble::glimpse` - which provides a cleaner view of the underlying data, and will always render the data even if it is stored remotely in a database.

```{r, load data}

# Load in the life tables from SSA (`babynames` package) and glimpse
life_tables <- babynames::lifetables
tibble::glimpse(life_tables)

str(life_tables)

```

**Do some quick visual exploration**

This is where it starts to get fun (assuming you aren't already having fun) - exploring the data visually. We know from our source what the definition of each variable is. For instance, we know that variable `x` is age in years; we know that `lx` is the number of individuals alive at year `x`; we know the number of survivors by `sex`; and we know the number of survivors across each `year`.
With this data, we can calculate a weighted average age for each sex for each year using a handful of `dplyr` functions. We can then pass this data through to be visualized using `ggplot` - quickly visualizing some trends!

```{r, manipulate-and-visualize-data}

# Manipulate our data
life_tables %>%                       # The pipe operator will 'pipe' our `life_tables` dataframe
                                      # as the first argument to the following function

  dplyr::select(x, lx, sex, year) %>% # dplyr::select will select the relevant variables (columns)
                                      # that we need and create a new dataframe

  dplyr::group_by(year, sex) %>%      # dplyr::group_by will group our observations (rows) into the
                                      # relevant categories (year and sex) to run calculations on

  dplyr::summarise_each(funs(weighted.mean(., lx)), -lx) %>%
                                      # dplyr::summarise_each summarises each of the
                                      # ungrouped columns (in this case, age and number of people)
                                      # based on the function defined in the funs() argument
                                      # - in this case, it's a weighted mean

  # Visualize the results
  ggplot(aes(year, x, group = sex)) + # You can then use the piping operator to feed the final product
                                      # (a dataframe of weighted average ages by year and gender) directly
                                      # into the data argument of your ggplot function

    geom_linerange(aes(ymin = 0, ymax = x, colour = sex), position = position_dodge(5)) +
                                      # This builds a line plot from 0 to the age of each gender by year
                                      # and colors them based on their classification (M or F)

    geom_point(aes(colour = sex), position = position_dodge(5)) +
                                      # This builds a dot plot for the age of each gender by year
                                      # also colored by gender

    scale_colour_manual(values = c('blue', 'pink')) +
                                      # This manual defines the coloration of our classifiers
                                      # - (M == 'blue, F == 'pink')

    labs(title = 'Average Age by Cohort',
         subtitle = 'Ages based on the weighted average number of individuals for each age among each cohort.',
         caption = 'Data provided by the Social Security Administration')

```

**Build some models**

Another use-case for the `tidyverse` family would be applying a function across a dataframe. In the old days, this would be done either through the `apply` family or via a good ol' `for` loop. However, with `purrr` comes the handy `map` function - which will allow you to _map_ a function across your data.

For example, let's say we want to be crazy and model the propensity of a given name over time. In other words, we are going to model the change in the number of individual names as a function of time. To set this up, we are going to dive back into the `babynames` package, and export out the dataframe of names.

```{r, manipulate-and-model-data}

# First, let's nest all of the data for each name into their own column
by.name <- babynames %>%              # Feed the babynames data into the next function

  group_by(name) %>%                  # Group the dataframe by name

  nest()                              # Nest the grouped data into a list

# We can see that each element within `data` represents the entire data for each group (or in this case, each name)
glimpse(by.name$data[[1]])

# Now that the data is in this format, we can fit a linear model to each name
by.name.model <- by.name %>%          # Feed the by.name data into the next function

  mutate(model = purrr::map(data, ~ lm(n ~ year, data = .))
                                      # Mutate the by.name dataframe to build a new column titled "model"

)

# Take a glimpse - we now see a new column 'model' housing all of the modeling results
glimpse(by.name.model)

# We can also now extract model coefficients using `broom::tidy`
by.name.model %>%                     # Feed by.name.model dataframe into the next function

  unnest(model %>% purrr::map(broom::tidy))
                                      # Unnest the contents of the "model" column and
                                      # output the rownames (coefficients in this case)

```

### What else can `tidyverse` do?
There are an insane number of functions embedded into `tidyverse` - far more than a single tutorial can cover. We hit on some of the main packages today with `dplyr` for quick data manipulation and `ggplot` for good-looking visualization, but packages like `purrr` and `tidyr` can help to take manipulation even further prior to visualization.

To learn more about how you can use `tidyverse` and its dependencies, check out [the official page](http://tidyverse.org/) or read Hadley Wickham's [R for Data Science](http://r4ds.had.co.nz/). Go make cool stuff!
