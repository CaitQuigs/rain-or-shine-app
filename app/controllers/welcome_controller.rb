class WelcomeController < ApplicationController
  def test
  	response = HTTParty.get("http://api.wunderground.com/api/#{ENV['wunderground_api_key']}/geolookup/conditions/q/AZ/Phoenix.json")

  	puts "***************************"
  	puts response
  	puts "***************************"
  	@location = response['location']['city']
  	@temp_f = response['current_observation']['temp_f']
  	@temp_c = response['current_observation']['temp_c']
  	@weather_icon = response['current_observation']['icon_url']
  	@weather_words = response['current_observation']['weather']
  	@forecast_link = response['current_observation']['forecast_url']
  	@real_feel = response['current_observation']['feelslike_f']
	end

  def index
  	 # Creates an array of states that our user can choose from on our index page
    @states = %w(HI AK CA OR WA ID UT NV AZ NM CO WY MT ND SD NB KS OK TX LA AR MO IA MN WI IL IN MI OH KY TN MS AL GA FL SC NC VA WV DE MD PA NY NJ CT RI MA VT NH ME DC).sort!

    # removes spaces from the 2-word city names and replaces the space with an underscore 
    if params[:city] != nil
    	params[:city].gsub!(" ", "_")
    end

    #checks that the state and city params are not empty before calling the API
    if params[:state] != "" && params[:city] != "" && params[:state] != nil && params[:city] != nil
      results = HTTParty.get("http://api.wunderground.com/api/#{Figaro.env.wunderground_api_key}/geolookup/conditions/q/#{params[:state]}/#{params[:city]}.json")
		  
      # check to see if there is an error response.
      if results['response']['error'] != nil && results['response']['error'] != ''
        # if there is an error, we report it to our user via the @error variable 
        @error = results['response']['error']['description']

      # if no error is returned from the call, we fill our instants variables with the result of the call 
      else
        @location = "#{results['location']['city']}, #{results['location']['state']}"
        @temp_f = results['current_observation']['temp_f']
        @temp_c = results['current_observation']['temp_c']
        @weather_icon_url = results['current_observation']['icon_url']
        @weather_words = results['current_observation']['weather']
        @forecast_link = results['current_observation']['forecast_url']
        @real_feel_f = results['current_observation']['feelslike_f']
        @real_feel_c = results['current_observation']['feelslike_c']
        if @weather_words.downcase == "clear"
          @body_class = "clear"
        elsif @weather_words.downcase.include?("thunderstorm") || @weather_words.downcase.include?("squalls")
          if @weather_words.downcase.include?("snow") || @weather_words.downcase.include?("ice")
            @body_class = "winterstorm"
          else
            @body_class = "thunderstorm"
          end
        elsif @weather_words.downcase.include?("snow") || @weather_words.downcase.include?("ice")
          @body_class = "snow"
        elsif @weather_words.downcase.include?("fog") || @weather_words.downcase.include?("mist") || @weather_words.downcase.include?("haze")
          @body_class = "fog"
        elsif @weather_words.downcase.include?("rain") || @weather_words.downcase.include?("drizzle") || @weather_words.downcase.include?("spray")
          @body_class = "rain"
        elsif @weather_words.downcase == "partly cloudy" || @weather_words.downcase == "scattered clouds"
          @body_class = "partly_cloudy"
        elsif @weather_words.downcase == "mostly cloudy"
          @body_class = "cloudy"
        elsif @weather_words.downcase == "overcast"
          @body_class = "overcast"
        elsif @weather_words.downcase == "hail"
          @body_class = "hail"
        elsif @weather_words.downcase.include?("smoke") || @weather_words.downcase.include?("ash")
          @body_class = "smoke"
        elsif @weather_words.downcase.include?("sand") || @weather_words.downcase.include?("dust")
          @body_class = "sandstorm"
        elsif @weather_words.downcase.include?("funnel")
          @body_class = "funnel_cloud"
        else
          @body_class = "clear"
        end
      end
    end
  end
end
