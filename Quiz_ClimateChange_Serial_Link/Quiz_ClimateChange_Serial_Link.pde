import processing.video.*;
import ddf.minim.*;
import processing.serial.*;

Serial arduinoPort;
int obj_select = 0;

PImage planetImage;
int questionNumber = 0;
int totalScore = 0;
int[] userAnswers;
String[][] questions;
int[] additionalPoints;
int state = 0;
int timer = 0;
int feedbackTimer = 0;
boolean showingFeedback = false;
PFont customFont;
boolean enterKeyPressed = false;

Minim minim;
AudioSnippet enterSound;
AudioPlayer backgroundMusic;
Movie finalVideo;

void setup() {
  arduinoPort = new Serial(this, Serial.list()[2], 9600);
  size(1400, 800);
  textAlign(CENTER, CENTER);
  customFont = createFont("font.otf", 12);
  textFont(customFont);
  planetImage = loadImage("planet.jpg");

  questions = new String[][] {
    {"How often do you eat animal-based products?", "Never", "Occasionally", "Often", "background1.jpg"},
    {"How much of the food you eat is unprocessed, unpackaged, or locally grown?", "Never", "Occasionally", "Often", "background2.jpg"},
    {"How many people live in your household?", "Only me", "Me + partner", "2+", "background3.jpg"},
    {"How far do you travel by car or motorcycle each week?", "None", "<100km", ">100km", "background4.jpg"}
    // Add more questions as needed
  };

  userAnswers = new int[questions.length];
  additionalPoints = new int[]{
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300
    // Add more points as needed
  };

  state = 0;
  timer = millis() + 10000;

  finalVideo = new Movie(this, "/Users/idacarlsson/Desktop/multimodal_interfaces-main/Quiz_Arduino_Code/multimodal_interfaces/Quiz_ClimateChange_Serial_Link/FinalVideo.mp4");

  minim = new Minim(this);
  backgroundMusic = minim.loadFile("background-runamok.wav");
  backgroundMusic.loop();

  enterSound = minim.loadSnippet("enter.wav");
}

void draw() {
  if (0 < arduinoPort.available()) {
    obj_select = arduinoPort.read();
    objectPlaced(obj_select);
  }

  if (state == 0 && millis() > timer) {
    displayBackground("initialBackground.jpg", 10000);
  } else if (state == 1 && millis() > timer) {
    displayBackground("secondBackground.jpg", 10000);
  } else if (state >= 2 && state < questions.length * 2 + 2) {
    int questionIndex = (state - 2) / 2;
    if ((state - 2) % 2 == 0) {
      displayBackgroundAndQuestion(questions[questionIndex][4], 20000, questions[questionIndex]);
      showingFeedback = false;
    } else {
      if (userAnswers[questionIndex] != 0 && !showingFeedback) {
        feedbackTimer = millis();
        showingFeedback = true;
      }

      if (showingFeedback && millis() < feedbackTimer + 3000) {
        displayFeedback(userAnswers[questionIndex], questions[questionIndex]);
      } else {
        if (questionIndex < questions.length - 1) {
          questionNumber++;
          state = questionNumber * 2 + 2;
          userAnswers[questionNumber - 1] = 0;
          showingFeedback = false;
        } else {
          state = questions.length * 2 + 2;
        }
      }
    }
  } else if (state == questions.length * 2 + 2) {
    image(finalVideo, 0, 0, width, height);
    int numPlanets = getNumPlanets(totalScore);
    for (int i = 0; i < numPlanets; i++) {
      float x = map(i, 0, numPlanets, 50, width - 50);
      float y = height / 2;
      image(planetImage, x - 50, y - 50, 100, 100);
    }

    fill(255);
    textSize(24);
    text("Quiz Complete!", width / 2, height / 2 - 120);
    textSize(18);
    text("Your total score is: " + totalScore, width / 2, height / 2 - 60);
    text(getPlanetInfo(totalScore), width / 2, height / 2);
    textSize(16);
    text("Press 'R' to redo the quiz", width / 2, height / 2 + 180);

    if (userAnswers[questions.length - 1] != 0 && !finalVideo.isPlaying()) {
      finalVideo.loop();
    }
  }
}

void displayBackground(String background, int duration) {
  PImage currentBackgroundImage = loadImage(background);
  image(currentBackgroundImage, 0, 0, width, height);

  if (millis() > timer + duration) {
    state++;
    timer = millis();
  }
}

