class profile::jenkins_master_consul {
  ### Jenkins Server Config ###
  class { '::jenkins':
    cli => true,
  }
  jenkins::plugin { [
    'git',
    'git-client',
    'scm-api',
    'notification',
  ]: }

  class { '::python':
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => true,
  }

  # GitHub SSH Setup
  file { 'ssh-key-directory':
    ensure  => directory,
    path    => '/var/lib/jenkins/.ssh',
    owner   => 'jenkins',
    mode    => '0700',
    require => Class['jenkins'],
  }
  file { 'deploy-key':
    ensure  => file,
    path    => '/var/lib/jenkins/.ssh/id_rsa',
    owner   => 'jenkins',
    mode    => '0400',
    content => hiera('deploy_private_key', ''),
    require => Class['jenkins'],
  }
  file { 'github_known_hosts':
    ensure  => file,
    path    => '/var/lib/jenkins/.ssh/known_hosts',
    owner   => 'jenkins',
    mode    => '0644',
    source  => 'puppet:///modules/profile/jenkins_master_consul/github_known_hosts',
    replace => false,
    require => Class['jenkins'],
  }

  # END GitHub SSH Setup #

  class { '::jenkins_job_builder':
    version             => 'latest',
    manage_dependencies => false,
  }
  # Sad hack because Class['jenkins_job_builder'] does not contain resources properly
  # Do not do this at home. Ever. Please.
  # Kittens die.
  Class['::python::install'] -> Package['jenkins-job-builder']
  ### END Jenkins Server Config ###

  ### Jenkins Infrastructure as Code (IaC) config ###
  $_config_repo = hiera('jenkins::job_config_repo', undef)
  $_update_jenkins_jobs_cmd = 'jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update /etc/jenkins_jobs/conf'
  if $_config_repo {
    vcsrepo { '/etc/jenkins_jobs/conf':
      ensure   => present,
      source   => $_config_repo,
      provider => 'git',
      require  => Class['::jenkins_job_builder'],
      notify   => Exec['bootstrap-jenkins-jobs'],
    }
    exec { 'bootstrap-jenkins-jobs':
      command     => $_update_jenkins_jobs_cmd,
      path        => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin',
        '/sbin',
        '/bin',
      ],
      refreshonly => true,
    }
  }
  file { '/usr/local/bin/update-jenkins-jobs':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    content => "#!/usr/bin/env bash\n${_update_jenkins_jobs_cmd}",
  }
  ### End Jenkins IaC config ###

  ### Consul Service Advertisment ###
  adapter::consul_service_with_check { 'jenkins':
    tags => ['master'],
    port => '8080',
  }
  ### END Consul Service Advertisment ###
}
