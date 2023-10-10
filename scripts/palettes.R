################################################################################################################################
# Palettes
################################################################################################################################

dark  <- list(blue   = RColorBrewer::brewer.pal(12,"Paired")[2], 
              green  = RColorBrewer::brewer.pal(12,"Paired")[4], 
              red    = RColorBrewer::brewer.pal(12,"Paired")[6], 
              orange = RColorBrewer::brewer.pal(12,"Paired")[8], 
              purple = RColorBrewer::brewer.pal(12,"Paired")[10], 
              gray   = "#777777",
              black  = "#000000",
              white  = "#FFFFFF")

light <- list(blue   = RColorBrewer::brewer.pal(12,"Paired")[1], 
              green  = RColorBrewer::brewer.pal(12,"Paired")[3], 
              red    = RColorBrewer::brewer.pal(12,"Paired")[5], 
              orange = RColorBrewer::brewer.pal(12,"Paired")[7], 
              purple = RColorBrewer::brewer.pal(12,"Paired")[9], 
              gray   = "#777777",
              black  = "#000000",
              white  = "#FFFFFF")


dePal <- list(de = "#BE0F34", 
              oth = "#C0C0C0",
              all = "#1d1d1d",
              "Bavaria" = "#00CC00",
              "Non Bavaria" = "#C0C0C0", 
              "Dusseldorf"  = "#FFb266",
              "Non Dusseldorf" = "#C0C0C0",
              "Germany" = "#BE0F34",
              "Non Germany" = "#B0B0B0",
              "Hamburg" = "#00FFFF",                   
              "Non Hamburg" = "#C0C0C0",
              "Lower_Saxony" = "#FF007F", 
              "Non Lower_Saxony" = "#C0C0C0",
              "Lower Saxony" = "#FF007F", 
              "Non Lower Saxony" = "#C0C0C0",
              "Munich"  = "#66FF66",
              "Non Munich" = "#C0C0C0",
              "North_Rhine-Westphalia" = "#FF8000",
              "North Rhine-Westphalia" = "#FF8000",
              "Non North_Rhine-Westphalia" = "#C0C0C0",
              "Non North Rhine-Westphalia" = "#C0C0C0",
              "Saarland" = "#0000CC", 
              "Non Saarland" = "#C0C0C0", 
              "Baden-Württemberg" = "#990000", 
              "Non Baden-Württemberg" = "#C0C0C0", 
              "Baden-Wurttemberg" = "#990000", 
              "Non Baden-Wurttemberg" = "#C0C0C0", 
              "Berlin" = "#000099", 
              "Non Berlin" = "#C0C0C0", 
              "Brandenburg" = "#999900", 
              "Non Brandenburg" = "#C0C0C0", 
              "Bremen" = "#009999", 
              "Non Bremen" = "#C0C0C0", 
              "Hesse" = "#990099", 
              "Non Hesse" = "#C0C0C0", 
              "Mecklenburg-Vorpommern" = "#CC00CC", 
              "Non Mecklenburg-Vorpommern" = "#C0C0C0", 
              "Mecklenburg-Western Pomerania" = "#CC00CC", 
              "Non Mecklenburg-Western Pomerania" = "#C0C0C0", 
              "Rhineland-Palatinate" = "#00CC66", 
              "Non Rhineland-Palatinate" = "#C0C0C0", 
              "Saxony" = "#660033", 
              "Non Saxony" = "#C0C0C0", 
              "Saxony-Anhalt" = "#003366", 
              "Non Saxony-Anhalt" = "#C0C0C0", 
              "Schleswig-Holstein" = "#663300", 
              "Non Schleswig-Holstein" = "#C0C0C0", 
              "Thuringia" = "#7F00FF", 
              "Non Thuringia" = "#C0C0C0"
)

ukPal <- list(eng = "#BE0F34",
              sct = "#191970",
              wls = "#F5CF47",
              nir = "#9ECEEB",
              oth = "#C7C2BC")

countryPal <- list("China"         = "#872434",
                   "Italy"         = "#33A02C",
                   "Spain"         = "#F5CF47",  
                   "France"        = "#1F78B4",
                   "Belgium"       = "#000000",
                   "Netherlands"   = "#FF7F00",
                   "Ireland"       = "#AAB300",
                   "Switzerland"   = "#BE0F34",
                   "Germany"       = "#CF7A30", 
                   "US"            = "#A6CEE3",
                   "Sweden"        = "#007770",
                   "Portugal"      = "#6A3D9A",
                   "Other"         = "#C7C2BC")

################################################################################################################################

mPal <- function(c, alpha=1.0) {
  if (is.character(c) && substr(c,1,1) == "#") {
      return(paste0(c,format(as.hexmode(round(alpha*255)), width=2)))
  } else {
      return(rgb(red=c[1], green=c[2], blue=c[3], alpha=round(alpha*255), maxColorValue=255))
  }
}


plotPalette <- function(pal, alpha=1.0) {
  
  root <- sqrt(length(pal))
  layout(matrix(1:(round(root)*ceiling(root)), nrow=round(root)))
  
  par(mar=c(2,0,0,0))
  for (col in 1:length(pal)) {
      plot(1,type='n',xlim=c(0,1),ylim=c(0,1), axes=FALSE, ylab="", xlab="")
      rect(0,0,1,1,col=mPal(pal[[col]], alpha=alpha))
      if (is.null(names(pal)[col])) {
          mtext(col,line=0,side=1)
      } else {
          mtext(names(pal)[col],line=0,side=1)
      }
  }
}


