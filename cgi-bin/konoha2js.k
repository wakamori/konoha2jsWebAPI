#!/usr/local/bin/konoha

using konoha.io.*;
using konoha.conv.*;

/* please change it to your own setting!! */
KONOHA2JS="/usr/local/bin/konoha2js";
TMP_SCRIPT="/var/tmp/tmp.k";
SCRIPT_DIR="/Users/tsunade/Development/konoha_hp/tmp/";
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
		OutputStream ous= new OutputStream(TMP_SCRIPT);
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
			String jsscript = exec(KONOHA2JS + " -j -r -i " + TMP_SCRIPT);
			OUT.println(header);
			OUT.println(jsscript);
		} else if (m["requestedType"] == "html") {
			header = "Access-Control-Allow-Origin: http://konohascript.org\n";
			header += "Content-type: application/json\n\n";
			int currentTime = System.getTime();
			String htmladdr = "/tmp/src" + currentTime + ".html";
			if (m["htmlDocument"] == null || m["htmlDocument"] == "") {
				String jsscript = exec(KONOHA2JS + " -r -i " + TMP_SCRIPT);
				OutputStream ous_html = new OutputStream(SCRIPT_DIR + "src" + currentTime + ".html");
				ous_html.println(jsscript);
				ous_html.close();
				OUT.println(header);
				OUT.println("{\"src\": \"" + htmladdr + "\"}");
			} else {
				String jsscript = exec(KONOHA2JS + " -j -r -i " + TMP_SCRIPT);
				OutputStream ous_html = new OutputStream(SCRIPT_DIR + "src" + currentTime + ".html");
				ous_html.println(m["htmlDocument"].replace(HTML_REPLACE_TARGET, jsscript));
				ous_html.close();
				OUT.println(header);
				OUT.println("{\"src\": \"" + htmladdr + "\"}");
			}
		} else {
			ERR.println("unexpected requestedType option!!");
			OUT.println(header);
			OUT.println("ERROR!!: unexpected requestedType option!!");
		}
	}
}
cgi = new CGI();
