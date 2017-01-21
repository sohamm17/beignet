/* 
 * Copyright © 2012 Intel Corporation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Benjamin Segovia <benjamin.segovia@intel.com>
 */

/**
 * \file function.hpp
 * \author Benjamin Segovia <benjamin.segovia@intel.com>
 */
#ifndef __GBE_IR_FUNCTION_HPP__
#define __GBE_IR_FUNCTION_HPP__

#include "ir/immediate.hpp"
#include "ir/register.hpp"
#include "ir/instruction.hpp"
#include "ir/profile.hpp"
#include "ir/sampler.hpp"
#include "ir/printf.hpp"
#include "ir/image.hpp"
#include "sys/vector.hpp"
#include "sys/set.hpp"
#include "sys/map.hpp"
#include "sys/alloc.hpp"

#include <ostream>

namespace gbe {
namespace ir {
  /*! Commonly used in the CFG */
  typedef set<BasicBlock*> BlockSet;
  class Unit; // Function belongs to a unit

  /*! Function basic blocks really belong to a function since:
   *  1 - registers used in the basic blocks belongs to the function register
   *      file
   *  2 - branches point to basic blocks of the same function
   */
  class BasicBlock : public NonCopyable, public intrusive_list<Instruction>
  {
  public:
    /*! Empty basic block */
    BasicBlock(Function &fn);
    /*! Releases all the instructions */
    ~BasicBlock(void);
    /*! Append a new instruction at the end of the stream */
    void append(Instruction &insn);
    void insertAt(iterator pos, Instruction &insn);
    /*! Get the parent function */
    Function &getParent(void) { return fn; }
    const Function &getParent(void) const { return fn; }
    /*! Get the next and previous allocated block */
    BasicBlock *getNextBlock(void) const { return this->nextBlock; }
    BasicBlock *getPrevBlock(void) const { return this->prevBlock; }
    /*! Get / set the first and last instructions */
    Instruction *getFirstInstruction(void) const;
    Instruction *getLastInstruction(void) const;
    /*! Get successors and predecessors */
    const BlockSet &getSuccessorSet(void) const { return successors; }
    const BlockSet &getPredecessorSet(void) const { return predecessors; }
    /*! Get the label index of this block */
    LabelIndex getLabelIndex(void) const;
    /*! Apply the given functor on all instructions */
    template <typename T>
    INLINE void foreach(const T &functor) {
      auto it = this->begin();
      while (it != this->end()) {
        auto curr = it++;
        functor(*curr);
      }
    }
    set <Register> undefPhiRegs;
    set <Register> definedPhiRegs;
  /* these three are used by structure transforming */
  public:
    /* if needEndif is true, it means that this bb is the exit of an
     * outermost structure, so this block needs another endif to match
     * the if inserted at the entry of this structure, otherwise this
     * block is in the middle of a structure, there's no need to insert
     * extra endif. */
    bool needEndif;
    /* if needIf is true, it means that this bb is the entry of an
     * outermost structure, so this block needs an if instruction just
     * like other unstructured bbs. otherwise this block is in the
     * middle of a structure, there's no need to insert an if. */
    bool needIf;
    /* since we need to insert an if and endif at the entry and exit
     * bb of an outermost structure respectively, so the endif is not
     * in the same bb with if, in order to get the endif's position,
     * we need to store the endif label in the entry bb. */
    LabelIndex endifLabel;
    /* the identified if-then and if-else structure contains more than
     * one bbs, in order to insert if, else and endif properly, we give
     * all the IF ELSE and ENDIF a label for convenience. matchingEndifLabel
     * is used when inserts instruction if and else, and matchingElseLabel
     * is used when inserts instruction if. */
    LabelIndex matchingEndifLabel;
    LabelIndex matchingElseLabel;
    /* IR ELSE's target is the matching ENDIF's LabelIndex, thisElseLabel
     * is used to store the virtual label of the instruction just below
     * ELSE. */
    LabelIndex thisElseLabel;
    /* betongToStructure is used as a mark of wether this bb belongs to an
     * identified structure. */
    bool belongToStructure;
    /* isStructureExit and matchingStructureEntry is used for buildJIPs at
     * backend, isStructureExit is true means the bb is an identified structure's
     * exit bb, while matchingStructureEntry means the entry bb of the same
     * identified structure. so if isStructureExit is false then matchingStructureEntry
     * is meaningless. */
    bool isStructureExit;
    /* This block is an exit point of a loop block. It may not be exit point of
       the large structure block. */
    bool isLoopExit;
    /* This block has an extra branch in the end of the block. */
    bool hasExtraBra;
    BasicBlock *matchingStructureEntry;
    /* variable liveout is for if-else structure liveness analysis. eg. we have an sequence of
     * bbs of 0, 1, 2, 3, 4 and the CFG is as below:
     *  0
     *  |\
     *  1 \
     *  |  2
     *  4  |
     *   \ /
     *    3
     * we would identify 1 and 4 an sequence structure and 0 1 4 2 an if-else structure.
     * since we will insert an else instruction at the top of bb 2, we have to add an
     * unconditional jump at the bottom of bb 4 to bb 2 for executing the inserted else. this
     * would cause a change of CFG. at origin, bb 2 always executes before bb 4, but after
     * this insertion, bb 2 may executes after bb 4 which leads to bb 2's livein(i.e. part of
     * bb 0's liveout) may be destroyed by bb 4. so we inserted the livein of the entry of
     * else node into all the basic blocks belong to 'then' part while the liveout is
     * calculated in structural_analysis.cpp:calculateNecessaryLiveout(); */
    std::set<Register> liveout;
    /* selfLoop's label.
     * */
    LabelIndex whileLabel;
  private:
    friend class Function; //!< Owns the basic blocks
    BlockSet predecessors; //!< Incoming blocks
    BlockSet successors;   //!< Outgoing blocks
    BasicBlock *nextBlock; //!< Block allocated just after this one
    BasicBlock *prevBlock; //!< Block allocated just before this one
    Function &fn;          //!< Function the block belongs to
    GBE_CLASS(BasicBlock);
  };

