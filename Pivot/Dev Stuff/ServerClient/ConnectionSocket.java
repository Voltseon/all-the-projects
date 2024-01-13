import java.net.*;
import java.io.*;
import java.nio.*;
import java.util.Arrays;

public class ConnectionSocket
{
  public DatagramSocket socket;
  public boolean hooked;

  public ConnectionSocket(DatagramSocket socket) throws IOException
  {
    this.socket = socket;
    hooked = false;
    Start();
  }

  public void Send(String message) throws IOException
  {
    if (message == null)
    {
      return;
    }
    byte[] msgBytes = message.getBytes();
    byte[] lengthBytes = ByteBuffer.allocate(4).putInt(msgBytes.length).array();
    byte[] messageWithLength = new byte[4 + msgBytes.length];
    System.arraycopy(lengthBytes, 0, messageWithLength, 0, 4);
    System.arraycopy(msgBytes, 0, messageWithLength, 4, msgBytes.length);
    DatagramPacket packet = new DatagramPacket(messageWithLength, messageWithLength.length, socket.getInetAddress(), socket.getPort());
    socket.send(packet);
  }

  public String Receive() throws IOException
  {
    byte[] receivedData = new byte[65535]; // Adjust this buffer size as needed.
    DatagramPacket receivePacket = new DatagramPacket(receivedData, receivedData.length);
    socket.receive(receivePacket);
    byte[] rawData = Arrays.copyOfRange(receivePacket.getData(), receivePacket.getOffset(), receivePacket.getLength());
    int msgLen = ByteBuffer.wrap(rawData, 0, 4).getInt();
    byte[] msgData = Arrays.copyOfRange(rawData, 4, rawData.length);
    return new String(msgData);
  }

  public void Close()
  {
    socket.close();
  }

  public void Start() throws IOException
  {
    Send("Bitch");
  }

  public boolean isConnected()
  {
    // DatagramSocket doesn't have a connected state like Socket, so you may need to track the connection state separately.
    return true; // You can customize this logic as needed.
  }
}
