#!/usr/local/bin/konoha

using konoha.io.*;

KONOHA2JS="/usr/local/bin/konoha2js";
TMP_SCRIPT="/var/tmp/tmp.k";
class CGI {
	String header = "Access-Control-Allow-Origin: http://konohascript.org\n"
	header += "Content-type: application/javascript\n\n";
	CGI() {
		String request_method = $env.REQUEST_METHOD;
		if (request_method != "POST") {
			ERR.println("unexpected request method: " + request_method);
			throw new Script!!("unexpected request method: " + request_method);		}
		//String input = "";
		String tmp;
		OutputStream ous= new OutputStream(TMP_SCRIPT);
		//while ((tmp = IN.readLine()) != null) {
		//	input += (tmp + "\n");
		//}
		String input = IN.read().decode().trim();
		OUT.println(header);
		ous.println(input);
		ous.close();
		String jsscript = exec(KONOHA2JS + " -j -r -i " + TMP_SCRIPT);
		OUT.println(jsscript);
	}
}
cgi = new CGI();
