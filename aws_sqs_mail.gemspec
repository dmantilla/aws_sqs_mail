#version = File.read('README.textile').scan(/^\*\s+([\d\.]+)/).flatten

Gem::Specification.new do |s|
  s.name     = "aws_sqs_mail"
  s.version  = "0.1.0"
  s.date     = "2009-07-29"
  s.summary  = "Adds an enqueue method to ActionMailer::Base, this adds the message to Amazon SQS which can be delivered later"
  s.email    = "daniel@celect.org"
  s.homepage = "http://github.com/dmantilla/aws_sqs_mail/tree/master"
  s.description = "Uses Amazon SQS to enqueue messages and then deliver them at a later time"
  s.authors  = ["Daniel Mantilla"]

  s.has_rdoc = false
  s.rdoc_options = ["--main", "README.textile"]
  s.extra_rdoc_files = ["README.textile"]

  # run git ls-files to get an updated list
  s.files = %w[
    MIT-LICENSE
    README.textile
    aws_sqs_mail.gemspec
    init.rb
    lib/aws_sqs_mail.rb
  ]
end
