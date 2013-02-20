define static_sites::jekyll(
  $source_repo,
  $dir_name    = $title,
  $site_name   = $title,
  $revision    = 'master',
  $provider    = 'git',
  $nx_conf_dir = $nginx::params::nx_conf_dir,
  $latest      = false,
) {
  $repo_dir     = "${static_sites::home}/.staging/${dir_name}"
  $web_dir      = "${static_sites::home}/${dir_name}"
  $jekyll_exec  = "jekyll-${title}"
  $cleanup_exec = "cleanup-${title}"
  $rsync_exec   = "rsync-${title}"
  $update_exec  = "git-pull-${title}"

  if $latest {
    exec{$update_exec:
      path        => ["/bin","/usr/bin","/usr/local/bin"],
      provider    => shell,
      command     => 'true',
      onlyif      => 'git pull | grep -v "Already up-to-date"',
      cwd         => $repo_dir,
      user        => $static_sites::user,
      notify      => Exec[$jekyll_exec],
      require     => [Vcsrepo[$repo_dir], Class['static_sites']],
    }
  }

  exec{$jekyll_exec:
    path        => ["/bin","/usr/bin","/usr/local/bin"],
    provider    => shell,
    command     => 'jekyll',
    cwd         => $repo_dir,
    user        => $static_sites::user,
    notify      => Exec[$rsync_exec],
    require     => [Vcsrepo[$repo_dir], Class['static_sites']],
    refreshonly => true,
  }

  exec{$rsync_exec:
    path        => ["/bin", "/usr/bin","/usr/local/bin"],
    provider    => shell,
    command     => "rsync -tav --delete ./ ${web_dir}/",
    cwd         => "${repo_dir}/_site",
    user        => $static_sites::user,
    notify      => Exec[$cleanup_exec],
    require     => [Exec[$jekyll_exec], Class ['static_sites']],
    refreshonly => true,
  }

  exec{$cleanup_exec:
    path        => ["/bin", "/usr/bin","/usr/local/bin"],
    provider    => shell,
    command     => "git reset --hard && git clean -f",
    cwd         => "${repo_dir}",
    require     => [Exec[$jekyll_exec], Class ['static_sites']],
    user        => $static_sites::user,
    refreshonly => true,
  }

  vcsrepo{$repo_dir:
    ensure   => 'present',
    provider => $provider,
    source   => $source_repo,
    user     => $static_sites::user,
    notify   => Exec[$jekyll_exec],
    require  => Class['static_sites'],
  }

  file{$web_dir:
    ensure  => directory,
    owner   => $static_sites::user,
    group   => $static_sites::user,
    require => Vcsrepo[$repo_dir],
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
