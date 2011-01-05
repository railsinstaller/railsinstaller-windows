module RailsInstaller::Downloads

  require "net/http"

  # Original download() code taken from Rubinius and then butchered ;)
  # https://github.com/evanphx/rubinius/blob/master/configure#L307-350
  def download(url, download_path, count = 3)

   filename = File.basename(url)

   begin

      if ENV["http_proxy"]
        protocol, userinfo, host, port = URI::split(ENV["http_proxy"])
        proxy_user, proxy_pass = userinfo.split(/:/) if userinfo
        http = Net::HTTP::Proxy(host, port, proxy_user, proxy_pass)
      else
        http = Net::HTTP
      end

      uri = URI.parse(url)

      print "Downloading from #{url} to #{download_path}\n" if $Flags[:verbose]
      http.get_response(uri) do |response|

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
            return download(response["location"], download_path, count - 1)

          when Net::HTTPOK

            FileUtils.mkdir_p(File.dirname(download_path))
            size  = 0
            total = response.header["Content-Length"].to_i

            # Ensure that the destination directory exists.
            FileUtils.mkdir_p(download_path) unless Dir.exists?(download_path)

            Dir.chdir(download_path) do
              # See https://github.com/oneclick/rubyinstaller/blob/master/rake/contrib/uri_ext.rb#L234-276
              # for another alternative to this.
              File.open(filename, "wb") do |file|
                response.read_body do |chunk|
                  file << chunk
                  size += chunk.size
                  print "\r      [ %d%% (%d of %d) ]" % [(size * 100) / total, size, total]
                end
              end
              print ": done!\n\n"
            end

          else

            raise RuntimeError, "Failed to download #{url}: #{response.message}"

        end

      end

    rescue Exception => exception
      File.unlink(File.join(download_path,filename)) if File.exists?(File.join(download_path, filename))
      print " ERROR: #{exception.message}\n"
      return false
    end

    return true
  end
end
