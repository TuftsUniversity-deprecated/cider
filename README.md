# CIDER

CIDER is a web-based archival collection management tool designed by [the Digital Collections and Archives group at Tufts University](http://sites.tufts.edu/dca/).

## Installation

CIDER has many third-party library dependencies, as listed in the file CIDER/cpanfile. 

Assuming you are on a Unix-like system with access to a reasonably up-to-date [Perl](http://perl.org), you can install them all at once by running the following command while your working directory is the "CIDER" subdirectory (the same directory that contains the cpanfile):

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

This should crunch though the installation of a bunch of Perl modules that CIDER needs. It'll take a few minutes. When it's all done, CIDER will be ready for testing and configuration

## Testing

### Regression tests

CIDER includes a suite of regression tests you can run from the command line. To run them, first create a MySQL database called `cider_test`. Either make it a local database with passwordless access by the root user, or set it up however you like and then update the "DB Conf" section of the file CIDER/t/conf/cider.conf to match. Then, from the CIDER directory, run this command:

    prove -l lib t

### Test CIDER server

CIDER also includes a single-user development server that runs the full application under a single listener on localhost port 3000, in the typical manner of Catalyst-based applications. From the CIDER directory, run it like so:

    perl script/cider_server.pl
    
The script will fail with various (hopefully) informative error messages until you have CIDER's database and configuration file set up appropriately. When it runs successfully, you should be able to see your local copy of CIDER working by visiting http://localhost:3000 in your favorite web browser.

## Configuration

First, within the CIDER directory, copy the file cider-dist.conf to cider.conf. Then, edit it to taste. 

If you don't want to use LDAP as your CIDER installation's authentication method, then you'll need to wade into [the various Catalyst authentication plugins](https://metacpan.org/search?q=catalyst%20plugin%20authentication) and their various installation requirements and configuration directives.

## Database setup

After creating a new MySQL database for CIDER's benefit, populate it with tables using the file CIDER/cider.sql. A command something like this should do the trick:

    mysql -u cideruser -p secretpassword ciderdb < CIDER/cider.sql

## Deployment

CIDER is built on [the Catalyst web application framework](http://catalystframework.org), and as such may be deployed like any other Catalyst app. See [the deployment chapter of the Catalyst manual](https://metacpan.org/pod/distribution/Catalyst-Manual/lib/Catalyst/Manual/Deployment.pod).

Tufts DCA prefers to deploy it using [Starman](https://metacpan.org/pod/distribution/Starman/script/starman), via the `ciderctl` program which you can find within this repository (CIDER/bin/ciderctl).

## Support

To report bugs or make feature requests, please visit [the Issues page on CIDER's GitHub website](https://github.com/TuftsUniversity/cider/issues).

## Authors and maintainers

The core codebase was developed by [Appleseed Software Consulting](http://appleseed-sc.com), who continues to maintain it. The lead developer and maintainer is Jason McIntosh (jmac@jmac.org). Doug Orleans (dougorleans@gmail.com) made significant early contributions as well.

# License

Copyright 2012-2015 Tufts University
    
CIDER is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
    
CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.
    
You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.