  /*! In fine, function input arguments can be pushed from the constant
   *  buffer if they are structures. Other arguments can be images (textures)
   *  and will also require special treatment.
   */
  struct FunctionArgument {
    enum Type {
      GLOBAL_POINTER    = 0, // __global
      CONSTANT_POINTER  = 1, // __constant
      LOCAL_POINTER     = 2, // __local
      VALUE             = 3, // int, float
      STRUCTURE         = 4, // struct foo
      IMAGE             = 5, // image*d_t
      SAMPLER           = 6,
      PIPE              = 7  // pipe
    };

    struct InfoFromLLVM { // All the info about passed by llvm, using -cl-kernel-arg-info
      uint32_t addrSpace;
      std::string typeName;
      std::string typeBaseName;
      std::string accessQual;
      std::string typeQual;
      std::string argName; // My different from arg->getName()
      uint32_t typeSize;


      // only llvm-3.6 or later has kernel_arg_base_type in metadata.
#if (LLVM_VERSION_MAJOR == 3) && (LLVM_VERSION_MINOR <= 5)
      bool isImage1dT() const {
        return typeName.compare("image1d_t") == 0;
      }
      bool isImage1dArrayT() const {
        return typeName.compare("image1d_array_t") == 0;
      }
      bool isImage1dBufferT() const {
        return typeName.compare("image1d_buffer_t") == 0;
      }
      bool isImage2dT() const {
        return typeName.compare("image2d_t") == 0;
      }
      bool isImage2dArrayT() const {
        return typeName.compare("image2d_array_t") == 0;
      }
      bool isImage3dT() const {
        return typeName.compare("image3d_t") == 0;
      }
      bool isSamplerType() const {
        return typeName.compare("sampler_t") == 0;
      }
#else
      bool isImage1dT() const {
        return typeBaseName.find("image1d_t") !=std::string::npos;
      }
      bool isImage1dArrayT() const {
        return typeBaseName.find("image1d_array_t") !=std::string::npos;
      }
      bool isImage1dBufferT() const {
        return typeBaseName.find("image1d_buffer_t") !=std::string::npos;
      }
      bool isImage2dT() const {
        return typeBaseName.find("image2d_t") !=std::string::npos;
      }
      bool isImage2dArrayT() const {
        return typeBaseName.find("image2d_array_t") !=std::string::npos;
      }
      bool isImage3dT() const {
        return typeBaseName.find("image3d_t") !=std::string::npos;
      }
      bool isSamplerType() const {
        return typeBaseName.compare("sampler_t") == 0;
      }
#endif

