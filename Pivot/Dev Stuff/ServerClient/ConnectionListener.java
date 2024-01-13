import java.io.IOException;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.net.DatagramPacket;

public class ConnectionListener extends Thread
{
  private int ticks_per_second;
  private DatagramSocket datagramSocket;
  public ConnectionSocket clientSocket;

  public ConnectionListener(int port) throws SocketException
  {
    this.datagramSocket = new DatagramSocket(port);
    // Get the ticks per second from config.ini
    ticks_per_second = Integer.parseInt(Config.GetConfig("ticks_per_second"));
  }

  @Override
  public void run()
  {
    byte[] receiveData = new byte[65535]; // Adjust this buffer size as needed.

    while (!datagramSocket.isClosed())
    {
      DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);

      try
      {
        datagramSocket.receive(receivePacket);
        String receivedMessage = new String(receivePacket.getData(), 0, receivePacket.getLength());
        // Process the received message if needed.

        // Set the clientSocket to the sender's address and port
        clientSocket = new ConnectionSocket(datagramSocket);
        clientSocket.socket.connect(receivePacket.getSocketAddress());

        System.out.println("Client connected!");
      }
      catch (IOException e)
      {
        e.printStackTrace();
        System.out.println("Something went wrong with connecting!");
        clientSocket = null;
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
