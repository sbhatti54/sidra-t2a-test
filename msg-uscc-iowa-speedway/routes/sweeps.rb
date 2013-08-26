# encoding: utf-8
class MyApp < Sinatra::Application
  #http://www.vibescm.com/app/contest_campaigns/520399
  def get_loc()
         location = request.path.downcase
         location = location[1..location.length]
         if location.index("/") != nil
           location = location[0..location.index("/")-1]
         end
         location 
   end
   
  get "/sweeps/enter" do
     @scripts = "../../../js/jq.sweeps_check.js"
     @js = @scripts.split(",")
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
 	 	erb :sweeps_index, :layout => :sweeps_layout
 	end

    get "/sweeps/test/enter" do
     @scripts = "../../../js/jq.sweeps_check.js"
     @js = @scripts.split(",")
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
    erb :sweeps_index_test, :layout => :sweeps_layout
  end
 	
 	 get "/sweeps/thanks" do
 	    @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
       puts "cookie crumb"
       puts cookies["USCC_SPEEDWAY_LOCATION"]
       @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
 	 	erb :sweeps_thanks, :layout => :sweeps_layout
 	 end
  
    get "/sweeps/already" do
      @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
       puts "cookie crumb"
       puts cookies["USCC_SPEEDWAY_LOCATION"]
       @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	 	erb :sweeps_already, :layout => :sweeps_layout
   	end
   	
   	get "/sweeps/nonuscc" do
      @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
       puts "cookie crumb"
       puts cookies["USCC_SPEEDWAY_LOCATION"]
       @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	 	erb :sweeps_not_uscc, :layout => :sweeps_layout
   	end
   	

 	    get "/sweeps/rules" do
      @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
      erb :rules, :layout => :sweeps_layout
    end

    

   	get "/rules" do
       puts "cookie crumb"
       puts cookies["USCC_SPEEDWAY_LOCATION"]
       @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	 	erb :rules, :layout => false
   	end
   	

 	 post "/sweeps/confirm" do
 	  #hidden var in form
 	  @campaignid = "520399"
 	  @shortcode = '5000'
 	  @form_values = Hash.new
          @form_values = {"created_at" => Time.now,
                     "first_name" => WebToolbox.fill_nil(params[:first_name].to_s),
                     "last_name" => WebToolbox.fill_nil(params[:last_name].to_s),
                     "mobile_phone" => WebToolbox.fill_nil(params[:mobile_phone].to_s),
                     "phone" =>  WebToolbox.fill_nil(params[:mobile_phone].to_s),
                     "email" => WebToolbox.fill_nil(params[:email].to_s),
                     "address"=> WebToolbox.fill_nil(params[:address].to_s),
                     "date_of_birth"=> WebToolbox.fill_nil(params[:date_of_birth].to_s),
                     "city" => WebToolbox.fill_nil(params[:city].to_s),
                     "state" => WebToolbox.fill_nil(params[:state].to_s),
                     "zip" => WebToolbox.fill_nil(params[:zip].to_s)
                     
                 }
           # debugging
           # @form_array = @form_values.flatten
            puts @form_values["first_name"]
            puts @form_values["last_name"]
            puts @form_values["mobile_phone"]
            puts @form_values["phone"]
            puts @form_values["email"]
            puts @form_values["date_of_birth"]
            puts @form_values["address"]
            puts @form_values["city"]
            puts @form_values["state"]
            puts @form_values["zip"]
            
            @env_url = request.url.downcase
            if @env_url =~ /0.0.0.0/ 
              @carrier = "101"
            else 
              @carrier = MsgToolbox.get_carrier_code(@form_values["mobile_phone"])
              @carrier = @carrier.to_s
            end
           #submit to catapult
            puts @carrier
            puts @carrier.class
            #lazy carrier validation
            if @carrier == "101"
              @contest_call = MsgToolbox.enter_contest(@campaignid, @form_values,@shortcode) 
                  #debug
                  puts @contest_call
                  #todo .. grab this from the @contest_call xml returned
                  @contest_call = @contest_call.to_s
                  
                  if @contest_call =~ /sorry/
                    redirect "/sweeps/already"
                  else
                        res_hash = XmlSimple.xml_in(@contest_call)
                        if res_hash.has_key?('bad-request')
                          @body =  res_hash["bad-request"][0]
                        else
                          @body =  res_hash["ok"][0]
                        end
                        
                      @shortcode = "5000"
                      #todo .. grab this from the @contest_call xml returned
                      @sms_msg = MsgToolbox.send_sms(@form_values["mobile_phone"],@body, @shortcode)
                      redirect "/sweeps/thanks"
                  end
            else
                redirect "/sweeps/nonuscc"      
            end  
                    
 	 end

end
