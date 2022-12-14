\name{plotInCytoscape}
\alias{plotInCytoscape}
\title{Plot a pathway graph in Cytoscape highlighting the relevant path.}
\description{
  Renders the topology of a pathway as a Cytoscape graph and marks the
  genes of the selected path.
}
\usage{
plotInCytoscape(graph, path, color="#6699FF", main="graph")
}
\arguments{
  \item{graph}{a \code{graphNEL} object.}
  \item{path}{vector summarizing a path (a rows of clipper output
    matrix).}
  \item{color}{color code string: genes of the most involved fragment will be colored using
    color. Deafult = "#6699FF"}
  \item{main}{a graph name to be used in Cytoscape. Default = 'graph'}
}
\details{
  Requires the \code{RCy3} package.
}
\seealso{
  \code{\link{clipper}}
}

\examples{

\dontrun{if (require(graphite)) {
  if (requireNamespace("RCy3")){
    kegg  <- pathways("hsapiens", "kegg")
    graph <- pathwayGraph(convertIdentifiers(kegg$'Chronic myeloid leukemia', "entrez"))
}
    path <- c(3,17,5,9,13.04,2.60,0.209,0.321,"6,7,8,9,10",
    "3,5,6,7,8,9,10,14,17", "ENTREZID:1029;ENTREZID:4193;ENTREZID:7157",
    "ENTREZID:1019;ENTREZID:1021;ENTREZID:1026;ENTREZID:1029;ENTREZID:595")
plotInCytoscape(graph,path)
    }
  }
}
