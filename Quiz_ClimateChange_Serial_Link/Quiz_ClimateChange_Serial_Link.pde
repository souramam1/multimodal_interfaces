import processing.video.*;

// KATY
import ddf.minim.*;
Minim minim;
AudioSnippet enterSound;  // Use AudioSnippet for additional sounds
AudioPlayer backgroundMusic;
// Katy

PImage planetImage; // Declare a PImage variable for the planet image
int questionNumber = 0; // Variable to keep track of the current question
int totalScore = 0; // Variable to keep track of the user's total score
int[] userAnswers; // Array to store user's answers for each question
String[][] questions; // 2D array to store questions, options, and background image file names
int[] additionalPoints; // Array to store additional points for each option within a question
int state = 0; // Variable to keep track of the current state
int timer = 0; // Timer variable to control duration
int feedbackTimer = 0; // Timer variable for feedback duration
boolean showingFeedback = false; // Flag to indicate whether feedback is being shown
PFont customFont;
boolean enterKeyPressed = false; // Declare the enterKeyPressed variable


Movie finalVideo;

void setup() {
  size(1400, 800);
  textAlign(CENTER, CENTER);
  customFont = createFont("font.otf", 12);  // Replace "YourFont.ttf" with the actual font file
  textFont(customFont);
  planetImage = loadImage("planet.jpg"); // Replace "planet.jpg" with your image file

  // Initialize the questions, options, and background image file names
  questions = new String[][] {
    {"How often do you eat animal-based products?", "Never", "Occasionally", "Often", "background1.jpg"},
    {"How much of the food you eat is unprocessed, unpackaged, or locally grown?", "Never", "Occasionally", "Often", "background2.jpg"},
    {"How many people live in your household?", "Only me", "Me + partner", "2+", "background3.jpg"},
    {"How far do you travel by car or motorcycle each week?", "None", "<100km", ">100km", "background4.jpg"}
    // Add more questions as needed
  };
  userAnswers = new int[questions.length];
  additionalPoints = new int[]{
    // For Question 1
    100, 200, 300,

    // For Question 2
    100, 200, 300,

    // For Question 3
    100, 200, 300,

    // For Question 4
    100, 200, 300
    // Add more points as needed
  };

  // Set the initial state and timer
  state = 0;
  timer = millis() + 10000; // Start the timer with a delay of 10 seconds for each background image

  // Load the video
  finalVideo = new Movie(this, "/Users/idacarlsson/Desktop/multimodal_interfaces-main/Quiz_ClimateChange_Serial_Link/FinalVideo.mp4"); // Replace with your video file
  
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("background-runamok.wav");
  backgroundMusic.loop();  // Loop the background music

  // Load the enter sound
  enterSound = minim.loadSnippet("enter.wav");
}

void draw() {
  if (state == 0 && millis() > timer) {
    // Display the initial background for 10 seconds
    displayBackground("initialBackground.jpg", 10000);
  } else if (state == 1 && millis() > timer) {
    // Display the second background for 10 seconds
    displayBackground("secondBackground.jpg", 10000);
  } else if (state >= 2 && state < questions.length * 2 + 2) {
    // Handle user input for the current question
    int questionIndex = (state - 2) / 2;
    if ((state - 2) % 2 == 0) {
      // Display the background and question for the current question
      displayBackgroundAndQuestion(questions[questionIndex][4], 20000, questions[questionIndex]);
      showingFeedback = false; // Reset showingFeedback for the new question
    } else {
      // Display feedback if the user has chosen an option
      if (userAnswers[questionIndex] != 0 && !showingFeedback) {
        feedbackTimer = millis();
        showingFeedback = true;
      }

      if (showingFeedback && millis() < feedbackTimer + 3000) {
        displayFeedback(userAnswers[questionIndex], questions[questionIndex]);
      } else {
        // Check if there are more questions
        if (questionIndex < questions.length - 1) {
          // Move to the next question and its background
          questionNumber++;
          state = questionNumber * 2 + 2;
          // Clear the user's answer for the current question
          userAnswers[questionNumber - 1] = 0;
          showingFeedback = false; // Reset showingFeedback for the new question
        } else {
          // If no more questions, move to the final screen
          state = questions.length * 2 + 2;
        }
      }
    }
  } else if (state == questions.length * 2 + 2) {
    // Play video as the background
    image(finalVideo, 0, 0, width, height);
    // Draw the planet image(s) based on the number of planets required
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

    // Check if the user has chosen an option for the last question and the video is not already playing
    if (userAnswers[questions.length - 1] != 0 && !finalVideo.isPlaying()) {
      finalVideo.loop(); // Start playing the video
    }
  }
}


void displayBackground(String background, int duration) {
  // Draw the background image
  PImage currentBackgroundImage = loadImage(background);
  image(currentBackgroundImage, 0, 0, width, height);

  // Increment the state after a specified duration
  if (millis() > timer + duration) {
    state++;
    timer = millis();
  }
}

void displayBackgroundAndQuestion(String background, int duration, String[] question) {
  // Draw the background image
  PImage currentBackgroundImage = loadImage(background);
  image(currentBackgroundImage, 0, 0, width, height);

  // Increment the state after a specified duration
  if (millis() > timer + duration) {
    state++;
    timer = millis();
  }

  // Display the question and options
  displayQuestion(question);
}

void displayQuestion(String[] question) {
  // Question
  fill(0, 0, 0); // Text color black
  textSize(36); // Increase text size
  text(question[0], width / 2, height / 2 - 150); // Move the question higher

  // Options
  for (int i = 0; i < 3; i++) {
    fill(114, 116, 68); // #727444
    rectMode(CENTER);
    rect((i + 1) * width / 4, height / 2, 300, 80, 10); // Increase the size of the options box
    fill(238, 230, 119); // #EEE677
    textSize(20);
    text((i + 1) + ") " + question[i + 1], (i + 1) * width / 4, height / 2);
  }
}


void displayFeedback(int userChoice, String[] question) {
  if (userChoice >= 1 && userChoice <= 3) {
    // Set background color
    background(color(114, 116, 68)); // RGB values for #727444
    
    textFont(customFont);

    // Display feedback text
    fill(238, 230, 119);
    textSize(55); // Increase text size
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
    
    // Play the enter sound
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
      state = questionNumber * 2 + 2; // Move to the next question and its background
      userAnswers[questionNumber - 1] = 0;
      showingFeedback = false; // Reset showingFeedback for the new question
    } else if (questionNumber == questions.length - 1 && answerValue != 0) {
      questionNumber++;
      state = questions.length * 2 + 2; // Skip to the final screen

      // Validate the user's answer and update the total score
      if (answerValue >= 1 && answerValue <= 3) {
        totalScore += additionalPoints[questionNumber * 3 + (answerValue - 1)];
      }

      // Check if the user has chosen an option for the last question and the video is not already playing
      if (userAnswers[questionNumber - 1] != 0 && !finalVideo.isPlaying()) {
        finalVideo.loop(); // Start playing the video
      }
    }
  } else if (keyCode == '1' || keyCode == '2' || keyCode == '3') {
    // Store the user's answer for the current question
    userAnswers[questionNumber] = keyCode - '0';

    // Move to the next state to display the next question and background
    state++;
  } else if (key == 'r' || key == 'R') {
    // Set to the first question and reset total score and user answers
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
    state = 2; // Skip the initial and second background display
  }
}

void stop() {
  // Close both the player and the snippet
  enterSound.close();
  backgroundMusic.close();
  minim.stop();
  super.stop();
}

void movieEvent(Movie m) {
  m.read();
}
