module RailsInstaller

  require "net/http"
  require "tempfile"

  # Original download() code taken from Rubinius and then butchered ;)
  # https://github.com/evanphx/rubinius/blob/master/configure#L307-350
  def self.download(package, count = 3)

   filename = File.basename(package.url)
   return if File.exists?(File.join(RailsInstaller::Archives, filename))

   begin

      if ENV["http_proxy"]
        protocol, userinfo, host, port = URI::split(ENV["http_proxy"])
        proxy_user, proxy_pass = userinfo.split(/:/) if userinfo
        http = Net::HTTP::Proxy(host, port, proxy_user, proxy_pass)
      else
        http = Net::HTTP
      end

      uri = URI.parse(package.url)

      print "Downloading from #{package.url} to #{RailsInstaller::Archives}\n" if $Flags[:verbose]
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
            package.url = response["location"]
            return download(package, count - 1)

          when Net::HTTPOK

            temp_file = Tempfile.new("download-#{filename}")
            temp_file.binmode

            size  = 0
            total = response.header["Content-Length"].to_i

            # Ensure that the destination directory exists.
            FileUtils.mkdir_p(RailsInstaller::Archives) unless File.directory?(RailsInstaller::Archives)
            if File.exist?(File.join(RailsInstaller::Archives, filename))
              FileUtils.rm_f(File.join(RailsInstaller::Archives,filename))
            end

            Dir.chdir(RailsInstaller::Archives) do
              # See https://github.com/oneclick/rubyinstaller/blob/master/rake/contrib/uri_ext.rb#L234-276
              # for another alternative to this.
              response.read_body do |chunk|
                temp_file << chunk
                size += chunk.size
                print "\r  => %d%% (%d of %d) " % [(size * 100) / total, size, total]
              end

              temp_file.close
              FileUtils.mv(
                temp_file.path,
                File.join(RailsInstaller::Archives, filename),
                :force => true
              )

              print "\n\n"
            end

          else

            raise RuntimeError, "Failed to download #{url}: #{response.message}"

        end

      end

   rescue Exception => exception

      if File.exists?(File.join(RailsInstaller::Archives, filename))
        File.unlink(File.join(RailsInstaller::Archives,filename))
      end

      printf "ERROR: #{exception.message}\n"

      return false

    end

    return true
  end
end