      bool isImageType() const {
        return isImage1dT() || isImage1dArrayT() || isImage1dBufferT() ||
               isImage2dT() || isImage2dArrayT() || isImage3dT();
      }

      bool isPipeType() const {
        return typeQual.compare("pipe") == 0;
      }
    };

    /*! Create a function input argument */
    INLINE FunctionArgument(Type type, Register reg, uint32_t size, const std::string &name, uint32_t align, InfoFromLLVM& info, uint8_t bti) :
      type(type), reg(reg), size(size), align(align), name(name), info(info), bti(bti) { }

    Type type;     //!< Gives the type of argument we have
    Register reg;  //!< Holds the argument
    uint32_t size; //!< == sizeof(void*) for ptr, sizeof(elem) for the rest
    uint32_t align; //!< address alignment for the argument
    const std::string name; //!< Holds the function name for IR output
    InfoFromLLVM info;  //!< Holds the llvm passed info
    uint8_t bti; //!< binding table index
    GBE_STRUCT(FunctionArgument); // Use custom allocator
  };

  /*! Maps the pushed register to the function argument */
  struct PushLocation {
    INLINE PushLocation(const Function &fn, uint32_t argID, uint32_t offset) :
      fn(fn), argID(argID), offset(offset) {}
    /*! Get the pushed virtual register */
    Register getRegister(void) const;
    const Function &fn;       //!< Function it belongs to
    uint32_t argID;           //!< Function argument
    uint32_t offset;          //!< Offset in the function argument
    GBE_STRUCT(PushLocation); // Use custom allocator
  };

  /*! For maps and sets */
  INLINE bool operator< (const PushLocation &arg0, const PushLocation &arg1) {
    if (arg0.argID != arg1.argID) return arg0.argID < arg1.argID;
    return arg0.offset < arg1.offset;
  }

  /*! CFG loops */
  struct Loop : public NonCopyable
  {
  public:
    Loop(LabelIndex pre,
         int paren,
         const vector<LabelIndex> &in,
         const vector<std::pair<LabelIndex, LabelIndex>> &exit) :
         preheader(pre), parent(paren), bbs(in), exits(exit) {}

    LabelIndex preheader;
    int parent;
    vector<LabelIndex> bbs;
    vector<std::pair<LabelIndex, LabelIndex>> exits;
    GBE_STRUCT(Loop);
  };

