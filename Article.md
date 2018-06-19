# Getting Started with Broadcasting Non-English SMS Messages with Rails and the Nexmo API   
*Ben Greenberg*

## Overview

In this article we are going to demonstrate how to create a Ruby on Rails application to broadcast SMS messages to a list of phone numbers. There are a multitude of use cases for broadcasting messages to employees, customers or clients. Whether you want to share the latest sale with your loyal customers, update employees on an important announcement or notify your clients of an upcoming schedule change, the ability to broadcast that message easily and efficiently is integral. With the help of the Nexmo Ruby Gem and the Nexmo API we can easily create an application to accomplish this. We can leverage the built in Unicode support of the Nexmo API to send SMS messages in any language, including languages that are not based on English characters, like Hebrew, Mandarin or Arabic.

Let's get started!

## Prerequisites

In order to begin our tutorial we are going to require the following:

* A [Nexmo account](https://dashboard.nexmo.com/sign-up) (free to sign up and get 2&euro; free credit!)
* [Rails](https://rubyonrails.org/) installed on your computer
* Basic comprehension of [Ruby](https://www.ruby-lang.org/en/documentation/)

## Setting Up Our Rails Application

To begin let's go ahead and initialize a new Rails application. This can be done by simply typing in the command line:

```
rails new name-of-app
```

At the time of initialization you can also specify the database you prefer, with `--database=[DATABASE]`. If you do not specify a database Rails will default to SQLite. You can also offer an additional flag of `-T` to skip installing the default unit tests. For example, with both flags specified your initialization would look like this: `rails new name-of-app --database=postgresql -T`, which would create a new Rails app running with a PostgreSQL database and no default tests installed. 

Once the installation completes we can open up the new directory in our preferred code editor. There are a few items we want to accomplish to make sure our application can handle non-English characters.

First, go ahead and open up the development configuration file found at `/config/environments/development.rb` and add the following line:

```ruby
 config.encoding = "utf-8"
 ```

 This ensures that our application can handle Unicode encoding, which will allow us to work with non-English characters. You can also add the above line to the `/config/environments/production.rb` file to equip the production version of our application with the same capability. 

 Lastly, in this step, we also want to update the opening `<html>` tag in the application layout file to accomodate whichever language we are writing in. This is good practice even if we are writing an English application since it makes our website more accessible to those utilizing screen readers and other assistive devices. When we open up the `application.html.erb` file in `/app/views/layouts/` we make the following adjustment:

 ```html
 <html lang="[USE TWO OR THREE LETTER CODE FOR YOUR LANGUAGE]"> 
 ```

 You can find the appropriate language code in the [Language Subtag Registry](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry). For example, if we were building an application in Hebrew, we would use `he` and if we were building an application in Hungarian we would use `hu`. Additionally, if the language you are using is read from right to left and not left to right, you can also add `dir="rtl"` in the opening `<html>` tag so that the browser knows to render the content in the appropriate direction.

 We are now ready to add the Nexmo Gem to our application and to acquire and safely store our API keys.

## Installing the Nexmo Gem and Acquiring Our API Keys

At this point we are now ready to install the Nexmo gem in our application! The Nexmo gem facilitates our interaction with the Nexmo API and is a powerful tool to bring the full suite of communications potential into our application. While we are installing the Nexmo gem we are also going to include the [dotenv](https://github.com/bkeepers/dotenv) gem as well. Dotenv allows us to safely store confidential information like API keys without exposing them to the wider Internet. 

In order to install the Nexmo gem open up your `Gemfile` found in the root directory of your project and add the following line near the top of the file:

```ruby
gem 'nexmo'
```

We also want to include the dotenv gem, but we only need it for development and testing, so we will group it in the `:development, :test` categories. Find the `group :development, :test` block in your `Gemfile` and add the following:

```ruby
gem 'dotenv-rails'
```

At this point after you save the file you are ready to incorporate these new gems into your app by executing the `bundle install` command from your command line. You will see in the output from the command that both the Nexmo and the dotenv-rails gems were successfully installed. 

There is just a couple more steps necessary to make sure that our API keys can be stored securely. First, add the following file to your root directory: `.env`. The `.env` file is where we will store our API keys. Secondly, are you planning to maintain this project with Git version control? If so, make sure to also add `.gitignore` to your root directory, if it is not already there, and make sure that you add `.env` in your `.gitignore` file. This will ensure that Git will not commit your private keys to the repository where they could potentially be viewed by others.

Now let's obtain our API keys from Nexmo so we can interact with the Nexmo API and begin sending out SMS messages. This would be a good time to sign up for a free Nexmo account. You can do so by going to [https://dashboard.nexmo.com/sign-up](https://dashboard.nexmo.com/sign-up). It takes just a moment and once you are done you will discover 2&euro; of credit to begin exploring all that you can do. 

After creating an account you will see your dashboard, which looks like this:

![Nexmo Dashboard](nexmo-dashboard.png)

As you can see there are two codes you need to access the API: the API key and the API secret. If you click the icon that looks like an eye you will reveal the API secret. Open up the `.env` file you created just a few moments ago and add the following:

```ruby
api_key=[YOUR API KEY]
api_secret=[YOUR API SECRET]
```

Make sure to replace `[YOUR API KEY]` and `[YOUR API SECRET]` with your actual API key and API secret. 

Congratulations you have now successfully installed the Nexmo gem, acquired your API keys and stored them safely and securely! You are now ready to go ahead and build your actual messenger logic and view. Let's dive in to our next step!

## Generating Our Files and Creating Our Model Method

There are several ways that we could organize the logic for our messenger application. In general, it is good practice to separate out the concerns of the various aspects of our application into their respective places and not to conflate them all together. Therefore, for this walkthrough, we are going to build the code that will connect to the Nexmo API and deliver the message as a model method. This will allow us to keep our controller logic succinct and to the point. 

First, let's generate the model, controller and view file structure for our messenger. We can do this by typing `rails generate controller Messenger` from the command line. We will see Rails create for us a controller and a model file as well as a view file structure. Namely, we now have the following to work with:

* `/app/assets/controllers/messenger_controller.rb` 
* `/app/assets/models/messenger.rb`
* `/app/views/messenger/`

In addition, Rails also created for us places to store Javascript and CSS for our messenger, if we wish to further customize our application's functionality and style.

When we open up our messenger model file we will see the following:

```ruby
class Messenger < ApplicationRecord
  
end
```

This is a brand new Rails model just waiting for us to give it some code! 

We are going to create a class method that will be accessible to all the subsequent code that references our messenger class. For clarity sake, let's call our method `send_message`. First, we need to initialize a new Nexmo client using our API key and API secret. Then, we need to build the text message we want to send, keeping the receipient phone number and message dynamically generated based on the content our application gives to it. Lastly, we'll output some feedback to ourselves so we know whether it sent successfully, and if not, what error message we received back from the Nexmo API. This is what it all looks like put together:

```ruby
def self.send_message(number, message)
  client = Nexmo::Client.new(
    api_key: ENV['api_key'], api_secret: ENV['api_secret']
    )
  response = client.sms.send(
    from: 'YOUR NEXMO NUMBER', 
    to: number, 
    text: message, 
    type: 'unicode'
  )
  if response.messages.first.status == '0'
    puts "Sent message id=#{response.messages.first.message_id}" 
  else 
    puts "Error: #{response.messages.first.error_text}"
  end
end
```

Within the creation of our `client` you will notice the usage of `ENV['api_key']` and `ENV['api_secret']`, which is referencing the variables we set in the `.env` file. We reference them as environment variables using the `ENV[ ]` format. 

Along with our API keys, we also need a Nexmo phone number to send SMS messages from. That number is entered between the single quotes on the `from:` line in the creation of our `response`. As part of your free Nexmo trial you will have access to a trial phone number from which you can send messages. Looking again at our Nexmo dashboard, the second half of the dashboard begins with "Try the API" and in that section is a `curl` command pre-made for you. In that `curl` command is your Nexmo trial phone number on the penultimate line of the command that begins with `-d from=`.  

Also, as part of our `response` you can see the `to:` and the `text:` fields are set to the heretofore undefined `number` and `message` keywords. These are referencing variables that we define in the creation of our method. They will be filled in with actual data that our controller will send to the method.

Lastly, a very important aspect of the composition of our `response` is the `type:` field. This is not necessary every time you send an SMS through the Nexmo API, but it is necessary when you are sending messages with non-English characters. 

At this point we are now ready to proceed with creating our Controller logic. Let's do it!

## Building Our Controller

Now that we have a model method that connects to the Nexmo API and sends the data to it to create an SMS message, we need to setup our controller so that our application knows to use this method. In a similar fashion to when we first opened our messenger model, when we open our messenger controller in `/app/controllers/messenger_controller.rb` we will find a clean slate waiting for us to fill it in with details:

```ruby
class MessengerController < ApplicationController

end
```

Our application is going to have the capability to take in a list of phone numbers in order to broadcast an SMS message to each one of them. In that case, we want to use an iterator to loop over a call to our model method for each phone number. We also want to turn our string of phone numbers into a data structure that can be iterated over, like an array, for example. We will use the `.split()` function to separate our string of phone numbers into an array. We need to give the function a character by which to split the numbers. Let's tell our users to provide us the phone numbers separated by a ',' and we'll `.split()` with the ',' as well. 

Once we have an array of phone numbers we can go ahead and send them to our model method:

```ruby
@numbers = message_params[:numbers].split(",")
@numbers.each do |num|
  sanitized_num = num.gsub(/([-() ])/, '')
  Messager.send_message(sanitized_num, message_params[:message])
end
```

On the first line we create our array of phone numbers and assign it to a variable `@numbers`. On the third line we scrub our phone numbers of any extraneous characters often associated with phone numbers like dashes and open and closed parentheses. Line two is where we open our iteration through the phone number array utilizing `.each()` and line five closes it. The fourth line is the heart of our controller method, which is where we send each sanitized phone number and the message to the `.send_message()` model method. When we put it all together we have the following:

```ruby
def new
  @numbers = message_params[:numbers].split(",")
  @numbers.each do |num|
    sanitized_num = num.gsub(/([-() ])/, '')
    Messager.send_message(sanitized_num, message_params[:message])
  end
  render :index
end
```

The last item we want to take care of in our controller is creating a private method to ensure that the parameters we are receiving are only the ones we expect to receive. We do that by creating a method called `message_params` and whitelisting in it which specific parameters we allow to be received. You may have noticed the usage of `message_params` in our `new` method above. This is a reference to the method we are going to create right now:

```ruby
private

def message_params
  params.permit(:numbers, :message)
end
```

Now we can move on to our last step, which is creating a view with a simple form for users to broadcast SMS messages from. 

## Creating Our View

Within the `/app/views/messenger/` folder we are going to create one file, `index.html.erb`, which is where we will build our form. For our purposes, we are going to concern ourselves with the creation of a simple form with minimal design. However, you should feel free to add any design flourishes you would like to your actual application. 

First, let's give a title to our page:

```html
<h1>The Messenger App</h1>
```

Then, let's invite our users to fill out the form:

```html
<h2>Submit Your Message Here:</h2>
```

And now let's use the Rails form helper syntax to build out our form:

```ruby
<%= form_tag("/messenger/new", method: "post") do %>
  <%= label_tag(:numbers, "Phone Number:") %>
  <br />
  <%= text_area_tag(:numbers, "02-123-4567, 03-123-4567, 04-123-4567", size: "24x6") %>
  <br />
  <%= label_tag(:message, "Message:" %>
  <br />
  <%= text_area_tag(:message, "What do you want to say?", size: "24x6") %>
  <br />
  <%= submit_tag("Submit") %>
<% end %>
```

Finally, we want to make sure our application routes our paths correctly. In the `routes.rb` file, located in `/config/`, add the following two lines:

```ruby
root 'messenger#index'

post '/messenger/new', to: 'messenger#new'
```

Way to go! If you made it this far, you now have a fully functioning Rails application that can broadcast SMS messages in any language powered by Nexmo. Take a deep breath because you deserve it. 

## To Recap

In this walkthrough we accomplished quite a lot. We learned how to setup a Rails application and how to leverage the Nexmo Ruby gem to communicate with the Nexmo API. We learned how to acquire our API keys and how to safely and securely store them, while also taking advantage of version control with Git. We built an application that utilizes Nexmo's unicode capability to send SMS messages in any language, from Albanian to Zulu, regardless of the type of characters used in the language. 

This is just the tip of the iceberg of what can be accomplished with Nexmo to communicate with a global audience, whether you are building intelligent chatbots or synthesizing human speech, you can find the resources to help make that possible with Nexmo.

## Further Reading

To learn more about this subject consider the following:

* [Nexmo API SMS Overview](https://developer.nexmo.com/messaging/sms/overview)
* [Nexmo API SMS Documentation](https://developer.nexmo.com/api/sms)
* [Nexmo API Country Specific Features](https://developer.nexmo.com/messaging/sms/guides/country-specific-features)
* [Concatenation and Ecoding SMS Messages](https://developer.nexmo.com/messaging/sms/guides/concatenation-and-encoding)
* [Make An Outbound Text-to-Speech Phone Call With Ruby on Rails](https://www.nexmo.com/blog/2017/11/02/outbound-text-to-speech-voice-call-ruby-on-rails-dr/)
* [Getting Started With SMS and Voice Programmable Communications](https://www.nexmo.com/blog/2017/03/03/sms-voice-programmable-communications-dr/)







