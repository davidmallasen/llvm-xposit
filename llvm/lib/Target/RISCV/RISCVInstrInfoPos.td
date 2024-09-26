//===-- RISCVInstrInfoPos.td - RISC-V 'Pos' instructions ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the RISC-V instructions from the standard 'Pos',
// Single-Precision Posit Floating-Point instruction set extension.
// See: https://posithub.org/docs/RISC-V/RISC-V.htm
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// RISC-V specific DAG Nodes.
//===----------------------------------------------------------------------===//
/*
def SDT_RISCVFMV_W_X_RV64
    : SDTypeProfile<1, 1, [SDTCisVT<0, f32>, SDTCisVT<1, i64>]>;
def SDT_RISCVFMV_X_ANYEXTW_RV64
    : SDTypeProfile<1, 1, [SDTCisVT<0, i64>, SDTCisVT<1, f32>]>;

def riscv_fmv_w_x_rv64
    : SDNode<"RISCVISD::FMV_W_X_RV64", SDT_RISCVFMV_W_X_RV64>;
def riscv_fmv_x_anyextw_rv64
    : SDNode<"RISCVISD::FMV_X_ANYEXTW_RV64", SDT_RISCVFMV_X_ANYEXTW_RV64>;
*/

// For SDTypeProfile see llvm/include/llvm/Target/TargetSelectionDAG.td
def riscv_qclr
    : SDNode<"RISCVISD::QCLR", SDTNone, [SDNPHasChain]>;

//===----------------------------------------------------------------------===//
// Instruction class templates
//===----------------------------------------------------------------------===//

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class PosQMAS_rr<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs),
              (ins PosR32:$rs1, PosR32:$rs2), opcodestr, "$rs1, $rs2">;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
