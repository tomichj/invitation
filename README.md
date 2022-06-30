# Invitation

A Rails gem to issue scoped invitations.

Please see the [CHANGELOG] for information on the latest changes.

Please use [GitHub Issues] to report bugs. You can contact me directly on twitter at
[@JustinTomich](https://twitter.com/justintomich).

[![Gem Version](https://badge.fury.io/rb/invitation.svg)](https://badge.fury.io/rb/invitation) ![Build status](https://travis-ci.org/tomichj/invitation.svg?branch=master) ![Code Climate](https://codeclimate.com/github/tomichj/invitation/badges/gpa.svg)


## Overview

Allow users to invite others to join an organization or resource. Plenty of gems can issue a 'system-wide' invitation,
but few offer 'scoped' invitations, giving an invited user access to a particular invitable organization or resource.

Invitations are issued via email. You can invite users new to join the system while giving them permissions to
a resource, or invite existing users by giving them access to a new resource.

* a user can invite someone to join an invitable by providing an email address to invite
* if the user already exists, that user is granted access to the invitable, and a notification email is sent
* if the user does not exist, sends an email with a link to sign up. When the new user signs up,
they are added to the invitable resource/organization.
* the invite grants the invited user access to ONLY the invitable organization they were invited to.


## Prerequisites

* An authentication system with a User model and current_user helper, e.g. https://github.com/tomichj/authenticate
* Your user model must include an :email attribute.
* Additional model classes that are resources or organizations you wish to invite users to join, usually with a
many-to-many relationship to your user model.
* You probably also want an authorization system to restrict who can issue invitations to particular resources

A example user-to-organization system you might be familiar with: Basecamp's concepts of accounts and 
projects (invitables) and users.


## Install

To get started, add Invitation to your `Gemfile` and run `bundle install` to install it:

```ruby
gem 'invitation'
```

Then run the invitation install generator:

```sh
rails generate invitation:install
```

If your user model is not User, you can optionally specify one: `rails generate invitation:install --model Profile`. 

The install generator does the following:

* Add an initializer at `config/initializers/invitation.rb`, see [Configure](#configure) below.
* Insert `include Invitation::User` into your `User` model.
* Create a migration for the Invite class.


Then run the migration that Invitation just generated.

```sh
rake db:migrate
```


## Configure

Override any of these defaults in your application `config/initializers/invitation.rb`.

```ruby
Invitation.configure do |config|
  config.user_model = '::User'
  config.user_registration_url = ->(params) { Rails.application.routes.url_helpers.sign_up_url(params) } 
  config.mailer_sender = 'reply@example.com'
  config.routes = true
  config.case_sensitive_email = true
end
```

Configuration parameters are described in detail here: [configuration]


### Invitable

You'll need to configure one or more model classes as `invitables`. Invitables are resources or organizations that
can be joined with an invite.

An `invitable` must have some sort of name for Invitation to use in views and mailers.  An invitable needs to 
call a class method, `invitable`, with one of the following options:
* `named: "String"`
* `named_by: :some_method_name`.

Example: a Company model that users can be invited to join. The companies are identified in invitation emails by
their `name` attribute:

```ruby
class Company < ActiveRecord::Base
  invitable named_by: :name
end
```


### User Registration Controller

Your user registration controller must `include Invitation::UserRegistration`. You'll want to invoke `set_invite_token`
before you execute your `new` action, and `process_invite_token` after your `create` action.

If you're using [Authenticate](https://github.com/tomichj/authenticate), for example:
```ruby
class UsersController < Authenticate::UsersController
  include Invitation::UserRegistration
  before_action :set_invite_token, only: [:new]
  after_action :process_invite_token, only: [:create]
end
``` 
To pass the invite token on signup, add `invite_token` as a hidden field in your signup form.

## Usage

Invitation adds routes to create invitations (GET new_invite and POST invites). Once you've configured
Invitation and set up an invitable, add a link to new_invite, specifying the the invitable id and type in the link:

```erb
  <%= link_to 'invite a friend', 
              new_invite_path(invite: { invitable_id: account.id, invitable_type: 'Account' } ) %>
```

Invitation includes a simple `invitations#new` view which accepts an email address for a user to invite. 

When the form is submitted, [invites#create](app/controllers/invitation/invites_controller.rb) will create
an [invite](app/models/invite.rb) to track the invitation. An email is then sent:

* a new user is emailed a link to your user registration page as set in [configuration], with a secure
invitation link that will be used to 'claim' the invitation when the new user registers 

* an existing user is emailed a notification to tell them that they've been added to the resource


### JSON Invitation

You can send a JSON request to [invites#create](app/controllers/invitation/invites_controller.rb).

* request:
```javascript
invite:
{
    "email": String,
    "invitable_id": Number,
    "invitable_type": String
}
```

or, with an array of multiple `emails`:

```javascript
invite:
{
    "emails": [String],
    "invitable_id": Number,
    "invitable_type": String
}
```

* response:
```javascript
{
    "id": Number, 
    "email": String, 
    "sender_id": Number, 
    "recipient_id": Number (optional), 
    "invitable_id": Number, 
    "invitable_type": String, 
}
```

or, with multiple emails requested, an array of responses:

```javascript
[{
    "id": Number, 
    "email": String, 
    "sender_id": Number, 
    "recipient_id": Number (optional), 
    "invitable_id": Number, 
    "invitable_type": String, 
},
{
    "id": Number, 
    "email": String, 
    "sender_id": Number, 
    "recipient_id": Number (optional), 
    "invitable_id": Number, 
    "invitable_type": String, 
}]
```

## Security

Many systems require authorization to issue invitations to a resource. `Invitation` does not handle authorization,
but is intended to be a simple, easily extended framework upon which you can impose any required authorization scheme.

Most implementations will require extending the `InvitationsController`. [See below](#controllers) to read more
about extending InvitationController.

A common use case:
* every invitable resource has authorization requirements exposed via a method, we'll call it `can_invite?(user)`
* the current user must be authorized before issuing invitations

To implement: extend `InvitesController` and add a before_action to authorize access to the resource or resources. A
real implementation would probably do something more than just `raise 'unauthorized'`.

```ruby
# app/controllers/invites_controller.rb
class InvitesController < Invitation::InvitesController
  before_action :authorize

  private

  def authorize
    invitable = load_invitable
    invitable.can_invite?(current_user) or raise 'unauthorized'
  end

  def load_invitable
    invite_params[:invitable_type].classify.constantize.find(invite_params[:invitable_id])
  end
end
```


## Overriding Invitation


### Views

You can quickly get started with a rails application using the built-in views. See [app/views](/app/views) for
the default views. When you want to customize an Invitation view, create your own copy of it in your app.

You can use the Invitation view generator to copy the default views and translations
(see [translations](#translations) below) into your application:

```sh
$ rails generate invitation:views
```


### Routes

Invitation adds routes to your application. See [config/routes.rb](/config/routes.rb) for the default routes.

If you want to control and customize the routes, you can turn off the built-in routes in
the Invitation [configuration] with `config.routes = false` and dump a copy of the default routes into your
application for modification.

To turn off Invitation's built-in routes:

```ruby
Invitation.configure do |config|
  config.routes = false
end
```

You can run a generator to dump a copy of the default routes into your application for modification. The generator
will also switch off the routes by setting `config.routes = false` in your [configuration].

```sh
$ rails generate invitation:routes
```


### Controllers

You can customize the `invites_controller.rb` and the `invites_mailer.rb`. See [app/controllers](/app/controllers)
for the controller, and [app/mailers](/app/mailers) for the mailer.

To override `invites_controller.rb`, subclass the controller and update your routes to point to your implementation.

* subclass the controller:

```ruby
# app/controllers/invites_controller.rb
class InvitesController < Invitation::InvitesController
  # render invite screen
  def new
    # ...
  end
  ...
end
```

* update your routes to use your new controller. 

Start by dumping a copy of Invitation's routes to your `config/routes.rb`:

```sh
$ rails generate invitation:routes 
```

Now update `config/routes.rb`, changing the controller entry so it now points to your `invites` controller instead
of `invitation/invites`:

```ruby
resources :invites, controller: 'invites', only: [:new, :create]
```

You can also use the Invitation controller generator to copy the default controller and mailer into 
your application if you would prefer to more heavily modify the controller.

```sh
$ rails generate invitation:controllers
```


### Layout

Invitation uses your application's default layout. If you would like to change the layout Invitation uses when
rendering views, you can either deploy copies of the controllers and customize them, or you can specify
the layout in an initializer. This should be done in a to_prepare callback in `config/application.rb`
because it's executed once in production and before each request in development.
                              
You can specify the layout per-controller:

```ruby
config.to_prepare do
  Invitation::InvitesController.layout 'my_invites_layout'
end
```


### Translations

All flash messages and email subject lines are stored in [i18n translations](http://guides.rubyonrails.org/i18n.html).
Override them like any other i18n translation.

See [config/locales/invitation.en.yml](/config/locales/invitation.en.yml) for the default messages.


## Thanks

This gem was inspired by and draws heavily from:
* https://gist.github.com/bigglesrocks/9026919

With additional inspiration from:
* https://github.com/scambra/devise_invitable

## Contributors

Many thanks to:

* [augustocbx](https://github.com/augustocbx) added pt-BR locale file and fixed an init bug
* [vincentwoo](https://github.com/vincentwoo/) raising the security bar, & bumping Invitation to rails 5.1
* [conarro](https://github.com/conarro) added case_sensitive_email configuration option
* [itkin](https://github.com/itkin) bugfix, stringified configuration.user_model 
* [thesubr00t](https://github.com/thesubr00t) made recipient association optional for rails 5+

## Future changes

Possible future changes, some of which may be breaking:

* accepted flag, so we can scope invites by accepted vs not yet accepted
* expiration date - invites expire, scope expired by not expired
* move all view text to locale
* issue many invitations at once?
* dynamic user name lookup? requires JS, CSS
* add JS support to invites#create

## License

This project rocks and uses MIT-LICENSE.


[configuration]: lib/invitation/configuration.rb
[CHANGELOG]: CHANGELOG.md
[GitHub Issues]: https://github.com/tomichj/invitation/issues
