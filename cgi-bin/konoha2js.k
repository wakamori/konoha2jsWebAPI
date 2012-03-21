#!/usr/local/bin/konoha

using konoha.io.*;
using konoha.conv.*;

/* please change it to your own setting!! */
KONOHA2JS="/usr/local/bin/konoha2js";
TMP_KONOHA_DIR="/tmp/";
HTML_REPLACE_TARGET="<-- KONOHA_JS_CODE -->";

class CGI {
	String header = "";
	CGI() {
		String request_method = $env.REQUEST_METHOD;
		if (request_method != "POST") {
			ERR.println("unexpected request method: " + request_method);
			throw new Script!!("unexpected request method: " + request_method);		
		}
		//String input = "";
		String tmp;
		int currentTime = System.getTime();
		String kscriptaddr = TMP_KONOHA_DIR + "tmp" + currentTime + ".k";
		OutputStream ous= new OutputStream(kscriptaddr);
		//while ((tmp = IN.readLine()) != null) {
		//	input += (tmp + "\n");
		//}
		String input = IN.read().decode().trim();
		Map<String> m = {};
		foreach (String param in input.split("&")) {
			String[] k_v = param.split("=");
			m[k_v[0]] = k_v[1].convert(to:durl);
			ERR.println(k_v[1]);
		}
		ous.println(m["source"]);
		ous.close();
		if (m["requestedType"] == null || m["requestedType"] == "js") {
			header = "Access-Control-Allow-Origin: http://konohascript.org\n";
			header += "Content-type: application/javascript\n\n";
			String jsscript = exec(KONOHA2JS + " -j -r -i " + kscriptaddr);
			OUT.println(header);
			OUT.println(jsscript);
		} else if (m["requestedType"] == "html") {
			header = "Access-Control-Allow-Origin: http://konohascript.org\n";
			header += "Content-type: text/html; charset=UTF-8\n\n";
			if (m["htmlDocument"] == null || m["htmlDocument"] == "") {
				String jsscript = exec(KONOHA2JS + " -r -i " + kscriptaddr);
				OUT.println(header);
				OUT.println(jsscript);
			} else {
				String jsscript = exec(KONOHA2JS + " -j -r -i " + kscriptaddr);
				OUT.println(header);
				OUT.println(m["htmlDocument"].replace(HTML_REPLACE_TARGET, jsscript));
			}
		} else {
			ERR.println("unexpected requestedType option!!");
			OUT.println(header);
			OUT.println("ERROR!!: unexpected requestedType option!!");
		}
	}
}
cgi = new CGI();
