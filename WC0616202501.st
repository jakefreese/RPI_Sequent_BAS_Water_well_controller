PROGRAM Well_Control
  VAR
    SM_BAS0 : SM_BAS;
    STACK : SINT := 3;
  END_VAR
  VAR
    Well_PS AT %IX0.0 : BOOL := 0;
    Well_PS_MQTT AT %QW1 : INT := 0;
  END_VAR
  VAR
    Dry_Well : BOOL := 0;
    Dry_Well_Wait : BOOL := 0;
  END_VAR
  VAR
    System_Run AT %IX0.2 : BOOL := 0;
    System_Run_MQTT AT %QW2 : INT := 0;
    Pump_Run AT %IX0.3 : BOOL := 0;
    Pump_Run_MQTT AT %QW3 : INT := 0;
    Dry_Well_IN AT %IX0.4 : BOOL := 0;
    Dry_Well_IN_MQTT AT %QW4 : INT := 0;
  END_VAR
  VAR
    Dry_Well_Count : INT := 1000;
    Low_I_Delay : TIME;
    Dry_Well_Wait_Delay : TIME;
  END_VAR
  VAR
    Dry_Well_Wait_Delay_MQTT AT %QW5 : INT;
    Dry_Well_Wait_count_MQTT AT %QW6 : INT;
    Pump_I AT %IW1 : INT;
    Pump_I_MQTT AT %QW7 : INT;
  END_VAR
  VAR
    Pump_I_MIN : INT := 3280;
    Multiply : REAL := 1000.0;
    TON1 : TON;
    TON2 : TON;
    CTU0 : CTU;
    R_TRIG0 : R_TRIG;
    _TMP_LT48_OUT : BOOL;
    _TMP_MUL17_OUT : REAL;
    _TMP_REAL_TO_INT43_OUT : INT;
    _TMP_BOOL_TO_INT79_OUT : INT;
    _TMP_BOOL_TO_INT76_OUT : INT;
    _TMP_BOOL_TO_INT77_OUT : INT;
    _TMP_BOOL_TO_INT80_OUT : INT;
    _TMP_TIME_TO_INT70_OUT : INT;
    _TMP_DIV73_OUT : INT;
    _TMP_SUB72_OUT : INT;
    R_TRIG1 : R_TRIG;
  END_VAR

  _TMP_LT48_OUT := LT(Pump_I, Pump_I_MIN);
  TON1(IN := Well_PS AND NOT(Dry_Well_Wait) AND _TMP_LT48_OUT, PT := T#30s);
  Low_I_Delay := TON1.ET;
  TON2(IN := Dry_Well, PT := T#30m);
  Dry_Well_Wait_Delay := TON2.ET;
  SM_BAS0(STACK := STACK, TRIAC2 := Dry_Well, TRIAC4 := NOT(Dry_Well) AND Well_PS AND System_Run, LED1 := TRUE);
  Well_PS := SM_BAS0.DRY_C1;
  _TMP_MUL17_OUT := MUL(SM_BAS0.UNIV2, Multiply);
  _TMP_REAL_TO_INT43_OUT := REAL_TO_INT(_TMP_MUL17_OUT);
  Pump_I := _TMP_REAL_TO_INT43_OUT;
  Dry_Well := TON1.Q;
  Dry_Well_Wait := TON2.Q;
  System_Run := SM_BAS0.DRY_C3;
  Pump_Run := NOT(Dry_Well) AND Well_PS AND System_Run;
  Dry_Well_IN := Dry_Well;
  _TMP_BOOL_TO_INT79_OUT := BOOL_TO_INT(NOT(Dry_Well) AND Well_PS AND System_Run);
  Pump_Run_MQTT := _TMP_BOOL_TO_INT79_OUT;
  _TMP_BOOL_TO_INT76_OUT := BOOL_TO_INT(SM_BAS0.DRY_C1);
  Well_PS_MQTT := _TMP_BOOL_TO_INT76_OUT;
  _TMP_BOOL_TO_INT77_OUT := BOOL_TO_INT(SM_BAS0.DRY_C3);
  System_Run_MQTT := _TMP_BOOL_TO_INT77_OUT;
  _TMP_BOOL_TO_INT80_OUT := BOOL_TO_INT(Dry_Well);
  Dry_Well_IN_MQTT := _TMP_BOOL_TO_INT80_OUT;
  Pump_I_MQTT := _TMP_REAL_TO_INT43_OUT;
  _TMP_TIME_TO_INT70_OUT := TIME_TO_INT(TON2.ET);
  _TMP_DIV73_OUT := DIV(_TMP_TIME_TO_INT70_OUT, 60);
  _TMP_SUB72_OUT := SUB(30, _TMP_DIV73_OUT);
  Dry_Well_Wait_Delay_MQTT := _TMP_SUB72_OUT;
  R_TRIG0(CLK := Dry_Well);
  R_TRIG1(CLK := R_TRIG0.Q);
  CTU0(CU := R_TRIG1.Q, PV := Dry_Well_Count);
  Dry_Well_Wait_count_MQTT := CTU0.CV;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : Well_Control;
  END_RESOURCE
END_CONFIGURATION

(*DBG:char md5[] = "8ed843ce4794af0c3ff923a676854f24";*)
(*DBG:/**)
(*DBG: * This file is part of OpenPLC Runtime*)
(*DBG: **)
(*DBG: * Copyright (C) 2023 Autonomy, GP Orcullo*)
(*DBG: * Based on the work by GP Orcullo on Beremiz for uC*)
(*DBG: **)
(*DBG: * This program is free software; you can redistribute it and/or*)
(*DBG: * modify it under the terms of the GNU General Public License*)
(*DBG: * as published by the Free Software Foundation; either version 2*)
(*DBG: * of the License, or (at your option) any later version.*)
(*DBG: **)
(*DBG: * This program is distributed in the hope that it will be useful,*)
(*DBG: * but WITHOUT ANY WARRANTY; without even the implied warranty of*)
(*DBG: * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the*)
(*DBG: * GNU General Public License for more details.*)
(*DBG: **)
(*DBG: * You should have received a copy of the GNU General Public License*)
(*DBG: * along with this program; If not, see <http://www.gnu.org/licenses/>.*)
(*DBG: **)
(*DBG: */*)
(*DBG:*)
(*DBG:#include <stdbool.h>*)
(*DBG:*)
(*DBG:#include "iec_types_all.h"*)
(*DBG:#include "POUS.h"*)
(*DBG:*)
(*DBG:#define SAME_ENDIANNESS      0*)
(*DBG:#define REVERSE_ENDIANNESS   1*)
(*DBG:*)
(*DBG:uint8_t endianness;*)
(*DBG:*)
(*DBG:*)
(*DBG:extern WELL_CONTROL RES0__INSTANCE0;*)
(*DBG:*)
(*DBG:static const struct {*)
(*DBG:    void *ptr;*)
(*DBG:    __IEC_types_enum type;*)
(*DBG:} debug_vars[] = {*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.STACK), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.TRIAC1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.TRIAC2), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.TRIAC3), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.TRIAC4), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.LED1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.LED2), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.LED3), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.LED4), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN1_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN2_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN3_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN4_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN5_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN6_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN7_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.IN8_T), UINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.Q0_10V1), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.Q0_10V2), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.Q0_10V3), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.Q0_10V4), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV1), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV2), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV3), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV4), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV5), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV6), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV7), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.UNIV8), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C1), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C2), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C3), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C4), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C5), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C6), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C7), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.DRY_C8), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.OWB_T1), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.OWB_T2), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.OWB_T3), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SM_BAS0.OWB_T4), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.STACK), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.WELL_PS), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.WELL_PS_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_WAIT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SYSTEM_RUN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.SYSTEM_RUN_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PUMP_RUN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PUMP_RUN_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_IN_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_COUNT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.LOW_I_DELAY), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_WAIT_DELAY), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_WAIT_DELAY_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.DRY_WELL_WAIT_COUNT_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PUMP_I), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PUMP_I_MQTT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.PUMP_I_MIN), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.MULTIPLY), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON1.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.PT), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.ET), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.STATE), SINT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.PREV_IN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.CURRENT_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.TON2.START_TIME), TIME_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.R), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.PV), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CV), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU_T.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU_T.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU_T.CLK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU_T.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.CTU0.CU_T.M), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG0.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG0.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG0.CLK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG0.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG0.M), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_LT48_OUT), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_MUL17_OUT), REAL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_REAL_TO_INT43_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_BOOL_TO_INT79_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_BOOL_TO_INT76_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_BOOL_TO_INT77_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_BOOL_TO_INT80_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_TIME_TO_INT70_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_DIV73_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0._TMP_SUB72_OUT), INT_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.EN), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.ENO), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.CLK), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.Q), BOOL_ENUM},*)
(*DBG:    {&(RES0__INSTANCE0.R_TRIG1.M), BOOL_ENUM},*)
(*DBG:};*)
(*DBG:*)
(*DBG:#define VAR_COUNT               115*)
(*DBG:*)
(*DBG:uint16_t get_var_count(void)*)
(*DBG:{*)
(*DBG:    return VAR_COUNT;*)
(*DBG:}*)
(*DBG:*)
(*DBG:size_t get_var_size(size_t idx)*)
(*DBG:{*)
(*DBG:    if (idx >= VAR_COUNT)*)
(*DBG:    {*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case SINT_ENUM:*)
(*DBG:        return sizeof(SINT);*)
(*DBG:    case INT_ENUM:*)
(*DBG:        return sizeof(INT);*)
(*DBG:    case UINT_ENUM:*)
(*DBG:        return sizeof(UINT);*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return sizeof(REAL);*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return sizeof(BOOL);*)
(*DBG:    case TIME_ENUM:*)
(*DBG:        return sizeof(TIME);*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void *get_var_addr(size_t idx)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    switch (debug_vars[idx].type) {*)
(*DBG:    case SINT_ENUM:*)
(*DBG:        return (void *)&((__IEC_SINT_t *) ptr)->value;*)
(*DBG:    case INT_ENUM:*)
(*DBG:        return (void *)&((__IEC_INT_t *) ptr)->value;*)
(*DBG:    case UINT_ENUM:*)
(*DBG:        return (void *)&((__IEC_UINT_t *) ptr)->value;*)
(*DBG:    case REAL_ENUM:*)
(*DBG:        return (void *)&((__IEC_REAL_t *) ptr)->value;*)
(*DBG:    case BOOL_ENUM:*)
(*DBG:        return (void *)&((__IEC_BOOL_t *) ptr)->value;*)
(*DBG:    case TIME_ENUM:*)
(*DBG:        return (void *)&((__IEC_TIME_t *) ptr)->value;*)
(*DBG:    default:*)
(*DBG:        return 0;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void force_var(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    void *ptr = debug_vars[idx].ptr;*)
(*DBG:*)
(*DBG:    if (forced) {*)
(*DBG:        size_t var_size = get_var_size(idx);*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case SINT_ENUM: {*)
(*DBG:            memcpy(&((__IEC_SINT_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_SINT_t *) ptr)->value = *((SINT *) val);*)
(*DBG:            ((__IEC_SINT_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case INT_ENUM: {*)
(*DBG:            memcpy(&((__IEC_INT_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_INT_t *) ptr)->value = *((INT *) val);*)
(*DBG:            ((__IEC_INT_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case UINT_ENUM: {*)
(*DBG:            memcpy(&((__IEC_UINT_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_UINT_t *) ptr)->value = *((UINT *) val);*)
(*DBG:            ((__IEC_UINT_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case REAL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_REAL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_REAL_t *) ptr)->value = *((REAL *) val);*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case BOOL_ENUM: {*)
(*DBG:            memcpy(&((__IEC_BOOL_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_BOOL_t *) ptr)->value = *((BOOL *) val);*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        case TIME_ENUM: {*)
(*DBG:            memcpy(&((__IEC_TIME_t *) ptr)->value, val, var_size);*)
(*DBG:            //((__IEC_TIME_t *) ptr)->value = *((TIME *) val);*)
(*DBG:            ((__IEC_TIME_t *) ptr)->flags |= __IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    } else {*)
(*DBG:        switch (debug_vars[idx].type) {*)
(*DBG:        case SINT_ENUM:*)
(*DBG:            ((__IEC_SINT_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case INT_ENUM:*)
(*DBG:            ((__IEC_INT_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case UINT_ENUM:*)
(*DBG:            ((__IEC_UINT_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case REAL_ENUM:*)
(*DBG:            ((__IEC_REAL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case BOOL_ENUM:*)
(*DBG:            ((__IEC_BOOL_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        case TIME_ENUM:*)
(*DBG:            ((__IEC_TIME_t *) ptr)->flags &= ~__IEC_FORCE_FLAG;*)
(*DBG:            break;*)
(*DBG:        default:*)
(*DBG:            break;*)
(*DBG:        }*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void swap_bytes(void *ptr, size_t size) *)
(*DBG:{*)
(*DBG:    uint8_t *bytePtr = (uint8_t *)ptr;*)
(*DBG:    size_t i;*)
(*DBG:    for (i = 0; i < size / 2; ++i) *)
(*DBG:    {*)
(*DBG:        uint8_t temp = bytePtr[i];*)
(*DBG:        bytePtr[i] = bytePtr[size - 1 - i];*)
(*DBG:        bytePtr[size - 1 - i] = temp;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void trace_reset(void)*)
(*DBG:{*)
(*DBG:    for (size_t i=0; i < VAR_COUNT; i++) *)
(*DBG:    {*)
(*DBG:        force_var(i, false, 0);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_trace(size_t idx, bool forced, void *val)*)
(*DBG:{*)
(*DBG:    if (idx >= 0 && idx < VAR_COUNT) *)
(*DBG:    {*)
(*DBG:        if (endianness == REVERSE_ENDIANNESS)*)
(*DBG:        {*)
(*DBG:            // Aaaaarghhhh... Stupid AVR is Big Endian.*)
(*DBG:            swap_bytes(val, get_var_size(idx));*)
(*DBG:        }*)
(*DBG:*)
(*DBG:        force_var(idx, forced, val);*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)
(*DBG:void set_endianness(uint8_t value)*)
(*DBG:{*)
(*DBG:    if (value == SAME_ENDIANNESS || value == REVERSE_ENDIANNESS)*)
(*DBG:    {*)
(*DBG:        endianness = value;*)
(*DBG:    }*)
(*DBG:}*)
(*DBG:*)