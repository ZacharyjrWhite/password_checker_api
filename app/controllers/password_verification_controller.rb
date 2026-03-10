require 'zxcvbn'
require 'digest/sha1'
require 'securerandom'

class PasswordVerificationController < ApplicationController

    rate_limit to: 10, within: 1.minute, with: -> {
        render json: { error: "Too many requests. Try again later." 
    }, status: :too_many_requests }

    PASSWORD_CACHE = {}
    PWNED_CACHE = {}

    def welcome
        render :index    # explicitly render index.html.erb
    end

    def check
        data = JSON.parse(request.raw_post) rescue {}

        if data['password'].present?

            password = data['password'].to_s

            result = PASSWORD_CACHE[password] ||= Zxcvbn.test(password)

            render json: {
                password: password,
                score: result.score,
                crack_time: result.crack_time,
                crack_time_display: result.crack_time_display,
                feedback: {
                warning: result.feedback.warning,
                suggestions: result.feedback.suggestions
                }
            }

        else

            render json: { error: "No password received" }, status: :bad_request

        end

    end

    def haveIbeenPwned
        data = JSON.parse(request.raw_post) rescue {}
        
        if data['password'].present?
            
            password = data['password'].to_s
            
            sha1 = Digest::SHA1.hexdigest(password).upcase
            prefix = sha1[0,5]
            suffix = sha1[5..-1]

            url = URI("https://api.pwnedpasswords.com/range/#{prefix}")
            response = PWNED_CACHE[prefix] ||= Net::HTTP.get(url)

            
            pwned = false
            match = response.lines.find do |line|
                pwned = line.split(':')[0] == suffix
            end

            count = 0

            if match
                count = match.split(':')[1].to_i
            end

            render json: {
                password: password,
                pwned: pwned,
                count: count
            }

        else

            render json: { error: "No password received" }, status: :bad_request

        end

    end

    def generate

        length = params[:length].to_i
        length = 16 if length <= 0

        password = generate_password(length)

        result = PASSWORD_CACHE[password] ||= Zxcvbn.test(password)

        render json: {
            password: password,
            score: result.score,
            crack_time: result.crack_time,
            crack_time_display: result.crack_time_display,
            feedback: {
            warning: result.feedback.warning,
            suggestions: result.feedback.suggestions
            }
        }
    end

    # Helper functions 
    # generate_password was found online: source: https://generate-random.org/passwords/ruby
    def generate_password(length = 16, include_special = true)
        lowercase = ('a'..'z').to_a
        uppercase = ('A'..'Z').to_a
        numbers   = ('0'..'9').to_a
        special   = '!@#$%^&*()-_=+[]{}|;:,.<>?'.chars

        chars = lowercase + uppercase + numbers
        chars += special if include_special

        Array.new(length) { chars[SecureRandom.random_number(chars.length)] }.join
    end

end