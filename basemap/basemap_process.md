# Basemap Development Process

The goal of basemap development is to have a representation of what is where at a point in time close to the current year. Most fundamentally, information about the the types of households and jobs within each MAZ is needed to provide the Travel Model with the locations of trip origins and destinations. Ideally, the basemap also includes additional higher resolution data (i.e., parcels, buildings) that is helpful in understanding the likelihood of future growth in households and/or jobs in each MAZ. I will briefly review the different datasets used in this process and then discuss two approaches to processing the data for use in exploratory analysis and urban modeling.

Many datasets provide information for the basemap:
* Parcels: polygons representing land ownership. There are just over 2 million of these and, in theory, they completely tile the region (in reality, they often overlap or leave gaps). The parcels vary in size form huge (e.g., most of the Presidio) to quite smale. Tha majority are single family home lots but we are the least interested in those.
* Buildings: 
