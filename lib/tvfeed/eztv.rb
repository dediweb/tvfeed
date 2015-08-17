require 'tvfeed/source'
require 'uri'

class TVFeedSource::EZTV < TVFeedSource
  def initialize(config)
    super

    @search_url = "https://eztv.ag/search/"
    @search_method = 'POST'
    @post_params = {
      "SearchString1" => '{{query}}',
      "SearchString" => "",
      "search" => "Search"
    }
  end

  def parse_results(html)
    m = html.scan /<td.*?class="forum_thread_post".*?<tr.*?class="forum_header_border"/m

    results = []

    m.each do |blob|
      n = blob.match /<a href="(\/ep\/.*?)".*?>(.*?)<\/a>/m

      if n
        url = n[1]
        title = n[2]

        n = blob.match /<a href="(magnet:\?.*?)"/
        if n
          magnet = URI.unescape(n[1]).gsub '&amp;', '&'

          extra = get "https://eztv.ag" + url

          n = extra.body.match /Seeds: <span class=".*?">([0-9]+)<\/span>.*?Peers: <span class=".*?">([0-9]+)<\/span>.*?<b>Filesize:<\/b> (.*?)</m

          results.push({
            :url => url,
            :title => title,
            :magnet => magnet,
            :trusted => true,
            :size => n[3],
            :seeds => n[1].to_i,
            :peers => n[2].to_i
          })
        end
      end
    end

    results
  end
end
