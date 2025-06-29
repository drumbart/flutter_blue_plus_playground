// Configuration
#define DEVICE_NAME "ESP32-BLE"
#define SERVICE_UUID BLEUUID((uint16_t)0x180A)

// LED Configuration
#define RED_LED_CHAR_UUID    "ff000000-1234-5678-1234-56789abcdef0"
#define GREEN_LED_CHAR_UUID  "00ff0000-1234-5678-1234-56789abcdef0"
#define YELLOW_LED_CHAR_UUID "ffff0000-1234-5678-1234-56789abcdef0"
#define RGB_LED_CHAR_UUID    "ffffffff-1234-5678-1234-56789abcdef0"

// Pin Configuration
const int redButtonPin = 4;
const int redLedPin = 5;

const int yellowButtonPin = 15;
const int yellowLedPin = 18;

const int greenButtonPin = 2;
const int greenLedPin = 19;

const int rgbButtonPin = 13;
const int rgbrLedPin = 21;
const int rgbgLedPin = 22;
const int rgbbLedPin = 23;

// Debounce Configuration
const unsigned long DEBOUNCE_DELAY = 50;

// Global variables
bool deviceConnected = false;

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// Base LED State Management
class RgbLed {
protected:
  const int buttonPin;
  bool ledState;
  bool buttonPressed;
  unsigned long lastDebounceTime;
  BLECharacteristic* characteristic;

public:
  RgbLed(int btnPin, BLECharacteristic* char_) 
    : buttonPin(btnPin), ledState(false), 
      buttonPressed(false), lastDebounceTime(0), characteristic(char_) {
    pinMode(buttonPin, INPUT);
  }

  virtual void update() {
    int reading = digitalRead(buttonPin);
    if (reading == HIGH && !buttonPressed && (millis() - lastDebounceTime > DEBOUNCE_DELAY)) {
      ledState = !ledState;
      setState(ledState);
      if (deviceConnected && characteristic != nullptr) {
        characteristic->setValue(ledState ? "1" : "0");
        characteristic->notify();
      }
      buttonPressed = true;
      lastDebounceTime = millis();
    } else if (reading == LOW) {
      buttonPressed = false;
    }
  }

  virtual void setState(bool state) = 0;  // Pure virtual function
};

// Single Color LED Base Class
class SingleColorLed : public RgbLed {
protected:
  const int ledPin;

public:
  SingleColorLed(int btnPin, int lPin, BLECharacteristic* char_) 
    : RgbLed(btnPin, char_), ledPin(lPin) {
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, LOW);
  }

  void setState(bool state) override {
    digitalWrite(ledPin, state ? HIGH : LOW);
  }
};

// Red LED
class RedLed : public SingleColorLed {
public:
  RedLed(int btnPin, int lPin, BLECharacteristic* char_) 
    : SingleColorLed(btnPin, lPin, char_) {}
};

// Green LED
class GreenLed : public SingleColorLed {
public:
  GreenLed(int btnPin, int lPin, BLECharacteristic* char_) 
    : SingleColorLed(btnPin, lPin, char_) {}
};

// Yellow LED
class YellowLed : public SingleColorLed {
public:
  YellowLed(int btnPin, int lPin, BLECharacteristic* char_) 
    : SingleColorLed(btnPin, lPin, char_) {}
};

// RGB LED
class RgbFullLed : public RgbLed {
private:
  const int redPin;
  const int greenPin;
  const int bluePin;
  uint8_t redValue = 255;
  uint8_t greenValue = 255;
  uint8_t blueValue = 255;
  const uint8_t RGB_THRESHOLD = 127;

public:
  RgbFullLed(int btnPin, int rPin, int gPin, int bPin, BLECharacteristic* char_) 
    : RgbLed(btnPin, char_), redPin(rPin), greenPin(gPin), bluePin(bPin) {
    // Configure pins for digital output
    pinMode(redPin, OUTPUT);
    pinMode(greenPin, OUTPUT);
    pinMode(bluePin, OUTPUT);
    
    setState(false);
  }

  void setState(bool state) override {
    ledState = state;  // Update the ledState variable
    Serial.printf("RgbFullLed setState called with state: %s\n", state ? "ON" : "OFF");
    
    if (state) {
      // Use digital output to set the RGB values
      // For digital output, we'll use a threshold to determine if a color component is on or off
      bool redOn = redValue > RGB_THRESHOLD;
      bool greenOn = greenValue > RGB_THRESHOLD;
      bool blueOn = blueValue > RGB_THRESHOLD;
      
      digitalWrite(redPin, redOn ? HIGH : LOW);
      digitalWrite(greenPin, greenOn ? HIGH : LOW);
      digitalWrite(bluePin, blueOn ? HIGH : LOW);
      
      Serial.printf("RGB LED turned ON with values: R=%s, G=%s, B=%s\n", 
                   redOn ? "HIGH" : "LOW",
                   greenOn ? "HIGH" : "LOW",
                   blueOn ? "HIGH" : "LOW");
    } else {
      // Turn off all LEDs
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, LOW);
      digitalWrite(bluePin, LOW);
      Serial.println("RGB LED turned OFF");
    }
  }
  
  // Set RGB color values
  void setColor(uint8_t red, uint8_t green, uint8_t blue) {
    Serial.printf("setColor called with: R=%d, G=%d, B=%d\n", red, green, blue);
    
    redValue = red;
    greenValue = green;
    blueValue = blue;
    
    // If LED is on, update the color immediately
    if (ledState) {
      Serial.println("LED is ON, applying color immediately");
      // For digital output, we'll use a threshold to determine if a color component is on or off
      digitalWrite(redPin, redValue > 127 ? HIGH : LOW);
      digitalWrite(greenPin, greenValue > 127 ? HIGH : LOW);
      digitalWrite(bluePin, blueValue > 127 ? HIGH : LOW);
      Serial.printf("Applied digital values: R=%s, G=%s, B=%s\n", 
                   redValue > 127 ? "HIGH" : "LOW",
                   greenValue > 127 ? "HIGH" : "LOW",
                   blueValue > 127 ? "HIGH" : "LOW");
    } else {
      Serial.println("LED is OFF, color will be applied when turned on");
    }
    
    Serial.printf("RGB LED color set to: R=%d, G=%d, B=%d\n", red, green, blue);
  }
};

