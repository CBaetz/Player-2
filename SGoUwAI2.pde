//Initials
int blocks = 8;
int tokens = 4;

//Visuals
float boxSize = 40;
int size = 400;
int topMargin = 70;
color colour1 = #ff8800;
color colour2 = #0088ff;
color background = #c0c0c0;
float rectWid = 100;
float rectHei = boxSize;
float rectBuffer = 10;
boolean stop = false;

//Peices
int turn = -1;
int roll = 0;
int[] tokens1 = new int[tokens];
int[] tokens2 = new int[tokens];

//AI stuffs
int[] layers = {blocks + 1, 6, tokens};
float[][][] Weights = new float[layers.length - 1][][];
float[][] Balances = new float[layers.length - 1][];
float[][] Output = new float[layers.length][0];
String WeightsName = "weigths";
String BalancesName = "balances.txt";
int _length = 10000;
int wins1 = 0;
int wins2 = 0;

//Dummies
float[] empty = {};

void setup()
{
  //Size
  size(400, 400);

  //Setup
  textAlign(CENTER, TOP);
  textSize(rectHei);

  //Proper size setup
  for (int i = 0; i < Weights.length; i ++)
  {
    Weights[i] = new float[layers[i]][layers[i + 1]];
    Balances[i]=  new float[layers[i + 1]];
  }
  
  //Getting the program
  for(int i = 0; i < Weights.length; i ++)
  {
    String name = WeightsName + i + ".txt";
    Weights[i] = read2d(name);
  }
  Balances = read2d(BalancesName);
  
  startingGame();
  
  /*//----------------------
  //Resetting the ai
  for(int i = 0; i < Weights.length; i ++)
  {
    randomize(Weights[i]);
  }
  randomize(Balances);
  
  for(int i = 0; i < Weights.length; i ++)
  {
    String name = WeightsName + i + ".txt";
    write2d(Weights[i], name);
  }
  
  write2d(Balances, BalancesName);
  
  *///----------------------
}

void draw()
{ 
  //Visuals
  clear();
  background(background);
  drawBoard();
  drawTokens();
  drawTurn();

  //Displaying roll
  fill(0);
  text(roll, size / 2, rectBuffer);

  //Reordering
  tokens1 = sort(tokens1);
  tokens2 = sort(tokens2);
  
  if(wins1 + wins2 >= _length)
  {
    println(wins1 + "     " + wins2);
    println(float(wins1) / float(wins2));
    println(float(wins2) / float(wins1));
    exit();
  }else
  {
    startingGame();
  }
}

float[][] NeuralNetwork()
{
  float[][] o = new float[layers.length][0];
  if (turn < 0)
  {
    o[0] = float(tokens2);
    for(int i = 0; i < tokens; i++)
    {
      o[0] = append(o[0], tokens1[i]);
    }
    o[0] = append(o[0],roll);
  }
  else if(turn > 0)
  {
    o[0] = float(tokens1);
    for(int i = 0; i < tokens; i++)
    {
      o[0] = append(o[0], tokens2[i]);
    }
    o[0] = append(o[0],roll);  
  }
  
  for(int i = 0; i < layers.length - 1; i++)
  {
    o[i + 1] = sig(MulAdd(Weights[i], o[i], Balances[i]));
  }
  
  return o;
}

float[] MulAdd(float[][] a, float[]v, float[] v2)
{
  //Matrix * vector + another vector;
  float[] O = new float[a[0].length];
  for (int i = 0; i < v.length; i ++)
  {
    for (int j = 0; j < a[0].length; j ++)
    {
      O[j] += v[i] * a[i][j];
    }
  }

  for (int j = 0; j < a[0].length; j ++)
  {
    O[j] += v2[j];
  }

  return O;
}

float[] sig(float[] v)
{
  //Taking the tanh squishing function
  for (int i  = 0; i < v.length; i++)
  {
    v[i] = (exp(2 * v[i]) - 1) / ( exp(2 * v[i]) + 1);
  }
  return v;
}

int len(String[][] a)
{
  //if null then length = 0;
  if (a == null)
  {
    return 0;
  } else
  {
    return a.length;
  }
}

void drawBoard()
{
  for (int i = 0; i < blocks; i ++)
  {
    fill(255);
    rect(size / 2 - boxSize / 2, topMargin + boxSize * i, boxSize, boxSize);
  }
}

void drawTokens()
{
  for (int i = 0; i < tokens; i ++)
  {
    fill(colour1);
    //Unplayed tokens
    if (tokens1[i] < 0)
    {
      ellipse(boxSize / 2, boxSize / 2 + i * boxSize, boxSize, boxSize);
    }
    //Done tokens
    else if (tokens1[i] >= blocks)
    {
      ellipse(boxSize / 2, size - (boxSize / 2 + (tokens - 1 - i) * boxSize), boxSize, boxSize);
    }
    //Others
    else
    {
      ellipse(size / 2, topMargin + boxSize / 2 + boxSize * tokens1[i], boxSize, boxSize);
    }

    fill(colour2);
    //Unplayed tokens
    if (tokens2[i] < 0)
    {
      ellipse(size - boxSize / 2, boxSize / 2 + i * boxSize, boxSize, boxSize);
    }
    //Done tokens
    else if (tokens2[i] >= blocks)
    {
      ellipse(size - boxSize / 2, size - (boxSize / 2 + (tokens - 1 - i) * boxSize), boxSize, boxSize);
    }
    //Others
    else
    {
      ellipse(size / 2, topMargin + boxSize / 2 + boxSize * tokens2[i], boxSize, boxSize);
    }
  }
}

