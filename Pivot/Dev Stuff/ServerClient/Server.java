import java.net.*;
import java.util.*;
import java.io.*;

public class Server
{
  public static void main(String[] args) throws IOException, ClassNotFoundException
  {
    // Reference to own socket
    ServerSocket serverSocket = null;
    // Whether the server is ready for connections
    boolean listening = true;
    // A list containing all inactive clients
    ArrayList<ConnectionSocket> clientSockets = new ArrayList<>();
    // A list of all connection servers
    ArrayList<ConnectionServer> connectionServers = new ArrayList<>();
    // A seperate thread for listening to new connections
    ConnectionListener connectionListener = null;
    // Get the ticks per second from config.ini
    int ticks_per_second = Integer.parseInt(Config.GetConfig("ticks_per_second"));
    // Port
    int port = Integer.parseInt(Config.GetConfig("port"));
    // Max servers
    int max_servers = Integer.parseInt(Config.GetConfig("max_servers"));
    // Max players
    int max_players = Integer.parseInt(Config.GetConfig("max_players"));

    // Try to get the server up
    try
    {
      serverSocket = new ServerSocket(port); // All the other servers are on 9997
      connectionListener = new ConnectionListener(port);
      connectionListener.start();
      System.out.println("Server is up and running on port: " + port + "!");
    }
    catch (IOException e)
    {
      System.err.println("Could not listen on port: " + port + ".");
      System.exit(-1);
    }

    // Listen loop
    while (listening)
    {
      if (connectionListener.clientSocket != null)
      {
        if (clientSockets.contains(connectionListener.clientSocket))
        {
          connectionListener.clientSocket.Send("You are already connected!");
        }
        else
        {
          clientSockets.add(connectionListener.clientSocket);
          connectionListener.clientSocket.Send("You are now connected!");
        }
        connectionListener.clientSocket = null;
      }

      // Go through all the clients
      for (int i = 0; i < clientSockets.size(); i++)
      {
        ConnectionSocket clientSocket = clientSockets.get(i);
        if (clientSocket.hooked)
        {
          clientSockets.remove(i);
          continue;
        }
        try
        {
          String serverToConnect = (String)clientSocket.Receive();

          if (serverToConnect != null && !serverToConnect.equals(""))
          {
            System.out.println("Server to connect: " + serverToConnect);
            clientSocket.Send("Connected you to: " + serverToConnect);
            if (!ServerExists(connectionServers, serverToConnect))
            {
              if (connectionServers.size() >= max_servers)
              {
                clientSocket.Send("Servers are at a capacity!");
                clientSockets.remove(i);
                clientSocket.Close();
                continue;
              }
              ConnectionServer connectionServer = new ConnectionServer(serverToConnect, serverSocket);
              connectionServer.clientSockets.add(clientSocket);
              connectionServer.Start();
              connectionServers.add(connectionServer);
              clientSocket.hooked = true;
            }
            else
            {
              int serverIndex = FindServer(connectionServers, serverToConnect);
              if (serverIndex != -1)
              {
                if (connectionServers.get(serverIndex).clientSockets.size() >= max_players)
                {
                  clientSocket.Send("Server is full!");
                  clientSockets.remove(i);
                  clientSocket.Close();
                  continue;
                }
                connectionServers.get(serverIndex).clientSockets.add(clientSocket);
                clientSocket.hooked = true;
              }
            }
            if (clientSocket.hooked)
            {
              clientSockets.remove(i);
            }
            else
            {
              clientSocket.Send("Something went wrong!");
              clientSockets.remove(i);
              clientSocket.Close();
            }
          }
        }
        catch (Exception e)
        {
          System.out.println("Client disconnected!");
          clientSockets.remove(i);
        }
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

    // Close the server
    serverSocket.close();
  }

  private static boolean ServerExists(ArrayList<ConnectionServer> connectionServers, String serverName)
  {
    for (int i = 0; i < connectionServers.size(); i++)
    {
      if (connectionServers.get(i).serverName.equals(serverName))
      {
        if (connectionServers.get(i).clientSockets.size() == 0)
        {
          connectionServers.remove(i);
          return false;
        }
        return true;
      }
    }

    return false;
  }

  private static int FindServer(ArrayList<ConnectionServer> connectionServers, String serverName)
  {
    for (int i = 0; i < connectionServers.size(); i++)
    {
      if (connectionServers.get(i).serverName.equals(serverName))
      {
        return i;
      }
    }

    return -1;
  }
}