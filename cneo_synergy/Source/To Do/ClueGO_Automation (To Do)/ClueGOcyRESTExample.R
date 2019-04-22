########################################
#### ClueGO cyREST Example Workflow ####
########################################

#### Please make sure that Cytoscape v3.6+' is started and the Cytoscape Apps 'yFiles Layout Algorithms' and 'ClueGO v2.5.2' are installed before running this script! ####

# required libraries that need to be installed before starting the script
require(xml2)
require(RJSONIO)
require(httr) # needs the libssl-dev and libcurl4-openssl-dev packages in linux (ubuntu: sudo apt-get install libssl-dev libcurl4-openssl-dev)



# Helper function to transform output into a data frame
text.to.data.frame <- function(table.text) {
    table <- NULL
    rows <- unlist(strsplit(result.table.text, split="\n"))
    header <- t(unlist(strsplit(rows[1], split="\t")))
    for(i in 2:length(rows)) {
        if(is.null(table)) {
            table <- t(unlist(strsplit(rows[i], split="\t")))
        } else {
            table <- rbind(table,t(unlist(strsplit(rows[i], split="\t"))))
        }
    }
    table <- as.data.frame(table)
    names(table) <- header
    return(table)
}


#### choose the example to run with one or two gene lists ####
example.selection = "ClueGO Rest Example for one gene list"
#example.selection = "ClueGO Rest Example for two gene lists"


#### Basic settings for cyREST ####
# home.folder = "/home/user"
home.folder = Sys.getenv("HOME")
output.folder = paste(home.folder,example.selection,sep="/")
dir.create(output.folder)

cluego.home.folder = paste(home.folder,"ClueGOConfiguration","v2.5.3",sep="/")
port.number = 1234
host.address <- "localhost"

# define base urls
cytoscape.base.url = paste("http://",host.address,":", toString(port.number), "/v1", sep="")
cluego.base.url = paste(cytoscape.base.url,"apps","cluego","cluego-manager", sep="/")

print(paste("Example analysis Parameters for ",example.selection,sep=""))
print(paste("User Home Folder: ",home.folder,sep=""))
print(paste("User Output Folder: ",output.folder,sep=""))
print(paste("Cytoscape Base URL: ",cytoscape.base.url,sep=""))
print(paste("ClueGO Base URL: ",cluego.base.url,sep=""))

#### 0.0 Start up ClueGO in case it is not running yet
response <- POST(url=paste(cytoscape.base.url,"apps","cluego","start-up-cluego",sep="/"), encode = "json")
# wait 2 seconds to make sure ClueGO is started
if(grepl("HTTP ERROR 500",response)) {
    print("wait 2 secs")
    Sys.sleep(2)
}

#### 1.0 Select the ClueGO Organism to analyze ####
organism.name = "Homo Sapiens" # (run "1.1 Get all ClueGO organisms" to get all options)
print(paste("1.0 Select the ClueGO Organism to analyze: ",organism.name,sep=""))
response <- PUT(url=paste(cluego.base.url,"organisms","set-organism",URLencode(organism.name),sep="/"), encode = "json")

## [optional functions and settings, un comment and modify if needed]
# 1.1 Get all ClueGO organisms
# response <- GET(paste(cluego.base.url,"organisms","get-all-installed-organisms",sep="/"))
# print(content(response))
#
# 1.2 Get all info for installed organisms
# response <- GET(paste(cluego.base.url,"organisms","get-all-organism-info",sep="/"))
# print(content(response))

#### 2.0 Upload IDs for a specific Cluster ####
print(paste("2.0 Upload IDs for a specific Cluster",sep=""))

## [optional functions and settings, un comment and modify if needed]
# # 2.1 Select the ClueGO ID type
# id.type.name = "# Automatic #" # (run "2.3 Get ClueGO ID types" to get all options)
# response <- PUT(url=paste(cluego.base.url,"ids","set-id-type",id.type.name,sep="/"), encode = "json")
# 
# # 2.2 Refresh ClueGO source files
# POST(url=paste(cluego.base.url,"ids","refresh-cluego-id-files",sep="/"), encode = "json")
# 
# # 2.3 Get ClueGO ID types
# response <- GET(paste(cluego.base.url,"ids","get-all-installed-id-types",sep="/"))
# print(content(response))


