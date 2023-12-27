import ddf.minim.*;

Minim minim;
AudioPlayer player;

void setup() {
  size(400, 400);
  minim = new Minim(this);
  player = minim.loadFile("enter.wav");  // Replace "your_file.mp3" with the path to your MP3 file
}

void draw() {
  background(255);
  // Display instructions
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Press ENTER to play the MP3 file", width / 2, height / 2);
}

void keyPressed() {
  if (key == ENTER) {
    if (!player.isPlaying()) {
      player.play();
    } else {
      player.rewind(); // Rewind to the beginning if already playing
    }
  }
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}
