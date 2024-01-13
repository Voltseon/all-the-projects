import java.awt.*;
import java.util.ArrayList;
import java.util.Vector;

public class PivotPlayer
{
  public int id; //
  public String name; //
  public String graphic; //
  public String transformed; //
  public float[] spriteColor; //
  public int pattern; //
  public int direction; //
  public int health; //
  public int[] dashLocation; //
  public int dashDistance; //
  public float realX; //
  public float realY; //
  public int xOffset; //
  public int yOffset; //
  public String character; //
  public boolean isDead; //
  public boolean isGuarding; //
  public boolean isInvulnerable; //
  public int[] hitbox; //
  public ArrayList<PivotAttack> attacks;
  public boolean isReady; // Ready in character selection
  public boolean isSet; // Ready in game
  public int map; //
  public int x; //
  public int y; //
  public String version; //
  public int settingStocks; //
  public int settingTime; //
  public int stocks;

  public PivotPlayer(String jsonData)
  {
    UpdatePlayer(jsonData);
  }

  public void UpdatePlayer(String jsonData)
  {
    if (jsonData == null)
    {
      return;
    }
    attacks = new ArrayList<PivotAttack>();
    for (int i = 0; i < jsonData.length(); i++)
    {
      if (jsonData.charAt(i) == '[')
      {
        int j = i + 1;
        while (jsonData.charAt(j) != ']')
        {
          if (jsonData.charAt(j) == ',')
          {
            jsonData = jsonData.substring(0, j) + " " + jsonData.substring(j + 1);
          }
          j++;
        }
      }
    }
    jsonData = jsonData.replace("{", "");
    jsonData = jsonData.replace("}", "");
    jsonData = jsonData.replace("[ ", "");
    jsonData = jsonData.replace("] ", "");
    jsonData = jsonData.replace("`", "");
    jsonData = jsonData.replace("  ", " ");
    String[] jsonArray = jsonData.split(",");
    for (int i = 0; i < jsonArray.length; i++)
    {
      String[] jsonPair = jsonArray[i].split(": ");
      switch (jsonPair[0])
      {
        case "name":
          name = jsonPair[1];
          break;
        case "character":
          character = jsonPair[1];
          break;
        case "dash_distance":
          dashDistance = Integer.parseInt(jsonPair[1]);
          break;
        case "dash_location":
          dashLocation = new int[2];
          if (jsonPair[1].equals("[]") || jsonPair[1].equals("") || jsonPair[1] == null)
          {
            break;
          }
          String[] dashLocationArray = jsonPair[1].replace("[","").replace("]","").split(" ");
          for (int j = 0; j < dashLocationArray.length; j++)
          {
            if (dashLocationArray[j].equals(""))
            {
              continue;
            }
            dashLocation[j] = Integer.parseInt(dashLocationArray[j]);
          }
          break;
        case "direction":
          direction = Integer.parseInt(jsonPair[1]);
          break;
        case "graphic":
          graphic = jsonPair[1];
          break;
        case "hitbox":
          String[] hitboxArray = jsonPair[1].replace("[","").replace("]","").split(" ");
          hitbox = new int[hitboxArray.length];
          for (int j = 0; j < hitboxArray.length; j++)
          {
            hitbox[j] = Integer.parseInt(hitboxArray[j]);
          }
          break;
        case "hp":
          health = Integer.parseInt(jsonPair[1]);
          break;
        case "id":
          id = Integer.parseInt(jsonPair[1]);
          break;
        case "is_dead":
          isDead = Boolean.parseBoolean(jsonPair[1]);
          break;
        case "is_guarding":
          isGuarding = Boolean.parseBoolean(jsonPair[1]);
          break;
        case "map":
          map = Integer.parseInt(jsonPair[1]);
          break;
        case "ready":
          isReady = Boolean.parseBoolean(jsonPair[1]);
          break;
        case "set":
          isSet = Boolean.parseBoolean(jsonPair[1]);
          break;
        case "real_x":
          realX = Float.parseFloat(jsonPair[1]);
          break;
        case "real_y":
          realY = Float.parseFloat(jsonPair[1]);
          break;
        case "sprite_color":
          String[] spriteColorArray = jsonPair[1].replace("[","").replace("]","").split(" ");
          spriteColor = new float[spriteColorArray.length];
          for (int j = 0; j < spriteColorArray.length; j++)
          {
            spriteColor[j] = Float.parseFloat(spriteColorArray[j]);
          }
          break;
        case "transformed":
          transformed = jsonPair[1];
          break;
        case "version":
          version = jsonPair[1];
          break;
        case "x":
          x = Integer.parseInt(jsonPair[1]);
          break;
        case "y":
          y = Integer.parseInt(jsonPair[1]);
          break;
        case "pattern":
          pattern = Integer.parseInt(jsonPair[1]);
          break;
        case "setting_stocks":
          settingStocks = Integer.parseInt(jsonPair[1]);
          break;
        case "setting_time":
          settingTime = Integer.parseInt(jsonPair[1]);
          break;
        case "x_offset":
          xOffset = Integer.parseInt(jsonPair[1]);
          break;
        case "y_offset":
          yOffset = Integer.parseInt(jsonPair[1]);
          break;
        case "invulnerable":
          isInvulnerable = Boolean.parseBoolean(jsonPair[1]);
          break;
        case "stocks":
          stocks = Integer.parseInt(jsonPair[1]);
          break;
        default:
          // Detect pivot attacks
          if (jsonPair[0].contains("melee_") || jsonPair[0].contains("ranged_") || jsonPair[0].contains("none_"))
          {
            String[] attackArray = jsonPair[1].replace("[","").replace("]","").split(" ");
            float x = Float.parseFloat(attackArray[0]) / 100F;
            float y = Float.parseFloat(attackArray[1]) / 100F;
            boolean isPlaying = Boolean.parseBoolean(attackArray[2]);
            boolean isActive = Boolean.parseBoolean(attackArray[3]);
            int frame = Integer.parseInt(attackArray[4]);
            int angle = Integer.parseInt(attackArray[5]);
            boolean critical = Boolean.parseBoolean(attackArray[6]);
            int direction = Integer.parseInt(attackArray[7]);
            int id = Integer.parseInt(attackArray[8]);
            int[] hitbox = new int[4];
            hitbox[0] = Integer.parseInt(attackArray[9]);
            hitbox[1] = Integer.parseInt(attackArray[10]);
            hitbox[2] = Integer.parseInt(attackArray[11]);
            hitbox[3] = Integer.parseInt(attackArray[12]);
            int damage = Integer.parseInt(attackArray[13]);
            int move_type = (jsonPair[1].contains("melee_") ? 0 : (jsonPair[1].contains("ranged_") ? 1 : 2));
            String name = jsonPair[0].substring(jsonPair[0].indexOf("_") + 1);
            attacks.add(new PivotAttack(name, x, y, isPlaying, isActive, frame, angle, critical, direction, id, hitbox, damage, move_type));
          }
          break;
      }
    }    
  }

