module ActionMailer
  class Base
    def self.enqueue(sqs_queue, method, *args)
      tmail_obj = self.send("create_#{method}".to_sym, *args)
      deliver_now = false
      
      if sqs_queue.is_a? RightAws::SqsGen2::Queue
        yaml_obj = YAML::dump(tmail_obj)
        if yaml_obj.size < 8192
          sqs_queue.push yaml_obj
          RAILS_DEFAULT_LOGGER.info "[MAIL ENQUEUED] FROM: #{tmail_obj.from} TO: #{tmail_obj.to.join(',')} SUBJECT: #{tmail_obj.subject}"
        else
          deliver_now = true
        end
      else
        deliver_now = true
      end
      
      if deliver_now
        self.deliver(tmail_obj)
        RAILS_DEFAULT_LOGGER.warn "[MAIL NOT ENQUEUED] FROM: #{tmail_obj.from} TO: #{tmail_obj.to.join(',')} SUBJECT: #{tmail_obj.subject}"
      end
      
      tmail_obj
    end
  end
end

module AwsSqs
  module Mail
    def self.process(sqs_queue)
      exit_flag = false
      until($exit)
        success, failure = 0, 0

        while(message = sqs_queue.receive)
          if message.to_s == 'stop'
            exit_flag = true
            break
          end

          begin
            tmail_obj = YAML::load(message.to_s)
            mail_header = 
            ActionMailer::Base.deliver(tmail_obj)
            
            RAILS_DEFAULT_LOGGER.info "[MAIL DELIVERED] FROM: #{tmail_obj.from} TO: #{tmail_obj.to.join(',')} SUBJECT: #{tmail_obj.subject}"
            message.delete
          rescue   Exception => e
            RAILS_DEFAULT_LOGGER.error "* [MAIL DELIVERY ERROR]"
            RAILS_DEFAULT_LOGGER.error error.backtrace.inspect
          end
          break if $exit # leave if we're exiting
        end
        
        break if exit_flag
        
        sleep(60)
      end      
    end
  end
end
