module BigcommerceAPI

  class Base
    extend BigcommerceAPI

    include HTTParty
    format :json
    headers 'Accept' => "application/json"
    headers 'Content-Type' => "application/json"

    def initialize(params={})
      # for the time being, accept old school API params
      if params[:username] and params[:api_key]
        self.class.basic_auth params[:username], params[:api_key]
      # default to Oauth
      else
        self.class.headers 'X-Auth-Client' => params[:client_id]
        self.class.headers 'X-Auth-Token' => params[:access_token]
      end

      # if we're using Oauth, we're probably grabbing :store_hash
      # accept :store_url for legacy purposes
      if params[:store_url]
        self.class.base_uri(params[:store_url] + '/api/v2/')
      else
        self.class.base_uri("https://api.bigcommerceapp.com/stores/#{params[:store_hash]}/v2/")
      end
    end

    def time
      response = self.class.get('/time')
      response.parsed_response['time']
    end
    alias_method :get_time, :time

    def information
      response = self.class.get('/information')
      response.parsed_response['information']
    end
    alias_method :info, :information

    # this grabs all of the FIRST LEVEL attributes
    # it ignores hashed and constructed nested attributes,
    # since Big Commerce won't let us set those anyway
    def attributes(strip_empty=false)
      hash = {}
      self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var) if (var.to_s['_hash'].nil? and var.to_s['_resource'].nil? and var.to_s[self.resource + '_type'].nil?) }
      hash = BigcommerceAPI::Resource.date_adjust(hash)
      BigcommerceAPI::Resource.clean!(hash) if strip_empty
      hash.delete('id') if strip_empty
      return hash
    end

    class << self
      def clean!(hash)
        hash.each do |k, v| 
          if v.is_a? Hash
            clean!(v)
          else
            hash.delete(k) if v.nil? or v == ''
          end
        end
      end

      # Returns the date formatted as
      # RFC 2822 string
      def to_rfc2822(datetime)
        datetime.strftime("%a, %d %b %Y %H:%M:%S %z")
      end
      
      def date_adjust(params)
        [:date_created, :date_modified, :date_last_imported, :date_shipped, :min_date_created, :max_date_created, :min_date_modified, :max_date_modified, :min_date_last_imported, :max_date_last_imported].each do |date|
          [date, date.to_s].each do |d|
            if params[d] and !params[d].nil? and params[d] != ''
              if params[d].is_a?(String)
                params[d] = DateTime.parse(params[d])
              end
              # params[d] = CGI::escape(to_rfc2822(params[d]))
              params[d] = to_rfc2822(params[d])
            end
          end
        end
        return params
      end
    end
        
  end

end