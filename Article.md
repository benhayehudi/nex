# Getting Started with Broadcasting Non-English SMS Messages with Rails and the Nexmo API   
*Ben Greenberg*

## Overview

In this article we are going to demonstrate how to create a Ruby on Rails application to broadcast SMS messages to a list of phone numbers. There is a multitude of use cases for broadcasting messages to employees, customers or clients. Whether you want to share the latest sale with your loyal customers, update employees on an important update or notify your clients of an upcoming schedule change, the ability to broadcast that message easily and efficiently is integral. With the help of the Nexmo Ruby Gem and the Nexmo API we can easily create an application to accomplish this. We can leverage the built in Unicode support of the Nexmo API to send SMS messages in any language, including languages that are not based on English characters, like Hebrew, Mandarin or Arabic.

Let's get started!

## Prerequisites

In order to begin our tutorial we are going to require the following:

* A [Nexmo account](https://dashboard.nexmo.com/sign-up) (free to sign up and get &euro;2 free credit!)
* [Rails](https://rubyonrails.org/) installed on your computer
* Basic comprehension of [Ruby](https://www.ruby-lang.org/en/documentation/)

## Setting Up Our Rails Application

To begin let's go ahead and initialize a new Rails application. This can be done by simply typing in the command line:

```
rails new name-of-app
```

At the time of initialization you can also specify the database you prefer, with `--database=[DATABASE]`. If you do not specify a database Rails will default to SQLite. You can also offer an additional flag of `-T` to skip installing the default unit tests. For example, with both flags specified your initialization would look like this: `rails new name-of-app --database=postgresql -T`, which would create a new Rails app running with a PostgreSQL database and no default tests installed. 

Once the installation completes we can open up the new directory in our preferred code editor. There is going to be a few items we want to accomplish to make sure our application can handle non-English characters and that we have a safe place to store our eventual Nexmo API keys.

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

## Installing the Nexmo Gem and Acquiring Our API Keys



## Creating Our Message Logic and View



## To Recap



## Further Reading






