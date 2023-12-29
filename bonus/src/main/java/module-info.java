module com.example.bonus {
    requires javafx.controls;
    requires javafx.fxml;


    opens com.example.bonus to javafx.fxml;
    exports com.example.bonus;
}