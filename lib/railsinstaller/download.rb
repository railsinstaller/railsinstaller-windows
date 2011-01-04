module RailsInstaller

  # Original download code taken from Rubinius and then butchered ;)
  # https://github.com/evanphx/rubinius/blob/master/configure#L307-350
  require "net/http"

  def self.download(url, file_path, count = 3)

    begin

     if ENV["http_proxy"]
        protocol, userinfo, host, port  = URI::split(ENV["http_proxy"])
        proxy_user, proxy_pass = userinfo.split(/:/) if userinfo
        http = Net::HTTP::Proxy(host, port, proxy_user, proxy_pass)
      else
        http = Net::HTTP
      end

      print "Downloading from #{url} to #{file_path}\n" if $Flags[:verbose]
      http.get_response(URI(url)) do |response|

        case response

        when Net::HTTPNotFound

          raise NET::HTTPNotFound, "Looking for #{url} and received a 404!"
          return false

        when Net::HTTPClientError

          print "ERROR: Client Error : #{response.inspect}\n"
          return false

        when Net::HTTPRedirection

          raise "Too many redirections for the original url, halting." if count <= 0
          print "Redirected to #{response["Location"]}\n" if verbose
          return (download(URI.parse(response["location"]), file_path, count - 1).read(options, &block))

        when Net::HTTPOK

          FileUtils.mkdir_p(File.dirname(file_path))
          size = 0
          total = response.header["Content-Length"].to_i

          # See https://github.com/oneclick/rubyinstaller/blob/master/rake/contrib/uri_ext.rb#L234-276
          # for another alternative to this.
          File.open file_path, "wb" do |f|
            response.read_body do |chunk|
              f << chunk
              size += chunk.size
              print "\r      [ %d%% (%d of %d) ]" % [(size * 100) / total, size, total]
            end
          end
          print "%s" ": done!\n"

        else

          raise RuntimeError, "Failed to download #{url}: #{response.message}"

        end

      end

    rescue Exception => exception
      File.unlink(file_path) if File.exists?(file_path)
      print " ERROR: #{exception.message}\n"
      return false
    end

    return true
  end

end
