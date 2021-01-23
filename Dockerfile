# Use Google's official Dart image.
FROM google/dart-runtime-base

# To be able to include local packages we need to follow rules from
# https://hub.docker.com/r/google/dart-runtime-base

WORKDIR /logkeep/log_keep_back

ADD pkg/log_keep_shared/pubspec.yaml /logkeep/pkg/log_keep_shared/

ADD log_keep_back/pubspec.* /logkeep/log_keep_back/
RUN pub get
ADD . /logkeep
RUN pub get --offline