#!/usr/local/bin/konoha
class CGI {
	String header = "Content-type: text/html\n\n";
	CGI() {
		OUT.print(header);
		print "Hello world";
	}
}
cgi = new CGI();