class PosQEmpty<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs), (ins), opcodestr, "">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class PosQ_d<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs PosR32:$rd), (ins), opcodestr, 
              "$rd">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class PosALUS_rr<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs PosR32:$rd),
              (ins PosR32:$rs1, PosR32:$rs2), opcodestr, "$rd, $rs1, $rs2">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class PosUnaryOp_r<bits<7> funct7, RegisterClass rdty, RegisterClass rs1ty, 
                   string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs rdty:$rd), (ins rs1ty:$rs1),
              opcodestr, "$rd, $rs1">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class PosCmpS_rr<bits<7> funct7, string opcodestr>
    : RVInstR<funct7, 0b111, OPC_POSIT, (outs GPR:$rd),
              (ins PosR32:$rs1, PosR32:$rs2), opcodestr, "$rd, $rs1, $rs2">,
      Sched<[]>;

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let Predicates = [HasExtXPosit] in {
let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def PLW : RVInstI<0b101, OPC_POSIT, (outs PosR32:$rd),
                  (ins GPR:$rs1, simm12:$imm12),
                   "plw", "$rd, ${imm12}(${rs1})">,
          Sched<[]>;

// let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
// def PLD : RVInstI<0b101, OPC_POSIT, (outs PosR32:$rd),
//                   (ins GPR:$rs1, simm12:$imm12),
//                    "pld", "$rd, ${imm12}(${rs1})">,
//           Sched<[]>;

// Operands for stores are in the order srcreg, base, offset rather than
// reflecting the order these fields are specified in the instruction
// encoding.
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def PSW : RVInstS<0b110, OPC_POSIT, (outs),
                  (ins PosR32:$rs2, GPR:$rs1, simm12:$imm12),
                   "psw", "$rs2, ${imm12}(${rs1})">,
          Sched<[]>;

// let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
// def PSD : RVInstS<0b110, OPC_POSIT, (outs),
//                   (ins PosR32:$rs2, GPR:$rs1, simm12:$imm12),
//                    "psd", "$rs2, ${imm12}(${rs1})">,
//           Sched<[]>;

def QMADD_S  : PosQMAS_rr<0b0011110, "qmadd.s">,
               Sched<[]>{
  let rd = 0b00000;
}
def QMSUB_S  : PosQMAS_rr<0b0100010, "qmsub.s">,
               Sched<[]>{
  let rd = 0b00000;
}
def QCLR_S   : PosQEmpty<0b0100110, "qclr.s">,
               Sched<[]>{
  let rd = 0b00000;
  let rs1 = 0b00000;
  let rs2 = 0b00000;
}
def QNEG_S   : PosQEmpty<0b0101010, "qneg.s">,
               Sched<[]>{
  let rd = 0b00000;
  let rs1 = 0b00000;
  let rs2 = 0b00000;
}
def QROUND_S : PosQ_d<0b0101110, "qround.s">,
               Sched<[]>{
  let rs1 = 0b00000;
  let rs2 = 0b00000;
}

def PADD_S : PosALUS_rr<0b0000010, "padd.s">,
             Sched<[]>;
def PSUB_S : PosALUS_rr<0b0000110, "psub.s">,
             Sched<[]>;
def PMUL_S : PosALUS_rr<0b0001010, "pmul.s">,
             Sched<[]>;
def PDIV_S : PosALUS_rr<0b0001110, "pdiv.s">,
             Sched<[]>;

def PSQRT_S : PosUnaryOp_r<0b0011010, PosR32, PosR32, "psqrt.s">,
              Sched<[]> {
  let rs2 = 0b00000;
}

def PMIN_S   : PosALUS_rr<0b0010010, "pmin.s">,
               Sched<[]>;
def PMAX_S   : PosALUS_rr<0b0010110, "pmax.s">,
               Sched<[]>;

def PSGNJ_S  : PosALUS_rr<0b1010010, "psgnj.s">,
               Sched<[]>;
def PSGNJN_S : PosALUS_rr<0b1010110, "psgnjn.s">,
               Sched<[]>;
def PSGNJX_S : PosALUS_rr<0b1011010, "psgnjx.s">,
               Sched<[]>;

def PEQ_S : PosCmpS_rr<0b1100110, "peq.s">;
def PLT_S : PosCmpS_rr<0b1101010, "plt.s">;
def PLE_S : PosCmpS_rr<0b1101110, "ple.s">;

def PCVT_W_S  : PosUnaryOp_r<0b0110010, GPR, PosR32, "pcvt.w.s">,
                Sched<[]> {
  let rs2 = 0b00000;
}

def PCVT_WU_S : PosUnaryOp_r<0b0110110, GPR, PosR32, "pcvt.wu.s">,
                Sched<[]> {
  let rs2 = 0b00000;
}

def PCVT_S_W  : PosUnaryOp_r<0b1000010, PosR32, GPR, "pcvt.s.w">,
                Sched<[]> {
  let rs2 = 0b00000;
}

def PCVT_S_WU : PosUnaryOp_r<0b1000110, PosR32, GPR, "pcvt.s.wu">,
                Sched<[]> {
  let rs2 = 0b00000;
}

def PMV_X_W : PosUnaryOp_r<0b1011110, GPR, PosR32, "pmv.x.w">,
              Sched<[]> {
  let rs2 = 0b00000;
}

def PMV_W_X : PosUnaryOp_r<0b1100010, PosR32, GPR, "pmv.w.x">,
              Sched<[]> {
  let rs2 = 0b00000;
}
} // Predicates = [HasExtXPosit]

let Predicates = [HasExtXPosit, IsRV64] in {
def PCVT_L_S  : PosUnaryOp_r<0b0111010, GPR, PosR32, "pcvt.l.s">,
                Sched<[]> {
  let rs2 = 0b00000;
}

def PCVT_LU_S : PosUnaryOp_r<0b0111110, GPR, PosR32, "pcvt.lu.s">,
                Sched<[]> {
  let rs2 = 0b00011;
}

def PCVT_S_L  : PosUnaryOp_r<0b1001010, PosR32, GPR, "pcvt.s.l">,
                Sched<[]> {
  let rs2 = 0b00010;
}

def PCVT_S_LU : PosUnaryOp_r<0b1001110, PosR32, GPR, "pcvt.s.lu">,
                Sched<[]> {
  let rs2 = 0b00011;
}
} // Predicates = [HasExtXPosit, IsRV64]

//===----------------------------------------------------------------------===//
// Assembler Pseudo Instructions (User-Level ISA, Version 2.2, Chapter 20)
//===----------------------------------------------------------------------===//