# example for 2 gene lists to compare

# 2.4 Set the number of Clusters
if(example.selection == "ClueGO Rest Example for two gene lists") {
    max.input.panel.number = 2
} else {
    max.input.panel.number = 1
}
response <- PUT(url=paste(cluego.base.url,"cluster","max-input-panel",max.input.panel.number,sep="/"), encode = "json")

## [optional functions and settings, un comment and modify if needed]
# 2.5 Set analysis properties for a Cluster, this is to repeat for each input cluster
cluster1 = "1"
cluster2 = "2"

input.panel.index = cluster1 # set here the cluster number e.g. "1"
node.shape = "Ellipse" # ("Ellipse","Diamond","Hexagon","Octagon","Parallelogram","Rectangle","Round Rectangle","Triangle","V")
cluster.color = "#ff0000" # The color in hex, e.g. #F3A455
min.number.of.genes.per.term = 3
min.percentage.of.genes.mapped = 4
no.restrictions = FALSE # TRUE for no restricions in number and percentage per term
response <- PUT(url=paste(cluego.base.url,"cluster","set-analysis-properties",input.panel.index,node.shape,URLencode(cluster.color,reserved = TRUE),min.number.of.genes.per.term,min.percentage.of.genes.mapped,no.restrictions,sep="/"), encode = "json")

if(example.selection == "ClueGO Rest Example for two gene lists") {
    input.panel.index = cluster2 # set here the cluster number e.g. "2"
    node.shape = "Ellipse" # ("Ellipse","Diamond","Hexagon","Octagon","Parallelogram","Rectangle","Round Rectangle","Triangle","V")
    cluster.color = "#0000ff" # The color in hex, e.g. #F3A455
    min.number.of.genes.per.term = 3
    min.percentage.of.genes.mapped = 4
    no.restrictions = FALSE # TRUE for no restricions in number and percentage per term
    response <- PUT(url=paste(cluego.base.url,"cluster","set-analysis-properties",input.panel.index,node.shape,URLencode(cluster.color,reserved = TRUE),min.number.of.genes.per.term,min.percentage.of.genes.mapped,no.restrictions,sep="/"), encode = "json")
}


# set gene list for cluster 1
file.location = paste(cluego.home.folder,"ClueGOExampleFiles/GSE6887_Bcell_Healthy_top200UpRegulated.txt",sep="/")
gene.list1 <- toJSON(read.table(file.location,as.is=TRUE,header=FALSE)[[1]])
response <- PUT(url=paste(cluego.base.url,"cluster","upload-ids-list",URLencode(cluster1),sep="/"), body=gene.list1, encode = "json", content_type_json())

if(example.selection == "ClueGO Rest Example for two gene lists") {
    # set gene list for cluster 2
    
    file.location = paste(cluego.home.folder,"ClueGOExampleFiles/GSE6887_NKcell_Healthy_top200UpRegulated.txt",sep="/")
    gene.list2 <- toJSON(read.table(file.location,as.is=TRUE,header=FALSE)[[1]])
    response <- PUT(url=paste(cluego.base.url,"cluster","upload-ids-list",URLencode(cluster2),sep="/"), body=gene.list2, encode = "json", content_type_json())
}
# To add here in the same way if you have more than 2 cluster to compare


# 2.6 Select visual style
if(example.selection == "ClueGO Rest Example for two gene lists") {
    visual.style = "ShowClusterDifference"  # (ShowGroupDifference, ShowSignificanceDifference, ShowClusterDifference)
} else {
    visual.style = "ShowGroupDifference"  # (ShowGroupDifference, ShowSignificanceDifference, ShowClusterDifference)
}
response <- PUT(url=paste(cluego.base.url,"cluster","select-visual-style",visual.style,sep="/"), encode = "json")


####  3.0 Select Ontologies
print(paste("3.0 Select Ontologies",sep=""))

selected.ontologies <- toJSON(c("3;Ellipse","8;Triangle","9;Rectangle")) # (run "3.1 Get all available Ontologies" to get all options)
response <- PUT(url=paste(cluego.base.url,"ontologies","set-ontologies",sep="/"), body=selected.ontologies, encode = "json", content_type_json())

