#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"  // Custom Service UUID
#define CHARACTERISTIC_UUID "abcdef01-1234-5678-1234-56789abcdef0"  // Custom Characteristic UUID

// Pins
const int buttonPin = 4;
const int ledPin = 5;

// State variables
bool ledState = false;
bool lastButtonState = LOW;
bool buttonPressed = false;

unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

// BLE
BLECharacteristic *pCharacteristic;
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

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    if (value.length() > 0) {
      if (value == "1" || value == "0") {
        ledState = (value == "1");
        digitalWrite(ledPin, ledState);
        Serial.print("BLE wrote LED state: ");
        Serial.println(ledState ? "ON" : "OFF");
      }
    }
  }
};

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, ledState);

  // BLE setup
  BLEDevice::init("ESP32-BLE");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_WRITE
                    );
  pCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
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
      ledState = !ledState;
      digitalWrite(ledPin, ledState);
      Serial.print("Button pressed. LED toggled to: ");
      Serial.println(ledState ? "ON" : "OFF");

      buttonPressed = true;

      // Optional: send new LED state to BLE client (only works if client is subscribed & read enabled)
      // pCharacteristic->setValue(ledState ? "1" : "0");
      // pCharacteristic->notify();
    } else if (reading == LOW) {
      buttonPressed = false;
    }
  }

  lastButtonState = reading;
}