#### lyritical: analysis of song lyrics
## author: Miles Benton
## created: 2016-03-14
## last modified: 2018-06-05

# load required packages
require(geniusR)
require(tidytext)
require(wordcloud2)
require(tidyverse)

##########################################################################
############################# song_wordcloud #############################
##                                                                      ##
## example usage                                                        ##
# song_wordcloud(song = 'hallowed be thy name', artist = 'iron maiden') ##
##########################################################################

song_wordcloud <- function(song, artist) {
  
  # now using the geniusR package to scrape info
  genius_data <- genius_lyrics(artist = artist, song = song)
  
  tidy_genius <- genius_data %>% 
    unnest_tokens(word, lyric) %>% 
    anti_join(stop_words)
  
  word_data <- tidy_genius %>% 
    count(word, sort = TRUE)
  
  # extract and clean the lyrics
  lyrics_clean <- genius_data$lyric %>%
    gsub('<br>', ' ', .) %>%
    gsub('.*<p>|</p>.*', '', .) %>%
    gsub('  |   ', ' ', .) %>%
    gsub("[[:punct:]]", "", .) %>%
    strsplit(., split = ' ') %>%
    unlist(.) %>%
    tolower(.)
  lyrics_clean <- lyrics_clean[lyrics_clean != ""]
 
  # explore/analysis of lyrics
  cat('\n', 'Wordcloud for the song', paste0('"', song, '"'), 'by the artist', paste0('"', artist, '".'))
  cat('\n', 'There are', length(lyrics_clean), 'words in this song, and', (unique(lyrics_clean) %>% length(.)), 'of these are unique.')
  lyrics_sorted <- table(lyrics_clean) %>% sort(.) 
  cat('\n', 'The word', paste0('"', names(lyrics_sorted)[length(lyrics_sorted)], '"'), 'appears most at', 
      lyrics_sorted[length(lyrics_sorted)], 'times.', 'For non-stop words', paste0('"', word_data$word[1], '"'), 
      'appears', paste0('"', word_data$n[1], '"'), 'times in this song.', '\n')

  # create wordcloud
  suppressWarnings(wordcloud2(word_data, minSize = 1))
}
## END
##########################################################################


###########################################################################
############################  album_wordcloud  ############################
##                                                                       ##
## example usage                                                         ##
# album_wordcloud(album = 'once more round the sun', artist = 'Mastodon') #
###########################################################################

album_wordcloud <- function(album, artist) {
  
  # now using the geniusR package to scrape info
  genius_data <- genius_album(artist = artist, album = album)
  
  tidy_genius <- genius_data %>% 
    unnest_tokens(word, lyric) %>% 
    anti_join(stop_words)
  
  word_data <- tidy_genius %>% 
    count(word, sort = TRUE)
  
  # extract and clean the lyrics
  lyrics_clean <- genius_data$lyric %>%
    gsub('<br>', ' ', .) %>%
    gsub('.*<p>|</p>.*', '', .) %>%
    gsub('  |   ', ' ', .) %>%
    gsub("[[:punct:]]", "", .) %>%
    strsplit(., split = ' ') %>%
    unlist(.) %>%
    tolower(.)
  lyrics_clean <- lyrics_clean[lyrics_clean != ""]
  
  # explore/analysis of lyrics
  
  cat('\n', 'Wordcloud for', paste0('"', album, '"'), 'by', paste0('"', artist, '".'))
  cat('\n', 'There are', genius_data$track_n %>% unique() %>% length(), 'tracks on this album.')
  # lyrics_sorted <- table(lyrics_clean) %>% sort(.) 
  # cat('\n', 'The word', paste0('"', names(lyrics_sorted)[length(lyrics_sorted)], '"'), 'appears most at', 
  #     lyrics_sorted[length(lyrics_sorted)], 'times.', '\n')
  
  # create wordcloud
  suppressWarnings(wordcloud2(word_data, minSize = 1))
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