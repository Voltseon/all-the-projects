import java.io.File;
import java.io.FileNotFoundException;
import java.util.Dictionary;
import java.util.Hashtable;
import java.util.Scanner;

public class Config
{
  public static Dictionary<String, String> config;

  static
  {
    config = new Hashtable<>();
    try
    {
      File myObj = new File("config.ini");
      Scanner myReader = new Scanner(myObj);
      while (myReader.hasNextLine())
      {
        String data = myReader.nextLine();
        String[] splitData = data.split(": ");
        config.put(splitData[0], splitData[1]);
      }
      myReader.close();
    }
    catch (FileNotFoundException e)
    {
      System.out.println("Config file was not found.");
    }
    
  }

  public static String GetConfig(String string)
  {
    return config.get(string);
  }
  
}
