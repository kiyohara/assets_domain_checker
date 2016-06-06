require "Hashie"
require "terminal-table"

module AssetsDomainChecker
  class AssetsDomain < ::Hashie::Mash
    def self.parse_ltsv(file)
      unless File.exist?(file)
        raise "file not found: #{file}"
      end
      arr = LTSV.load(file)

      res = []
      arr.each do |i|
        res << AssetsDomain.new(i)
      end
      res
    end

    def self.dump_ltsv(obj)
      res = ""
      if obj.is_a?(Array)
        obj.each do |i|
          res += "#{LTSV.dump(i.to_hash)}\n"
        end
      else
        res = LTSV.dump(obj.to_hash)
      end
      res
    end

    def self.puts_array(arr)
      rows = []
      total_ref_count = 0
      arr.each do |i|
        total_ref_count += i.ref_count
      end

      arr.each do |i|
        rows << [
          i.snipped_domain,
          i.ref_count,
          "%6.2f%"%(i.ref_count * 100.0 / total_ref_count)
        ]
      end

      table = Terminal::Table.new :rows => rows
      puts table
    end

    def <=>(other)
      self.ref_count <=> other.ref_count
    end
  end
end
