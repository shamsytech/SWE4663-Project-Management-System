package main;
import java.io.FileInputStream;
import java.util.Properties;

public class DBUtil {
    public static Properties loadDBProperties() {
        Properties props = new Properties();
        try {
            FileInputStream fis = new FileInputStream("db.properties");
            props.load(fis);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return props;
    }
}
