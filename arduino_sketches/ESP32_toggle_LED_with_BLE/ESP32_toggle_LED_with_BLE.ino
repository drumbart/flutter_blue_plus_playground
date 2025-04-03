#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

#define RED_LED_CHAR_UUID    "ff000000-1234-5678-1234-56789abcdef0"
#define GREEN_LED_CHAR_UUID  "00ff0000-1234-5678-1234-56789abcdef0"
#define YELLOW_LED_CHAR_UUID "ffff0000-1234-5678-1234-56789abcdef0"

// Pins
const int buttonPin = 4;
const int redLedPin = 5;
const int greenLedPin = 18;
const int yellowLedPin = 19;

// State variables
bool redLedState = false;
bool greenLedState = false;
bool yellowLedState = false;

bool lastButtonState = LOW;
bool buttonPressed = false;

unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

// BLE
BLECharacteristic *pRedChar;
BLECharacteristic* pGreenChar;
BLECharacteristic* pYellowChar;

bool deviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("BLE client connected");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    BLEDevice::startAdvertising();
    Serial.println("BLE client disconnected");
  }
};

class LedWriteCallback : public BLECharacteristicCallbacks {
  int pin;
public:
  LedWriteCallback(int assignedPin) : pin(assignedPin) {}

  void onWrite(BLECharacteristic *pCharacteristic) override {
    String value = pCharacteristic->getValue();
    if (value == "1" || value == "0") {
      bool state = (value == "1");
      digitalWrite(pin, state);
      Serial.printf("BLE wrote to pin %d: %s\n", pin, state ? "ON" : "OFF");
    }
  }
};

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT);
  pinMode(redLedPin, OUTPUT);
  digitalWrite(redLedPin, redLedState);

  // BLE setup
  BLEDevice::init("ESP32-BLE");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEUUID serviceUUID = BLEUUID((uint16_t)0x180A);

  BLEService *pService = pServer->createService(serviceUUID);
  pRedChar = pService->createCharacteristic(
    RED_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  pRedChar->addDescriptor(new BLE2902());

  pGreenChar = pService->createCharacteristic(
    GREEN_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  pGreenChar->addDescriptor(new BLE2902());

  pYellowChar = pService->createCharacteristic(
    YELLOW_LED_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  pYellowChar->addDescriptor(new BLE2902());
  
  pRedChar->setCallbacks(new LedWriteCallback(redLedPin));
  pGreenChar->setCallbacks(new LedWriteCallback(greenLedPin));
  pYellowChar->setCallbacks(new LedWriteCallback(yellowLedPin));

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(serviceUUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Helps with connection stability
  BLEDevice::startAdvertising();

  Serial.println("BLE Server started!");
}

void loop() {
  int reading = digitalRead(buttonPin);

  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading == HIGH && !buttonPressed) {
      redLedState = !redLedState;
      digitalWrite(redLedPin, redLedState);
      Serial.print("Button pressed. LED toggled to: ");
      Serial.println(redLedState ? "ON" : "OFF");

      buttonPressed = true;

      pRedChar->setValue(redLedState ? "1" : "0");
      pRedChar->notify();
    } else if (reading == LOW) {
      buttonPressed = false;
    }
  }

  lastButtonState = reading;
}