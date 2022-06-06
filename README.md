# Jebbit Webhook Client Example

An example rails application that can receive & verify Jebbit webhooks. 

See the [full documentation](https://jebbit-public-api-docs.s3.amazonaws.com/index.html) for more information.



## Setup

Ensure ruby 3 is installed and then `bundle install` to install required gems. 

Run `rails s` to start the server. 



## Important Files

`app/controllers/webhooks_controller.rb` -> controller that receives webhooks
`app/services/jebbit_webhooks_service.rb` -> service class that validates the webhook's signature

