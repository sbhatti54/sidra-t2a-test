 module WebToolbox
   ## validators 
   def self.fill_nil(param)
       if param.empty?
         param = "NULL"
       else
         param = param
       end 
     end
   
     def self.valid_phone(param)
        @regex_mdn = Regexp.new('^[2-9][0-8][0-9]\d+$')
        @mdn_test = param.match @regex_mdn
        @mdn_test
     end

     def self.validate_email(param)
          #returns email if the email is valid n/a if not... 
          email = param
          regex_email = Regexp.new('^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*\.(\w{2}|(com|net|org|edu|int|mil|gov|arpa|biz|aero|name|coop|info|pro|museum))')
         if email != nil
          email_test = email.match regex_email
          if email_test == nil
            email = "n/a"
          else
            email
          end
         else 
           email = "n/a"
         end  
        email
     end
     

     def self.valid_number(param)  
       @regex_numeric = Regexp.new('^[0-9]+$')
       @numeric_test = param.match @regex_numeric
       @numeric_test
     end
   #end validators... 
   
  ### html /text 
  def self.capitalize(param)
      param = param.to_s
      param = param[0].upcase+param[1..param.length].downcase
      param 
  end
   
end