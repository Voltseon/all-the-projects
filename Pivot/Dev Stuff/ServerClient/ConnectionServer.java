import java.net.ServerSocket;
import java.time.LocalDate;
import java.util.ArrayList;

public class ConnectionServer
{
  public String serverName;
  public ArrayList<ConnectionSocket> clientSockets;
  public ServerSocket serverSocket;
  public LocalDate startDate;
  public Thread serverThread;
  public ArrayList<PivotPlayer> players;
  public float timer;
  public int stocks;

  public ConnectionServer(String serverName, ServerSocket serverSocket)
  {
    this.serverName = serverName;
    this.serverSocket = serverSocket;
    clientSockets = new ArrayList<ConnectionSocket>();
    startDate = LocalDate.now();
    players = new ArrayList<PivotPlayer>();
  }

  public void Start()
  {
    serverThread = new Thread(new ServerThread(this));
    serverThread.start();
  }
}
