#### analysis of song lyrics
## author: Miles Benton
## created: 2016-03-14
## last modified: 2016-03-14


# things to explore:
# wordcloud
# number of words
# unique words
# could get track metadata (length etc) and compare to above

# load required packages
require(rvest)
require(magrittr)
require(wordcloud)
require(XML)

# define song and artist
song <- 'hero of the day'
artist <- 'metallica'
# could add tolower() for upper case if used

song <- 'Elastic Heart'
artist <- 'Sia'

# define the search term
lyric_search <- paste(song, 'lyrics', artist, sep = '-') %>% gsub(' ', '-', .)

# generate the html link
lyric_html <- paste0('http://www.lyrics.com/', lyric_search, '.html') %>% tolower(.)

# scrape the html
lyrics <- read_html(lyric_html)

# extract and clean the lyrics
lyrics_clean <- lyrics %>%
                html_node("#lyrics") %>% 
                html_text() %>% gsub('\n', ' ', .) %>% 
                gsub('---.*', '', .) %>% 
                gsub('  ', ' ', .) %>% 
                gsub(',', '', .) %>% 
                strsplit(., split = ' ') %>%
                unlist(.) %>%
                tolower(.)

# explore/analysis of lyrics
length(lyrics_clean)
unique(lyrics_clean) %>% length(.)
table(lyrics_clean) %>% sort(.) %>% max(.)  # number of times for 'top' word
table(lyrics_clean) %>% sort(.) %>% barplot(., las = 2)
wordcloud(lyrics_clean, min.freq = 1)



##################################################################
# can access artist pages which list all songs (links to lyrics) #
# eg. http://www.lyrics.com/metallica                            #
##################################################################

# metallica <- read_html("http://www.lyrics.com/metallica")

## define an artist and get urls for all their listed lyrics from lyrics.com
# 
# artist <- 'Sia'
# artist <- 'Metallica'
# 
# url <- paste0("http://www.lyrics.com/", artist)
# doc <- htmlParse(url)
# links <- xpathSApply(doc, "//a/@href")
# links <- unique(links[grep('-remix-|-DVD-|-dvd-|radio-version|-live-|-soundtrack-|/track-|-track-|-mix-|untitled|-version-', links, 
# invert = T)])
# free(doc)
# 
# # grab a random selection of songs
# links_sample <- as.character(sample(links, 50))
# 
# # create a empty object (need to look at apply for this)
# lyric_results <- NULL
# 
# # find the lyrics where possible
# for (i in links_sample) {
#   
#   link <- paste0('http://www.lyrics.com', i)
#   cat('getting lyrics for:', link, '\n')
#   
#   try(silent = T,
#   lyrics <- read_html(link) %>%
#             html_node("#lyrics") 
#   )
#   
#   if (exists('lyrics') == TRUE) {
#   
#   lyrics <- html_text(lyrics) %>% 
#             gsub('\n', ' ', .) %>% 
#             gsub('---.*', '', .) %>% 
#             gsub('  ', ' ', .) %>% 
#             # gsub(',', '', .) %>%
#             # gsub('?', '', .) %>%
#             gsub("[[:punct:]]", "", .) %>%
#             strsplit(., split = ' ') %>%
#             unlist(.) %>%
#             tolower(.) %>%
#             paste(collapse = ' ')
#   
#   lyric_results <- rbind(lyric_results, lyrics)
#   
#   rm(lyrics)
#   
#   }
# }
# 
# 
# # define a colour pallete
# require(RColorBrewer)
# pal <- brewer.pal(6,"Dark2")
# pal <- pal[-(1)]
# 
# # create wordcloud
# wordcloud(lyric_results, scale = c(3,.5), min.freq = 2, colors = pal)



artist_wordcloud <- function(artist, verbose = TRUE, max.words = 250) {
  
  cat('building wordcloud for:', artist, '\n')
  
  url <- paste0("http://www.lyrics.com/", artist) %>% tolower(.)
  doc <- htmlParse(url)
  links <- xpathSApply(doc, "//a/@href")
  links <- links[grep('-lyrics-', links)]
  links <- links[grep('-remix-|-DVD-|-dvd-|radio-version|-live-|-soundtrack-|/track-|-track-|-mix-|untitled|-version-|-dvdlive-', 
                      links, invert = T)] %>%
           unique(.)
  free(doc)
  
  # grab a random selection of songs
  # links_sample <- as.character(sample(links, 50))
  links_sample <- as.character(links)
  
  # create a empty object (need to look at apply for this)
  lyric_results <- NULL
  
  # find the lyrics where possible
  for (i in links_sample) {
    
    link <- paste0('http://www.lyrics.com', i)
    
    if (verbose == TRUE) cat('getting lyrics for:', link, '\n')
    
    try(silent = T,
        lyrics <- read_html(link) %>%
          html_node("#lyrics") 
    )
    
    if (exists('lyrics') == TRUE) {
      
      lyrics <- html_text(lyrics) %>% 
        gsub('\n', ' ', .) %>% 
        gsub('---.*', '', .) %>% 
        gsub('  ', ' ', .) %>% 
        # gsub(',', '', .) %>%
        # gsub('?', '', .) %>%
        gsub("[[:punct:]]", "", .) %>%
        strsplit(., split = ' ') %>%
        unlist(.) %>%
        tolower(.) %>%
        paste(collapse = ' ')
      
      lyric_results <- rbind(lyric_results, lyrics)
      
      rm(lyrics)
      
    }
  }
  # define a colour pallete
  require(RColorBrewer)
  pal <- brewer.pal(6, "Dark2")
  pal <- pal[-(1)]
  
  # create wordcloud
  wordcloud(lyric_results, scale = c(3,.5), min.freq = 3, colors = pal, max.words = max.words)
  
  # some stats
  cat('\n', 'there were', length(links), 'songs found on lyrics.com for', artist, '\n')
  cat('\n', length(lyric_results), 'songs had lyrics available', '\n')
  # cat('\n', '\n')
  # cat('\n', '\n')
  
}

# artist_wordcloud('metallica')
# artist_wordcloud('Sia')
artist_wordcloud('Chevelle', verbose = F)
artist_wordcloud('Disturbed', verbose = F, max.words = 300)


