require 'net/http'

class TVFeedSource
  def initialize(config)
    @config = config
    @search_method = 'GET'
  end

  def find(show, season, episode)
    results = []

    @config[:formats].each do |format|
      query = format.clone
      query.gsub! '{{season}}', season.to_s
      query.gsub! '{{episode}}', episode.to_s
      query.gsub! '{{0season}}', season.to_s.rjust(2,'0')
      query.gsub! '{{0episode}}', episode.to_s.rjust(2,'0')

      url = @search_url.gsub '{{query}}', show + ' ' + query

      if @search_method == 'GET'
        url.gsub! ' ', '%20'
        html = Net::HTTP.get_response(URI(url))
      else
        post = @post_params.clone

        post.each do |key, value|
          post[key].gsub! '{{query}}', query
          post[key].gsub! '{{season}}', season.to_s
          post[key].gsub! '{{episode}}', episode.to_s
          post[key].gsub! '{{0season}}', season.to_s.rjust(2,'0')
          post[key].gsub! '{{0episode}}', episode.to_s.rjust(2,'0')
        end

        u = URI.parse(url)

        http = Net::HTTP.new(u.host, u.port)

        if url.match /^https:\/\//
          http.use_ssl = true
        end

        req = Net::HTTP::Post.new(u.path)
        req.set_form_data(post)

        html = http.request(req)
      end

      parse_results(html.body).each do |result|
        if result[:seeds] >= @config[:min_seeds] and (!@config[:trusted_only] || result[:trusted])
          if result[:title].downcase.include? query.downcase
            results.push result
          end
        end
      end
    end

    results = results.sort_by do |k| k[:seeds] end

    limited_results = []

    results.reverse_each do |result|
      limited_results.push result

      if limited_results.length >= @config[:max_results]
        break
      end
    end

    limited_results
  end

  def get(url)
    Net::HTTP.get_response(URI(url))
  end
end
