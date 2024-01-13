import java.awt.*;

public class PivotAttack
{
  public String name;
  public int direction;
  public float x;
  public float y;
  public int power;
  public int[] hitbox;
  public int frame;
  public boolean active;
  public boolean playing;
  public boolean critical;
  public int angle;
  public int id;
  public int move_type;

  public PivotAttack(String name, float x, float y, boolean isPlaying, boolean isActive, int frame, int angle, boolean critical, int direction, int id, int[] hitbox, int damage, int move_type)
  {
    this.name = name;
    this.direction = direction;
    this.x = x;
    this.y = y;
    this.power = damage;
    this.hitbox = hitbox;
    this.frame = frame;
    this.active = isActive;
    this.playing = isPlaying;
    this.critical = critical;
    this.angle = angle;
    this.id = id;
    this.move_type = move_type;
  }

  public String Stringify()
  {
    if (x == 0 && y == 0) { return null; }
    String json = "{";
    json += "\"name\":\"" + name + "\",";
    json += "\"direction\":" + direction + ",";
    json += "\"x\":" + x + ",";
    json += "\"y\":" + y + ",";
    json += "\"power\":" + power + ",";
    json += "\"hitbox\":\"" + hitbox[0] + " " + hitbox[1] + " " + hitbox[2] + " " + hitbox[3] + "\",";
    json += "\"frame\":" + frame + ",";
    json += "\"active\":" + active + ",";
    json += "\"playing\":" + playing + ",";
    json += "\"critical\":" + critical + ",";
    json += "\"angle\":" + angle + ",";
    json += "\"id\":" + id + ",";
    json += "\"move_type\":" + move_type;
    json += "}";
    return json;
  }
}
