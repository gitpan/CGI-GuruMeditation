##
##  CGI::GuruMeditation -- Guru Meditation for CGIs
##  Copyright (c) 2004-2005 Ralf S. Engelschall <rse@engelschall.com>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
##  General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
##  USA, or contact Ralf S. Engelschall <rse@engelschall.com>.
##
##  GuruMeditation.pm: Module Implementation
##

package CGI::GuruMeditation;

require 5.006;
use strict;
use IO::File;

our $VERSION = 0.05;
my $name;

sub import {
    my ($self, $name) = @_;

    #   optionally remember program name
    $CGI::GuruMeditation::name = $name;

    #   setup termination handler
    $SIG{__DIE__} = sub {
        my ($msg) = @_;

        #   make sure we are not called multiple times
        $SIG{__DIE__} = 'IGNORE';

        #   determine optional hint message
        my $hint = '';
        if ($msg =~ m|line\s+(\d+)|) {
            my $line = $1;
            my $io = new IO::File "<$0";
            my @code = $io->getlines();
            $io->close();
            my $i = -1;
            $hint = join("", map { s/^/sprintf("%d: ", $line+$i++)/se; $_; } @code[$line-2..$line]);
        }

        #   determine title
        my $title = (  defined($CGI::GuruMeditation::name)
                     ? $CGI::GuruMeditation::name . ": "
                     : "") . "GURU MEDITATION";

        #   properly escape characters for HTML inclusion
        sub escape_html {
            my ($txt) = @_;
            $txt =~ s/&/&amp;/sg;
            $txt =~ s/</&lt;/sg;
            $txt =~ s/>/&gt;/sg;
            $txt =~ s/^\s+//s;
            $txt =~ s/\s+$//s;
            $txt =~ s/\r//sg;
            $txt =~ s/\n\n+/\n/sg;
            $txt =~ s/([^\n])$/$1\n/s;
            return $txt;
        }
        $title = &escape_html($title);
        $hint  = &escape_html($hint);
        $msg   = &escape_html($msg);
        $msg   =~ s/(\n.)/<br>$1/sg;

        #   generate HTTP response header
        my $O = "Content-Type: text/html; charset=ISO-8859-1\n\n";

        #   generate HTML page header
        $O .=
            "<html>\n" .
            "  <head>\n" .
            "    <style type=\"text/css\">\n" .
            "      HTML {\n" .
            "          width:  100%;\n" .
            "          height: auto;\n" .
            "      }\n" .
            "      BODY {\n" .
            "          background: #cccccc;\n" .
            "          margin:     0 0 0 0;\n" .
            "          padding:    0 0 0 0;\n" .
            "      }\n" .
            "      DIV.canvas {\n" .
            "          background: #000000;\n" .
            "          border: 20px solid #000000;\n" .
            "      }\n" .
            "      DIV.error1 {\n" .
            "          border-top:          4px solid #cc3333;\n" .
            "          border-left:         4px solid #cc3333;\n" .
            "          border-right:        4px solid #cc3333;\n" .
            "          border-bottom:       4px solid #cc3333;\n" .
            "          padding:             10px 10px 10px 10px;\n" .
            "          font-family:         sans-serif, helvetica, arial;\n" .
            "          background:          #000000;\n" .
            "          color:               #cc3333;\n" .
            "      }\n" .
            "      DIV.error2 {\n" .
            "          border-top:          4px solid #000000;\n" .
            "          border-left:         4px solid #000000;\n" .
            "          border-right:        4px solid #000000;\n" .
            "          border-bottom:       4px solid #000000;\n" .
            "          padding:             10px 10px 10px 10px;\n" .
            "          font-family:         sans-serif, helvetica, arial;\n" .
            "          background:          #000000;\n" .
            "          color:               #cc3333;\n" .
            "      }\n" .
            "      SPAN.title {\n" .
            "          font-size:           200%;\n" .
            "          font-weight:         bold;\n" .
            "      }\n" .
            "      TT.text {\n" .
            "          font-weight:         bold;\n" .
            "      }\n" .
            "    </style>\n" .
            "    <script language=\"JavaScript\">\n" .
            "    var count = 0;\n" .
            "    function blinker() {\n" .
            "        var obj = document.getElementById('error');\n" .
            "        if (count++ % 2 == 0) {\n" .
            "            obj.className = 'error1';\n" .
            "        }\n" .
            "        else {\n" .
            "            obj.className = 'error2';\n" .
            "        }\n" .
            "        setTimeout('blinker()', 1000);\n" .
            "    }\n" .
            "    </script>\n" .
            "    <title>$title</title>\n" .
            "  </head>\n";

        #   generate HTML page body
        $O .=
            "  <body onLoad=\"setTimeout('blinker()', 1);\">\n" .
            "    <div class=\"canvas\">\n" .
            "      <div id=\"error\" class=\"error1\">\n" .
            "        <span class=\"title\">$title</span>\n" .
            "        <p>\n" .
            "        <tt class=\"text\">\n" .
            "          $msg" .
            "        </tt><br>\n" .
            "        <pre>\n$hint</pre>\n" .
            "      </div>\n" .
            "    </div>\n" .
            "  </body>\n" .
            "</html>\n";

        #   send response and die gracefully
        $|++;
        print STDOUT $O;
        exit(0);
    };
}

1;

__END__

=pod

=head1 NAME

B<CGI::GuruMeditation> -- Guru Meditation for CGIs

=head1 SYNOPSIS

 use CGI;
 use CGI::GuruMeditation:

=head1 DESCRIPTION

This is a small module accompanying the B<CGI> module, allowing
the display of an error screen (somewhat resembling the classical
red-on-black blinking "Guru Meditation" from the good old AmigaOS before
version 2.04) in case of abnormal termination of a CGI. The module
simply installs a C<$SIG{__DIE__}> handler which sends a HTTP response
to F<STDOUT> showing a HTML/CSS based screen with the Perl error message
and optionally an excerpt from CGI's source code where the error
occurred. This provides both optically more pleasant and functionally
more elaborate error messages for CGIs.

=head1 HISTORY

This small module actually was a quick hack and proof of concept during
the development of B<OSSP quos>. It was later found useful and reusable
enough for other CGIs.

=head1 AUTHOR

Ralf S. Engelschall E<lt>rse@engelschall.comE<gt>

=head1 SEE ALSO

B<CGI>, B<CGI::Carp>.

http://en.wikipedia.org/wiki/Guru_meditation

=cut

