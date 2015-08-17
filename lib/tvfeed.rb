require 'tvfeed/tpb'
require 'tvfeed/eztv'
require 'tvfeed/kass'

class TVFeed
  def initialize(config)
    @all_sources = {
      'tpb' => 'TPB',
      'eztv' => 'EZTV',
      'kass' => 'KASS'
    }
    @active_sources = config[:sources]

    @config = {
      :formats => ['S{{0season}}E{{0episode}}','{{season}}x{{0episode}}'],
      :max_results => 20,
      :min_seeds => 2,
      :trusted_only => true
    }
 
    @config.each do |key, value|
      if config[key]
        @config[key] = config[key]
      end
    end
  end

  def find_episode(show, season, episode)
    results = {
      :total => 0,
      :season => season,
      :episode => episode
    }

    @active_sources.each do |source|
      if @all_sources[source] == nil
        raise "TVFeed: source \"#{source}\" does not exist. Available sources are: " + @all_sources.keys.join(', ')
      end

      src = Object::const_get('TVFeedSource::' + @all_sources[source]).new(@config)

      results[source] = []

      src.find(show, season, episode).each do |result|
        results[source].push result
        results[:total] += 1
      end
    end

    results
  end

  def find_next_episode(show, season, episode, verbose=false, checked_season=false)
    if verbose
      print "#{show}: #{season} #{episode+1} ... "
    end

    results = find_episode(show, season, episode+1)

    if results[:total] == 0
      if verbose
        puts "NOT FOUND"
      end

      if !checked_season
        return find_next_episode(show, season+1, 0, verbose, true)
      end

      return false
    end

    if verbose
      puts "FOUND!"
    end

    results
  end
end
