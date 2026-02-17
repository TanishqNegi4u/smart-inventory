package utils;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class AppStartup implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println(">>> AppStartup: Application starting...");
        DatabaseInitializer.initialize();
        System.out.println(">>> AppStartup: Ready!");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println(">>> AppStartup: Application stopping.");
    }
}
