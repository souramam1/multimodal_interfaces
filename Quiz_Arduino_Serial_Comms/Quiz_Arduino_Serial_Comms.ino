const int analogPin0 = A0; // Define the analog pin
const int analogPin1 = A1; // Define the analog pin
const int analogPin2 = A2; // Define the analog pin
const int analogPin3 = A3; // Define the analog pin

const int threshold_high = 800; // Upper threshold for rising values
const int threshold_low = 600;  // Lower threshold for falling values

const int buffer_size = 10; // Number of readings to consider for change detection


int prev_sensed_list[4] = {0}; // Array to hold previous sensed values
int sensor_buffer[4][buffer_size] = {0}; // Buffer to store previous readings
int obj_select = 9;

void setup() {
  Serial.begin(9600); // Initialize serial communication for debugging
}

void loop() {
  int sensorValue0 = analogRead(analogPin0); // Read the analog value from A0
  int sensorValue1 = analogRead(analogPin1); // Read the analog value from A1
  int sensorValue2 = analogRead(analogPin2); // Read the analog value from A2
  int sensorValue3 = analogRead(analogPin3); // Read the analog value from A3
  int sensor_reading_list[4] = {sensorValue0, sensorValue1, sensorValue2, sensorValue3};
  int sensed_list[4] = {0}; // Initialize sensed_list with 0 values

  // Shift readings in the buffer
  for (int i = 0; i < 4; i++) {
    for (int j = buffer_size - 1; j > 0; j--) {
      sensor_buffer[i][j] = sensor_buffer[i][j - 1];
    }
    sensor_buffer[i][0] = sensor_reading_list[i]; // Add latest reading to the buffer
  }

  for (int i = 0; i < 4; i++) {
    if (setThreshold(sensor_buffer[i], sensed_list[i], prev_sensed_list[i]) == 4){
      //Serial.println("WRITING TO SERIAL PORT HIGH");
      int on = i;
      //Serial.println(on);
      if(on != 0){
        obj_select = on;
      }
      else{
        if(obj_select != 9){
          //Serial.print("Sending the number : ");
          //Serial.println(obj_select);
          Serial.write(obj_select);
        }
        else{
          //Serial.println("Will not send since object removed");
        }

      }
      
    } // Pass sensor buffer to check for change
    else if(setThreshold(sensor_buffer[i], sensed_list[i], prev_sensed_list[i]) == 3){
      //Serial.println("WRITING TO SERIAL PORT LOW");
      int off = i + 4;
      //Serial.println(off);
      if(off-obj_select == 4){
        obj_select = 9;
        //Serial.print("THE VALUE OF on has been set to: ");
        //Serial.println(obj_select);
      }
      
      

      
    }
    else{
      //do nothing
    }
  }

  for (int i = 0; i < 4; i++) {
    //Serial.println(sensed_list[i]); // Print updated sensed_list values
  }



  delay(20); // Add a delay to make the output readable (adjust as needed)

  // Update previous sensed_list values
  for (int i = 0; i < 4; i++) {
    prev_sensed_list[i] = sensed_list[i];
  }
}

int setThreshold(int sensor_buffer[], int &sense_num, int &prev_value) {
  int consecutive_threshold = buffer_size - 2; // Number of consecutive readings needed for change detection
  int count_state = 0;

  for (int i = 0; i < buffer_size; i++) {
    if (sensor_buffer[i] > threshold_high) {
      count_state++;
    } else {
      count_state = 0;
    }

    if (count_state >= consecutive_threshold) {
      sense_num = 1; // Set sense_num to 1 if the desired state is achieved
      break;
    }
  }

  // Check if the current value is different from the previous value
  if (sense_num != prev_value) {
    // Perform action or set an output when the values change
    if (sense_num == 1) {
      //Serial.println("Sense change high");
      return 4;
    }
    else{
      //Serial.println("Sense change low");
      return 3;
    }
  } else {
    // No change in value
    // Perform other actions if needed when the values remain the same
    
  }
}

