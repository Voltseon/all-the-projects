import java.io.*;
import java.util.ArrayList;

public class Session extends Thread
{
  private ArrayList<PivotPlayer> players;
  private int ticks_per_second;
  private String serverName;
  private String lastMessage;
  private int timer;
  private int stocks;

  public Session(String serverName)
  {
    super();
    this.ticks_per_second = Integer.parseInt(Config.GetConfig("ticks_per_second"));
    this.serverName = serverName;
    this.lastMessage = "";
  }

  public void addPlayer(PivotPlayer player)
  {
    players.add(player);
  }

  @Override
  public void run()
  {
    while (players.size() > 0)
    {
      System.out.println(serverName + " - Connected clients: " + players.size());
      // Amount of players who still have stocks
      int pivotingPlayers = players.size();

      // Receive all clients
      for (int i = 0; i < players.size(); i++)
      {
        PivotPlayer player = players.get(i);
        try
        {
          lastMessage = ((String) player.Receive());
          if (players.size() < i + 1)
          {
            PivotPlayer newPlayer = new PivotPlayer(lastMessage);
            if (i == 0)
            {
              timer = player.settingTime;
              stocks = player.settingStocks;
            }
            player.stocks = stocks;
            players.add(player);
          }
          else
          {
            PivotPlayer newPlayer = players.get(i);
            player.UpdatePlayer(lastMessage);
          }
          //clientSocket.Send("You are now connected!");
        }
        catch (IOException e)
        {
          System.out.println("Client disconnected!");
          players.remove(i);
        }
      }

      String[] messages = new String[players.size()];

      // Do some pivoting
      for (int i = 0; i < players.size(); i++)
      {
        PivotPlayer player = players.get(i);
        for (int j = 0; j < players.size(); j++)
        {
          if (j == i)
          {
            continue;
          }
          PivotPlayer opponent = players.get(j);
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

      timer -= 1.0 / ticks_per_second;
      for (int i = 0; i < players.size(); i++)
      {
        messages[i] += "\"timer\": " + timer + ",";
      }

      if (timer <= 0 || players.size() <= 1 || pivotingPlayers <= 1)
      {
        // Match has ended
        
        // Get the player with the most stocks and health
        PivotPlayer winner = null;
        for (int i = 0; i < players.size(); i++)
        {
          PivotPlayer player = players.get(i);
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
        for (int i = 0; i < players.size(); i++)
        {
          PivotPlayer player = players.get(i);
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
      for (int i = 0; i < players.size(); i++)
      {
        PivotPlayer player = players.get(i);
        finalMessage += "{" + player.Stringify() + messages[i] + "}";
      }

      // Send message to all clients
      for (int i = 0; i < players.size(); i++)
      {
        ConnectionSocket clientSocket = players.get(i);
        try
        {
          clientSocket.Send(finalMessage);
        }
        catch (IOException e)
        {
          System.out.println("Client disconnected!");
          players.remove(i);
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
