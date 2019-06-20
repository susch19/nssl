
#include <FAB_LED.h>
#include <HID.h>

// Declare the LED protocol and the port
sk6812<D, 0>  strip;

// How many pixels to control
const int numPixels = 100;

// How bright the LEDs will be (max 255)
const uint8_t maxBrightness = 255;

// The pixel array to display
rgbw  pixels[numPixels] = {};


void setup()
{
	strip.clear(1000);
    Serial.begin(256000);
}

void loop()
{
	if(Serial.available()){
        int count = Serial.read() * 5;
        
        if(count != 0)
        {
            Serial.print("ACK");

            byte receiveChars[count];
            Serial.readBytes(receiveChars , count);

            Serial.print("ACK");
            for (int i = 0; i < count; i++)
            {
                int pos = receiveChars[i++];
                pixels[pos].g = receiveChars[i++];
                pixels[pos].r = receiveChars[i++];
                pixels[pos].b = receiveChars[i++];
                pixels[pos].w = receiveChars[i];
            }

	        strip.sendPixels(numPixels, pixels);
        }
    }
}

/*
elements.append(pos)
    elements.append(int(r * (maxBrightness / 255.0)))
    elements.append(int(g * (maxBrightness / 255.0)))
    elements.append(int(b * (maxBrightness / 255.0)))
    elements.append(int(w * (maxBrightness / 255.0)))


def writeSerial(data, recursiv = False):
    global ser, isWriting
    if isWriting == True and recursiv == False:
        return False
    isWriting = True
    ser.write([int(len(data))/5])
    k = ser.read(3)
    if k == "ACK":
        ser.write(data)
        k == ser.read(3)
        if k == "ERR":
            writeSerial(data, True)
        isWriting = False
        return True
    isWriting = False
    return False
    */