// BLE Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("BLE client connected");
  }
  
  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    BLEDevice::startAdvertising();
    Serial.println("BLE client disconnected");
  }
};

class LedWriteCallback : public BLECharacteristicCallbacks {
  RgbLed& led;
  bool isRgbLed;
public:
  LedWriteCallback(RgbLed& ledRef, bool isRgb = false) 
    : led(ledRef), isRgbLed(isRgb) {}
  
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue();
    Serial.printf("Received BLE write: %s, length: %d\n", value.c_str(), value.length());
    
    // Check if this is an RGB LED
    if (isRgbLed) {
      Serial.println("Processing RGB LED data");
      // Handle RGB LED data
      if (value.length() >= 4) {
        // Get the raw data from the String
        uint8_t data[4];
        for (int i = 0; i < 4; i++) {
          data[i] = (uint8_t)value[i];
        }
        
        Serial.printf("RGB data: [%d, %d, %d, %d]\n", data[0], data[1], data[2], data[3]);
        
        // First byte is the command (1 for color update, 0 for off)
        if (data[0] == 1) {
          // Next 3 bytes are RGB values
          RgbFullLed* rgbLed = (RgbFullLed*)&led;
          rgbLed->setColor(data[1], data[2], data[3]);
          led.setState(true);
          Serial.printf("RGB LED color update: R=%d, G=%d, B=%d\n", data[1], data[2], data[3]);
        } else if (data[0] == 0) {
          // Turn off the LED
          led.setState(false);
          Serial.println("RGB LED turned OFF");
        }
      } else if (value == "1" || value == "0") {
        // Handle simple toggle for RGB LED
        bool newState = (value == "1");
        led.setState(newState);
        Serial.printf("RGB LED %s\n", newState ? "ON" : "OFF");
      } else {
        Serial.printf("Unexpected RGB LED data format: %s\n", value.c_str());
      }
    } else {
      // Handle standard LED (on/off only)
      if (value == "1" || value == "0") {
        bool newState = (value == "1");
        led.setState(newState);
        Serial.printf("Standard LED %s\n", newState ? "ON" : "OFF");
      } else {
        Serial.printf("Unexpected standard LED data format: %s\n", value.c_str());
      }
    }
  }
};

// Global variables
RgbLed* redLed;
RgbLed* yellowLed;
RgbLed* greenLed;
RgbLed* rgbLed;
BLEServer* pServer = nullptr;
BLEService* pService = nullptr;

void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE LED Control...");

  // Initialize BLE
  BLEDevice::init(DEVICE_NAME);
  pServer = BLEDevice::createServer();
  if (!pServer) {
    Serial.println("Failed to create BLE server!");
    return;
  }
  
  pServer->setCallbacks(new MyServerCallbacks());
  pService = pServer->createService(SERVICE_UUID);
  if (!pService) {
    Serial.println("Failed to create BLE service!");
    return;
  }

  // Create characteristics
  auto redChar = pService->createCharacteristic(
    RED_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  redChar->addDescriptor(new BLE2902());

  auto yellowChar = pService->createCharacteristic(
    YELLOW_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  yellowChar->addDescriptor(new BLE2902());
  
  auto greenChar = pService->createCharacteristic(
    GREEN_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  greenChar->addDescriptor(new BLE2902());

  auto rgbChar = pService->createCharacteristic(
    RGB_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  rgbChar->addDescriptor(new BLE2902());

  // Initialize LED objects
  redLed = new RedLed(redButtonPin, redLedPin, redChar);  
  yellowLed = new YellowLed(yellowButtonPin, yellowLedPin, yellowChar);
  greenLed = new GreenLed(greenButtonPin, greenLedPin, greenChar);
  rgbLed = new RgbFullLed(rgbButtonPin, rgbrLedPin, rgbgLedPin, rgbbLedPin, rgbChar);

  // Set callbacks
  redChar->setCallbacks(new LedWriteCallback(*redLed));
  yellowChar->setCallbacks(new LedWriteCallback(*yellowLed));
  greenChar->setCallbacks(new LedWriteCallback(*greenLed));
  rgbChar->setCallbacks(new LedWriteCallback(*rgbLed, true));

  // Start service and advertising
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(pService->getUUID());
  pAdvertising->setScanResponse(true);
  pAdvertising->start();

  Serial.println("BLE Server started successfully!");
}

void loop() {
  if (redLed) redLed->update();
  if (yellowLed) yellowLed->update();
  if (greenLed) greenLed->update();
  if (rgbLed) rgbLed->update();
}

// Cleanup on reset
void cleanup() {
  if (pService) {
    pService->stop();
  }
  if (pServer) {
    BLEDevice::stopAdvertising();
  }
  BLEDevice::deinit(true);
  
  delete redLed;
  delete greenLed;
  delete yellowLed;
  delete rgbLed;
}