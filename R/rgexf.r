.defAtt <- function(x, parent) {
################################################################################
# Prints the nodes and edges att definition
################################################################################  
  FUN <- function(x, PAR) {
    newXMLNode(name='attribute', parent=PAR,
               attrs=x)
  }
  
  apply(x, MARGIN=1, FUN, PAR=parent)
}

.addNodesEdges <- function(x, parent, type='node') {
################################################################################
# Prints the nodes and edges
################################################################################  
  # Local function that prints each node
  FUN <- function(x, PAR, type) {
    if (type=='node') {
      x['id'] <- gsub("^[ \t]*", "", x['id'])
      tempnode0 <-
        newXMLNode(name=type, parent=PAR, attrs=c(x[c('id','label')]))
    }
    else if (type=='edge') {
      x['source'] <- gsub("^[ \t]*", "", x['source'])
      x['target'] <- gsub("^[ \t]*", "", x['target'])
      tempnode0 <-
        newXMLNode(name=type, parent=PAR, attrs=c(x[c('source','target')]))
    }
    
    # In the case there is a dynamic attributes defined
    if (!is.na(x['start'])) {xmlAttrs(tempnode0)['start'] <- as.character(x['start'])}
    if (!is.na(x['end'])) {xmlAttrs(tempnode0)['end'] <- as.character(x['end'])}
      
    # Attributes printing
    attributes <- length(grep('^att', names(x))) > 0
    if (attributes) att <- x[grep('^att', names(x))]

    if (attributes) {      
      tempDF <- data.frame(names(att), att, stringsAsFactors=F)
      colnames(tempDF) <- c('for', 'value')
      
      tempnode1 <- newXMLNode('attvalues', parent=tempnode0)
      
      # Local function that prints attributes
      FUN2 <- function(x) {
        newXMLNode(name='attvalue', parent=tempnode1, attrs=x)
      }
      apply(tempDF, MARGIN = 1, FUN2)
    }
  }
  apply(x, MARGIN = 1, FUN, PAR=parent, type=type)
}

