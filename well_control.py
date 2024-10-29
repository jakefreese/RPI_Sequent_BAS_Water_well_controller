    async def start_dry_well_timer(self):
        await asyncio.sleep(Pump_Low_I_time)
        self.Dry_Well = 1
        print("Dry_Well set to 1 after 30 seconds")

    async def reset_dry_well_timer(self):
        await asyncio.sleep(Dry_Well_Time)
        self.Dry_Well = 0
        print("Dry_Well reset to 0 after 15 minutes")
