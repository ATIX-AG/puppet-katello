# == Class: katello
#
# Install and configure katello
#
# === Parameters:
#
# $user::               The Katello system user name;
#                       default 'katello'
#
# $group::              The Katello system user group;
#                       default 'katello'
#
# $user_groups::        Extra user groups the Katello user is a part of;
#                       default 'foreman
#
# $oauth_key::          The oauth key for talking to the candlepin API;
#                       default 'katello'
#
# $oauth_secret::       The oauth secret for talking to the candlepin API;
#
# $log_dir::            Location for Katello log files to be placed
#
class katello (

  $user = $katello::params::user,
  $group = $katello::params::group,
  $user_groups = $katello::params::user_groups,

  $oauth_key = $katello::params::oauth_key,
  $oauth_secret = $katello::params::oauth_secret,

  $log_dir = $katello::params::log_dir

  ) inherits katello::params {

  group { $katello::group:
    ensure => 'present'
  }


  class { 'apache::certs': } ~>
  class { 'katello::install': } ~>
  class { 'katello::certs': } ~>
  class { 'katello::config': } ~>
  Exec['foreman-rake-db:seed']

  class { 'pulp::parent::certs': } ~>
  class { 'pulp':
    oauth_key     => $katello::oauth_key,
    oauth_secret  => $katello::oauth_secret,
    messaging_url => 'ssl://localhost:5671',
  } ~>
  class { 'candlepin':
    user_groups    => $katello::user_groups,
    oauth_key      => $katello::oauth_key,
    oauth_secret   => $katello::oauth_secret,
    deployment_url => 'katello',
    before         => Exec['foreman-rake-db:seed']
  } ~>
  class{ 'pulp':
    oauth_key     => $katello::oauth_key,
    oauth_secret  => $katello::oauth_secret,
    before        => Exec['foreman-rake-db:seed']
  } ~>
  class{ 'elasticsearch':
    before         => Exec['foreman-rake-db:seed']
  } ~>
  class{ 'katello::service': }
}
