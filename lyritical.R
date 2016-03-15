#### lyritical: analysis of song lyrics
## author: Miles Benton
## created: 2016-03-14
## last modified: 2016-03-16

# load required packages
require(rvest)
require(magrittr)
require(wordcloud)
require(XML)
require(RColorBrewer)

##########################################################################
############################# song_wordcloud #############################
## using decoda for lyrics                                              ##
## eg. 'http://www.decoda.com/metallica-one-lyrics'                     ##
## example usage                                                        ##
# song_wordcloud(song = 'hallowed be thy name', artist = 'iron maiden') ##
##########################################################################

song_wordcloud <- function(song, artist) {
  
  # define the search term
  lyric_search <- paste(artist, song, 'lyrics', sep = '-') %>% gsub(' ', '-', .)
  
  # generate the html link
  lyric_html <- paste0('http://www.decoda.com/', lyric_search) %>% tolower(.) %>% gsub(' ', '', .)
  
  # scrape the html
  lyrics <- read_html(lyric_html)
  
  # extract and clean the lyrics
  lyrics_clean <- lyrics %>%
    html_node("#lyrics-output") %>% 
    # html_text() %>% 
    gsub('<br/>', ' ', .) %>% 
    gsub('.*<p>|</p>.*', '', .) %>%
    gsub('  |   ', ' ', .) %>% 
    gsub("[[:punct:]]", "", .) %>%
    strsplit(., split = ' ') %>%
    unlist(.) %>%
    tolower(.)
  lyrics_clean <- lyrics_clean[lyrics_clean != ""] 
  
  # horrible line below that needs addressing, some songs contain info that needs trimming out
  lyrics_clean <- lyrics_clean[lyrics_clean %>% grep('classlyr|chorusspan', ., invert = T)] %>% gsub('.*span|chorus', '', .)
  lyrics_clean <- lyrics_clean[lyrics_clean != ""] 
  # filter 'junk' words
  lyrics_clean2 <- lyrics_clean[grep('^to$|^of$|^a$|^i$|^the$|^for$|^in$|^on$|^and$|^im$|^me$', lyrics_clean, invert = T, fixed = F)]
  
  # explore/analysis of lyrics
  cat('\n', 'There are', length(lyrics_clean), 'words in this song, and', (unique(lyrics_clean) %>% length(.)), 'are unique.', '\n')
  lyrics_sorted <- table(lyrics_clean2) %>% sort(.) 
  cat('\n', 'The word', names(lyrics_sorted)[length(lyrics_sorted)], 'appears most at', lyrics_sorted[length(lyrics_sorted)], 'times.', '\n')
  
  # define a colour pallete
  require(RColorBrewer)
  pal <- brewer.pal(6, "Dark2")
  pal <- pal[-(1)]
  # wordcloud
  suppressWarnings(wordcloud(lyrics_clean, min.freq = 1, colors = pal))
  
}
## END
##########################################################################


##########################################################################
############################ artist_wordcloud ############################
#                                                                       ##
## search artist and get urls for all their lyrics from lyrics.com      ##
## can access artist pages which list all songs (links to lyrics)       ##
# eg. http://www.lyrics.com/metallica                                   ##
## example usage                                                        ##
# artist_wordcloud('Mastodon', verbose = F, max.words = 300)            ##
##########################################################################

artist_wordcloud <- function(artist, verbose = TRUE, max.words = 250) {
  
  cat('building wordcloud for:', artist, '\n')
  
  url <- paste0("http://www.lyrics.com/", artist) %>% tolower(.) %>% gsub(' ', '', .)
  doc <- htmlParse(url)
  links <- xpathSApply(doc, "//a/@href")
  links <- links[grep('-lyrics-', links)]
  links <- links[grep('-remix-|-DVD-|-dvd-|radio-version|-live-|-soundtrack-|/track-|-track-|-mix-|untitled|-version-|-dvdlive-', 
                      links, invert = T)] %>%
           unique(.)
  free(doc)
  
  # grab a random selection of songs
  # links_sample <- as.character(sample(links, 50))
  # links_sample <- as.character(links)
  
  # create a empty object (need to look at apply for this)
  lyric_results <- NULL
  
  # find the lyrics where possible
  for (i in links) {
    
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
      
      lyric_results <- rbind(lyric_results, data.frame(song = i, lyrics = lyrics))
      
      rm(lyrics)
      
    }
  }
  # clean up song name in results
  lyric_results$song <- gsub('-lyrics.*|/', '', lyric_results$song) %>% gsub('-', ' ', .)
  
  # define a colour pallete
  require(RColorBrewer)
  pal <- brewer.pal(6, "Dark2")
  pal <- pal[-(1)]
  
  # create wordcloud
  wordcloud(lyric_results$lyrics, scale = c(3,.5), min.freq = 3, colors = pal, max.words = max.words)
  # get word counts for each song
  lyric_stats <- sapply(gregexpr("[[:alpha:]]+", lyric_results$lyrics), function(x) sum(x > 0))
  # add word counts to lyric_results
  lyric_results <- data.frame(lyric_results, word.count = lyric_stats)
  
  # some stats
  cat('\n', 'there were', length(links), 'songs found on lyrics.com for', artist, '\n')
  cat('\n', nrow(lyric_results), 'songs had lyrics available', '\n')
  # a little more indepth
  cat('\n', 'the average number of words per song for', artist, 'is', round(mean(lyric_stats), 0), '\n')
  cat('\n', 'the most words per song for', artist, 'is', max(lyric_stats),
      paste0('(', lyric_results[lyric_results$word.count == max(lyric_stats),]$song, ')'), '\n')
  cat('\n', 'the least words per song for', artist, 'is', min(lyric_stats),
      paste0('(', lyric_results[lyric_results$word.count == min(lyric_stats),]$song, ')'), '\n')
  
}
## END
##########################################################################