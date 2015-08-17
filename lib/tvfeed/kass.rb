require 'tvfeed/source'
require 'uri'

class TVFeedSource::KASS < TVFeedSource
  def initialize(config)
    super

    @search_url = 'http://kass.filesoup.co.uk/usearch/?q={{query}}'
  end

  def parse_results(html)
    m = html.scan /<tr class="(even|odd)".*?>(.*?)<\/tr>/m

    results = []

    if m
      for i in 0...m.length
        n = m[i][1].match /<a rel=".*?" class=".*?" href="(.*?)#comment">.*?onclick=".*?'name': '(.*?)', 'magnet': '(.*?)'/m

        if n
          url = n[1]
          title = n[2]
          magnet = n[3]
          trusted = m[i][1].include?('title="Verified Torrent"')

          n = m[i][1].match /<td class="nobr center">([0-9\.]+) <span>(.*?)<.*?<td.*?>.*?<\/td>.*?<td.*?>.*?<\/td>.*?<td.*?>([0-9]+)<\/td>.*?<td.*?>([0-9]+)<\/td>/m

          if n
            results.push({
              :url => URI.unescape(url),
              :title => URI.unescape(title),
              :magnet => URI.unescape(magnet),
              :trusted => trusted,
              :size => n[1] + ' ' + n[2],
              :seeds => n[3].to_i,
              :peers => n[4].to_i
            })
          end
        end
      end
    end

    results
  end
end
