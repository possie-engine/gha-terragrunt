#!/bin/bash

function setupSecrets {
	# Setup the secrets for aws credentials and kubernetes credentials
  mkdir -p ~/.kube && mkdir -p ~/.aws
  echo "${kubeConfig}" > ~/.kube/config
  echo "${awsCredentials}" > ~/.aws/credentials
  echo "${awsConfig}" > ~/.aws/config

  # Setup tf module fetching key
  mkdir -p ~/.ssh \
  && echo "${tfModuleKey}" > ~/.ssh/id_rsa \
  && chmod 400 ~/.ssh/id_rsa \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts \
	&& echo "StrictHostKeyChecking no" > ~/.ssh/config
}
