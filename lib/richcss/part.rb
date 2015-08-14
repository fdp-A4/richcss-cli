require 'json'
require 'rest-client'
require 'uri'
require 'zipruby'

module Richcss
  class Part
    attr_accessor :name

    # Fetch url and download the part
    def fetch()
       puts "Fetching part #{name}"

      begin
        resp = RestClient.get "http://localhost:3000/api/part/#{name}"
        if resp.code == 200
          body = JSON.parse(resp.to_str)
          self.install(body['url'])
        else
          puts "Error: Part #{name} cannot be found."
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

    # Install this part
    def install(resource)
      uri = URI.parse(resource)

      http_object = Net::HTTP.new(uri.host, uri.port)
      http_object.use_ssl = true if uri.scheme == 'https'
      begin
        http_object.start do |http|
          request = Net::HTTP::Get.new uri.request_uri
          http.read_timeout = 500
          http.request request do |response|
            case response
            when Net::HTTPRedirection then
              location = response['location']
              install(location)
            else
              puts "Installing part..."

              # TODO make verifier class do this
              if !Dir.exists?('parts')
                FileUtils.mkdir_p('parts')
              end

              Dir.chdir('parts') do
                Zip::Archive.open_buffer(response.body) do |ar|

                   #save the directory name for rename later
                   oldDirName = ar[0].name

                   ar.each do |zf|
                      if zf.directory?
                         FileUtils.mkdir_p(zf.name)
                      else
                         dirname = File.dirname(zf.name)
                         FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
                         open(zf.name, 'wb') do |f|
                            f << zf.read
                         end
                      end
                   end

                   FileUtils.move(oldDirName, name)

                end
              end
            end
          end
        end
      rescue Exception => e
        puts e
      end
    end
  end
end
