require "nokogiri"
require "uri"
require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"
require "faraday/encoding"
require "resolv"

module AssetsDomainChecker
  module Util
    USER_AGENT="Mozilla/5.0 (Linux; Android 5.1.1; SOV32 Build/32.0.D.0.282) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.133 Mobile Safari/537.36"

    def load_uri(uri)
      conn = Faraday::Connection.new() do |builder|
        builder.use FaradayMiddleware::FollowRedirects
        builder.use :cookie_jar
        builder.response :encoding
        builder.adapter Faraday.default_adapter
      end
      conn.headers[:user_agent] = USER_AGENT

      response = conn.get(uri.to_s)

      Nokogiri::HTML.parse(response.body, nil, response.body.encoding.to_s)
    end

    REG_IS_ADDR=/.*\.\d+$/

    def addr?(str)
      return str if REG_IS_ADDR.match(str)
    end

    CONCAT_DEPTH_DOMAIN_DEFAULT = [
      ".ne.jp",
      ".co.jp",
    ]

    def escape_cd_domain(cd_domain)
      ".#{cd_domain.gsub(/\./, '___')}"
    end

    def unescape_cd_domain(escaped_cd_domain)
      escaped_cd_domain.sub(/^\./, '').gsub(/___/, '.')
    end

    def snip_domain(domain:, depth: 0, concat_depath_domain: CONCAT_DEPTH_DOMAIN_DEFAULT)
      depth = depth.to_i
      return domain if depth <= 0
      return domain if addr?(domain)

      cd_domain = nil
      concat_depath_domain.each do |i|
        if domain.match(/#{i}$/)
          cd_domain = escape_cd_domain(i)
          domain.sub!(/#{i}$/, cd_domain)
          break
        end
      end

      str_reg_base = "\\.([^.]*)"
      str_reg = ""
      depth.times do |i|
        str_reg += str_reg_base
      end
      str_reg += "$"
      reg = Regexp.new(str_reg)

      match = reg.match(domain)
      if match
        res = match.to_a[1..-1].join(".")
      else
        res = domain
      end

      unless cd_domain.nil?
        res = res.sub!(/#{cd_domain}$/, unescape_cd_domain(cd_domain))
      end

      return res
    end

    def convert_host(host:, domain_depth: 0)
      addr = Resolv.getaddress(host)
      name = Resolv.getname(addr).to_s
      snip_domain(domain: name, depth: domain_depth)
    end

    def puts_error(msg: "", debug: "")
      if msg.to_s.length > 0
        STDERR.puts "ERROR: #{msg.to_s}"
      else
        STDERR.puts "ERROR occured"
      end

      puts_debug(debug)
    end

    def puts_debug(msg)
      if ENV['DEBUG'] && msg.to_s.length > 0
        STDERR.puts "DEBUG: #{msg.to_s}"
      end
    end

    def error_exit(msg: "", debug: "")
      puts_error(msg: msg, debug: debug)
      exit 1
    end
  end
end
