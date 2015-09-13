/*
Processing sketch for a simple music player.
The player loads songs a pre-specified directory.
Controls - 'p' to pause/play, 'n' for the next track, 'b' for the previous track

Authors: Kartik Lovekar (kslovekar@gmail.com)
         Prithvijit Chakrabarty (prithvichakra@gmail.com)
*/

import ddf.minim.*;
import java.io.*;
import java.util.*;

Minim minim;
ddf.minim.AudioPlayer song;
AudioMetaData meta;
Play playButton;
Rewind rewind;
Forward ffwd;
long startTime = 0;
long endTime = 0;
ArrayList<String> filePaths = new ArrayList<String>(); 
boolean play = false;
int num = 0;
int numFiles = 0;
float position;
float len;

void setup()
{
  size(500,500);
  final File folder = new File("E:/music/Until the Quiet Comes/Flying Lotus feat. Niki Randa - The Kill.aiff");
  getFilePaths(folder);
  playButton = new Play((width-width/25)/2, height-height/5, width/25, height/50);
  rewind = new Rewind(width/2 - 71, height-height/5, width/25, height/50);
  ffwd = new Forward(width/2 + 50, height-height/5, width/25, height/50);
  minim = new Minim(this);
  startTime = System.currentTimeMillis();
  loadSong();
}

void draw()
{
  background(0);
  
  playButton.update();
  playButton.draw();
  rewind.update();
  rewind.draw();
  ffwd.update(); 
  ffwd.draw();
  
  if(play == true)
    text("Now Playing: "+meta.author()+" - "+meta.title(),8,15);
  else
    text("Paused: "+meta.author()+" - "+meta.title(),8,15);
  fill(250);
  
  stroke(250);
  line(0, 8*height/9, width, 8*height/9);
  
  // Drawing the waveform
  for(int i = 0; i < song.bufferSize()-1; i++)
  {
    float x1 = map(i, 0, song.bufferSize(), 0, width);
    float x2 = map(i+1, 0, song.bufferSize(), 0, width);
    line(x1, height/5 + song.left.get(i)*height/10, x2, height/5 + song.left.get(i+1)*height/10);
    line(x1, 2*height/5 + song.right.get(i)*height/10, x2, 2*height/5 + song.right.get(i+1)*height/10);
  }
  
  // Mapping position of the seek circle to song length
  position = map(song.position(), 0, len, 0, width);
  ellipse(position, 8*height/9, 15, 15);
  fill(250);
  
  if(play == true)
    endTime = System.currentTimeMillis();
  // check if current track is over to load next track
  if(endTime - startTime >= len && !song.isPlaying() && play == true)
  {
    num++;
    loadSong();
    song.play();
    play = true;
  }
}

void keyPressed()
{
  if(key == 'p')
  {
    if(!play)
    {
      song.play();
      play = true;
     }
    else
    {
      song.pause();
      play = false;
    }
  }
  if(key == 'n') // to load next track
  {
    song.pause(); // pause current track 
    num++;
    play = true;
    loadSong();
    song.play();
    
  }
  if(key == 'b') // to load previous track
  {
    song.pause(); // pause current track
    num--;
    play = true;
    loadSong();
    song.play();
  }
}

// Fast forwards or rewinds when mouse is pressed
void mousePressed()
{
  playButton.mousePressed();
  rewind.mousePressed();
  ffwd.mousePressed();
}

void mouseReleased()
{
  playButton.mouseReleased();
  rewind.mouseReleased();
  ffwd.mouseReleased();
}

// loading file paths from specified directory
void getFilePaths(final File folder) 
{
  if(!folder.isDirectory())
  {
    filePaths.add(folder.getPath());
    return;
  }
  for(final File fileEntry : folder.listFiles())
  {
    if(fileEntry.isDirectory())
      getFilePaths(fileEntry);
    else
    {
      String path = fileEntry.getPath();
      if(checkExt(path))
      {  
        filePaths.add(path);
        numFiles++;
      }
    }
  }
}

boolean checkExt(String path)
{
  if(path.substring(path.length()-3,path.length()).equals("mp3")||path.substring(path.length()-4,path.length()).equals("aiff"))
    return true;
  return false;
}

void loadSong()
{
  if(num == numFiles) // going back to the first track
    num = 0;
  if(num == -1) 
    num = 0;
  if(numFiles == 0)
    num = 0;
  startTime = System.currentTimeMillis();
  song = minim.loadFile(filePaths.get(num));
  meta = song.getMetaData();
  position = map(song.position(), 0, song.length(), 0, width);
  len = song.length();
}
