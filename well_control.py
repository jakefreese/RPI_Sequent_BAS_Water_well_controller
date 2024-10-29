import asyncio
import megabas as m
import time
import sys
from Adafruit_IO import MQTTClient

ADAFRUIT_IO_KEY = 'my adafruit key'
ADAFRUIT_IO_USERNAME = 'my username'

# Define callback functions which will be called when certain events happen.
def connected(client):
    # Connected function will be called when the client is connected to Adafruit IO.
    # This is a good place to subscribe to feed changes.  The client parameter
    # passed to this function is the Adafruit IO MQTT client so you can make
    # calls against it easily.
    print('Connected to Adafruit IO!  Listening for changes...')
    # Subscribe to changes on a feed named DemoFeed.
    client.subscribe('my username')

def disconnected(client):
    # Disconnected function will be called when the client disconnects.
    print('Disconnected from Adafruit IO!')
    sys.exit(1)

def message(client, feed_id, payload):
    # Message function will be called when a subscribed feed has a new value.
    # The feed_id parameter identifies the feed, and the payload parameter has
    # the new value.
    print('Feed {0} received new value: {1}'.format(feed_id, payload))

# Setup the callback functions defined above.

client = MQTTClient(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

client.on_connect    = connected
client.on_disconnect = disconnected
client.on_message    = message

# Connect to the Adafruit IO server.
client.connect()

def setTriac(output, relay, state):
    # Placeholder function to control the triac output
    print(f"Setting Triac: output={output}, relay={relay}, state={state}")

# timer durations
Pump_Low_I_time = int(30) # 30 Seconds
Dry_Well_Time = int(900)  # 900 Seconds 15min
Input_Read_time = int(1)  # 1 Second
print_variables_time = int(5)  # 5 Seconds

# Set the BAS inputs and outputs
Well_Run_output = m.setTriac(1,1,0)            # BAS Traic 1
Dry_Well_Lamp = m.setTriac(1,2,0)     # BAS Triac 2
Pressure_switch = m.getContactCh(1,1)  # BAS DI 1
Pump_I = m.getUIn(1,2)          # BAS AI 2 
#RUN = m.getContactCh(1,3) #BAS DI 3

class WellController:
    def __init__(self):
        self.Pump_Low_I = 0          # Initialize Pump_Low_I
        self.Dry_Well = 0            # Initialize Dry_Well as an integer
        self.Pump_Min_I = 8.0        # Initialize Pump_Min_I 8.0 Amps minimum current
        self.Well_Run = 0            # Initialize Well_Run
        self.RUN = 1                 # Initialize RUN

    async def run(self):
        while self.RUN == 1:
            # RUN input allows the enables the controller to run
            Pressure_switch = m.getContactCh(1,1)  # Read from BAS DI 1
            Pump_I = m.getUIn(1,2)            # Read from BAS AI 2
            time.sleep(0.5)
            
            #If Pressure Switch is on and Dry Well is off, turn on the Well
            if Pressure_switch == 1 and self.Dry_Well == 0:
                self.Well_Run = 1
                m.setTriac(1,1,1)
                print("WELL RUN", self.Well_Run)
            else:
                self.Well_Run = 0
                m.setTriac(1,1,0)
                print("WELL RUN", self.Well_Run)
                
        # When pump is running check the pump current, it must be greater than 8.0 Amps
        #30 second delay before action is taken
        while Pressure_switch == 1:
            if Pump_I < self.Pump_Min_I:
                self.Pump_Low_I = 1
                print("Pump Low I", self.Pump_Low_I)
                asyncio.create_task(self.start_dry_well_timer())
            #if pump current is less than 8.0 Amps for 30 seconds, turn off the pump
            if self.Dry_Well == 1:
                asyncio.create_task(self.reset_dry_well_timer())
                m.setTriac(1,2,1)
                print("Dry Well", self.Dry_Well)

    # async function to run timer for 30 seconds
    async def start_dry_well_timer(self):
        await asyncio.sleep(Pump_Low_I_time)
        self.Dry_Well = 1
        print("Dry_Well set to 1 after 30 seconds")
    # async function to reset timer for 15 minutes
    async def reset_dry_well_timer(self):
        await asyncio.sleep(Dry_Well_Time)
        self.Dry_Well = 0
        print("Dry_Well reset to 0 after 15 minutes")

    # Send new values every 10 seconds.
    async def publish_data(self):
        while True:
            print('Publishing a new message every 10 seconds (press Ctrl-C to quit)...')
            print('Publishing')
            print("Well_Run: ", self.Well_Run)
            print("Pump_I: ", Pump_I)
            print("Dry_Well: ", self.Dry_Well)
            print("Pressure_switch: ", Pressure_switch)
            client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump', self.Well_Run)
            client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump-i', Pump_I)
            client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-dry-well-delay', self.Dry_Well)
            await asyncio.sleep(10)
            asyncio.create_task(self.publish_data())



if __name__ == "__main__":
    controller = WellController()
    controller.run()

m.wdtSetPeriod(1, 1800)

