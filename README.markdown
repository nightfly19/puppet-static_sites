# Static Sites module

Sage Imel <sage@sagenite.net>

This module deploys and can keep up-to-date static websites,
and websites made with a few static site generators (currently (Jekyll)[https://github.com/mojombo/jekyll], and (Misaki)[https://github.com/liquidz/misaki]).

# Dependencies

## Required
* Debian/Ubuntu
* NGINX
* [puppetlabs-vcsrepo](https://github.com/puppetlabs/puppetlabs-vcsrepo)

## Recommended
* [puppetlabs-nginx](https://github.com/puppetlabs/puppetlabs-nginx)

# Quick Start

Currently this module is closely coupled to Debian family Linux and to NGINX.

The static_sites class is required to use the included types:
* static_sites::static
* static_sites::jekyll
* static_sites::misaki

## Example Usage

### Preperation
<pre>
  include nginx

  class{"static_sites":
    manage_user => true,
    manage_home => true,
    private_key => "your private key here",
    public_key  => "your public key here",
  }
</pre>

### Static Site
<pre>
  static_sites::static{"example.com":
    source_repo => 'git@github.com:user/example.com',
    latest      => true,
  }
</pre>

### Misaki Site
<pre>
  static_sites::misaki{"example.net":
    source_repo  => 'git@github.com:user/example.net',
    project_name => 'example',
    revision     => 'example',
    latest       => true,
  }
</pre>
