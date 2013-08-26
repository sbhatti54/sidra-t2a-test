 module SpeedwayTools
   ## trivia
   def self.ans_check(month,question, ans)
        month = month.to_i
        question = question.to_s
        c = Hash.new 
        c = {"correct" => "0","ans" => "NULL"} 
            
        if month < 7
          case question 
                 when "1" then 
                     c["ans"] = "Brad Keselowski"
                     if ans == "Brad Keselowski"
                        c["correct"] = "1"
                     end
                 when "2" then 
                       c["ans"] = "Ricky Stenhouse Jr."
                       if ans == "Ricky Stenhouse Jr."
                          c["correct"] = "1"
                       end    
                 when "3" then 
                      c["ans"] = "Rusty Wallace"
                      if ans == "Rusty Wallace"
                         c["correct"] = "1"
                      end
                 when "4" then 
                       c["ans"] = "Turn 3"
                       if ans == "Turn 3"
                          c["correct"] = "1"
                      end
                 when "5" then 
                      c["ans"] = "2006"
                      if ans == "2006"
                         c["correct"] = "1"
                      end
                when "end" then 
                          c["ans"] = "2006"
                          if ans == "2006"
                             c["correct"] = "1"
                          end      
              end
        end
        
        if month == 7
          case question 
                 when "1" then 
                     c["ans"] = "James Buescher"
                     if ans == "James Buescher"
                        c["correct"] = "1"
                     end
                 when "2" then 
                       c["ans"] = "Eldora Speedway"
                       if ans == "Eldora Speedway"
                          c["correct"] = "1"
                       end
                 when "3" then
                      c["ans"] ="Ron Hornaday Jr."
                      if ans == "Ron Hornaday Jr."
                         c["correct"] = "1"
                      end
                 when "4" then 
                       c["ans"] = "Camping World"
                       if ans == "Camping World"
                          c["correct"] = "1"
                       end
                 when "5" then 
                      c["ans"] = "ARCA"
                      if ans == "ARCA"
                         c["correct"] = "1"
                      end
                when "end" then 
                  c["ans"] = "ARCA"
                  if ans == "ARCA"
                    c["correct"] = "1"
                  end    
                end
        end  
        
        if month == 8
           case question 
                   when "1" then 
                       if ans == ""
                          c["correct"] = "1"
                       end
                   when "2" then 
                         if ans == ""
                            c["correct"] = "1"
                         end
                   when "3" then 
                        if ans == ""
                           c["correct"] = "1"
                        end
                   when "4" then 
                         if ans == ""
                            c["correct"] = "1"
                         end
                   when "5" then 
                        if ans == ""
                           c["correct"] = "1"
                        end
                  end
        end
      
      c
    end
   
end