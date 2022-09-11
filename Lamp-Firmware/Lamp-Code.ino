#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#include <Adafruit_NeoPixel.h>

// neopixels
#define PIN       2
#define NUMPIXELS 3
uint8_t R = 0, G = 0, B = 0;

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

// ble constants
#define SERVICE_UUID "d692a318-2485-4317-9cef-794a22ee7a3f"
#define R_UUID       "57393a70-64a7-4d66-9892-9280a6b68bfd"
#define G_UUID       "acde099b-8769-4d12-a924-4aef77cdcb5f"
#define B_UUID       "411c9a4e-69e5-4b95-b3b1-5fae8b071514"

void update_LEDs() {
  pixels.clear();
  
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, pixels.Color(R, G, B));
  }

  pixels.show();
}

class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      Serial.println("Client connected.");
    }

    void onDisconnect(BLEServer* pServer) {
      Serial.println("Client disconnected.");
      BLEDevice::startAdvertising();
    }
};

class R_Charic_Callback: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      R = *(pCharacteristic->getData());
    }
};

class G_Charic_Callback: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      G = *(pCharacteristic->getData());
    }
};

class B_Charic_Callback: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      B = *(pCharacteristic->getData());
      update_LEDs();
    }
};

void setup() {
  Serial.begin(115200);
  
  ledcAttachPin(15, 0);
  ledcSetup(0, 12000, 8);
  ledcWrite(0, 255);
  pixels.begin();

  // i assume these are the pins for the neopixels
  pinMode(15, OUTPUT);
  pinMode(2,  OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);

  BLEDevice::init("ESP32 RGB Lamp");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  
  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *r_charic = pService->createCharacteristic(
    R_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
  );
  BLECharacteristic *g_charic = pService->createCharacteristic(
    G_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
  );
  BLECharacteristic *b_charic = pService->createCharacteristic(
    B_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
  );

  r_charic->setCallbacks(new R_Charic_Callback());
  g_charic->setCallbacks(new G_Charic_Callback());
  b_charic->setCallbacks(new B_Charic_Callback());
  
  r_charic->setValue(&R, 1);
  g_charic->setValue(&G, 1);
  b_charic->setValue(&B, 1);

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void loop() { }
