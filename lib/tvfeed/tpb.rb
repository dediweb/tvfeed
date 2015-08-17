require 'tvfeed/source'
require 'uri'

class TVFeedSource::TPB < TVFeedSource
  def initialize(config)
    super

    @search_url = "https://thepiratebay.mn/search/{{query}}/0/7/0"
  end

  def parse_results(html)
    m = html.scan /<a href="(\/torrent\/.*?)" class="detLink" title=".*?">(.*?)<\/a>.*?<a href="(magnet:\?.*?<font).*?, Size ([0-9\.]+)&nbsp;([a-zA-Z]{3}).*?<td align="right">([0-9]+)<\/td>.*?<td align="right">([0-9]+)<\/td>/m

    results = []

    if m != nil
      for i in 0...m.length
        trusted = (m[i][2].include?('vip.gif') or m[i][2].include?('trusted.png'))

        results.push({
          :url => m[i][0],
          :title => m[i][1],
          :magnet => URI.unescape(m[i][2].gsub(/".*$/m, '')),
          :trusted => trusted,
          :size => m[i][3] + ' ' + m[i][4],
          :seeds => m[i][5].to_i,
          :peers => m[i][6].to_i
        })
      end
    end

    results
  end
end
