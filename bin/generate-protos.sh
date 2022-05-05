#!/usr/bin/env bash

set -eo pipefail

DIR=`dirname "$0"`
OUTPUT_DIR=$DIR/../lib/apollo-studio-tracing/proto

# echo "Removing old client"
# rm -f $OUTPUT_DIR/apollo.proto $OUTPUT_DIR/apollo_pb.rb

# echo "Downloading latest Apollo Protobuf IDL"
# curl --silent --output $OUTPUT_DIR/apollo.proto https://raw.githubusercontent.com/apollographql/apollo-server/main/packages/apollo-reporting-protobuf/src/reports.proto

echo "Generating Ruby client stubs"
protoc -I $OUTPUT_DIR --ruby_out $OUTPUT_DIR $OUTPUT_DIR/apollo.proto
