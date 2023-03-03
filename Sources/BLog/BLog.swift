
public struct BLog {
    public static var enable = false
    public static var showTread = false
    public static var showInConsole = true
    
    public static var daysLogToFile = 5
    public static var writeLogToFile = false {
        didSet {
            if enable { clearLogFiles() }
        }
    }
    
    public static var demitter = "- - - - - - - - - - - - - - - - - - - - -"
    
    public struct Network { }
}
