# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
#
# BrowserDetectPlugin is Copyright (C) 2018 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::BrowserDetectPlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use HTTP::BrowserDetect ();

use constant TRACE => 0; # toggle me

sub new {
  my $class = shift;

  my $this = bless({
    @_
  }, $class);

  return $this;
}

sub ua {
  my ($this, $initString) = @_;

  if ($this->{_ua} && (!$initString || $this->{_initString} eq $initString)) {
    return $this->{_ua};
  }
  
  unless ($initString) {
    my $request = Foswiki::Func::getRequestObject();
    $initString = $request->userAgent();
  }

  $this->{_initString} = $initString;

  writeDebug("$initString");

  $this->{_ua} = HTTP::BrowserDetect->new($initString);

  return $this->{_ua}
}


sub finish {
  my $this = shift;

  undef $this->{_ua};
}

sub BROWSERINFO {
  my ($this, $session, $params, $topic, $web) = @_;

  #writeDebug("called BROWSERINFO()");
  my $result = $params->{_DEFAULT} || $params->{format} || '$user_agent';

  my $initString = $params->{ua};
  my $ua = $this->ua($initString);

  # strings
  foreach my $prop (qw(
    browser browser_string browser_version browser_major browser_minor browser_beta

    os os_string os_version os_major os_minor os_beta

    device device_string

    robot_string robot_id robot_version robot_major robot_minor robot_beta

    user_agent country language

    engine engine_string engine_version engine_major engine_minor engine_beta

  )) {
    $result =~ s/\$$prop\b/$ua->$prop()||''/ge;
  }

  # lists
  $result =~ s/\$all_robot_ids\b/join(", ", sort $ua->all_robot_ids())||''/ge;
  $result =~ s/\$browser_properties\b/join(", ", $ua->browser_properties())||''/ge;

  # booleans
  foreach my $prop (qw(
    gecko webkit trident presto khtml

    windows win16 win3x win31 win32 winme win95 win98 winnt win2k winxp win2k3
    winvista win7 win8 win8_0 win8_1 win10 win10_0 wince winphone winphone7
    winphone7_5 winphone8 winphone10
    adm android aol aol3 aol4 aol5 aol6 applecoremedia audrey avantgo avantgo
    blackberry browsex chrome dalvik dsi elinks emacs epiphany firefox galeon icab

    ie ie10 ie11 ie3 ie4 ie4up ie5 ie55 ie55up ie5up ie6 ie7 ie8 ie9 ie_compat_mode

    iopener ipad iphone ipod kindle kindlefire konqueror links lotusnotes lynx
    mobile_safari mosaic mozilla n3ds nav2 nav3 nav4 nav45 nav45up nav4up nav6
    nav6up navgold neoplanet neoplanet2 netfront netscape obigo

    opera opera3 opera4 opera5 opera6 opera7

    palm polaris ps3 psp pubsub realplayer realplayer_browser safari seamonkey silk
    staroffice ucbrowser wap webos webtv

    mac mac68k macppc macosx ios

    unix sun sun4 sun5 suni86 irix irix5 irix6 hpux hpux9 hpux10 aix aix1 aix2 aix3
    aix4 linux sco unixware mpras reliant dec sinix freebsd bsd

    chromeos dotnet firefoxos lib mobile robot tablet webview x11

    vms amiga ps3gameos pspgameos
  )) {
    $result =~ s/\$$prop\b/$ua->$prop?'1':'0'/ge;
  }


  return $result;
}

sub writeDebug {
  return unless TRACE;
  Foswiki::Func::writeDebug("BrowserDetectPlugin::Core - $_[0]");
  #print STDERR "BrowserDetectPlugin::Core - $_[0]\n";
}

1;
