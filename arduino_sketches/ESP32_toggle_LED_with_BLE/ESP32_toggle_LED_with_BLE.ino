#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

#define RED_LED_CHAR_UUID    "ff000000-1234-5678-1234-56789abcdef0"
#define GREEN_LED_CHAR_UUID  "00ff0000-1234-5678-1234-56789abcdef0"
#define YELLOW_LED_CHAR_UUID "ffff0000-1234-5678-1234-56789abcdef0"

// Pins
const int redButtonPin = 4;
const int greenButtonPin = 15;
const int yellowButtonPin = 2;

const int redLedPin = 5;
const int greenLedPin = 18;
const int yellowLedPin = 19;

// State variables
bool redLedState = false;
bool greenLedState = false;
bool yellowLedState = false;

bool redButtonPressed = false;
bool greenButtonPressed = false;
bool yellowButtonPressed = false;

unsigned long lastDebounceTimeRed = 0;
unsigned long lastDebounceTimeGreen = 0;
unsigned long lastDebounceTimeYellow = 0;
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
  pinMode(redButtonPin, INPUT);
  pinMode(greenButtonPin, INPUT);
  pinMode(yellowButtonPin, INPUT);

  pinMode(redLedPin, OUTPUT);
  pinMode(greenLedPin, OUTPUT);
  pinMode(yellowLedPin, OUTPUT);

  digitalWrite(redLedPin, redLedState);
  digitalWrite(greenLedPin, greenLedState);
  digitalWrite(yellowLedPin, yellowLedState);

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
  pAdvertising->start();

  Serial.println("BLE Server started!");
}

void loop() {
  handleButton(redButtonPin, redLedPin, redLedState, redButtonPressed, lastDebounceTimeRed, pRedChar);
  handleButton(greenButtonPin, greenLedPin, greenLedState, greenButtonPressed, lastDebounceTimeGreen, pGreenChar);
  handleButton(yellowButtonPin, yellowLedPin, yellowLedState, yellowButtonPressed, lastDebounceTimeYellow, pYellowChar);
}

void handleButton(int buttonPin, int ledPin, bool &ledState, bool &buttonPressed, unsigned long &lastDebounce, BLECharacteristic* characteristic) {
  int reading = digitalRead(buttonPin);
  if (reading == HIGH && !buttonPressed && (millis() - lastDebounce > debounceDelay)) {
    ledState = !ledState;
    digitalWrite(ledPin, ledState);
    if (deviceConnected && characteristic != nullptr) {
      characteristic->setValue(ledState ? "1" : "0");
      characteristic->notify();
    }
    buttonPressed = true;
    lastDebounce = millis();
  } else if (reading == LOW) {
    buttonPressed = false;
  }
}
