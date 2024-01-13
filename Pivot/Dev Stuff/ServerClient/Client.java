import java.io.*;
import java.net.*;

public class Client
{
  public static void main(String[] args) throws IOException, ClassNotFoundException
  {
    // Ask user to input server name to connect to
    BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
    String serverName = in.readLine();

    // Get the ticks per second from config.ini
    int ticks_per_second = Integer.parseInt(Config.GetConfig("ticks_per_second"));

    // Connect to the server
    ConnectionSocket clientSocket = new ConnectionSocket(new DatagramSocket(Integer.parseInt(Config.GetConfig("port")), InetAddress.getByName(Config.GetConfig("host"))));
    // Tell the server what server we want to connect to
    clientSocket.Send(serverName);

    // Connection loop
    while (clientSocket.isConnected())
    {
      // Send a message to the server (this is just an example)
      clientSocket.Send("Hello!");

      // Receive a message from the server (this is just an example)
      String message = (String)clientSocket.Receive();
      if (message != null)
      {
        // Print the message
        System.out.println(message);
      }

      // Wait for a bit
      try
      {
        Thread.sleep(1000 / ticks_per_second);
      }
      catch (InterruptedException e)
      {
        System.out.println("Server thread interrupted!");
      }
    }

    // Close the socket
    clientSocket.Close();
  }
}
