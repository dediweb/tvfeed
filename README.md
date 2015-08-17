TVFeed v1.0.0
=============

This gem is designed to provide a feed of new TV episodes as magnet links from torrent sites.
This is offered purely for research purposes and should suit those who wish to independently
research the availability of popular TV episodes on torrent sites.

Please do not use this to pirate TV shows.

Currently supported sites are:

- tpb - The Pirate Bay
- eztv - EZTV
- kass - Kickass Torrents

I may add others by request, or if anyone wants to send me a pull request feel free.


Find a specific episode
-----------------------

This will look for season 3 episode 2:

    require 'tvfeed'

    f = TVFeed.new({
      :sources => ['tpb','eztv','kass']
    })

    p f.find_episode "some show", 2, 3


Find the next episode
---------------------

This will look for the next episode *after* season 2 episode 3.  If the next episode number (in this case episode 4)
doesn't exist, it will try looking for the first episode in the next season.  The response includes :season and
:episode numbers for the returned episode which can be fed back into the method repeatedly until all new episodes
have been found.

    require 'tvfeed'

    f = TVFeed.new({
      :sources => ['tpb','eztv','kass']
    })

    p f.find_next_episode "some show", 2, 3


Parameters
----------

The :sources parameter has no default and must be set by the calling code.
The defaults for the other options are below:

    f = TVFeed.new({
      :formats => ['S{{0season}}E{{0episode}}','{{season}}x{{0episode}}'],
      :max_results => 20,
      :min_seeds => 2,
      :trusted_only => true
    })

0season and 0episode are 0-padded versions of the season and episode number.
