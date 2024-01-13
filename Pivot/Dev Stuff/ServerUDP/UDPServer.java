import java.net.DatagramSocket;
import java.net.DatagramPacket;
import java.io.IOException;

public class UDPServer
{
  public static void main(String[] args)
  {
    DatagramSocket socket = null;
    try
    {
      socket = new DatagramSocket(Integer.parseInt(Config.GetConfig("port")));
      byte[] receiveData = new byte[1024];
      while (true)
      {
        DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
        socket.receive(receivePacket);

        String message = new String(receivePacket.getData(), 0, receivePacket.getLength());
        System.out.println("Received: " + message);
        
        String response = "Response from UDP server";
        byte[] responseData = response.getBytes();
        DatagramPacket responsePacket = new DatagramPacket(responseData, responseData.length, receivePacket.getAddress(), receivePacket.getPort());
        socket.send(responsePacket);
      }
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }
    finally
    {
      if (socket != null)
      {
        socket.close();
      }
    }
  }
}
