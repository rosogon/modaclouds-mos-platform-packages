

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class RunService {
	
	public static void main (String[] arguments) throws Throwable {
		
		Logger logger = LoggerFactory.getLogger (RunService.class);
		
		logger.info ("starting example service...");
		
		String listenIp = System.getenv ("MODACLOUDS_SERVICE_X_ENDPOINT_IP");
		String listenPort = System.getenv ("MODACLOUDS_SERVICE_X_ENDPOINT_PORT");
		
		String service_Y_Ip = System.getenv ("MODACLOUDS_SERVICE_Y_ENDPOINT_IP");
		String service_Y_Port = System.getenv ("MODACLOUDS_SERVICE_Y_ENDPOINT_PORT");
		
		logger.info ("listening on IP `{}`, port `{}`...", listenIp, listenPort);
		logger.info ("connecting to service Y on IP `{}`, port `{}`...", service_Y_Ip, service_Y_Port);
		
		logger.info ("executing...");
		
		Thread.sleep (3600 * 1000);
	}
}
