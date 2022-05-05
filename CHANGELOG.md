# [1.1.0](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/compare/v1.0.1...v1.1.0) (2020-12-16)


### Features

* support global `enabled` flag for tracing ([16d9186](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/16d91865db51315c2b0a378402d96a9414a31c8f))

## [1.0.1](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/compare/v1.0.0...v1.0.1) (2020-11-02)


### Bug Fixes

* **tracing:** avoid trapping SIGINT, just use `at_exit` ([de7c85e](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/de7c85e63b455a98474694a972daf001f8b12719))

# [1.0.0](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/compare/v0.1.0...v1.0.0) (2020-10-26)


### Bug Fixes

* revert Rails.logger reference, doesn't work correctly in non-Rails environment ([eeea691](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/eeea6913be0171db0b45c58ff6b34dddbbea764b))
* **debug:** add debug queueing ([074bb79](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/074bb79aef78a7b5f65744dd5a6ea4a913de4338))
* **tracing:** ensure thread started when queueing traces ([4bb2238](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/4bb22387fc5230909b1201a58b7be922a153dcb7))
* properly capture errors and record them on traces ([3ba25ff](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/3ba25fff60efab9a98f6212192b7543de9a19057))
* use Rails.logger if it exists ([b0a7103](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/b0a7103882cda74dbcf39cf6f84339e655e3506b))
* **tracing:** fix multiplexed tracing ([43b6c86](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/43b6c86006be2f300211b2c2bccdf5b8d0ffc658))
* remove NotInstalledError, remove unused src file ([dc8e31d](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/dc8e31da901c998ef1bafc6a5b28aae51f3ee0c6))


### chore

* remove debug statements, initial release! ([5f634c0](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/commit/5f634c05f5560fa6cf9f68cfb5837c715828214c))


### BREAKING CHANGES

* Initial release. Substantially divergent from `apollo-federation-ruby`, so marking
this as a breaking change.
