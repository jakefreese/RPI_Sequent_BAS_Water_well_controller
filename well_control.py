# Pressure Switch controls pump run.
# Pump current is compared 30 seconds after pump start, if pump current below Pump_Min_I
# Pump will be stopped for 15 minutes 
#  
# Triac output to motor relay 
# Triac output to Dry Well local indicator lamp

# Output pump current to MQTT once every 10 seconds
# Output pressure switch state and drywell state to MQTT when it changes

# Pump_Low_I_Timer 30 second delay
# Dry_Well_Timer 15 minutes
# Temperature information and pressure values will be added in future

# import random
import asyncio
import megabas as m
import time
import sys
# import json
from Adafruit_IO import MQTTClient

ADAFRUIT_IO_KEY = 'my adafruit key'
ADAFRUIT_IO_USERNAME = 'my username'
# jakefreese/feeds/ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump
# jakefreese/feeds/ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump-i
# jakefreese/feeds/ar-hq-trailer-park-well.ar-hq-trailer-park-dry-well-delay


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
    
def getTriac(stack, state):
    print(f"Stack: stack={stack}, state={state}")

Pump_Low_I_time = int(30) # 30 Seconds
Dry_Well_Time = int(900)  # 900 Seconds 15min
Input_Read_time = int(1)  # 1 Second

# Set the BAS inputs and outputs
global Pressure_switch
global Pump_I
global Pump_Low_I
global Dry_Well_in
global Well_Run
Well_Run_output = m.setTriac(1,1,0)            # BAS DO 1
Dry_Well_Lamp = m.setTriac(1,2,0)    # BAS DO 2
Pressure_switch = m.getContactCh(1,1)  # BAS DI 1
Pump_I = m.getUIn(1,2)           # BAS AI 2 
Dry_Well_in = 0
Pump_Low_I = 0          # Initialize Pump_Low_I
Dry_Well = 0            # Initialize Dry_Well
Pump_Min_I = 8          # Initialize Pump_Min_I 8 Amps minimum current
Well_Run = 0            # Initialize Well_Run
RUN = 1

async def update_sensor_values():
    while RUN == 1:
        Pressure_switch = m.getContactCh(1,1)  # Read from BAS DI 1
        Pump_I = m.getUIn(1,2)            # Read from BAS AI 2
        await asyncio.sleep(Input_Read_time)
        # start the sensor update task
        asyncio.create_task(update_sensor_values())


async def control_pump():
    if Dry_Well_in == 0 & Pressure_switch == 1:
            m.setTriac(1, 1, 1)
    else:
            m.setTriac(1, 1, 0)
    await asyncio.sleep(Input_Read_time)
    # start the pump control task
    asyncio.create_task(control_pump())


async def delay_pump_low_i():
    print("Starting 30-second delay...")
    # Pump protection to compare pump input current and fixed value of Pump_Min_I
    # Pump_Low_I_time = 30 seconds delay to compare pump current after Pressure_switch is on
    if Pressure_switch == 1 and Pump_I < Pump_Min_I:
        await asyncio.sleep(Pump_Low_I_time)
        print(f"Pump_Low_I after delay: {Pump_Low_I}")
        # start the delay pump low i task
        asyncio.create_task(dry_well_delay())


async def dry_well_delay():
    print("Starting 15-minute dry well delay, and shutting down pump...")
    # Dry well delay to shut down pump for 15 minutes if pump current is below Pump_Min_I
    m.setTriac(1,2,1) 
    await asyncio.sleep(Dry_Well_Time)
    print("Dry well delay expired.")
    Dry_Well_in = 0
    m.setTriac(1,2,0) 
    # start the dry well delay task
    asyncio.create_task(dry_well_delay())


m.wdtSetPeriod(1, 1800)

client.loop_background()
# Now send new values every 10 seconds.
print('Publishing a new message every 10 seconds (press Ctrl-C to quit)...')
while True:

    print('Publishing')
    print("Well_Run: ", Well_Run)
    print("Pump_I: ", Pump_I)
    print("Dry_Well: ", Dry_Well)
    print("Pressure_switch: ", Pressure_switch)
    print("Well Run Triac:", getTriac(1,1))
    print("Dry Well Triac:", getTriac(1,2))
    client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump', Well_Run)
    client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-water-well-pump-i', Pump_I)
    client.publish('ar-hq-trailer-park-well.ar-hq-trailer-park-dry-well-delay', Dry_Well)
    time.sleep(10)
