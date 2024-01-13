import java.io.*;
import java.util.ArrayList;

public class ServerThread extends Thread
{
  public ConnectionServer connectionServer;
  private int ticks_per_second;
  private String lastmessage;

  public ServerThread(ConnectionServer connectionServer)
  {
    this.connectionServer = connectionServer;
    // Get the ticks per second from config.ini
    this.ticks_per_second = Integer.parseInt(Config.GetConfig("ticks_per_second"));
    lastmessage = "Fuck you!";
  }

  @Override
  public void run()
  {
    while (connectionServer.clientSockets.size() > 0)
    {
      System.out.println(connectionServer.serverName + " - Connected clients: " + connectionServer.clientSockets.size());
      // Amount of players who still have stocks
      int pivotingPlayers = connectionServer.clientSockets.size();

      // Receive all clients
      for (int i = 0; i < connectionServer.clientSockets.size(); i++)
      {
        ConnectionSocket clientSocket = connectionServer.clientSockets.get(i);
        try
        {
          lastmessage = ((String) clientSocket.Receive());
          if (connectionServer.players.size() < i + 1)
          {
            PivotPlayer player = new PivotPlayer(lastmessage);
            if (i == 0)
            {
              connectionServer.timer = player.settingTime;
              connectionServer.stocks = player.settingStocks;
            }
            player.stocks = connectionServer.stocks;
            connectionServer.players.add(player);
          }
          else
          {
            PivotPlayer player = connectionServer.players.get(i);
            player.UpdatePlayer(lastmessage);
          }
          //clientSocket.Send("You are now connected!");
        }
        catch (IOException e)
        {
          System.out.println("Client disconnected!");
          connectionServer.clientSockets.remove(i);
        }
      }

      String[] messages = new String[connectionServer.players.size()];

      // Do some pivoting
      for (int i = 0; i < connectionServer.players.size(); i++)
      {
        PivotPlayer player = connectionServer.players.get(i);
        for (int j = 0; j < connectionServer.players.size(); j++)
        {
          if (j == i)
          {
            continue;
          }
          PivotPlayer opponent = connectionServer.players.get(j);
          if (opponent.attacks == null)
          {
            opponent.attacks = new ArrayList<PivotAttack>();
          }
          for (int k = 0; k < opponent.attacks.size(); k++)
          {
            PivotAttack attack = opponent.attacks.get(k);
            if (player.IsColliding(attack))
            {
              messages[i] += "\"damage_taken_" + opponent.id + "\": "+ attack.power +",";
              messages[j] += "\"damage_dealt_" + player.id + "\": "+ attack.power +",";
              player.health -= attack.power;
              player.isInvulnerable = true;
              if (player.health <= 0)
              {
                messages[i] += "\"dead\": true,";
                messages[j] += "\"killed\": " + player.id + ",";
                player.health = 0;
                player.stocks -= 1;
                player.isDead = true;
              }
            }
          }

          if (player.stocks <= 0)
          {
            pivotingPlayers -= 1;
            player.stocks = 0;
          }
        }
      }

      connectionServer.timer -= 1.0 / ticks_per_second;
      for (int i = 0; i < connectionServer.players.size(); i++)
      {
        messages[i] += "\"timer\": " + connectionServer.timer + ",";
      }

      if (connectionServer.timer <= 0 || connectionServer.players.size() <= 1 || pivotingPlayers <= 1)
      {
        // Match has ended
        
        // Get the player with the most stocks and health
        PivotPlayer winner = null;
        for (int i = 0; i < connectionServer.players.size(); i++)
        {
          PivotPlayer player = connectionServer.players.get(i);
          if (winner == null)
          {
            winner = player;
          }
          else
          {
            if (player.stocks > winner.stocks)
            {
              winner = player;
            }
            else if (player.stocks == winner.stocks)
            {
              if (player.health > winner.health)
              {
                winner = player;
              }
            }
          }
        }
        
        // Send the winner message
        for (int i = 0; i < connectionServer.players.size(); i++)
        {
          PivotPlayer player = connectionServer.players.get(i);
          if (player == winner)
          {
            messages[i] += "\"winner\": true,";
          }
          else
          {
            messages[i] += "\"winner\": false,";
          }
          messages[i] += "\"game_over\": true,";
        }
      }

      // Make final message
      String finalMessage = "";
      for (int i = 0; i < connectionServer.players.size(); i++)
      {
        PivotPlayer player = connectionServer.players.get(i);
        finalMessage += "{" + player.Stringify() + messages[i] + "}";
      }

      // Send message to all clients
      for (int i = 0; i < connectionServer.clientSockets.size(); i++)
      {
        ConnectionSocket clientSocket = connectionServer.clientSockets.get(i);
        try
        {
          clientSocket.Send(finalMessage);
        }
        catch (IOException e)
        {
          System.out.println("Client disconnected!");
          connectionServer.clientSockets.remove(i);
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
  }
}