  /*! A function is :
   *  - a register file
   *  - a set of basic block layout into a CGF
   *  - input arguments
   */
  class Function : public NonCopyable
  {
  public:
    /*! Map of all pushed registers */
    typedef map<Register, PushLocation> PushMap;
    /*! Map of all pushed location (i.e. part of function argument) */
    typedef map<PushLocation, Register> LocationMap;
    /*! Create an empty function */
    Function(const std::string &name, const Unit &unit, Profile profile = PROFILE_OCL);
    /*! Release everything *including* the basic block pointers */
    ~Function(void);
    /*! Get the function profile */
    INLINE Profile getProfile(void) const { return profile; }
    /*! Get a new valid register */
    INLINE Register newRegister(RegisterFamily family,
                                bool uniform = false,
                                gbe_curbe_type curbeType = GBE_GEN_REG,
                                int subType = 0) {
      return this->file.append(family, uniform, curbeType, subType);
    }
    /*! Get the function name */
    const std::string &getName(void) const { return name; }
    /*! When set, we do not have choice any more in the back end for it */
    INLINE void setSimdWidth(uint32_t width) { simdWidth = width; }
    /*! Get the SIMD width (0 if not forced) */
    uint32_t getSimdWidth(void) const { return simdWidth; }
    /*! Extract the register from the register file */
    INLINE RegisterData getRegisterData(Register reg) const { return file.get(reg); }
    /*! set a register to uniform or nonuniform type. */
    INLINE void setRegisterUniform(Register reg, bool uniform) { file.setUniform(reg, uniform); }
    /*! return true if the specified regsiter is uniform type */
    INLINE bool isUniformRegister(Register reg) { return file.isUniform(reg); }
    /*! set register as specified payload type */
    INLINE void setRegPayloadType(Register reg, gbe_curbe_type curbeType, int subType) {
      file.setPayloadType(reg, curbeType, subType);
    }
    /*! get register's payload type. */
    INLINE void getRegPayloadType(Register reg, gbe_curbe_type &curbeType, int &subType) const {
      file.getPayloadType(reg, curbeType, subType);
    }
    /*! check whether a register is a payload register */
    INLINE bool isPayloadReg(Register reg) const{
      return file.isPayloadReg(reg);
    }
    /*! Get the register family from the register itself */
    INLINE RegisterFamily getRegisterFamily(Register reg) const {
      return this->getRegisterData(reg).family;
    }
    /*! Get the register from the tuple vector */
    INLINE Register getRegister(Tuple ID, uint32_t which) const {
      return file.get(ID, which);
    }
    /*! Set the register from the tuple vector */
    INLINE void setRegister(Tuple ID, uint32_t which, Register reg) {
      file.set(ID, which, reg);
    }
    /*! Get the type from the tuple vector */
    INLINE uint8_t getType(Tuple ID, uint32_t which) const {
      return file.getType(ID, which);
    }
    /*! Set the type into the tuple vector */
    INLINE void setType(Tuple ID, uint32_t which, uint8_t type) {
      file.setType(ID, which, type);
    }
    /*! Get the register file */
    INLINE const RegisterFile &getRegisterFile(void) const { return file; }
    /*! Get the given value ie immediate from the function */
    INLINE const Immediate &getImmediate(ImmediateIndex ID) const {
      return immediates[ID];
    }
    /*! Create a new immediate and returns its index */
    INLINE ImmediateIndex newImmediate(const Immediate &imm) {
      const ImmediateIndex index(this->immediateNum());
      this->immediates.push_back(imm);
      return index;
    }
    /*! Fast allocation / deallocation of instructions */
    DECL_POOL(Instruction, insnPool);
    /*! Get input argument */
    INLINE const FunctionArgument &getArg(uint32_t ID) const {
      GBE_ASSERT(args[ID] != NULL);
      return *args[ID];
    }
    INLINE FunctionArgument &getArg(uint32_t ID) {
      GBE_ASSERT(args[ID] != NULL);
      return *args[ID];
    }

    /*! Get arg ID. */
    INLINE int32_t getArgID(FunctionArgument *requestArg) {
      for (uint32_t ID = 0; ID < args.size(); ID++)
      {
        if ( args[ID] == requestArg )
          return ID;
      }
      GBE_ASSERTM(0, "Failed to get a valid argument ID.");
      return -1;
    }

    /*! Get the number of pushed registers */
    INLINE uint32_t pushedNum(void) const { return pushMap.size(); }
    /*! Get the pushed data location for the given register */
    INLINE const PushLocation *getPushLocation(Register reg) const {
      auto it = pushMap.find(reg);
      if (it == pushMap.end())
        return NULL;
      else
        return &it->second;
    }
    /*! Get the map of pushed registers */
    const PushMap &getPushMap(void) const { return this->pushMap; }
    /*! Get the map of pushed registers */
    const LocationMap &getLocationMap(void) const { return this->locationMap; }
    /*! Get input argument from the register (linear research). Return NULL if
     *  this is not an input argument
     */
    INLINE const FunctionArgument *getArg(const Register &reg) const {
      for (size_t i = 0; i < args.size(); ++i) {
        const FunctionArgument* arg = args[i];
        if (arg->reg == reg)
          return arg;
      }
      return NULL;
    }

    INLINE FunctionArgument *getArg(const Register &reg) {
      for (size_t i = 0; i < args.size(); ++i) {
        FunctionArgument* arg = args[i];
        if (arg->reg == reg)
          return arg;
      }
      return NULL;
    }