## [optional functions and settings, un comment and modify if needed]
# 3.1 Get all available Ontologies
# response <- GET(paste(cluego.base.url,"ontologies","get-ontology-info",sep="/"))
# print(content(response))
# 
# # 3.2 Select Evidence Codes
# evidence.codes <- toJSON(c("All")) # (run "3.3 Get all available Evidence Codes" to get all options)
# response <- PUT(url=paste(cluego.base.url,"ontologies","set-evidence-codes",sep="/"), body=evidence.codes, encode = "json", content_type_json())
# 
# # 3.3 Get all available Evidence Codes
# response <- GET(paste(cluego.base.url,"ontologies","get-evidence-code-info",sep="/"))
# print(content(response))
# 
# 3.4 Set min, max GO tree level
min.level = 5
max.level = 6
all.levels = FALSE
response <- PUT(url=paste(cluego.base.url,"ontologies","set-min-max-levels",min.level,max.level,all.levels,sep="/"), encode = "json")

# # 3.5 Use GO term significance cutoff
# p.value.cutoff = 0.05
# use.significance.cutoff = TRUE
# response <- PUT(url=paste(cluego.base.url,"ontologies",use.significance.cutoff,p.value.cutoff,sep="/"), encode = "json")
# 
# # 3.6 Use GO term fusion
# use.go.term.fusion = TRUE
# response <- PUT(url=paste(cluego.base.url,"ontologies",use.go.term.fusion,sep="/"), encode = "json")

# # 3.7 Set statistical parameters
# enrichment.type = "Enrichment/Depletion (Two-sided hypergeometric test)" # ("Enrichment (Right-sided hypergeometric test)", "Depletion (Left-sided hypergeometric test)", "Enrichment/Depletion (Two-sided hypergeometric test)")
# multiple.testing.correction = TRUE
# use.mid.pvalues = FALSE
# use.doubling = FALSE
# response <- PUT(url=paste(cluego.base.url,"stats",enrichment.type,multiple.testing.correction,use.mid.pvalues,use.doubling,sep="/"), encode = "json")
# 
# # 3.8 Set the Kappa Score level
# kappa.score = 0.4
# response <- PUT(url=paste(cluego.base.url,"ontologies","set-kappa-score-level",kappa.score,sep="/"), encode = "json")
# 
# # 3.9 Set grouping parameters
# do.grouping = TRUE
# coloring.type = "Random" # ("Random","Fix")
# group.leading.term = "Highest Significance" # ("Highest Significance","#Genes / Term","%Genes / Term","%Genes / Term vs Cluster")
# grouping.type = "Kappa Score" # ("Kappa Score","Tree")
# init.group.size = 1
# perc.groups.for.merge = 50
# perc.terms.for.merge = 50
# response <- PUT(url=paste(cluego.base.url,"grouping",do.grouping,coloring.type,group.leading.term,grouping.type,init.group.size,perc.groups.for.merge,perc.terms.for.merge,sep="/"), encode = "json")


#### 4.0 Run ClueGO Analysis ####
print(paste("4.0 Run ClueGO Analysis",sep=""))
# Run the analysis an save log file
analysis.name <- example.selection
analysis.option <- "Cancel and refine selection" # ("Continue analysis","Skip the grouping","Cancel and refine selection")  -> Analysis option in case there are more than 1000 terms found!
response <- GET(paste(cluego.base.url,URLencode(analysis.name),URLencode(analysis.option),sep="/"))
log.file.name = paste(output.folder,"ClueGO-Example-Analysis-log.txt",sep="/")
writeLines(content(response,encoding="UTF-8"),log.file.name)
# print(content(response, encode = "text"))

# 4.1 Get network id (SUID) (CyRest function from Cytoscape)
response <- GET(paste(cytoscape.base.url,"networks","currentNetwork",sep="/"))
current.network.suid <- content(response, encode = "json")$data$networkSUID
# print(current.network.suid)

print(paste("Save results",sep=""))

# Get network graphics (CyRest function from Cytoscape)
image.type = "svg" # png, pdf
response <- GET(paste(cytoscape.base.url,"networks",current.network.suid,"views",paste("first.",image.type,sep=""),sep="/"))
image.file.name = paste(output.folder,paste("ClueGOExampleNetwork.",image.type,sep=""),sep="/")
writeBin(content(response, encode = "raw"),image.file.name)

