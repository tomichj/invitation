# Invitation Changelog


## [0.6.1] - October 1, 2019

### Fix: generator support for rails 6.0
- fixed migration_version in generators to support rails 5 and above
- Appraisal entry and gemfile for Rails 6.0.0
- bumped gemspec to include rails 6.0.0
- switched from factory_girl to factory_bot

[0.6.0]: https://github.com/tomichj/invitation/compare/0.6.0...0.6.1


## [0.6.0] - May 1, 2019

### Feature: support for rails 6.0
- added Appraisal entry and gemfile for 6.0.0rc1
- bumped gemspec to include rails 6.0.0rc1
- bumped version

[0.6.0]: https://github.com/tomichj/invitation/compare/0.5.1...0.6.0


## [0.5.1] - June 7, 2018

### Feature: support for rails 5.2
- added Appraisal entry and gemfile for 5.2
- added rakefile tasks for build and release
- bumped gemspec to include rails 5.2
- bumped version
- added sqlite3.represent_boolean_as_integer = true to dummy app for specs
- specs now test for http status 201 instead of :success and :created,
  :success was deprecated, switched to 201 for brevity and longevity of test

[0.5.1]: https://github.com/tomichj/invitation/compare/0.5.0...0.5.1


## [0.5.0] - March 12, 2018

### API change
- `InviteForm` extracted from invites_controller.rb, added at `app/forms/invitation/invite_form.rb`
- `controllers_generator.rb` now has three targets: `create_controllers`, `create_mailers`, and `create_forms`
- deleted empty `lib/tasks/invitation_tasks.rake`

[0.5.0]: https://github.com/tomichj/invitation/compare/0.4.5...0.5.0


## [0.4.5] - March 9, 2018

### Bugfix:
- migration versioned for Rails >= 5

[0.4.5]: https://github.com/tomichj/invitation/compare/0.4.4...0.4.5


## [0.4.4] - September 30, 2017
- recipient association optional for Rails >= 5

[0.4.4]: https://github.com/tomichj/invitation/compare/0.4.3...0.4.4


## [0.4.3] - July 1, 2017

### API change
- configuration.user_model now accepts the user class (with a warning), or the user class name (a String)
 
[0.4.3]: https://github.com/tomichj/invitation/compare/0.4.2...0.4.3


## [0.4.2] - July 1, 2017

### API change
- accept a string for configuration.user_model and constantize it
 
[0.4.2]: https://github.com/tomichj/invitation/compare/0.4.1...0.4.2


## [0.4.1] - April 26, 2017

### Bugfix:
- added case_insensitive_email to template used by install generator
 
[0.4.1]: https://github.com/tomichj/invitation/compare/0.4...0.4.1


## [0.4] - April 26, 2017

### Feature:
- added case_sensitive_email configuration option.

[0.4]: https://github.com/tomichj/invitation/compare/0.3...0.4


## [0.3] - March 26, 2017

### Feature:
- Added support for Rails 5.1

[0.3]: https://github.com/tomichj/invitation/compare/0.2...0.3


## [0.2] - October 17, 2016

### Feature:
- adding pt-BR locale file and fixing an init bug.

[0.2]: https://github.com/tomichj/invitation/compare/0.1.1...0.2


## [0.1.1] - April 21, 2016

### Internal changes:
- invites controller now users a Form object, form accepts :email or :emails, builds one invite per email address.

[0.1.1]: https://github.com/tomichj/invitation/compare/0.1.0...0.1.1


## [0.1.0] - April 18, 2016

* `invites#create` supports :email or emails:[] in request, via html or json.
* `invites#create` error message reports emails it failed to invite
* `invites#create` invite_issued or invite_error messages now 'count' sensitive, e.g. "Invitation issued" vs "Invitations issued"
* removed after_invite_url from config, after invite user is redirected to invitable's show action
* added config.routes, set to true by default.
* fixed invitation view generator packaging
* significantly more tests

[0.1.0]: https://github.com/tomichj/invitation/compare/0.0.2...0.1.0


## [0.0.2] - April 11, 2016

* invites#create supports html or json. Redirects to invitable with html, returns invite (minus token) as json.
* gemspec dependencies cleaned up
* documentation updated

[0.0.2]: https://github.com/tomichj/invitation/compare/0.0.1...0.0.2


## 0.0.1 - April 9, 2016

Initial release.

