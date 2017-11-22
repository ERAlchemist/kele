require "httparty"
require "json"
require './lib/roadmap.rb'

class Kele
  include HTTParty
  include Roadmap

  def initialize(email, password)
    response = self.class.post(base_api_endpoint("sessions"), body: { "email": email, "password": password })
    raise InvalidStudentCodeError.new() if response.code == 401
    @auth_token = response["auth_token"]
  end

  def get_me
    response = self.class.get(base_api_endpoint("users/me"), headers: { "authorization" => @auth_token })
    @user_data = JSON.parse(response.body)
  end

  def get_mentor_availability(mentor_id)
    response = self.class.get(base_api_endpoint("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token }).to_a
    available = []
    response.each do |timeslot|
      if timeslot["booked"] == nil
        available.push(timeslot)
      end
    end
    available
  end

  def get_messages(page)
    response = self.class.get(base_api_endpoint("message_threads?page=#{page}"), headers: { "authorization" => @auth_token })
    @get_messages = JSON.parse(response.body)
  end

  def create_message(user_id, recipient_id, token=nil, subject, message)
    response = self.class.post(base_api_endpoint("messages"), body: { "user_id": user_id, "recipient_id": recipient_id, "token": token, "subject": subject, "stripped-text": message }, headers: { "authorization" => @auth_token })
    puts response
  end

  
  
	private

  def base_api_endpoint(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end

  


end
