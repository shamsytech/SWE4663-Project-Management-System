import java.sql.*;
import java.util.Properties;

public class Main {
    public static void main(String[] args) throws SQLException {
        Properties props = DBUtil.loadDBProperties();
        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String password = props.getProperty("db.password");

        Connection conn = DriverManager.getConnection(url, user, password);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("Connected successfully!");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
