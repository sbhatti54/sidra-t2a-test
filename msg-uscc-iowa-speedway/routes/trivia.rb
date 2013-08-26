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
    
  get "/trivia" do
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
     puts "cookie crumb"
     puts cookies["USCC_SPEEDWAY_LOCATION"]
     @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
 	 	erb :trivia_index, :layout => :trivia_layout
 	end
 	
   get "/trivia/thanks/:check" do
      @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
      @correct = "NULL"
      @month = 7
      @answer = params[:rr]
      @question = "end"
      check = SpeedwayTools.ans_check(@month,@question,@answer)
      @ans = check["ans"]
      
      
 	 	erb :trivia_thanks, :layout => :trivia_layout
 	end
 	
 	 get "/trivia/correct/:question" do
 	    @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
      @question = params[:question]
      @next = @question.to_i+1
      @next = @next.to_s
 	 	erb :trivia_correct, :layout => :trivia_layout
 	end
 	
 	
 	 get "/trivia/incorrect/:question" do
 	    @sheets = '../../../css/common.css,../../../css/responsive.css'
      @css = []
      @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
      @month = 7
      @question = params[:question]
      @answer = "na"
      
      check = SpeedwayTools.ans_check(@month,@question,@answer)
      @ans = check["ans"]
      
      @next = @question.to_i+1
      @next = @next.to_s
      @correct = "NULL"
 	 	erb :trivia_incorrect, :layout => :trivia_layout
 	end
 
  get "/trivia/:question" do
     @sheets = '../../../css/common.css,../../../css/responsive.css'
     @css = []
     @css = @sheets.split(",")
      puts "cookie crumb"
      puts cookies["USCC_SPEEDWAY_LOCATION"]
      @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
    question = params[:question]
    @month = 7
    
    if @month == 7
          case question
           when "1" then 
              erb :trivia_q1_july, :layout => :trivia_layout
           when "2" then 
              erb :trivia_q2_july, :layout => :trivia_layout
           when "3" then 
             erb :trivia_q3_july, :layout => :trivia_layout
           when "4" then 
             erb :trivia_q4_july, :layout => :trivia_layout
           when "5" then 
             erb :trivia_q5_july, :layout => :trivia_layout
           else 
              erb :trivia_index, :layout => :trivia_layout
           end
    else
          case question
           when "1" then 
              erb :trivia_q1, :layout => :trivia_layout
           when "2" then 
              erb :trivia_q2, :layout => :trivia_layout
           when "3" then 
             erb :trivia_q3, :layout => :trivia_layout
           when "4" then 
             erb :trivia_q4, :layout => :trivia_layout
           when "5" then 
             erb :trivia_q5, :layout => :trivia_layout
           else 
              erb :trivia_index, :layout => :trivia_layout
           end
       end     
  end

  get "/month" do
    puts Chronic.parse("month")#.utc+Time.zone_offset('CDT')
  end

  post "/trivia/confirm/:question" do
    question = params[:question]
    answer = params[:rr]
    month = 7
    puts question
    puts answer
    puts "cookie crumb"
    puts cookies["USCC_SPEEDWAY_LOCATION"]
    @cookie = cookies["USCC_SPEEDWAY_LOCATION"]
    check = SpeedwayTools.ans_check(month,question,answer)
    
    if check["correct"] == "1"
      #5th question is the last question on all months
      if question == "5"
        redirect "/trivia/thanks/#{check["correct"]}"
      else
        redirect "/trivia/correct/#{question}"
      end
    else
      if question == "5"
        redirect "/trivia/thanks/#{check["correct"]}"
      else
         redirect "/trivia/incorrect/#{question}"
      end
    end  
  end
 
end
