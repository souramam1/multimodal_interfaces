import processing.video.*;
import ddf.minim.*;
import processing.serial.*;

Serial arduinoPort;
int obj_select = 0;

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
  size(1273, 730);
  textAlign(CENTER, CENTER);
  customFont = createFont("font.ttf", 12);
  textFont(customFont);

  questions = new String[][] {
    {"How many servings of meat do you consume each week?", "0-3 servings", "4-9 servings", "10 or more servings", "background1.jpg"},
    {"How much food do you waste on a weekly basis?", "Less than 1 kg", "1-2 kg", "More than 2 kg", "background1.jpg"},
    {"What percentage of your produce is local and seasonal?", "75% or more", "50-74%", "Less than 50%", "background1.jpg"},
    {"How many energy-efficient appliances/light bulbs do you use?", "5 or more", "3-4", "2 or fewer", "background2.jpg"},
    {"What is your monthly energy consumption?", "Below 300 kWh", "300-600 kWh", "Above 600 kWh", "background2.jpg"},
    {"How often do you actively monitor your home energy usage?", "Weekly or more", "Monthly", "Rarely or never", "background2.jpg"},
    {"How far do you travel by car or motorcycle each week?", "Less than 50 km", "50-150 km", "More than 150 km", "background3.jpg"},
    {"How frequently do you travel by air?", "Rarely or never", "1-2 trips per year", "More than 2 trips per year", "background3.jpg"},
    {"How many days per week do you commute using a personal vehicle?", "0-2 days", "3-4 days", "5 or more days", "background3.jpg"},
    {"How many clothing items do you purchase annually?", "0-5 items", "6-15 items", "16 or more items", "background4.jpg"},
    {"How often do you purchase electronic devices/gadgets?", "Rarely or never", "1-2 times per year", "More than 2 times per year", "background4.jpg"},
    {"What percentage of your household items and furniture is sustainable?", "75% or more", "50-74%", "Less than 50%", "background4.jpg"}
    // Add more questions as needed
  };

  userAnswers = new int[questions.length];
  additionalPoints = new int[]{
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,
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
      displayBackgroundAndQuestion(questions[questionIndex][4], 2000, questions[questionIndex]);
      showingFeedback = false;
    } else {
      if (userAnswers[questionIndex] != 0 && !showingFeedback) {
        feedbackTimer = millis();
        showingFeedback = true;
      }

      if (showingFeedback) {
        // Display feedback for 4 seconds
        displayFeedback(userAnswers[questionIndex], questions[questionIndex]);
        if (millis() > feedbackTimer + 4000) {
          showingFeedback = false;  // Move this line here
          if (questionIndex < questions.length - 1) {
            questionNumber++;
            state = questionNumber * 2 + 2;
            userAnswers[questionNumber - 1] = 0;
          } else {
            state = questions.length * 2 + 2;
          }
        }
      } else {
        // Display question when not showing feedback
        displayQuestion(questions[questionIndex]);
      }
    }
  } else if (state == questions.length * 2 + 2) {
    image(finalVideo, 0, 0, width, height);

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
  fill(114, 116, 68); // Set text color to green
  textSize(36);
  text(question[0], width / 2, height / 2 - 150);

  for (int i = 0; i < 3; i++) {
    fill(114, 116, 68);
    rectMode(CENTER);
    rect((i + 1) * width / 4, height / 2, 300, 80, 10);
    fill(255); // Set text color to white
    textSize(20);
    text((i + 1) + ") " + question[i + 1], (i + 1) * width / 4, height / 2);
  }
}

void displayFeedback(int userChoice, String[] question) {
  if (userChoice >= 1 && userChoice <= 3) {
    background(255); // Set background color to white

    textFont(customFont);
    fill(114, 116, 68); // Set text color to green
    textSize(55);
    textAlign(CENTER, CENTER);

    String feedbackText = "The option you choose: " + userChoice + "\n"; 
    feedbackText += question[userChoice] + ".";
    text(feedbackText, width / 2, height / 2);
  }
}

String getPlanetInfo(int score) {
  textSize(35);
  return "You would need " + getNumPlanets(score) + " planet(s) to sustain your lifestyle.";
}

int getNumPlanets(int score) {
  println("Score " + score);
  if (score >= 10000) {
    return 5;
  } else if (score >= 2500) {
    return 4;
  } else if (score >= 2000) {
    return 3;
  } else if (score >= 1500) {
    return 2;
  } else if (score >= 1000) {
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

    // Calculate the index
    int index = questionNumber * 3 + (answerValue - 1);

    // Ensure the index is within bounds
    if (index >= 0 && index < additionalPoints.length) {
      println("Total Score " + additionalPoints[index]);
      totalScore += additionalPoints[index];
    } else {
      println("Invalid index: " + index);
    }

    // Rest of the code remains unchanged...
    // ... (checking bounds for questionNumber, etc.)
  } else if (key == 'r' || key == 'R') {
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
    state = 2;
  }
}

void objectPlaced(int obj_select) {
  println("HERE" + obj_select);

  if (obj_select >= 1 && obj_select <= 3) {
    int answerValue = obj_select;

    if (questionNumber < questions.length) {
      int index = questionNumber * 3 + (answerValue - 1);
      
      if (index >= 0 && index < additionalPoints.length) {
        totalScore += additionalPoints[index];
        userAnswers[questionNumber] = answerValue;

        // Play the enter sound
        enterSound.rewind();
        enterSound.play();

        feedbackTimer = millis();
        showingFeedback = true;

        // Call displayFeedback when the user answers the question
        displayFeedback(userAnswers[questionNumber], questions[questionNumber]);

        if (questionNumber < questions.length - 1) {
          // Transition to the next question after 4 seconds
          if (millis() > feedbackTimer + 4000) {
            questionNumber++;
            state = questionNumber * 2 + 2;
            userAnswers[questionNumber - 1] = 0;
            showingFeedback = false;
          }
        } else if (questionNumber == questions.length - 1) {
          // Move to the final state if this is the last question
          state = questions.length * 2 + 2;
          if (userAnswers[questionNumber] != 0 && !finalVideo.isPlaying()) {
            finalVideo.loop();
          }
        }
      } else {
        println("Invalid index: " + index);
        println("Question number: " + questionNumber);
        println("Answer value: " + answerValue);
      }
    }
  } else if (key == 'r' || key == 'R') {
    // Reset the quiz if 'R' is pressed
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
    state = 2;  // Move to the second state to start the quiz again
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
