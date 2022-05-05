# apollo-studio-tracing

[![CircleCI](https://circleci.com/gh/EnjoyTech/apollo-studio-tracing-ruby/tree/master.svg?style=svg)](https://circleci.com/gh/EnjoyTech/apollo-studio-tracing-ruby/tree/master)

This gem extends the [GraphQL Ruby](http://graphql-ruby.org/) gem to add support for sending trace data to [Apollo Studio](https://www.apollographql.com/docs/studio/). It is intended to be a full-featured replacement for the unmaintained [apollo-tracing-ruby](https://github.com/uniiverse/apollo-tracing-ruby) gem, and it is built HEAVILY from the work done within the Gusto [apollo-federation-ruby](https://github.com/Gusto/apollo-federation-ruby) gem as well an exploratory branch created [here](https://github.com/salsify/apollo-tracing-ruby/tree/feature/new-apollo-api).

## DISCLAIMER

This gem is still in a beta stage and may have some bugs or incompatibilities. See the [Known Issues and Limitations](#known-issues-and-limitations) below. If you run into any problems, please [file an issue](https://github.com/EnjoyTech/apollo-studio-tracing-ruby/issues).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apollo-studio-tracing'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install apollo-studio-tracing
```

## Getting Started

1. Add `use ApolloStudioTracing` to your schema class.
2. Change your controller to add `apollo_tracing_enabled: true` to the execution context. Ensure that `apollo_client_name` and `apollo_client_version` are set as well, for proper client information in Studio:

   ```ruby
   def execute
     # ...
     context = {
       apollo_client_name: request.headers["apollographql-client-name"],
       apollo_client_version: request.headers["apollographql-client-version"],
       apollo_tracing_enabled: Rails.env.production?,
     }
     # ...
   end
   ```

### Updating the Apollo .proto definition

Install [Google Protocol Buffers](https://github.com/protocolbuffers/protobuf) via Homebrew

```
$ brew install protobuf
```

Regenerate the Ruby protos with the included script:

```
$ bin/generate-proto.sh
Removing old client
Downloading latest Apollo Protobuf IDL
Generating Ruby client stubs
```

## Known Issues and Limitations

- Only works with class-based schemas, the legacy `.define` API will not be supported

## Maintainers

- [Luke Sanwick](https://github.com/lsanwick)
