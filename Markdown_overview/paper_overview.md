Spatial Analysis of the Flat Market in Prague
================
Petr Hrobař

# Abstract

Our study aims to examine the effect of spatial dependency in the Prague
flat market. Following the Tobler’s first law of geography: near things
are more related than distant things, we allow the flat’s price to be
not only the function of its own characteristics but also function of
its neighbourhood unit characteristics. We also evaluate different
spatial dependence matrices for analysis of estimated results. The
findings are as follows. First, based on the positive parameter of
spatial autocorrelation, we confirm spatial dependency in our dataset,
i.e. prices of flats tend to form spatial clusters. Second, once
controlling for spatial dependency, we are able to evaluate flat’s
prices more accurately. Third, based on the residual distribution across
space, we identify “grandiose“ clusters in which the price of estate can
be multiple times higher than outside the cluster simply due to the
location factor.

# Models used

## Linear Regression

First model used in our study is simple linear regression given as:

  
![ 
y = X\\beta + \\varepsilon,
](https://latex.codecogs.com/png.latex?%20%0A%20%20%20%20y%20%3D%20X%5Cbeta%20%2B%20%5Cvarepsilon%2C%0A
" 
    y = X\\beta + \\varepsilon,
")  

This model does not take spatial dependency into account. In order to
partially allow for spatial dependency, we propose simple feature based
on statistical learning clustering algorithms. Since we are working with
spatial data, we have coordinates available although we do not recommend
including coordinates into linear model directly.

## Spatial Lag Model

Spatial lag model can be obtained from when
![\\theta](https://latex.codecogs.com/png.latex?%5Ctheta "\\theta") and
![\\lambda](https://latex.codecogs.com/png.latex?%5Clambda "\\lambda")
are both equal to 0. Under this assumption derived model allows for
accounting for spatial dependency in dependent variable of neighbourhood
units. Therefore, model can be written as

  
![ y = \\rho W y + X\\beta + \\varepsilon
](https://latex.codecogs.com/png.latex?%20%20y%20%3D%20%5Crho%20W%20y%20%2B%20X%5Cbeta%20%2B%20%5Cvarepsilon%20
"  y = \\rho W y + X\\beta + \\varepsilon ")  

## Spatial Error model

Second spatial model used in our study is spatial error model. Using
this model specification we can account for spatial interactions among
the error terms. Formal model form can be described as:

  
![y = X \\beta + u
](https://latex.codecogs.com/png.latex?y%20%3D%20X%20%5Cbeta%20%2B%20u%20
"y = X \\beta + u ")  
  
![u = \\lambda W u +
\\varepsilon.](https://latex.codecogs.com/png.latex?u%20%3D%20%5Clambda%20W%20u%20%2B%20%5Cvarepsilon.
"u = \\lambda W u + \\varepsilon.")  

Selection for model can imply that some (spatially distributed)
independent variable was not included in the model. Once again,
parameters ![\\beta](https://latex.codecogs.com/png.latex?%5Cbeta
"\\beta"), ![\\lambda](https://latex.codecogs.com/png.latex?%5Clambda
"\\lambda") are estimated by the ML, see e.g. LeSage and Pace (2009).
Unlike the spatial lag model, coefficients from spatial error model can
be directly interpreted as marginal effects.

# Dataset

Flats estates are retrived from Czech estates site Sreality.cz which
contains various estates that are available to rent or buy. We suppose
that Prague flats listed here are credible representation of the real
flats market of the city, i.e. the listed estates follow the same DGP as
the estates not listed and thus not included in the dataset

Example of dataset can be inspected down below:

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:right;">

price

</th>

<th style="text-align:right;">

Meters

</th>

<th style="text-align:right;">

Rooms

</th>

<th style="text-align:right;">

Mezone

</th>

<th style="text-align:right;">

KK

</th>

<th style="text-align:right;">

panel

</th>

<th style="text-align:right;">

balcony\_or\_terrase

</th>

<th style="text-align:right;">

novostavba

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

9840000

</td>

<td style="text-align:right;">

93

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

3980000

</td>

<td style="text-align:right;">

55

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

5958150

</td>

<td style="text-align:right;">

59

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:right;">

4657156

</td>

<td style="text-align:right;">

76

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:right;">

5466765

</td>

<td style="text-align:right;">

64

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:right;">

5466765

</td>

<td style="text-align:right;">

64

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

# Empirical results

All estimated models can be inspected down below:

# References

<div id="refs" class="references">

<div id="ref-lesage2009introduction">

LeSage, J, and R Pace. 2009. “Introduction to Spatial Econometrics. Boca
Raton: Taylor and Francishttp://Dx. Doi. Org/10.1201/9781420064254.”

</div>

</div>
