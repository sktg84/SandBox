<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="java.security.Permission" %>
<%@ page import="java.util.*" %>

<%!
class StopExitSecurityManager extends SecurityManager {
	private SecurityManager _prevMgr = System.getSecurityManager();

	public void checkPermission(Permission perm) {
	}

	public void checkExit(int status) {
		super.checkExit(status);
		System.out.println("Called SYSTEM.EXIT!!");
		; // This throws an exception if an exit is called.
		try {
			throw new Exception();
		} catch (Exception ex) {
			StringWriter sw = new StringWriter();
			ex.printStackTrace(new PrintWriter(sw));
			String exceptionAsString = sw.toString();
			System.out.println(exceptionAsString);
			this.dumpLogs(exceptionAsString);
			try {
				sw.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		throw new ExitTrappedException(); 
	}
	private  void dumpLogs(String str) {
		try (PrintWriter out = new PrintWriter(new BufferedWriter(
				new FileWriter("sysExit.log",
						true)))) {
			out.println("INFO:"+new Date()+":"+str);
		} catch (IOException eq) {
			eq.printStackTrace();
			
		}
	}
	public SecurityManager getPreviousMgr() {
		return _prevMgr;
	}
}

class ExitTrappedException extends SecurityException {
}

class CodeControl {
	public CodeControl() {
		super();
	}

	public void disableSystemExit() {
		SecurityManager securityManager = new StopExitSecurityManager();
		System.setSecurityManager(securityManager);
	}

	public void enableSystemExit() {
		SecurityManager mgr = System.getSecurityManager();
		if ((mgr != null) && (mgr instanceof StopExitSecurityManager)) {
			StopExitSecurityManager smgr = (StopExitSecurityManager) mgr;
			System.setSecurityManager(smgr.getPreviousMgr());
		} else
			System.setSecurityManager(null);
	}
}


%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=MacRoman">
        <title>SYSTEM EXIT BLOCK JSP Page</title>
    </head>
    <body>
        <h1>System.exit() blocker...</h1>
        <%new CodeControl().disableSystemExit();%>
    </body>
</html>
