/*
 *	emulation special function interface
 *
 *	This file is part of GLISS2
 *	Copyright (c) 2017, IRIT UPS.
 *
 *	GLISS is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; either version 2 of the License, or
 *	(at your option) any later version.
 *
 *	GLISS is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with GLISS2; if not, write to the Free Software
 *	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
#ifndef GLISS_RISCV_EMU_H
#define GLISS_RISCV_EMU_H

#include <stdint.h>

#if defined(__cplusplus)
extern  "C" {
#endif

#define GLISS_EMU_STATE
#define GLISS_EMU_INIT(s)
#define GLISS_EMU_DESTROY(s)

#define BreakPoint		0
#define	IntegerOverflow	1
#define AddressError	2
#define SystemCall		3
#define Trap			4

void Prefetch(int uncached, int32_t pAddr, int32_t vAddr, int IorD, int hint);
void SignalException(int exception);
uint64_t COP_SD(int z, int rt);
uint32_t COP_SW(int z, int rt);
void SyncOperation(int stype);

#if defined(__cplusplus)
}
#endif

#endif /* GLISS_RISCV_EMU_H */
