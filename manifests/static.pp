define static_sites::static(
  $source_repo,
  $dir_name    = $title,
  $site_name   = $title,
  $revision    = 'master',
  $provider    = 'git',
  $nx_conf_dir = $nginx::params::nx_conf_dir,
  $latest      = false,
) {
  $repo_dir     = "${static_sites::home}/${dir_name}"
  $web_dir      = $repo_dir
  $update_exec  = "git-pull-${title}"

  if $latest {
    exec{$update_exec:
      path        => ["/bin","/usr/bin","/usr/local/bin"],
      provider    => shell,
      command     => 'true',
      onlyif      => 'git pull | grep -v "Already up-to-date"',
      cwd         => $repo_dir,
      user        => $static_sites::user,
      require     => [Vcsrepo[$repo_dir], Class['static_sites']],
    }
  }

  vcsrepo{$repo_dir:
    ensure   => 'present',
    provider => $provider,
    source   => $source_repo,
    user     => $static_sites::user,
    require  => Class['static_sites'],
  }

  file{"${site_name}-nginx":
    path    => "${nx_conf_dir}/conf.d/${site_name}.conf",
    mode    => '0744',
    owner   => $static_sites::user,
    group   => $static_sites::user,
    content => template('static_sites/static_site.erb'),
    require => Class['static_sites'],
    notify  => Service['nginx'],
  }
}
