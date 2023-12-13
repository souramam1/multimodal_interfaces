PImage backgroundImage; // Declare a PImage variable for the background image
PImage planetImage; // Declare a PImage variable for the planet image
int questionNumber = 0; // Variable to keep track of the current question
int totalScore = 0; // Variable to keep track of the user's total score
int[] userAnswers; // Array to store user's answers for each question
String[][] questions; // 2D array to store questions and options
int[] additionalPoints; // Array to store additional points for each option within a question

//////////////////////Added for serial connection //////////////////////////
import processing.serial.*;
Serial arduinoPort;
int receivedList = 32;
int obj_select = 32;

void setup() {
  printArray(Serial.list());
  arduinoPort = new Serial(this, Serial.list()[0], 9600);
  size(800, 600);
  textAlign(CENTER, CENTER);

  // Load the background image
  backgroundImage = loadImage("background.jpg"); // Replace "background.jpg" with your image file

  // Load the planet image
  planetImage = loadImage("planet.jpg"); // Replace "planet.jpg" with your image file

  // Initialize the questions, options, and additional points
  questions = new String[][] {
    {"How often do you eat animal-based products?", "Never", "Occasionally", "Often"},
    {"How much of the food you eat is unprocessed, unpackaged, or locally grown?", "Never", "Occasionally", "Often"},
    {"How many people live in your household?", "Only me", "Me + partner", "2+"},
    {"How far do you travel by car or motorcycle each week?", "None", "<100km", ">100km"}
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
}

void draw() {
  
  if (0 < arduinoPort.available()) {         // If data is available,
     obj_select = arduinoPort.read();  // read it and store it in val
    print(obj_select);
    objectPlaced(obj_select);
    
  }
  // Draw the background image
  if (backgroundImage != null && questionNumber != questions.length) {
    image(backgroundImage, 0, 0, width, height);
  } else {
    background(0); // Black background color on the last screen
  }

  fill(255); // Set text color to white

  // Display different questions based on the questionNumber
  if (questionNumber < questions.length) {
    displayQuestion(questions[questionNumber]);
  } else {
    displayFinalScreen();
  }
}

void displayQuestion(String[] question) {
  // Question
  fill(80, 120, 200, 180);
  rect(50, 50, width - 100, 100);
  fill(255);
  text(question[0], width / 2, 90);

  // Options
  for (int i = 0; i < 3; i++) {
    fill(120, 180, 255, 180);
    rect(100 + i * 200, 200, 150, 60);
    fill(255);
    text((i + 1) + ") " + question[i + 1], 175 + i * 200, 230);
  }
}

void displayFinalScreen() {
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
}

void keyPressed() {
  // Check the user's answer when the Enter key is pressed
  if (keyCode == ENTER) {
    int answerValue = userAnswers[questionNumber];
    print(answerValue);


    // Validate the user's answer and update the total score
    if (answerValue >= 1 && answerValue <= 3) {
      println("Total Score " + additionalPoints[questionNumber * 3 + (answerValue - 1)]);
      totalScore += additionalPoints[questionNumber * 3 + (answerValue - 1)];
    }

    // Move to the next question only if the user has entered an answer
    if (questionNumber < questions.length - 1 && answerValue != 0) {
      questionNumber++;
      // Clear the user's answer for the current question
      userAnswers[questionNumber - 1] = 0;
    } else if (questionNumber == questions.length - 1 && answerValue != 0) {
      // For the last question, move to the final screen
      questionNumber++;
    }
  } else if (keyCode == '1' || keyCode == '2' || keyCode == '3') {
    // Store the user's answer for the current question
    userAnswers[questionNumber] = keyCode - '0';
  } else if (key == 'r' || key == 'R') {
    // Set to the first question and reset total score and user answers
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
  }
}


void objectPlaced(int obj_select) {
  // Check the user's answer when the Enter key is pressed
  print("HERE");
  print(obj_select);
  if (obj_select != 0) {
    println("Here 2");
    //int answerValue = userAnswers[questionNumber];
    int answerValue = obj_select;
    println(answerValue);

    // Validate the user's answer and update the total score
    if (answerValue >= 1 && answerValue <= 3) {
      println("Total Score " + additionalPoints[questionNumber * 3 + (answerValue - 1)]);
      totalScore += additionalPoints[questionNumber * 3 + (answerValue - 1)];
    }

    // Move to the next question only if the user has entered an answer
    if (questionNumber < questions.length - 1 && answerValue != 0) {
      questionNumber++;
      // Clear the user's answer for the current question
      userAnswers[questionNumber - 1] = 0;
    } else if (questionNumber == questions.length - 1 && answerValue != 0) {
      // For the last question, move to the final screen
      questionNumber++;
    }
  } else if (obj_select == 1 || obj_select == 2 || obj_select == 3) {
    // Store the user's answer for the current question
    userAnswers[questionNumber] = obj_select - 0;
  } else if (key == 'r' || key == 'R') {
    // Set to the first question and reset total score and user answers
    questionNumber = 0;
    totalScore = 0;
    userAnswers = new int[questions.length];
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
