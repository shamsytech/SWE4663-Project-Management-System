package main;
import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public class ProjectDatabase {
    private Connection conn;

    // Load database connection on object creation
    public ProjectDatabase() {
        try {
            Properties props = new Properties();
            InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties");

            if (input == null) {
                System.out.println("db.properties not found in classpath!");
                return;
            }

            props.load(input);

            String url = props.getProperty("db.url");
            String user = props.getProperty("db.user");
            String password = props.getProperty("db.password");

            //Explicitly load MySQL JDBC driver (fixes No Suitable Driver error)
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(url, user, password);
            System.out.println("Connected to database!");
        } catch (Exception e) {
            System.out.println("Exception during DB init:");
            e.printStackTrace();
        }
    }



    // Method: Add a new project
    public void addProject(String name, String owner) {
        String sql = "INSERT INTO projects (ProjectName, OwnerName) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, owner);
            stmt.executeUpdate();
            System.out.println("✅ Project added.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method: Add a requirement
    public void addRequirement(int projectId, String type, String description) {
        String sql = "INSERT INTO requirements (ProjectID, Type, Description) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            stmt.setString(2, type);
            stmt.setString(3, description);
            stmt.executeUpdate();
            System.out.println("✅ Requirement added.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method: Log effort
    public void logEffort(int requirementId, Date date, double analysis, double design, double code, double test, double mgmt) {
        String sql = "INSERT INTO effort_tracking (RequirementID, EntryDate, AnalysisHours, DesignHours, CodingHours, TestingHours, ManagementHours) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, requirementId);
            stmt.setDate(2, date);
            stmt.setDouble(3, analysis);
            stmt.setDouble(4, design);
            stmt.setDouble(5, code);
            stmt.setDouble(6, test);
            stmt.setDouble(7, mgmt);
            stmt.executeUpdate();
            System.out.println("✅ Effort logged.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method: Print all projects
    public void printAllProjects() {
        String sql = "SELECT * FROM projects";
        try (Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                System.out.println("Project: " + rs.getInt("ProjectID") + " - " + rs.getString("ProjectName") + " (Owner: " + rs.getString("OwnerName") + ")");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method: View effort by requirement
    public void getEffortByRequirement(int requirementId) {
        String sql = "SELECT EntryDate, AnalysisHours, DesignHours, CodingHours, TestingHours, ManagementHours " +
                "FROM effort_tracking WHERE RequirementID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, requirementId);
            ResultSet rs = stmt.executeQuery();

            double total = 0;
            System.out.println("Effort Log for Requirement ID: " + requirementId);
            System.out.println("Date\t\tAnalysis\tDesign\tCoding\tTesting\tManagement\tTotal");

            while (rs.next()) {
                double analysis = rs.getDouble("AnalysisHours");
                double design = rs.getDouble("DesignHours");
                double code = rs.getDouble("CodingHours");
                double test = rs.getDouble("TestingHours");
                double mgmt = rs.getDouble("ManagementHours");
                double subtotal = analysis + design + code + test + mgmt;
                total += subtotal;

                System.out.printf("%s\t%.2f\t\t%.2f\t%.2f\t%.2f\t%.2f\t\t%.2f\n",
                        rs.getDate("EntryDate"), analysis, design, code, test, mgmt, subtotal);
            }

            System.out.printf("📊 Total Hours Logged: %.2f\n", total);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void getEffortSummaryByProject(int projectId) {
        String sql = """
        SELECT r.RequirementID, r.Description,
               SUM(e.AnalysisHours) AS Analysis,
               SUM(e.DesignHours) AS Design,
               SUM(e.CodingHours) AS Coding,
               SUM(e.TestingHours) AS Testing,
               SUM(e.ManagementHours) AS Management
        FROM requirements r
        LEFT JOIN effort_tracking e ON r.RequirementID = e.RequirementID
        WHERE r.ProjectID = ?
        GROUP BY r.RequirementID, r.Description
    """;

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            ResultSet rs = stmt.executeQuery();

            System.out.println("📊 Effort Summary for Project ID: " + projectId);
            System.out.println("Requirement\tAnalysis\tDesign\tCoding\tTesting\tManagement\tTotal");

            while (rs.next()) {
                double analysis = rs.getDouble("Analysis");
                double design = rs.getDouble("Design");
                double code = rs.getDouble("Coding");
                double test = rs.getDouble("Testing");
                double mgmt = rs.getDouble("Management");
                double total = analysis + design + code + test + mgmt;

                System.out.printf("%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n",
                        rs.getString("Description"), analysis, design, code, test, mgmt, total);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void getAllRequirementsByProject(int projectId) {
        String sql = "SELECT RequirementID, Type, Description FROM requirements WHERE ProjectID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            ResultSet rs = stmt.executeQuery();

            System.out.println("📌 Requirements for Project ID: " + projectId);
            while (rs.next()) {
                System.out.printf("ID: %d | Type: %s | Description: %s\n",
                        rs.getInt("RequirementID"), rs.getString("Type"), rs.getString("Description"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void getTeamMembersByProject(int projectId) {
        String sql = "SELECT MemberID, MemberName, Role FROM team_members WHERE ProjectID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            ResultSet rs = stmt.executeQuery();

            System.out.println("👥 Team Members for Project ID: " + projectId);
            while (rs.next()) {
                System.out.printf("ID: %d | Name: %s | Role: %s\n",
                        rs.getInt("MemberID"), rs.getString("MemberName"), rs.getString("Role"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void searchProjects(String keyword) {
        String sql = "SELECT ProjectID, ProjectName, OwnerName FROM projects WHERE ProjectName LIKE ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + keyword + "%");
            ResultSet rs = stmt.executeQuery();

            System.out.println("Search Results for: " + keyword);
            while (rs.next()) {
                System.out.printf("ID: %d | Name: %s | Owner: %s\n",
                        rs.getInt("ProjectID"), rs.getString("ProjectName"), rs.getString("OwnerName"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method: Register a new user
    public boolean createUser(String firstName, String lastName, String email, String passwordHash) {
        String sql = "INSERT INTO users (FirstName, LastName, Email, PasswordHash) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, firstName);
            stmt.setString(2, lastName);
            stmt.setString(3, email);
            stmt.setString(4, passwordHash);
            stmt.executeUpdate();
            System.out.println("✅ User created: " + email);
            return true;
        } catch (SQLException e) {
            System.err.println("Failed to create user: " + email);
            e.printStackTrace();
            return false;
        }
    }
    
    //Close connection (can also use try-with-resources in a wrapper)
    public void close() {
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
