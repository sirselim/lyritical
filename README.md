# lyritical
Analysis of song and artist lyrics in R - just for fun!!

The idea came to me as I was driving listening to Spotify - I wonder how many times the word *tonight* has been mentioned in this song? What about by this artist in general? There was only one way to find out, write a few lines of `R` script!

`lyritical` was born, part **lryi**cs, part analy**tical**, all just because.

## What does it do?

Currently there are functions to explore the number of times words are used in a given song, or by a given artist (so across all of their songs). `lyritical` uses web-scraping to pull lyrics from lyrics.com (*I will look to expand this later*) using the `rvest` package.

### song_wordcloud

Provide the artist and the song title and this function will generate a wordcloud, allowing direct visualisation of most present lyrics. This will also return the number of words in the song, the number of unique words and the word that appears the most (*still working on filtering 'junk' words*).

example:

    song_wordcloud(artist = 'sia', song = 'chandelier')

    There are 241 words in this song, and 88 are unique. 
    The word tonight appears most at 13 times.

![](images/sia_chandelier_wordcloud.png)

### artist_wordcloud

This function takes an artist name as input and pulls in all available lyrics and finally generates a wordcloud showing the prevalence of words used by said artist. Alongside the wordcloud there is also a basic reporting system which currently returns:

  - number of songs listed for the artist
  - number of songs with lyrics available
  - average number of words per song
  - most words per song (reports the song)
  - least words per song (reports the song)

example:

`artist_wordcloud(artist = 'Mastodon', verbose = F, max.words = 300)`

  - *artist*: your favourite artist (obviously)  
  - *verbose*: display a scrolling list of all songs as they are scraped from lyrics.com  
  - *max.words*: how many words should the wordcloud render?

![](images/artist_mastodon_cloud.png)

    there were 106 songs found on lyrics.com for Mastodon  
    12 songs had lyrics available  
    the average number of words per song for Mastodon is 174  
    the most words per song for Mastodon is 533 (last baron) 
    the least words per song for Mastodon is 62 (creature lives)  

## Things to do

  - convert to realtime shiny app
  - interactive wordclouds? (maybe using D3 or htmltools) 
  - work on reducing the number of 'filler' words reported (can, the, ... etc.)
  - add additional sources of lyrics
    + this adds complexity as there will need to be a way to removed duplicates
  - could get track metadata (length etc) and compare to other statistics
  - add a cache system where there is a check for previous artist searches
    + if artist has a csv file saved load and generate wordcloud, if not run as usual
    + add an overwrite argument to the function 

## Dependencies

There are currently 5 `R` packages required:

  - `rvest`
  - `magrittr`
  - `wordcloud`
  - `XML`
  - `RColorBrewer`