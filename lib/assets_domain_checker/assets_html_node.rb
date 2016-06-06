require "assets_domain_checker/util"

module AssetsDomainChecker
  class AssetsHTMLNodeArray
    include Util

    def nodes
      @nodes ||= []
    end

    def append(node)
      nodes << node
    end

    def to_s
      nodes.to_s
    end

    def group_by_host()
      buf_ref_count = {}
      nodes.each do |node|
        begin
          buf_ref_count[node.assets_host] = buf_ref_count[node.assets_host].to_i + 1
        rescue => e
          puts_debug(e)
          puts_debug("assets_uri_string: #{node.assets_uri_string}")
          next
        end
      end

      res = []
      buf_ref_count.keys.each do |i|
        res << AssetsDomain.new(
          domain: i,
          ref_count: buf_ref_count[i],
          ref_domain_count: 1,
        )
      end
      res
    end
  end

  class AssetsHTMLNode
    def self.parse(node:, default_host: "")
      tag_name = node.name.downcase
      case tag_name
      when 'img'
        return AssetsHTMLImg.new(node: node, default_host: default_host)
      when 'link'
        return AssetsHTMLLink.new(node: node, default_host: default_host)
      else
        raise StandardError "Unknown node: " + tag_name
      end
    end

    def initialize(node:, default_host: "")
      @node = node
      @default_host = default_host
    end

    def assets_uri_string
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def assets_uri
      @uri ||= URI.parse(assets_uri_string)
    end

    def assets_host
      if assets_uri.host.nil?
        @default_host
      else
        assets_uri.host
      end
    end
  end

  class AssetsHTMLImg < AssetsHTMLNode
    def assets_uri_string
      attr = @node.attribute('src')
      attr.nil? ? nil : attr.value
    end
  end

  class AssetsHTMLLink < AssetsHTMLNode
    def assets_uri_string
      @node.attribute('href').value
    end
  end
end
