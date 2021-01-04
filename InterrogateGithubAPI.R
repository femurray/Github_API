#Part 1 - Accessing Respository REST API

#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)
#install.packages("plotly")
library(plotly)
#install.packages("devtools")
require(devtools)

# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "femurray_REST_API",
                   key = "436298a79b8fb1791f4e",
                   secret = "f2dcb2a503587e4bd5efb6839c061952d6e7ac68")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- httr::config(token = github_token)
req <- GET("https://api.github.com/users/femurray/repos", gtoken)

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


#Part 2 - Metric Visualisation Project

#My account has very few contributions, so I will be 
#using someone else's github account to create 
#more interesting graphs

#I have chosen fabpot (Fabien Potencier), who is the 
#Github user with most contributions according to the
#first Google result for "most active github users".

myData = GET("https://api.github.com/users/fabpot/followers?per_page=100;", gtoken)
stop_for_status(myData)
extract = content(myData)
#converts into dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login

# Retrieve a list of usernames
id = githubDB$login
user_ids = c(id)

# Create an empty vector and data.frame
users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()
)

#loops through users and adds to list
for(i in 1:length(user_ids))
{
  
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  #Does not add users if they have no followers
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  #Loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    # Check that the user is not already in the list of users (duplicates)
    if (is.element(followingLogin[j], users) == FALSE)
    {
      #Add user to current list
      users[length(users) + 1] = followingLogin[j]
      
      #Retrieve data on each user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Retrieve who each user follows
      followingNumber = followingDF2$following
      
      #Retrieve each user's followers
      followersNumber = followingDF2$followers
      
      #Retrieve each user's number of repositories
      reposNumber = followingDF2$public_repos
      
      #Retrieve year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      #Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
      
    }
    next
  }
  #Stop when there are more than 100 users
  if(length(users) > 100)
  {
    break
  }
  next
}

#Use plotly to graph

Sys.setenv("plotly_username"="femurray")
Sys.setenv("plotly_api_key"="BMPXLhSQaa3tYcmn51gK")

#Plot repositories v followers coloured by year
plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

#Send to plotly
api_create(plot1, filename = "Repositories vs Followers")

#Plot 2 graphs following v followers coloured by year
plot2 = plot_ly(data = usersDB, x = ~following, y = ~followers, text = ~paste("Followers: ", followers, "<br>Following: ", following), color = ~dateCreated)
plot2

#Send to plotly
api_create(plot2, filename = "Following vs Followers")

#Now attempting to graph the 10 most popular languages used by the 100 users.
languages = c()

for (i in 1:length(users))
{
  RepositoriesUrl = paste("https://api.github.com/users/", users[i], "/repos", sep = "")
  Repositories = GET(RepositoriesUrl, gtoken)
  RepositoriesContent = content(Repositories)
  RepositoriesDF = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent))
  RepositoriesNames = RepositoriesDF$name
  
  #Loop through all the repositories of an individual user
  for (j in 1: length(RepositoriesNames))
  {
    #Find all repositories and save in data frame
    RepositoriesUrl2 = paste("https://api.github.com/repos/", users[i], "/", RepositoriesNames[j], sep = "")
    Repositories2 = GET(RepositoriesUrl2, gtoken)
    RepositoriesContent2 = content(Repositories2)
    RepositoriesDF2 = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent2))
    language = RepositoriesDF2$language
    
    #Removes repositories containing no specific languages
    if (length(language) != 0 && language != "<NA>")
    {
      languages[length(languages)+1] = language
    }
    next
  }
  next
}

#Puts 10 most popular languages in table 
allLanguages = sort(table(languages), increasing=TRUE)
top10Languages = allLanguages[(length(allLanguages)-9):length(allLanguages)]

#Converts to dataframe
languageDF = as.data.frame(top10Languages)

#Plot the data frame of languages
plot3 = plot_ly(data = languageDF, x = languageDF$languages, y = languageDF$Freq, type = "bar")
plot3

Sys.setenv("plotly_username"="femurray")
Sys.setenv("plotly_api_key"="BMPXLhSQaa3tYcmn51gK")
api_create(plot3, filename = "10 Most Popular Languages")
