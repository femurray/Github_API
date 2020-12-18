
#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "femurray_REST_API",
                   key = "436298a79b8fb1791f4e",
                   secret = "f2dcb2a503587e4bd5efb6839c061952d6e7ac68 ")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "femurray/datasharing", "created_at"] 

#above code sourced from https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

myData = fromJSON("https://api.github.com/users/femurray")

#num followers
myData$followers 

followers = fromJSON("https://api.github.com/users/femurray/followers")
followers$login #username of followers
myData$following #num followed

following = fromJSON("https://api.github.com/users/femurray/following")
following$login #username of followed people

myData$public_repos #num repositories

repos = fromJSON("https://api.github.com/users/femurray/repos")
repos$name #repositories names
repos$created_at #Repository date created
repos$full_name #gives full names of repositories


LCARepos <- fromJSON("https://api.github.com/repos/femurray/LCA/commits")
LCARepos$commit$message #Shows commit messages of LCA assignment


#Interrogate the Github API to extract data from another account by switching the username
shanaData = fromJSON("https://api.github.com/users/CaoimheShanahan1")
shanaData$followers #lists num followers 
shanaData$following #lists number of people followed
shanaData$public_repos #lists number of repositories 
shanaData$bio 


