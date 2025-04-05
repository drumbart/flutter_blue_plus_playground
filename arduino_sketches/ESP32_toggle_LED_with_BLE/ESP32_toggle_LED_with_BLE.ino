// Configuration
#define DEVICE_NAME "ESP32-BLE"
#define SERVICE_UUID BLEUUID((uint16_t)0x180A)

// LED Configuration
#define RED_LED_CHAR_UUID    "ff000000-1234-5678-1234-56789abcdef0"
#define GREEN_LED_CHAR_UUID  "00ff0000-1234-5678-1234-56789abcdef0"
#define YELLOW_LED_CHAR_UUID "ffff0000-1234-5678-1234-56789abcdef0"

// Pin Configuration
const int redButtonPin = 4;
const int greenButtonPin = 15;
const int yellowButtonPin = 2;
const int redLedPin = 5;
const int greenLedPin = 18;
const int yellowLedPin = 19;

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
private:
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

  void update() {
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

  void setState(bool state) {
    ledState = state;
    digitalWrite(ledPin, ledState);
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
Led* greenLed;
Led* yellowLed;
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
  
  auto greenChar = pService->createCharacteristic(
    GREEN_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  greenChar->addDescriptor(new BLE2902());
  
  auto yellowChar = pService->createCharacteristic(
    YELLOW_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  yellowChar->addDescriptor(new BLE2902());

  // Initialize LED objects
  redLed = new Led(redButtonPin, redLedPin, redChar);
  greenLed = new Led(greenButtonPin, greenLedPin, greenChar);
  yellowLed = new Led(yellowButtonPin, yellowLedPin, yellowChar);

  // Set callbacks
  redChar->setCallbacks(new LedWriteCallback(*redLed));
  greenChar->setCallbacks(new LedWriteCallback(*greenLed));
  yellowChar->setCallbacks(new LedWriteCallback(*yellowLed));

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
  if (greenLed) greenLed->update();
  if (yellowLed) yellowLed->update();
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
}