let Predicates = [HasExtXPosit] in {
def : InstAlias<"plw $rd, (${rs1})",  (PLW PosR32:$rd,  GPR:$rs1, 0), 0>;
def : InstAlias<"psw $rs2, (${rs1})", (PSW PosR32:$rs2, GPR:$rs1, 0), 0>;
// def : InstAlias<"pld $rd, (${rs1})",  (PLD PosR32:$rd,  GPR:$rs1, 0), 0>;
// def : InstAlias<"psd $rs2, (${rs1})", (PSD PosR32:$rs2, GPR:$rs1, 0), 0>;

def : InstAlias<"pmv.s $rd, $rs",  (PSGNJ_S  PosR32:$rd, PosR32:$rs, PosR32:$rs)>;
def : InstAlias<"pabs.s $rd, $rs", (PSGNJX_S PosR32:$rd, PosR32:$rs, PosR32:$rs)>;
def : InstAlias<"pneg.s $rd, $rs", (PSGNJN_S PosR32:$rd, PosR32:$rs, PosR32:$rs)>;

// pgt.s/pge.s are recognised by the GNU assembler but the canonical
// plt.s/ple.s forms will always be printed. Therefore, set a zero weight.
def : InstAlias<"pgt.s $rd, $rs, $rt",
                (PLT_S GPR:$rd, PosR32:$rt, PosR32:$rs), 0>;
def : InstAlias<"pge.s $rd, $rs, $rt",
                (PLE_S GPR:$rd, PosR32:$rt, PosR32:$rs), 0>;

// pmv.w.x and pmv.x.w were previously known as pmv.s.x and pmv.x.s. Both
// spellings should be supported by standard tools.
def : MnemonicAlias<"pmv.s.x", "pmv.w.x">;
def : MnemonicAlias<"pmv.x.s", "pmv.x.w">;

def PseudoPLW  : PseudoFloatLoad<"plw", PosR32>;
def PseudoPSW  : PseudoStore<"psw", PosR32>;
// def PseudoPLD  : PseudoFloatLoad<"pld", PosR32>;
// def PseudoPSD  : PseudoStore<"psd", PosR32>;
} // Predicates = [HasExtXPosit]

//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//===----------------------------------------------------------------------===//

// For the Pat class see llvm/include/llvm/Target/TargetSelectionDAG.td
let Predicates = [HasExtXPosit] in {

// Quire clear intrinsic
def : Pat<(riscv_qclr), (QCLR_S)>;

} // Predicates = [HasExtXPosit]

