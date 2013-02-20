class static_sites (
  $user        = 'www-data',
  $home        = '/var/www',
  $manage_user = false,
  $manage_home = false,
  $jekyll      = false,
  $misaki      = false,
  $private_key = undef,
  $public_key  = undef,
  $key_name    = 'id_rsa'
) {
  $ssh_dir = "${static_sites::home}/.ssh"
  $private_key_file = "${ssh_dir}/${key_name}"
  $public_key_file = "${private_key_file}.pub"

  if $manage_user {
    group{$static_sites::user:
      ensure  => present,
    }
    
    user{$static_sites::user:
      ensure  => present,
      gid     => $static_sites::user,
      home    => $static_sites::home,
      require => Group[$static_sites::user],
    }
  }

  
  File{
    owner => $static_sites::user,
    group => $static_sites::user,
  }

  Package{
    ensure => installed
  }

  @file{$ssh_dir:
      ensure   => directory,
      mode     => '0700',
  }

  if $manage_home {
    file{$static_sites::home:
      ensure   => directory,
      mode     => '0755',
    }

    file{"${static_sites::home}/.staging":
      ensure => directory,
      mode   => '0700',
    }
  }

  #Manage the prerequisites for using the jekyll site type
  if $static_sites::jekyll {
    package {
      'rubygems':;
      'ruby-dev':;
      'build-essential':;
    }
      
    package {'jekyll':
      provider => gem,
      require  => [Package['rubygems'], Package['build-essential'], Package['ruby-dev']],
    }
  }

  #Manage the prerequisites for using the jekyll site type
  if $static_sites::misaki {
    package {
      'openjdk-7-jre-headless':;
      'leiningen':;
    }
  }

  if $static_sites::private_key {
    realize File[$ssh_dir]
    
    file{$private_key_file:
      ensure   => file,
      mode     => '0700',
      content  => $static_sites::private_key,
    }
  }

  if $static_sites::public_key {
    realize File[$ssh_dir]
    
    file{$public_key_file:
      ensure   => file,
      mode     => '0700',
      content  => $static_sites::public_key,
    }
  }
}