gexf <- function(
################################################################################  
# Prints the gexf file
################################################################################
  nodes,
  edges,
  edgesAtt=NULL,
  nodesAtt=NULL,
  nodeDynamic=NULL,
  edgeDynamic=NULL,
  output = NA,
  tFormat='double',
  defaultedgetype = 'undirected'
  ) {
  require(XML, quietly = T)
  
  # Defining paramters
  #nNodes <- length(nodes)
  #nLinks <- length(edges)
  nEdgesAtt <- ifelse(length(edgesAtt) > 0, NCOL(edgesAtt), 0)
  nNodesAtt <- ifelse(length(nodesAtt) > 0, NCOL(nodesAtt), 0)
  dynamic <- c(length(nodeDynamic) > 0 , length(edgeDynamic) > 0)
  
  if (!any(dynamic)) mode <- 'static' else mode <- 'dynamic'

  # Starting xml
  xmlFile <- newXMLDoc(addFinalizer=T)
  gexf <- newXMLNode(name='gexf', doc = xmlFile)
  
  # gexf att

  newXMLNamespace(node=gexf, namespace='http://www.gexf.net/1.2draft')
  newXMLNamespace(
    node=gexf, namespace='http://www.gexf.net/1.1draft/viz', prefix='viz')
  newXMLNamespace(
    node=gexf, namespace='http://www.w3.org/2001/XMLSchema-instance',
    prefix='xsi'
  ) 
  
  xmlAttrs(gexf) <- c( 
    'xsi:schemaLocation' = 'http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd',
    version=1.2)
  
  # graph
  xmlGraph <- newXMLNode(name='graph', parent=gexf)
  if (mode == 'dynamic') {
    strTime <- min(c(unlist(nodeDynamic), unlist(edgeDynamic)), na.rm=T)
    endTime <- max(c(unlist(nodeDynamic), unlist(edgeDynamic)), na.rm=T)
    xmlAttrs(xmlGraph) <- c(mode=mode, start=strTime, end=endTime,
                            timeformat=tFormat, defaultedgetype=defaultedgetype)
    
    
  } else {
    xmlAttrs(xmlGraph) <- c(mode=mode)
  }

  datatypes <- matrix(
    c(
      'string', 'character',
      'integer', 'integer',
      'float', 'double',
      'boolean', 'logical'
      ), byrow=T, ncol =2)
  
  # nodes att definitions
  if (nNodesAtt > 0) {
    if (nNodesAtt == 1) {
      TIT <- 'att1' 
      TYPE <- typeof(nodesAtt) 
    }
    else {
      TIT <- colnames(nodesAtt)
      TYPE <- sapply(nodesAtt, typeof)
    }
    
    nodesAttDf <- data.frame(
      id = paste('att',1:nNodesAtt,sep=''),
      title = TIT,
      type = TYPE,
      stringsAsFactors=F
    )
    
    # Fixing datatype
    for (i in 1:NROW(datatypes)) {
      nodesAttDf$type <- gsub(datatypes[i,2], datatypes[i,1], nodesAttDf$type)
    }
    
    xmlAttNodes <- newXMLNode(name='attributes', parent=xmlGraph)
    xmlAttrs(xmlAttNodes) <- c(class='node', mode='static')
    .defAtt(nodesAttDf, parent=xmlAttNodes)
    
  } 
  else {
    nodesAttDf <- NULL
  }

  # edges att
  if (nEdgesAtt > 0) {
    if (nEdgesAtt == 1) {
      TIT <- 'att1' 
      TYPE <- typeof(edgesAtt) 
    }
    else {
      TIT <- colnames(edgesAtt)
      TYPE <- sapply(edgesAtt, typeof)
    }
    
    edgesAttDf <- data.frame(
      id = paste('att',1:nEdgesAtt,sep=''),
      title = TIT,
      type = TYPE,
      stringsAsFactors=F
      )
    
    # Fixing datatype
    for (i in 1:NROW(datatypes)) {
      edgesAttDf$type <- gsub(datatypes[i,2], datatypes[i,1], edgesAttDf$type)
    }
    
    xmlAttEdges <- newXMLNode(name='attributes', parent=xmlGraph)
    xmlAttrs(xmlAttEdges) <- c(class='edge', mode='static')
    .defAtt(edgesAttDf, parent=xmlAttEdges)
  } 
  else {
    edgesAttDf <- NULL
  }
  
  ##############################################################################
  # The basic dataframe definition  for nodes
  
  if (dynamic[1] & nNodesAtt > 0) {nodes <- cbind(nodes, nodeDynamic, nodesAtt)}
  if (dynamic[1] & nNodesAtt == 0) {nodes <- cbind(nodes, nodeDynamic)}
  if (!dynamic[1] & nNodesAtt > 0) {nodes <- cbind(nodes, nodesAtt)}
  
  # Naming the columns
  attNames <- nodesAttDf['id']
  if (!is.null(nodeDynamic)) tmeNames <- c('start', 'end') else tmeNames <- NULL
    
  colnames(nodes) <- unlist(c('id', 'label', tmeNames, attNames))
  
  # NODES
  xmlNodes <- newXMLNode(name='nodes', parent=xmlGraph)
  .addNodesEdges(nodes, xmlNodes, 'node')

  ##############################################################################
  # The basic dataframe definition  for edges
  if (dynamic[2] & nEdgesAtt > 0) {edges <- cbind(edges, edgeDynamic, edgesAtt)}
  if (dynamic[2] & nEdgesAtt == 0) {edges <- cbind(edges, edgeDynamic)}
  if (!dynamic[2] & nEdgesAtt > 0) {edges <- cbind(edges, edgesAtt)}
  
  # Naming the columns
  attNames <- edgesAttDf['id']
  if (!is.null(edgeDynamic)) tmeNames <- c('start', 'end') else tmeNames <- NULL
  colnames(edges) <- unlist(c('source', 'target', tmeNames, attNames))

  # EDGES
  xmlEdges <- newXMLNode(name='edges', parent=xmlGraph)
  .addNodesEdges(edges, xmlEdges, 'edge')  
  results <- saveXML(xmlFile, encoding='UTF-8')
  class(results) <- 'gexf'
  
  if (is.na(output)) {
    return(results)
  } else {
    print(results, file=output)
    cat('GEXF graph written successfuly\n')
  }
}