/*
/// Floating point constants
//def fpimm0 : PatLeaf<(fpimm), [{ return N->isExactlyValue(+0.0); }]>;

/// Generic pattern classes
class PatPosR32PosR32<SDPatternOperator OpNode, RVInstR Inst>
    : Pat<(OpNode PosR32:$rs1, PosR32:$rs2), (Inst $rs1, $rs2)>;

//class PatFPR32FPR32DynFrm<SDPatternOperator OpNode, RVInstRFrm Inst>
//    : Pat<(OpNode FPR32:$rs1, FPR32:$rs2), (Inst $rs1, $rs2, 0b111)>;

let Predicates = [HasExtXPosit] in {

/// Floating point constants
//def : Pat<(f32 (fpimm0)), (FMV_W_X X0)>;

/// Float conversion operations

// [u]int32<->float conversion patterns must be gated on IsRV32 or IsRV64, so
// are defined later.

/// Float arithmetic operations

def : PatPosR32PosR32<fadd, PADD_S>;
def : PatPosR32PosR32<fsub, PSUB_S>;
def : PatPosR32PosR32<fmul, PMUL_S>;
def : PatPosR32PosR32<fdiv, PDIV_S>;}

def : Pat<(fsqrt PosR32:$rs1), (PSQRT_S PosR32:$rs1)>;

def : Pat<(fneg PosR32:$rs1), (PSGNJN_S $rs1, $rs1)>;
def : Pat<(fabs PosR32:$rs1), (PSGNJX_S $rs1, $rs1)>;

def : PatPosR32PosR32<fcopysign, PSGNJ_S>;
def : Pat<(fcopysign PosR32:$rs1, (fneg PosR32:$rs2)), (PSGNJN_S $rs1, $rs2)>;


// fmadd: rs1 * rs2 + rs3
def : Pat<(fma FPR32:$rs1, FPR32:$rs2, FPR32:$rs3),
          (FMADD_S $rs1, $rs2, $rs3, 0b111)>;

// fmsub: rs1 * rs2 - rs3
def : Pat<(fma FPR32:$rs1, FPR32:$rs2, (fneg FPR32:$rs3)),
          (FMSUB_S FPR32:$rs1, FPR32:$rs2, FPR32:$rs3, 0b111)>;

// fnmsub: -rs1 * rs2 + rs3
def : Pat<(fma (fneg FPR32:$rs1), FPR32:$rs2, FPR32:$rs3),
          (FNMSUB_S FPR32:$rs1, FPR32:$rs2, FPR32:$rs3, 0b111)>;

// fnmadd: -rs1 * rs2 - rs3
def : Pat<(fma (fneg FPR32:$rs1), FPR32:$rs2, (fneg FPR32:$rs3)),
          (FNMADD_S FPR32:$rs1, FPR32:$rs2, FPR32:$rs3, 0b111)>;


// The ratified 20191213 ISA spec defines fmin and fmax in a way that matches
// LLVM's fminnum and fmaxnum
// <https://github.com/riscv/riscv-isa-manual/commit/cd20cee7efd9bac7c5aa127ec3b451749d2b3cce>.
def : PatPosR32PosR32<fminnum, PMIN_S>;
def : PatPosR32PosR32<fmaxnum, PMAX_S>;

/// Setcc

def : PatPosR32PosR32<seteq, PEQ_S>;
def : PatPosR32PosR32<setoeq, PEQ_S>;
def : PatPosR32PosR32<setlt, PLT_S>;
def : PatPosR32PosR32<setolt, PLT_S>;
def : PatPosR32PosR32<setle, PLE_S>;
def : PatPosR32PosR32<setole, PLE_S>;
*/
def Select_PosR32_Using_CC_GPR : SelectCC_rrirr<PosR32, GPR>;
/*
/// Loads

defm : LdPat<load, PLW, f32>;

/// Stores

defm : StPat<store, PSW, PosR32, f32>;

} // Predicates = [HasExtXPosit]

let Predicates = [HasExtXPosit, IsRV32] in {
// Moves (no conversion)
//def : Pat<(bitconvert (i32 GPR:$rs1)), (FMV_W_X GPR:$rs1)>;
//def : Pat<(i32 (bitconvert FPR32:$rs1)), (FMV_X_W FPR32:$rs1)>;

// posit->[u]int
def : Pat<(i32 (fp_to_sint PosR32:$rs1)), (PCVT_W_S $rs1)>;
def : Pat<(i32 (fp_to_uint PosR32:$rs1)), (PCVT_WU_S $rs1)>;

// [u]int->posit
def : Pat<(sint_to_fp (i32 GPR:$rs1)), (PCVT_S_W $rs1)>;
def : Pat<(uint_to_fp (i32 GPR:$rs1)), (PCVT_S_WU $rs1)>;
} // Predicates = [HasExtXPosit, IsRV32]

let Predicates = [HasExtXPosit, IsRV64] in {
// Moves (no conversion)
//def : Pat<(riscv_fmv_w_x_rv64 GPR:$src), (FMV_W_X GPR:$src)>;
//def : Pat<(riscv_fmv_x_anyextw_rv64 FPR32:$src), (FMV_X_W FPR32:$src)>;
//def : Pat<(sext_inreg (riscv_fmv_x_anyextw_rv64 FPR32:$src), i32),
//          (FMV_X_W FPR32:$src)>;

// FP->[u]int32 is mostly handled by the FP->[u]int64 patterns. This is safe
// because fpto[u|s]i produces poison if the value can't fit into the target.
// We match the single case below because fcvt.wu.s sign-extends its result so
// is cheaper than fcvt.lu.s+sext.w.
//def : Pat<(sext_inreg (assertzexti32 (fp_to_uint FPR32:$rs1)), i32),
//          (FCVT_WU_S $rs1, 0b001)>;

// posit->[u]int64
def : Pat<(i64 (fp_to_sint PosR32:$rs1)), (PCVT_L_S $rs1)>;
def : Pat<(i64 (fp_to_uint PosR32:$rs1)), (PCVT_LU_S $rs1)>;

// [u]int->posit. Match GCC and default to using dynamic rounding mode.
def : Pat<(sint_to_fp (i64 (sexti32 (i64 GPR:$rs1)))), (PCVT_S_W $rs1)>;
def : Pat<(uint_to_fp (i64 (zexti32 (i64 GPR:$rs1)))), (PCVT_S_WU $rs1)>;
def : Pat<(sint_to_fp (i64 GPR:$rs1)), (PCVT_S_L $rs1)>;
def : Pat<(uint_to_fp (i64 GPR:$rs1)), (PCVT_S_LU $rs1)>;
} // Predicates = [HasExtXPosit, IsRV64]
*/