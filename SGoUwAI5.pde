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
String WeightsName = "weigths";
String BalancesName = "balances.txt";
int _length = 20000;
int wins1 = 0;
int wins2 = 0;
float[][][] dWei = new float[layers.length - 1][][];
float[][] dBal = new float[layers.length - 1][];
float _fuzz = 0.1;
float _threshold = 1 + _fuzz * 1.5;

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
    dWei[i] = new float[layers[i]][layers[i + 1]];
    Balances[i]=  new float[layers[i + 1]];
    dBal[i]=  new float[layers[i + 1]];
  }
  
  randomize(dWei[0], _fuzz);
  
  //Getting the program
  for(int i = 0; i < Weights.length; i ++)
  {
    String name = WeightsName + i + ".txt";
    Weights[i] = read2d(name);
  }
  Balances = read2d(BalancesName);
  
  /*//----------------------
  //Resetting the ai
  for(int i = 0; i < Weights.length; i ++)
  {
    randomize(Weights[i], 2);
  }
  randomize(Balance, 2s);
  
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
}

float[][] NeuralNetwork(float[][][] Wei, float[][] Bal)
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
    o[i + 1] = sig(MulAdd(Wei[i], o[i], Bal[i]));
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
  if(winCheck() > _threshold)
  {
    //Changing the program
    Weights = add3d(Weights, dWei);
    Balances = add2d(Balances, dBal);
    
    //Saving the program
    for(int i = 0; i < Weights.length; i ++)
    {
      String name = WeightsName + i + ".txt";
      write2d(Weights[i], name);
    }
    write2d(Balances, BalancesName);
    println("done");
    exit();
  }else
  {
    mouseClicked();
  }
}

float winCheck()
{
  //Resetting
  wins1 = 0;
  wins2 = 0;
  
  //Resetting the fuzz
  for(int i = 0; i < dWei.length; i ++)
  {
    randomize(dWei[i], _fuzz);
  }
  randomize(dBal, _fuzz);
  
  //Playing
  while(wins1 + wins2 < _length)
  {
    startingGame();
  }

  return float(wins2) / float(wins1 + wins2) * 2;
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
  //Rolling
  roll = len(matchAll(binary(floor(random(16))), "1"));

  //Changing the turn
  turn *= -1;
  
  //Reordering
  tokens1 = sort(tokens1);
  tokens2 = sort(tokens2);
  
  //Doing the turns
  int i = 0;
  while (turn < 0)
  {
    if(win(tokens1) || win(tokens2))
    {
      break;
    }
    
    try{
      move2(tokens2[abs(maxArray(NeuralNetwork(add3d(Weights,dWei), add2d(Balances, dBal))[layers.length - 1]) - i)], roll);
    }catch (ArrayIndexOutOfBoundsException e)
    {
      println(tokens1);
      println(tokens2);
      println(roll);
      println(i);
      for(int j = 0; j < tokens; j ++)
      {
        move2(tokens2[j],roll);
      }
    }
    i ++;
  }
  while (turn > 0)
  {
    if(win(tokens1) || win(tokens2))
    {
      break;
    }
    move1(tokens1[abs(maxArray(NeuralNetwork(Weights, Balances)[layers.length - 1]) - i)], roll);
    i ++;
  }
  
  if(win(tokens2) && win(tokens1))
  {
    println("tie?");
    return;
  }else if(win(tokens2))
  {
    wins2++;
    return;
  }else if(win(tokens1))
  {
    wins1++;
    return;
  }
}

void move1(int piece, int amount)
{
  //Can the player move?
  if (piece != -2 && piece != blocks)
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
      if (find(piece + amount, tokens2) != -1)
      {
        tokens2[find(piece + amount, tokens2)] = -1;
      }
      rolling();
    }
  }
}

void move2(int piece, int amount)
{
  //Can the player move?
  if (piece != -2 && piece != blocks)
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
      if (find(piece + amount, tokens1) != -1)
      {
        tokens1[find(piece + amount, tokens1)] = -1;
      }
      rolling();
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

void randomize(float[][] a, float bounds)
{
  //Resets a
  for(int i = 0; i < a.length; i++)
  {
    for(int j = 0; j < a[i].length; j ++)
    {
      a[i][j] = random(-bounds, bounds);
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

float[][][] add3d(float[][][] a, float[][][] b)
{
  float[][][] o = new float[a.length][][];
  for(int i = 0; i < a.length; i ++)
  {
    o[i] = new float[a[i].length][a[i][0].length];
  }
  
  for(int i = 0; i < o.length; i ++)
  {
    for(int j = 0; j < o[i].length; j ++)
    {
      for(int k = 0; k < o[i][j].length; k ++)
      {
        o[i][j][k] += b[i][j][k] + a[i][j][k];
      }
    }
  }
  
  return o;
}

float[][] add2d(float[][] a, float[][] b)
{
  float[][] o = new float[a.length][];
  for(int i = 0; i < a.length; i ++)
  {
    o[i] = new float[a[i].length];
  }
  
  for(int i = 0; i < o.length; i ++)
  {
    for(int j = 0; j < o[i].length; j ++)
    {
      o[i][j] += b[i][j] + a[i][j];
    }
  }
  
  return o;
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
  if(wins1 + wins1 < _length / 2)
  {
    turn = 1;
  }
  else
  {
    turn = -1;
  }
  
  //Starting
  rolling();
}