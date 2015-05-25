

public class RunService {
	
	public static void main (String[] arguments) throws Throwable {
		
		System.err.printf ("[ii] starting example service...\n");
		
		String listenIp = System.getenv ("MODACLOUDS_SERVICE_X_ENDPOINT_IP");
		String listenPort = System.getenv ("MODACLOUDS_SERVICE_X_ENDPOINT_PORT");
		
		String service_Y_Ip = System.getenv ("MODACLOUDS_SERVICE_Y_ENDPOINT_IP");
		String service_Y_Port = System.getenv ("MODACLOUDS_SERVICE_Y_ENDPOINT_PORT");
		
		System.err.printf ("[ii] listening on IP `%s`, port `%s`...\n", listenIp, listenPort);
		System.err.printf ("[ii] connecting to service Y on IP `%s`, port `%s`...\n", service_Y_Ip, service_Y_Port);
		
		System.err.printf ("[ii] executing...\n");
		
		Thread.sleep (3600 * 1000);
	}
}