# 4.2 Get ClueGO result table
response <- GET(paste(cluego.base.url,"analysis-results","get-cluego-table",current.network.suid,sep="/"))
result.table.text <- content(response, encode = "text", encoding = "UTF-8")
table.file.name = paste(output.folder,"ClueGO-Example-Result-Table.txt",sep="/")
write.table(text.to.data.frame(result.table.text),file=table.file.name,row.names=FALSE,quote = FALSE, na="",col.names=TRUE, sep="\t")

# 4.3 Get ClueGO genes and main functions
number.of.functions.to.add = 3
response <- GET(paste(cluego.base.url,"analysis-results","get-main-functions",current.network.suid,number.of.functions.to.add,sep="/"))
result.table.text <- content(response, encode = "text", encoding = "UTF-8")
table.file.name = paste(output.folder,"ClueGO-Genes-With-Main-Functions.txt",sep="/")
write.table(text.to.data.frame(result.table.text),file=table.file.name,row.names=FALSE,quote = FALSE, na="",col.names=TRUE, sep="\t")

# 4.4 Get genes result table
response <- GET(paste(cluego.base.url,"analysis-results","get-gene-table",current.network.suid,sep="/"))
result.table.text <- content(response, encode = "text", encoding = "UTF-8")
table.file.name = paste(output.folder,"ClueGO-Gene-Table.txt",sep="/")
write.table(text.to.data.frame(result.table.text),file=table.file.name,row.names=FALSE,quote = FALSE, na="",col.names=TRUE, sep="\t")

# 4.5 Get Kappascore Matrix
response <- GET(paste(cluego.base.url,"analysis-results","get-kappascore-matrix",current.network.suid,sep="/"))
result.table.text <- content(response, encode = "text", encoding = "UTF-8")
table.file.name = paste(output.folder,"ClueGO-Kappascore-Matrix.txt",sep="/")
write.table(text.to.data.frame(result.table.text),file=table.file.name,row.names=FALSE,quote = FALSE, na="",col.names=TRUE, sep="\t")

# 4.6 Get binary Gene-Term Matrix
response <- GET(paste(cluego.base.url,"analysis-results","get-binary-gene-term-matrix",current.network.suid,sep="/"))
result.table.text <- content(response, encode = "text", encoding = "UTF-8")
table.file.name = paste(output.folder,"ClueGO-Binary-Gene-Term-Matrix.txt",sep="/")
write.table(text.to.data.frame(result.table.text),file=table.file.name,row.names=FALSE,quote = FALSE, na="",col.names=TRUE, sep="\t")

# 4.7 ClueGO Result Chart
# Get result charts for both cluster as pie chart
chart.type = "PieChart" # ("PieChart","BarChart")
image.type = "svg" # ("svg","png","pdf")
response <- GET(paste(cluego.base.url,"analysis-results","get-cluego-result-chart",current.network.suid,cluster1,chart.type,image.type,sep="/"))
image.file.name = paste(output.folder,paste("ClueGO-",chart.type,"-For-Cluster",cluster1,".",image.type,sep=""),sep="/")
writeBin(content(response, encode = "raw"),image.file.name)
if(example.selection == "ClueGO Rest Example for two gene lists") {
    response <- GET(paste(cluego.base.url,"analysis-results","get-cluego-result-chart",current.network.suid,cluster2,chart.type,image.type,sep="/"))
    image.file.name = paste(output.folder,paste("ClueGO-",chart.type,"-For-Cluster",cluster2,".",image.type,sep=""),sep="/")
    writeBin(content(response, encode = "raw"),image.file.name)
}

## [optional functions and settings, un comment and modify if needed]
# # 4.8 Remove ClueGO analysis result
# print(paste("Remove ClueGO Network",sep=""))
# # Remove analysis to reduce memory usage. This is important when using patch modes that create lots of analyses.
# response <- DELETE(paste(cluego.base.url,"remove-cluego-analysis-result",current.network.suid,sep="/"))
#
# 4.9 Remove all ClueGO analysis results
# print(paste("Remove all ClueGO Networks",sep=""))
# response <- DELETE(paste(cluego.base.url,"remove-all-cluego-analysis-results",sep="/"))

print(paste("Example analysis ",example.selection," done",sep=""))

