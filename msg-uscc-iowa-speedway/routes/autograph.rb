# encoding: utf-8
class MyApp < Sinatra::Application
  def get_loc()
         location = request.path.downcase
         location = location[1..location.length]
         if location.index("/") != nil
           location = location[0..location.index("/")-1]
         end
         location 
   end
   # Generate new base image id http://msg-umami-api.herokuapp.com/
   #step 1 in UI
   get "/autograph/choose" do
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
     erb :autograph_choose, :layout => :autograph_layout
  end
   
   #step 2 in UI
   get "/autograph/start/:img" do
    img = params[:img]
    @img_info = Hash.new
    @img_info = {"desc" => "NULL","base_img_id" => "NULL"} 
    
    case img
      when "kenny1"
        @img_info = {"desc" => "kenny1","base_img_id" => "519e37bb97b9950d1700000b","display_url"=>"https://msg-umami-t2a.s3.amazonaws.com/base_images/kennywallace_VA.jpg"}
      when "kenny2"
        @img_info = {"desc" => "kenny2","base_img_id" => "51a523ff81e77d4935000004","display_url"=>"https://msg-umami-t2a.s3.amazonaws.com/base_images/kennywallace_VA2.jpg"}
    end
    
    @sheets = '../../../css/common.css,../../../css/responsive.css'
    @css = []
    @css = @sheets.split(",")
    puts "cookie crumb"
    puts cookies["USCC_SPEEDWAY_LOCATION"]
    @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
	 	erb :autograph_start, :layout => :autograph_layout
	end

  #step 3 in UI
  get "/autograph/output" do
    #THE FILE NAME IS CASE SENSITIVE
		loc = request.url
	  @autograph_pic = params[:pic]
			@img_url = "http://msg-umami-t2a.s3.amazonaws.com/autographed_images/#{@autograph_pic}"
		#	http://0.0.0.0:9292/autograph/mobile?pic=UZ/kd11pgjgfAAAC.jpg
		#	http://0.0.0.0:9292/autograph/mobile?pic=uz/kd11pgjgfaaac.jpg
		#THE FILE NAME IS CASE SENSITIVE
			@mobile_url = loc.gsub("autograph/output","autograph/mobile")
			puts loc
			puts @autograph_pic
			puts @img_url
			puts @mobile_url
		 
	    @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	erb :autograph_output, :layout => :autograph_layout
	end
	
	get "/autograph/finished" do
		loc = request.url.downcase
     @autograph_pic = params[:pic]
			@img_url = "http://msg-umami-t2a.s3.amazonaws.com/autographed_images/#{@autograph_pic}"
			#puts @autograph_pic
			#puts @img_url
		
		  @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	erb :autograph_finished, :layout => :autograph_layout
	end

  get "/autograph/mobile" do
		loc = request.url
     @autograph_pic = params[:pic]
			@img_url = "http://msg-umami-t2a.s3.amazonaws.com/autographed_images/#{@autograph_pic}"
			#puts @autograph_pic
			#puts @img_url
			### hard coded ... oh well
			@short = MsgToolbox.shorten_url("http://usccspeed.hit2c.com/autograph/choose")
		  @short_pic = MsgToolbox.shorten_url(loc)
		  @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   	erb :autograph_mobile, :layout => :autograph_layout
	end
	
  get "/autograph/sandbox" do
      @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
    erb :autograph_sandbox, :layout => :autograph_layout
  end
  
  post "/autograph/sign/:baseImageId" do
    fname = WebToolbox.fill_nil(params[:first_name].to_s)
    img_desc = params[:img_desc]
    baseImageId = params[:baseImageId]
    #debug
    puts fname 
    puts img_desc
    puts baseImageId
    
    if fname != "NULL"
      @resp = MsgToolbox.sign_autograph(params[:first_name], params[:baseImageId])
		  if @resp == 400
			    flash[:error] = "The phrase you entered is restricted. Please Try again."
			    redirect "/autograph/start/#{img_desc}?err=n"
			  else 
			    @autograph_pic = @resp
				  redirect "/autograph/output?pic=#{@autograph_pic}"
			  end
		else
			  redirect "/autograph/start/#{img_desc}?err=o"
		end  
	end  	

  post "/autograph/sms" do
    loc = request.url
    @autograph_pic = params[:autograph_pic]
	  @img_url = params[:img_url]
	  @mobile_url = params[:mobile_url]
	  @mdn = params[:mdn]
	  @shortcode = "89635"
	  
	  @short_url = MsgToolbox.shorten_url(@mobile_url)

	  @copy = "Click #{@short_url} for your personalized virtual autograph from racing icon Kenny Wallace!"
	  puts @copy 
	  
	  @send_mt = MsgToolbox.send_sms(@mdn, @copy, @shortcode)
	  redirect "/autograph/finished?pic=#{@autograph_pic}"
  end
  
  get "/autograph/date" do
      today = Date.today
        if Chronic.parse(today).to_i <= Chronic.parse('2013-06-08').to_i
          puts "before"
        else
          puts "after"
        end
  end
  
end