void drawTurn()
{
  //Changing the colour
  fill(colour2);
  if (turn > 0)
  {
    fill(colour1);
  }

  rect(size / 2 - rectWid / 2, rectBuffer, rectWid, rectHei);
}

void mouseClicked()
{
  //Just the start
  println(tokens1);
  println("-----");
  println(tokens2);
}

int click(int x, int y)
{
  //Finding where anything was clicked
  if (x < boxSize && y < tokens * boxSize)
  {
    return -1;
  } else if (x < size / 2 + boxSize / 2 && x > size / 2 - boxSize / 2 && y > topMargin && y < topMargin + blocks * boxSize)
  {
    return floor((y - topMargin) / boxSize);
  } else
  {
    return -2;
  }
}

void rolling()
{
  //Rolling //<>//
  roll = len(matchAll(binary(floor(random(16))), "1"));

  //Changing the turn
  turn *= -1;
  
  if(win(tokens1))
  {
    wins1++;
    return;
  }else if(win(tokens2))
  {
    wins2++;
    return;
  }
  
  //Reordering
  tokens1 = sort(tokens1);
  tokens2 = sort(tokens2);

  //Doing the turns
  int i = 0;
  while (turn < 0)
  {
    move2(tokens2[abs(maxArray(NeuralNetwork()[layers.length - 1]) - i)], roll);
    i ++;
    if(abs(maxArray(NeuralNetwork()[layers.length - 1]) - i) >= 4)
    {
      return;
    }
  }
  while (turn > 0)
  {
    move1(tokens1[abs(maxArray(NeuralNetwork()[layers.length - 1]) - i)], roll);
    i ++;
    if(abs(maxArray(NeuralNetwork()[layers.length - 1]) - i) >= 4)
    {
      return;
    }
  }
}

void move1(int piece, int amount)
{
  //Can the player move?
  if (piece != -2 && piece != 8)
  {
    if (amount == 0)
    {
      //Dummy turn
      rolling();
    } else if (piece + amount >= blocks)
    {
      //Exiting
      tokens1[find(piece, tokens1)] = blocks;
      rolling();
    } else if (find(piece + amount, tokens1) == -1)
    {
      //Normal moves
      tokens1[find(piece, tokens1)] += amount;
      rolling();
      if (find(piece + amount, tokens2) != -1)
      {
        tokens2[find(piece + amount, tokens2)] = -1;
      }
    }
  }
}

void move2(int piece, int amount)
{
  //Can the player move?
  if (piece != -2 && piece != 8)
  {
    if (amount == 0)
    {
      //Dummy turn
      rolling();
    } else if (piece + amount >= blocks)
    {
      //Exiting the board
      tokens2[find(piece, tokens2)] = blocks;
      rolling();
    } else if (find(piece + amount, tokens2) == -1)
    {
      //Normal moves
      tokens2[find(piece, tokens2)] += amount;
      rolling();
      if (find(piece + amount, tokens1) != -1)
      {
        tokens1[find(piece + amount, tokens1)] = -1;
      }
    }
  }
}

int find(int o, int[] a)
{
  //searching for the first instance of a result in an array
  for (int i = 0; i < a.length; i ++)
  {
    if (a[i] == o)
    {
      return i;
    }
  }
  return -1;
}

void write2d(float[][] a, String name)
{
  String[] lines = {};

  //Making all the lines what they need to be
  for (int i = 0; i < a.length; i ++)
  {
    for (int j = 0; j < a[i].length; j++)
    {
      lines = append(lines, str(a[i][j]));
    }
    if (i != a.length - 1)
    {
      lines = append(lines, "");
    }
  }

  //Saving
  saveStrings(name, lines);
}

float[][] read2d(String name)
{
  //Load
  String[] data = loadStrings(name);

  //Compile
  float[][] a = new float[1][0];
  int x1 = 0;
  for (int i = 0; i < data.length; i ++)
  {
    if (data[i].length() == 0)
    {
      x1 ++;
      a = (float[][]) expand(a, a.length + 1);
      a[x1] = empty;
    } else
    {
      a[x1] = append(a[x1], float(data[i]));
    }
  }
  
  return a;
}

boolean win(int [] tok)
{
  boolean flag = true;
  for (int i = 0; i < tok.length; i ++)
  {
    if (tok[i] != blocks)
    {
      flag = false;
    }
  }
  return flag;
}

void randomize(float[][] a)
{
  //Resets a
  for(int i = 0; i < a.length; i++)
  {
    for(int j = 0; j < a[i].length; j ++)
    {
      a[i][j] = random(-2,2);
    }
  }
}

int maxArray(float[] v)
{
  int max = 0;
  for(int i = 0; i < v.length; i ++)
  {
    if(v[max] < v[i])
    {
      max = i;
    }
  }
  
  return max;
}

void startingGame()
{
  //Unplayed = -1;
  for (int i = 0; i < tokens; i ++)
  {
    tokens1[i] = -1;
    tokens2[i] = -1;
  }
  
  //Turn
  turn = -1;
  
  //Starting
  rolling();
}