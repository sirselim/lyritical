# lyritical
Analysis of song and artist lyrics in R - just for fun!!

The idea came to me as I was driving listening to spoitfy - I wonder how many times the word *tonight* has been mentioned in this song? What about by this artist in general? There was only one way to find out, write a few lines of `R` script!

`lyritical` was born, part **lryi**cs, part analy**tical**, all just because.

## What does it do?

example:

`artist_wordcloud(artist = 'Mastodon', verbose = F, max.words = 300)`

*artist*: your favourite artist ()obviously)  
*verbose*: display a scrolling list of all songs as they are scraped from lyrics.com  
*max.words*: how many words should the wordcloud render?

## Thing to do

  - convert to realtime shiny app
  - interactive wordclouds? (maybe using D3 or htmltools) 