void displayBackgroundAndQuestion(String background, int duration, String[] question) {
  PImage currentBackgroundImage = loadImage(background);
  image(currentBackgroundImage, 0, 0, width, height);

  if (millis() > timer + duration) {
    state++;
    timer = millis();
  }

  displayQuestion(question);
}

void displayQuestion(String[] question) {
  fill(0, 0, 0);
  textSize(36);
  text(question[0], width / 2, height / 2 - 150);

  for (int i = 0; i < 3; i++) {
    fill(114, 116, 68);
    rectMode(CENTER);
    rect((i + 1) * width / 4, height / 2, 300, 80, 10);
    fill(238, 230, 119);
    textSize(20);
    text((i + 1) + ") " + question[i + 1], (i + 1) * width / 4, height / 2);
  }
}

void displayFeedback(int userChoice, String[] question) {
  if (userChoice >= 1 && userChoice <= 3) {
    background(color(114, 116, 68));

    textFont(customFont);
    fill(238, 230, 119);
    textSize(55);
    textAlign(CENTER, CENTER);

    String feedbackText = "The option you choose: " + userChoice + "\n"; 
    feedbackText += question[userChoice] + ".";
    text(feedbackText, width / 2, height / 2);
  }
}

String getPlanetInfo(int score) {
  return "You would need " + getNumPlanets(score) + " planet(s) to sustain your lifestyle.";
}

int getNumPlanets(int score) {
  println("Score " + score);
  if (score >= 1000) {
    return 5;
  } else if (score >= 800) {
    return 4;
  } else if (score >= 600) {
    return 3;
  } else if (score >= 400) {
    return 2;
  } else if (score >= 200) {
    return 1;
  } else {
    return 0;
  }
}

void keyPressed() {
  if (keyCode == ENTER && !enterKeyPressed) {
    enterKeyPressed = true;
    enterSound.rewind();
    enterSound.play();

    int answerValue = userAnswers[questionNumber];
    print(answerValue);

    if (answerValue >= 1 && answerValue <= 3) {
      int index = questionNumber * 3 + (answerValue - 1);
      if (index >= 0 && index < additionalPoints.length) {
        println("Total Score " + additionalPoints[index]);
        totalScore += additionalPoints[index];
      } else {
        println("Invalid index: " + index);
      }
    }

    if (questionNumber < questions.length - 1 && answerValue != 0) {
      questionNumber++;
      state = questionNumber * 2 + 2;
      userAnswers[questionNumber - 1] = 0;
      showingFeedback = false;
    } else if (questionNumber == questions.length - 1 && answerValue != 0) {
      questionNumber++;
      state = questions.length * 2 + 2;

      if (answerValue >= 1 && answerValue <= 3) {
        totalScore += additionalPoints[questionNumber * 3 + (answerValue - 1)];
      }

      if (userAnswers[questionNumber - 1] != 0 && !finalVideo.isPlaying()) {
        finalVideo.loop();
      }
    }
  } else if (keyCode == '1' || keyCode == '2' || keyCode == '3') {
    userAnswers[questionNumber] = keyCode - '0';
    enterSound.rewind();
    enterSound.play();
    state++;
  } else if (key == 'r' || key == 'R') {
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
    state = 2;
  }
}

void objectPlaced(int obj_select) {
  print("HERE");
  print(obj_select);
  if (obj_select != 0) {
    println("Here 2");
    int answerValue = obj_select;
    println(answerValue);

    if (answerValue >= 1 && answerValue <= 3) {
      println("Total Score " + additionalPoints[questionNumber * 3 + (answerValue - 1)]);
      totalScore += additionalPoints[questionNumber * 3 + (answerValue - 1)];
    }

    if (questionNumber < questions.length - 1 && answerValue != 0) {
      questionNumber++;
      userAnswers[questionNumber - 1] = 0;
    } else if (questionNumber == questions.length - 1 && answerValue != 0) {
      questionNumber++;
    }
    feedbackTimer = millis();
    showingFeedback = true;
  } else if (obj_select == 1 || obj_select == 2 || obj_select == 3) {
    userAnswers[questionNumber] = obj_select - 0;
    feedbackTimer = millis();
    showingFeedback = true;
  } else if (key == 'r' || key == 'R') {
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
  }
}

void stop() {
  enterSound.close();
  backgroundMusic.close();
  minim.stop();
  super.stop();
}

void movieEvent(Movie m) {
  m.read();
}
