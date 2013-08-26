module MsgToolbox
  require 'faraday'
  require 'json'
  require 'xmlsimple'
  require 'open-uri'

  ###########################
  #
  #   PUBLIC METHODS
  #
  ###########################

  ##
  #
  # Send an SMS via Catapult
  #
  # Parameters:
  #   mdn - SMS destination
  #   body - content of SMS
  #   shortcode - short code to use when sending SMS
  #
  # Returns:
  #   XML in response body from Catapult
  #
  ##
  def self.send_sms(mdn, body, shortcode)
    sender = SmsSender.new
    return sender.send(mdn, body, shortcode)
  end

  ##
  #
  # Shorten a URL
  #
  # Parameters:
  #
  #   long_url - URL to be shortened
  #
  # Returns:
  #   short url
  #
  ##
  def self.shorten_url(long_url)
    shortener = UrlShortener.new
    @short_url = shortener.shorten(long_url)
  end

  ##
  #
  # Convenience method to clean supplied MDN of non-numerics
  #
  # Parameters:
  #
  #   mdn - mdn to be cleaned
  #
  # Returns:
  #   mdn stripped of all non-numeric characters
  #
  ##
  def self.clean_mdn(mdn)
    @clean_mdn =mdn.gsub(/[^0-9]/i, '')
  end

  ##
  #
  # Retrieve content from Magic Database
  #
  # Parameters:
  #   collection: base collection to search for content
  #   tags: array of tags to use as search criteria
  #
  # Returns:
  #   @objects: array of populated DataObjects
  #
  ##
  def self.get_content_by_tag(collection, tags)

    tags_json= '{ "tags": ' + JSON.generate(tags) + '}'
    tags_json = URI::encode(tags_json)
    @url = "http://msg-magic-db.herokuapp.com/api/v1.0/find/objects/#{collection}?q=#{tags_json}"

    retriever = ContentRetriever.new
    @objects = retriever.getContent(@url)
    return @objects

  end

  ##
  #
  # Retrieve single document from Magic Database
  #
  # Parameters:
  #   collection: base collection to search for content
  #   id: object id to retrieve
  #
  # Returns:
  #   @objects: array of populated DataObjects
  #
  ##
  def self.get_content_by_id(collection, id)

    id_json= '{ "_id": "' + id + '"}'
    id_json = URI::encode(id_json)
    @url = "http://msg-magic-db.herokuapp.com/api/v1.0/find/objects/#{collection}?q=#{id_json}"

    retriever = ContentRetriever.new
    @objects = retriever.getContent(@url)
    return @objects

  end


  ##
  #
  #  Find and send incentive offer to user
  #
  # Parameters:
  #   campaignID - incentive campaign id
  #   mdn - user's phone number
  #   mp_id - mobile page id used to display offer (check the campaign's bounceback text for this ID)
  #
  # Returns:
  #   @code - incentive code found or 'NONE', indicating no offers found
  #
  ##
  def self.get_offers(campaignID, mdn, shortcode, mp_id)
    mdn=mdn.gsub(/[^0-9]/i, '')
    conn = Faraday.new
    conn.basic_auth(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'])
    response = conn.get "http://www.vibescm.com/api/incentive_codes/issue/#{campaignID.to_s}.xml?mobile=#{mdn.to_s}"
    puts response.body
    response_hash= XmlSimple.xml_in(response.body)
    if response_hash["code"].nil?
      @code = 'NONE'
    else
      @code = response_hash["code"][0]
      unless shortcode.nil?
        @coupon_url="http://mp.vibescm.com/p/#{mp_id}?code=#{@code}"
        shortener = UrlShortener.new
        @short_url = shortener.shorten(@coupon_url)
        @sms_body="For an exclusive offer click: #{@short_url}?c=#{@code} Reply HELP for help, STOP to cancel-Msg&data rates may apply"
        sender = SmsSender.new
        sender.send(mdn, @sms_body, shortcode)
      end
    end
    @code
  end

  ##
  #
  # Subscribe mdn , attribute(s)  and custom attributes to catapult campaign.
  #
  # Parameters:
  #   attribute_values - hash of attributes to capture. MDN is required
  #   custom_attributes - hash of custom attributes to create and capture. (optional)
  #   opt_in - boolean for opt_in value - true=bounceback sent; false=no bounceback
  #
  # Returns:
  #   body of response object as XML
  #
  #
  ##
  def self.subscribe(campaignId, attribute_values, custom_attributes, opt_in)

    opt = opt_in ? "invite" : "auto"
    @url = "http://www.vibescm.com/api/subscription_campaigns/#{campaignId.to_s}/multi_subscriptions.xml"
    @payload = "<?xml version='1.0' encoding='UTF-8'?><subscriptions><opt_in>#{opt}</opt_in>"

    if custom_attributes
      @payload << "<create_attribute>true</create_attribute>"
    end

    @payload << "<user>"
    if attribute_values[:mdn]
      mdn=attribute_values[:mdn].gsub(/[^0-9]/i, '')
      @payload << "<mobile_phone>#{mdn}</mobile_phone>"
    end
    if attribute_values[:first_name]
      @payload << "<first_name type=\"string\">#{attribute_values[:first_name]}</first_name>"
    end
    if attribute_values[:last_name]
      @payload << "<last_name type=\"string\">#{attribute_values[:last_name]}</last_name>"
    end
    if attribute_values[:email]
      @payload << "<email type=\"string\">#{attribute_values[:email]}</email>"
    end
    if attribute_values[:birthday]
      @payload << "<birthday_on type=\"string\">#{attribute_values[:birthday]}</birthday_on>"
    end
    if attribute_values[:gender]
      @payload << "<gender type=\"string\">#{attribute_values[:gender]}</birthday_on>"
    end

    if custom_attributes
      @payload << "<attribute_paths>"
      custom_attributes.each_pair do |key, value|
        @payload << "<attribute_path>#{key.to_s}/#{value.to_s}</attribute_path>"
      end
      @payload << "</attribute_paths>"
    end

    @payload << "</user></subscriptions>"
    puts @url
    puts @payload
    conn = Faraday.new
    conn.basic_auth(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'])
    @response = conn.post do |req|
      req.url @url
      req.headers['Content-Type'] = 'application/xml'
      req.body = @payload
    end

    return @response.body

  end


  def self.simple_subscribe(campaignId, mdn)
    mdn=mdn.gsub(/[^0-9]/i, '')
    req_payload = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
    <subscription>
    <user>
    <mobile_phone>' + mdn + '</mobile_phone>
    </user>
    </subscription>'
    @url = "http://www.vibescm.com/api/subscription_campaigns/#{campaignId.to_s}/subscriptions.xml"
    conn = Faraday.new
    conn.basic_auth(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'])
    response = conn.post do |req|
      req.url @url
      req.headers['Content-Type'] = 'application/xml'
      req.body = req_payload
    end
    puts (response.body)
    return response.body
  end

  ##
  #
  # Subscribe mdn , attribute(s)  and nested custom attributes to catapult campaign.
  #
  # use case: when custom campaign attributes with same parent are present in campaign (i.e. - interest/music, interest/guest list, etc)
  # because we are using Hashes for our data, we cannot have multiple keys with the same value (in the example above: 'interest'). To deal with
  # this, set the parent attribute as the key in the custom_attributes hash and the values as an array assigned to that key. Provide the parent name
  # to this function and the nested attributes will be generated for catapult consumption ( 'interest' => ['music','guest list']).
  #
  # Parameters:
  #   attribute_values - hash of attributes to capture. MDN is required
  #   custom_attributes - hash of custom attributes to create and capture. parent attribute key has array of child values as value
  #   opt_in - boolean for opt_in value - true=bounceback sent; false=no bounceback
  #   parent_attribute - name of parent custom attribute that contains children
  #
  # Returns:
  #   body of response object as XML
  #
  # TODO: lots of repeated code in this method and subscribe. need to refactor to share.
  ##
  def self.subscribe_with_nested_attributes(campaignId, attribute_values, custom_attributes, parent_attribute, opt_in)

    opt = opt_in ? "invite" : "auto"
    @url = "http://www.vibescm.com/api/subscription_campaigns/#{campaignId.to_s}/multi_subscriptions.xml"
    @payload = "<?xml version='1.0' encoding='UTF-8'?><subscriptions><opt_in>#{opt}</opt_in>"

    if custom_attributes
      @payload << "<create_attribute>true</create_attribute>"
    end

    @payload << "<user>"
    if attribute_values[:mdn]
      mdn=attribute_values[:mdn].gsub(/[^0-9]/i, '')
      @payload << "<mobile_phone>#{mdn}</mobile_phone>"
    end
    if attribute_values[:first_name]
      @payload << "<first_name type=\"string\">#{attribute_values[:first_name]}</first_name>"
    end
    if attribute_values[:last_name]
      @payload << "<last_name type=\"string\">#{attribute_values[:last_name]}</last_name>"
    end
    if attribute_values[:email]
      @payload << "<email type=\"string\">#{attribute_values[:email]}</email>"
    end
    if attribute_values[:birthday]
      @payload << "<birthday_on type=\"string\">#{attribute_values[:birthday]}</birthday_on>"
    end
    if attribute_values[:gender]
      @payload << "<gender type=\"string\">#{attribute_values[:gender]}</birthday_on>"
    end

    if custom_attributes
      @payload << "<attribute_paths>"
      custom_attributes.each_pair do |key, value|
        if key.to_s == parent_attribute
          value.each do |val|
            @payload << "<attribute_path>#{key.to_s}/#{val}</attribute_path>"
          end
        else
          @payload << "<attribute_path>#{key.to_s}/#{value.to_s}</attribute_path>"
        end
      end
      @payload << "</attribute_paths>"
    end

    @payload << "</user></subscriptions>"
    puts @url
    puts @payload
    conn = Faraday.new
    conn.basic_auth(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'])
    @response = conn.post do |req|
      req.url @url
      req.headers['Content-Type'] = 'application/xml'
      req.body = @payload
    end

    return @response.body

  end

  ##
  #
  # Enter a contest campaign.
  #
  # Parameters:
  #   campaignId - campaign to enter
  #   form_values - hash of attributes to capture
  #   custom_attributes - hash of custom attributes to create and capture. (optional)
  #   shortcode - used to send SMS bounceback after entry (optional)
  #
  # Returns:
  #   text of response upon entry as defined in campaign + sms
  #   or text stating they've already entered, if applicable
  #
  ##
  def self.enter_contest(campaignId, form_values, shortcode)

      @url = "http://www.vibescm.com/api/amoe/enter.xml?id=#{campaignId}"
         @payload = "<?xml version='1.0' encoding='UTF-8'?>
                                 <contest_entry_data>
                                   <first_name>#{form_values["first_name"]}</first_name>
                                   <last_name>#{form_values["last_name"]}</last_name>
                                   <mobile_phone>#{form_values["mobile_phone"]}</mobile_phone>
                                   <phone>#{form_values["phone"]}</phone>
                                   <email>#{form_values["email"]}</email>
                                   <birthday>#{form_values["date_of_birth"]}</birthday>
                                   <street_address>#{form_values["address"]}</street_address>
                                   <city>#{form_values["city"]}</city>
                                   <state_code>#{form_values["state"]}</state_code>
                                   <postal_code>#{form_values["zip"]}</postal_code>
                                </contest_entry_data>"

             conn = Faraday.new
        	    conn.basic_auth(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'])
        	    response = conn.post do |req|
        	      req.url @url
        	      req.headers['Content-Type'] = 'application/xml'
        	      req.body = @payload
        	    end

      # debuging below 
      #puts @url
      #puts @payload
      
      #to use catapult output on thank you page parse response below.
      response.body
    end
  
  ##
  #
  # Sign an autograph image.
  #
  # Parameters:
  #   name - name to sign image with
  #   baseImageId - ID of base image as defined in MSG-Toolbox Image API
  #
  # Returns:
  #   Error code 400, indicating name was forbidden
  #   or signed image name
  ##
  def self.sign_autograph(name, baseImageId)
    conn = Faraday.new
    conn.basic_auth(ENV['MSG_API_USER'], ENV['MSG_API_PASS'])
    @result = conn.get "http://msg-umami-api.herokuapp.com/api/v2.0/autograph/sign/#{baseImageId}/#{name}"
    if @result.body.include? 'restricted'
      @result=400
    else
      puts @result.body
      resp_json = JSON.parse(@result.body)
      @result = resp_json['photo']['url'].gsub('https://msg-umami-t2a.s3.amazonaws.com/autographed_images/','')
      @result = URI::encode(@result)
    end
    @result
  end

  def self.send_international_sms(mdn, body)
    mdn=mdn.gsub(/[^0-9]/i, '')
    conn = Faraday.new
    @response = conn.get "http://list.lumata.com/wmap/SMS.html?User=msuk_vibes&Password=v1b3s4uk&Type=SMS&Body="+body+"+Vibes&Phone="+mdn+"&Sender=Vibes"
    @response.body["<html>"] = ""
    @response.body["</html>"] = ""
    @response.body["<body>"] = ""
    @response.body["</body>"] = ""
    return @response.body
  end

  ##
  #  Look up Carrier for MDN
  #
  # Parameters:
  #   mdn - mobile number
  #
  # Returns:
  #   carrier code as integer
  #
  # Carrier Code   Carrier Name
  # 101   U.S. Cellular
  # 102   Verizon Wireless
  # 103   Sprint Nextel(CDMA)
  # 104   AT&T
  # 105   T-Mobile
  #
  # full list of codes:
  #   http://wiki.vibes.com/display/API/Appendix+B++-+Carrier+Codes

  def self.get_carrier_code(mdn)
    require 'nokogiri'

    splat = ENV['SPLAT_API_USER']
    un = "Vibes #{splat}"
    pw = ENV['SPLAT_API_PASS']

    conn = Faraday.new "https://api.vibesapps.com/MessageApi/mdns/#{mdn}", ssl: {verify: false}
    @resp = conn.get do |req|
      req.headers['Authorization'] = un + ":" + pw
    end
    puts @resp.body
    doc = Nokogiri::XML(@resp.body)
    @doc = doc.xpath('//mdn').each do |record|
      @carriercode = record.at('@carrier').text
    end
    @carriercode.to_i
  end

  ###########################
  #
  #   PRIVATE NESTED CLASSES
  #
  ###########################

  class SmsSender
    def send(mdn, body, shortcode)
      @mdn=mdn.gsub(/[^0-9]/i, '')
      @payload = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
                    <mtMessage>
                      <destination address=\"#{@mdn}\" type=\"MDN\"/>
                      <source address=\"#{shortcode}\" type=\"SC\" />
                      <text><![CDATA[#{body}]]></text>
                    </mtMessage>"
      splat = ENV['SPLAT_API_USER']
      un = "Vibes #{splat}"
      pw = ENV['SPLAT_API_PASS']

      conn = Faraday.new 'https://api.vibesapps.com/MessageApi/mt/messages', ssl: {verify: false}
      response = conn.post do |req|
        req.headers['Content-Type'] = 'text/xml'
        req.headers['Authorization'] = un + ":" + pw
        req.body = @payload
      end
      puts '++++++++++++ SMS Sender response: ' + response.body
      return response.body
    end
  end

  class UrlShortener
    def shorten(url)
      conn = Faraday.new 'https://trustapi2.vibesapps.com/', ssl: {verify: false}
      conn.basic_auth(ENV['SHORT_USER'], ENV['SHORT_PASS'])
      resp = conn.get "/UrlShortener/api/shorten?url=#{url}"
      @short_url = resp.body
    end
  end


  class ContentRetriever
    def getContent(url)
      conn = Faraday.new
      conn.basic_auth(ENV['MSG_MAGIC_USER'], ENV['MSG_MAGIC_PASS'])

      response = conn.get url
      results = JSON.parse(response.body)
      @objects = Array.new

      results.each do |result|
        object = DataObject.new(result)
        @objects.push(object)
      end
      return @objects
    end
  end

  class DataObject
    def initialize(hash)
      hash.each do |k, v|

        ## create and initialize an instance variable for this key/value pair
        self.instance_variable_set("@#{k}", v)

        ## create the getter that returns the instance variable
        self.class.send(:define_method, k, proc { self.instance_variable_get("@#{k}") })

        ## create the setter that sets the instance variable
        self.class.send(:define_method, "#{k}=", proc { |v| self.instance_variable_set("@#{k}", v) })
      end
    end
  end

end
