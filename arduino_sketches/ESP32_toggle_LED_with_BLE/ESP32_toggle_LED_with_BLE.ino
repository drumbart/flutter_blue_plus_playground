// Configuration
#define DEVICE_NAME "ESP32-BLE"
#define SERVICE_UUID BLEUUID((uint16_t)0x180A)

// LED Configuration
#define RED_LED_CHAR_UUID    "ff000000-1234-5678-1234-56789abcdef0"
#define GREEN_LED_CHAR_UUID  "00ff0000-1234-5678-1234-56789abcdef0"
#define YELLOW_LED_CHAR_UUID "ffff0000-1234-5678-1234-56789abcdef0"
#define RGB_LED_CHAR_UUID    "ffffff00-1234-5678-1234-56789abcdef0"

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

// LED State Management
class Led {
protected:
  const int buttonPin;
  const int ledPin;
  bool ledState;
  bool buttonPressed;
  unsigned long lastDebounceTime;
  BLECharacteristic* characteristic;

public:
  Led(int btnPin, int lPin, BLECharacteristic* char_) 
    : buttonPin(btnPin), ledPin(lPin), ledState(false), 
      buttonPressed(false), lastDebounceTime(0), characteristic(char_) {
    pinMode(buttonPin, INPUT);
    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, ledState);
  }

  virtual void update() {
    int reading = digitalRead(buttonPin);
    if (reading == HIGH && !buttonPressed && (millis() - lastDebounceTime > DEBOUNCE_DELAY)) {
      ledState = !ledState;
      digitalWrite(ledPin, ledState);
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

  virtual void setState(bool state) {
    ledState = state;
    digitalWrite(ledPin, ledState);
  }
};

// RGB LED State Management
class RgbLed : public Led {
private:
  const int greenPin;
  const int bluePin;

public:
  RgbLed(int btnPin, int rPin, int gPin, int bPin, BLECharacteristic* char_) 
    : Led(btnPin, rPin, char_), greenPin(gPin), bluePin(bPin) {
    pinMode(greenPin, OUTPUT);
    pinMode(bluePin, OUTPUT);
    setColor(0, 0, 0);
  }

  void update() override {
    int reading = digitalRead(buttonPin);
    if (reading == HIGH && !buttonPressed && (millis() - lastDebounceTime > DEBOUNCE_DELAY)) {
      ledState = !ledState;
      if (ledState) {
        setColor(255, 255, 255); // White when on
      } else {
        setColor(0, 0, 0); // Off
      }
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

  void setState(bool state) override {
    ledState = state;
    if (ledState) {
      setColor(255, 255, 255); // White when on
    } else {
      setColor(0, 0, 0); // Off
    }
  }

  void setColor(int r, int g, int b) {
    digitalWrite(ledPin, r > 0 ? HIGH : LOW);
    digitalWrite(greenPin, g > 0 ? HIGH : LOW);
    digitalWrite(bluePin, b > 0 ? HIGH : LOW);
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
  Led& led;
public:
  LedWriteCallback(Led& ledRef) : led(ledRef) {}
  
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue();
    if (value == "1" || value == "0") {
      led.setState(value == "1");
      Serial.printf("BLE wrote to LED: %s\n", value == "1" ? "ON" : "OFF");
    }
  }
};

// Global variables
Led* redLed;
Led* yellowLed;
Led* greenLed;
Led* rgbLed;
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
  redLed = new Led(redButtonPin, redLedPin, redChar);  
  yellowLed = new Led(yellowButtonPin, yellowLedPin, yellowChar);
  greenLed = new Led(greenButtonPin, greenLedPin, greenChar);
  rgbLed = new RgbLed(rgbButtonPin, rgbrLedPin, rgbgLedPin, rgbbLedPin, rgbChar);

  // Set callbacks
  redChar->setCallbacks(new LedWriteCallback(*redLed));
  yellowChar->setCallbacks(new LedWriteCallback(*yellowLed));
  greenChar->setCallbacks(new LedWriteCallback(*greenLed));
  rgbChar->setCallbacks(new LedWriteCallback(*rgbLed));

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