/**
  * This sketch demonstrates how to use the <code>loadSample</code> method of <code>Minim</code>. 
  * The <code>loadSample</code> method allows you to specify the sample you want to load 
  * with a <code>String</code> and optionally specify what you want the buffer size of the 
  * returned <code>AudioSample</code> to be. Minim is able to load wav files, au files, aif
  * files, snd files, and mp3 files. When you call <code>loadSample</code>, if you just 
  * specify the filename it will try to load the sample from the data folder of your sketch. 
  * However, you can also specify an absolute path (such as "C:\foo\bar\thing.wav") and the 
  * file will be loaded from that location (keep in mind that won't work from an applet). 
  * You can also specify a URL (such as "http://www.mysite.com/mp3/song.mp3") but keep in mind 
  * that if you run the sketch as an applet you may run in to security restrictions 
  * if the applet is not on the same domain as the file you want to load. You can get around 
  * the restriction by signing all of the jars in the applet.
  * <p>
  * An <code>AudioSample</code> is a special kind of file playback that allows
  * you to repeatedly <i>trigger</i> an audio file. It does this by keeping the
  * entire file in an internal buffer and then keeping a list of trigger points.
  * <code>AudioSample</code> supports up to 20 overlapping triggers, which
  * should be plenty for short sounds. It is not advised that you use this class
  * for long sounds (like entire songs, for example) because the entire file is
  * kept in memory.
  * <p>
  * Use 'k' and 's' to trigger a ap[0] drum sample and a ap[1] sample, respectively. 
  * You will see their waveforms drawn when they are played back.
  */

import ddf.minim.*;
import processing.serial.*;

Minim minim;
AudioPlayer[] ap;
String soundFiles[] = {"./sounds/conga_roll.aif", "./sounds/didg_groove_4.mp3"};
String code = "";
boolean codeAvail = false;

void setup () {
  size(512, 200, P3D);
  minim = new Minim(this);
  
  /* Open port and set to buffer until line line feed. */
  String portName = "/dev/tty.usbmodemfa131";  //Serial.list()[0];
  Serial myPort = new Serial(this, portName);
  myPort.bufferUntil(10);
  background(0);

  ap = loadAudio(soundFiles); // loads the audio files into ap.
  
  // load BD.wav from the data folder
  /*ap[0] = minim.loadFile( "ghetto.mp3" );

  // An AudioSample will spawn its own audio processing Thread, 
  // and since audio processing works by generating one buffer 
  // of samples at a time, we can specify how big we want that
  // buffer to be in the call to loadSample. 
  // above, we requested a buffer size of 512 because 
  // this will make the triggering of the samples sound more responsive.
  // on some systems, this might be too small and the audio 
  // will sound corrupted, in that case, you can just increase
  // the buffer size.
  
  // if a file doesn't exist, loadSample will return null
  if ( ap[0] == null ) println("Didn't get ap[0]!");
  
  // load SD.wav from the data folder
  ap[1] = minim.loadFile("background.mp3" );
  if ( ap[1] == null ) println("Didn't get ap[1]!");*/
}

void draw () {
  background(0);
  stroke(255);
  
  if(codeAvail){
    processCode(code);
    codeAvail = false;
  }
  // use the mix buffer to draw the waveforms.
  
  for (int i = 0; i < ap[0].bufferSize() - 1; i++) {
    float x1 = map(i, 0, ap[0].bufferSize(), 0, width);
    float x2 = map(i+1, 0, ap[0].bufferSize(), 0, width);
    line(x1, 50 - ap[0].mix.get(i)*50, x2, 50 - ap[0].mix.get(i+1)*50);
    line(x1, 150 - ap[1].mix.get(i)*50, x2, 150 - ap[1].mix.get(i+1)*50);
  }
}

/* Loops the specified soundfile in the list of soundfiles. */
boolean play(int idx){
  boolean ret = false;
  if(idx>=0 && idx<ap.length){
    ap[idx].loop();
    ret = true;
  }
  return ret;
}

/* Pauses the specified soundfile in the list of soundfiles and rewinds it. */
boolean stopAndRewind(int idx){
  boolean ret = false;
  if(idx>=0 && idx<ap.length){
    ap[idx].pause();
    //ap[idx].rewind();
    ret = true;
  }
  return ret;
}

/* This is only for debugging now. */
void keyPressed () {
  switch(key){
    case 'a': code = "10"; codeAvail = true; break;
    case 's': code = "11"; codeAvail = true; break;/*
      if (ap[0].isPlaying())  { ap[0].pause(); } else { ap[0].play(); }
      break;*/
    case 'j': code = "20"; codeAvail = true; break;
    case 'k': code = "21"; codeAvail = true; break; /*
      if (ap[1].isPlaying())  { ap[1].pause(); } else { ap[1].play(); }
      break;*/
  }
}

/* Load specified audio files into a list of file players. */
AudioPlayer[] loadAudio(String names[]){
  int sz = names.length;
  AudioPlayer[] aFiles = new AudioPlayer[sz];
  for(int i=0; i<sz; i++){
    aFiles[i] = minim.loadFile(names[i]);
    if(aFiles[i] == null){
      println("Unable to load audio file:\t" + names[i]);
    }
  }
  return aFiles;
}

void serialEvent(Serial p) {
  code = p.readString().trim();
  codeAvail = true;
}

/* Process the code string.
   Attempts to parse the string into an integer then splits the integer into two parts:
     1) the one's digit is the operation code
     2) ten's digit and above is the index
   If the index is greater than 0, calls the appropriate operation with the index and sets the
     return value to whatever the operation returns. */
boolean processCode(String c) throws NumberFormatException{
  println(c);
  boolean ret = false;
  int cnum = Integer.parseInt(c);
  int idx = cnum/10;
  int op = cnum%10;
  if(idx>0){
    idx--; // decrement index to account for zero-indexed arrays.
    switch(op){
      case 0: ret = stopAndRewind(idx); break;
      case 1: ret = play(idx); break;
    }
  }
  return ret;
}
    
