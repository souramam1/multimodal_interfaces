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
    {"How many servings of meat do you consume each week?", "0-3 servings", "4-9 servings", "10 or more servings"},
    {"How much food do you waste on a weekly basis?", "Less than 1 kg", "1-2 kg", "More than 2 kg"},
    {"What percentage of your produce is local and seasonal?", "75% or more", "50-74%", "Less than 50%"},

    // Energy Consumption
    {"How many energy-efficient appliances/light bulbs do you use?", "5 or more", "3-4", "2 or fewer"},
    {"What is your monthly energy consumption?", "Below 300 kWh", "300-600 kWh", "Above 600 kWh"},
    {"How often do you actively monitor your home energy usage?", "Weekly or more", "Monthly", "Rarely or never"},

    // Transportation Footprint
    {"How far do you travel by car or motorcycle each week?", "Less than 50 km", "50-150 km", "More than 150 km"},
    {"How frequently do you travel by air?", "Rarely or never", "1-2 trips per year", "More than 2 trips per year"},
    {"How many days per week do you commute using a personal vehicle?", "0-2 days", "3-4 days", "5 or more days"},

    // Goods and Services Footprint
    {"How many clothing items do you purchase annually?", "0-5 items", "6-15 items", "16 or more items"},
    {"How often do you purchase electronic devices/gadgets?", "Rarely or never", "1-2 times per year", "More than 2 times per year"},
    {"What percentage of your household items and furniture is sustainable?", "75% or more", "50-74%", "Less than 50%"}
  };

  userAnswers = new int[questions.length];
  additionalPoints = new int[]{
    // For Question 1
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,

    // For Question 2
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,

    // For Question 3
    100, 200, 300,
    100, 200, 300,
    100, 200, 300,

    // For Question 4
    100, 200, 300,
    100, 200, 300,
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
