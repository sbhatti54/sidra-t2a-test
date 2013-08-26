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
   
  get "/" do
     @location = get_loc
     puts @location
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
	 	erb :index, :layout => :home_layout
	end
	
  get "/home" do
     @location = get_loc
     puts @location
     cookies["USCC_SPEEDWAY_LOCATION"] = params[:loc]
     #debug
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
	 	erb :home, :layout => :home_layout
	end

    get "/home/test" do
     @location = get_loc
     puts @location
     cookies["USCC_SPEEDWAY_LOCATION"] = params[:loc]
     #debug
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
   
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
    erb :home_test, :layout => :home_layout
  end
  
  get "/incompatible" do
	 	erb :home_index, :layout => :home_layout
	end

  get "/schedule" do
    redir = params[:destination]
    puts redir
    if redir == "rewards"
      redirect "https://customer.uscellular.com/uscellular/myaccount/login.jsp"
    else
      redirect "http://www.iowaspeedway.com"
    end
  end
  
end