  public String Stringify()
  {
    String json = "{";
    json += "\"name\": \"" + name + "\",";
    json += "\"character\": \"" + character + "\",";
    json += "\"dash_distance\": " + dashDistance + ",";
    if (dashLocation != null) { json += "\"dash_location\": " + dashLocation[0] + " " + dashLocation[1] + ","; }
    json += "\"direction\": " + direction + ",";
    json += "\"graphic\": \"" + graphic + "\",";
    if (hitbox != null) { json += "\"hitbox\": " + hitbox[0] + " " + hitbox[1] + " " + hitbox[2] + " " + hitbox[3] + " " + ","; }
    json += "\"hp\": " + health + ",";
    json += "\"id\": " + id + ",";
    json += "\"is_dead\": " + isDead + ",";
    json += "\"is_guarding\": " + isGuarding + ",";
    json += "\"map\": " + map + ",";
    json += "\"ready\": " + isReady + ",";
    json += "\"set\": " + isSet + ",";
    json += "\"real_x\": " + realX + ",";
    json += "\"real_y\": " + realY + ",";
    if (spriteColor != null) { json += "\"sprite_color\": " + spriteColor[0] + " " + spriteColor[1] + " " + spriteColor[2] + " " + spriteColor[3] + " " + ","; }
    json += "\"transformed\": \"" + transformed + "\",";
    json += "\"version\": \"" + version + "\",";
    json += "\"x\": " + x + ",";
    json += "\"y\": " + y + ",";
    json += "\"pattern\": " + pattern + ",";
    json += "\"setting_stocks\": " + settingStocks + ",";
    json += "\"setting_time\": " + settingTime + ",";
    json += "\"x_offset\": " + xOffset + ",";
    json += "\"y_offset\": " + yOffset + ",";
    json += "\"invulnerable\": " + isInvulnerable + ",";
    json += "\"stocks\": " + stocks + ",";
    json += "\"attacks\": ";
    if (attacks != null)
    {
      for (int i = 0; i < attacks.size(); i++)
      {
        String attackJson = attacks.get(i).Stringify();
        if (attackJson == null)
        {
          continue;
        }
        json += attackJson;
        if (i < attacks.size() - 1)
        {
          json += " &&& ";
        }
      }
    }
    json += "}";
    return json;
  }

  public boolean IsColliding(PivotAttack attack)
  {
    if (isDead || isGuarding || isInvulnerable || attack == null || hitbox == null || !attack.active || !attack.playing || attack.move_type == 2)
    {
      return false;
    }
    Rectangle hitbox = new Rectangle(this.hitbox[0], this.hitbox[1], this.hitbox[2], this.hitbox[3]);
    Rectangle attackHitbox = new Rectangle(attack.hitbox[0], attack.hitbox[1], attack.hitbox[2], attack.hitbox[3]);
    return hitbox.intersects(attackHitbox);
  }
}