    /*! Get output register */
    INLINE Register getOutput(uint32_t ID) const { return outputs[ID]; }
    /*! Get the argument location for the pushed register */
    INLINE const PushLocation &getPushLocation(Register reg) {
      GBE_ASSERT(pushMap.contains(reg) == true);
      return pushMap.find(reg)->second;
    }
    /*! Says if this is the top basic block (entry point) */
    bool isEntryBlock(const BasicBlock &bb) const;
    /*! Get function the entry point block */
    BasicBlock &getTopBlock(void) const;
    /*! Get the last block */
    const BasicBlock &getBottomBlock(void) const;
    /*! Get the last block */
    BasicBlock &getBottomBlock(void);
    /*! Get block from its label */
    BasicBlock &getBlock(LabelIndex label) const;
    /*! Get the label instruction from its label index */
    const LabelInstruction *getLabelInstruction(LabelIndex index) const;
    /*! Return the number of instructions of the largest basic block */
    uint32_t getLargestBlockSize(void) const;
    /*! Get the first index of the special registers and number of them */
    uint32_t getFirstSpecialReg(void) const;
    uint32_t getSpecialRegNum(void) const;
    /*! Indicate if the given register is a special one (like localID in OCL) */
    bool isSpecialReg(const Register &reg) const;
    /*! Create a new label (still not bound to a basic block) */
    LabelIndex newLabel(void);
    /*! Create the control flow graph */
    void computeCFG(void);
    /*! Sort labels in increasing orders (top block has the smallest label) */
    void sortLabels(void);
    /*! check empty Label. */
    void checkEmptyLabels(void);
    /*! Get the pointer family */
    RegisterFamily getPointerFamily(void) const;
    /*! Number of registers in the register file */
    INLINE uint32_t regNum(void) const { return file.regNum(); }
    /*! Number of register tuples in the register file */
    INLINE uint32_t tupleNum(void) const { return file.tupleNum(); }
    /*! Number of labels in the function */
    INLINE uint32_t labelNum(void) const { return labels.size(); }
    /*! Number of immediate values in the function */
    INLINE uint32_t immediateNum(void) const { return immediates.size(); }
    /*! Get the number of argument register */
    INLINE uint32_t argNum(void) const { return args.size(); }
    /*! Get the number of output register */
    INLINE uint32_t outputNum(void) const { return outputs.size(); }
    /*! Number of blocks in the function */
    INLINE uint32_t blockNum(void) const { return blocks.size(); }
    /*! Output an immediate value in a stream */
    void outImmediate(std::ostream &out, ImmediateIndex index) const;
    /*! Apply the given functor on all basic blocks */
    template <typename T>
    INLINE void foreachBlock(const T &functor) const {
      for (size_t i = 0; i < blocks.size(); ++i) {
        BasicBlock* block = blocks[i];
        functor(*block);
      }
    }
    /*! Apply the given functor on all instructions */
    template <typename T>
    INLINE void foreachInstruction(const T &functor) const {
      for (size_t i = 0; i < blocks.size(); ++i) {
        BasicBlock* block = blocks[i];
        block->foreach(functor);
      }
    }
    /*! Get wgBroadcastSLM in this function */
    int32_t getwgBroadcastSLM(void) const { return wgBroadcastSLM; }
    /*! Set wgBroadcastSLM for this function */
    void setwgBroadcastSLM(int32_t v) { wgBroadcastSLM = v; }
    /*! Get tidMapSLM in this function */
    int32_t gettidMapSLM(void) const { return tidMapSLM; }
    /*! Set tidMapSLM for this function */
    void settidMapSLM(int32_t v) { tidMapSLM = v; }
    /*! Does it use SLM */
    INLINE bool getUseSLM(void) const { return this->useSLM; }
    /*! Change the SLM config for the function */
    INLINE bool setUseSLM(bool useSLM) { return this->useSLM = useSLM; }
    /*! get SLM size needed for local variable inside kernel function */
    INLINE uint32_t getSLMSize(void) const { return this->slmSize; }
    /*! set slm size needed for local variable inside kernel function */
    INLINE void setSLMSize(uint32_t size) { this->slmSize = size; }
    /*! Get sampler set in this function */
    SamplerSet* getSamplerSet(void) const {return samplerSet; }
    /*! Get image set in this function */
    ImageSet* getImageSet(void) const {return imageSet; }
    /*! Get printf set in this function */
    PrintfSet* getPrintfSet(void) const {return printfSet; }
    /*! Set required work group size. */
    void setCompileWorkGroupSize(size_t x, size_t y, size_t z) { compileWgSize[0] = x; compileWgSize[1] = y; compileWgSize[2] = z; }
    /*! Get required work group size. */
    const size_t *getCompileWorkGroupSize(void) const {return compileWgSize;}
    /*! Set function attributes string. */
    void setFunctionAttributes(const std::string& functionAttributes) {  this->functionAttributes= functionAttributes; }
    /*! Get function attributes string. */
    const std::string& getFunctionAttributes(void) const {return this->functionAttributes;}
    /*! Get stack size. */
    INLINE uint32_t getStackSize(void) const { return this->stackSize; }
    /*! Push stack size. */
    INLINE void pushStackSize(uint32_t step) { this->stackSize += step; }
    /*! add the loop info for later liveness analysis */
    void addLoop(LabelIndex preheader,
                 int parent,
                 const vector<LabelIndex> &bbs,
                 const vector<std::pair<LabelIndex, LabelIndex>> &exits);
    INLINE const vector<Loop * > &getLoops() { return loops; }
    int getLoopDepth(LabelIndex Block) const;
    vector<BasicBlock *> &getBlocks() { return blocks; }
    /*! Get surface starting address register from bti */
    Register getSurfaceBaseReg(uint8_t bti) const;
    void appendSurface(uint8_t bti, Register reg);
    /*! Get instruction distance between two BBs include both b0 and b1,
        and b0 must be less than b1. */
    INLINE uint32_t getDistance(LabelIndex b0, LabelIndex b1) const {
      uint32_t insnNum = 0;
      GBE_ASSERT(b0.value() <= b1.value());
      for(uint32_t i = b0.value(); i <= b1.value(); i++) {
        BasicBlock &bb = getBlock(LabelIndex(i));
        insnNum += bb.size();
      }
      return insnNum;
    }
    /*! Output the control flow graph to .dot file */
    void outputCFG();
    uint32_t getOclVersion(void) const;
    /*! Does it use device enqueue */
    INLINE bool getUseDeviceEnqueue(void) const { return this->useDeviceEnqueue; }
    /*! Change the device enqueue infor of the function */
    INLINE bool setUseDeviceEnqueue(bool useDeviceEnqueue) {
      return this->useDeviceEnqueue = useDeviceEnqueue;
    }
  private:
    friend class Context;           //!< Can freely modify a function
    std::string name;               //!< Function name
    const Unit &unit;               //!< Function belongs to this unit
    vector<FunctionArgument*> args; //!< Input registers of the function
    vector<Register> outputs;       //!< Output registers of the function
    vector<BasicBlock*> labels;     //!< Each label points to a basic block
    vector<Immediate> immediates;   //!< All immediate values in the function
    vector<BasicBlock*> blocks;     //!< All chained basic blocks
    vector<Loop *> loops;           //!< Loops info of the function
    map<uint8_t, Register> btiRegMap;//!< map bti to surface base address
    RegisterFile file;              //!< RegisterDatas used by the instructions
    Profile profile;                //!< Current function profile
    PushMap pushMap;                //!< Pushed function arguments (reg->loc)
    LocationMap locationMap;        //!< Pushed function arguments (loc->reg)
    uint32_t simdWidth;             //!< 8 or 16 if forced, 0 otherwise
    bool useSLM;                    //!< Is SLM required?
    uint32_t slmSize;               //!< local variable size inside kernel function
    uint32_t stackSize;             //!< stack size for private memory.
    SamplerSet *samplerSet;         //!< samplers used in this function.
    ImageSet* imageSet;             //!< Image set in this function's arguments..
    PrintfSet *printfSet;           //!< printfSet store the printf info.
    size_t compileWgSize[3];        //!< required work group size specified by
                                    //   __attribute__((reqd_work_group_size(X, Y, Z))).
    std::string functionAttributes; //!< function attribute qualifiers combined.
    int32_t wgBroadcastSLM;         //!< Used for broadcast the workgroup value.
    int32_t tidMapSLM;              //!< Used to store the map between groupid and hw thread.
    bool useDeviceEnqueue;          //!< Has device enqueue?
    GBE_CLASS(Function);            //!< Use custom allocator
  };

  /*! Output the function string in the given stream */
  std::ostream &operator<< (std::ostream &out, const Function &fn);

} /* namespace ir */
} /* namespace gbe */

#endif /* __GBE_IR_FUNCTION_HPP__ */

