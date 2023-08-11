#include "llvm/Analysis/CallGraph.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/IR/InstVisitor.h"

#include "seadsa/AllocWrapInfo.hh"
#include "seadsa/DsaLibFuncInfo.hh"

#include "clam/Clam.hh"
#include "clam/CfgBuilder.hh"
#include "clam/HeapAbstraction.hh"
#include "clam/SeaDsaHeapAbstraction.hh"

using namespace clam;
using namespace llvm;

// Size Estimator of Allocated Objects via malloc
class AllocSizeVisitor: public InstVisitor<AllocSizeVisitor> {
  InterGlobalClam& m_analyzer;
  
public:
  AllocSizeVisitor(InterGlobalClam &analyzer)
    : m_analyzer(analyzer) {}
  
  void visitCallBase(CallBase &CB) {
    if (const Function* calleeF = CB.getCalledFunction()) {
      if (calleeF->getName() == "malloc") {
	ConstantRange interval = m_analyzer.range(CB, 1);
	llvm::outs() << "The size of the allocated object at " << CB << " is " << interval << "\n";
      }
    }
  }
};

void outputResults(Module &M, const InterGlobalClam &ana);

int main(int argc, char *argv[]) {
  if (argc < 2) {
    llvm::errs() << "Not found input file\n";
    llvm::errs() << "Usage " << argv[0] << " " << "FILE.bc\n";
    return 1;
  }
  
  //////////////////////////////////////  
  // Get module from LLVM file
  //////////////////////////////////////  
  LLVMContext Context;
  SMDiagnostic Err;
  std::unique_ptr<Module> M = parseIRFile(argv[1], Err, Context);
  if (!M) {
    Err.print(argv[0], errs());
    return 1;
  }
  

  //////////////////////////////////////
  // Run seadsa -- pointer analysis
  //////////////////////////////////////  
  CallGraph cg(*M);
  TargetLibraryInfoWrapperPass tliw;    
  seadsa::AllocWrapInfo allocWrapInfo(&tliw);
  allocWrapInfo.initialize(*M, nullptr);
  seadsa::DsaLibFuncInfo dsaLibFuncInfo;
  dsaLibFuncInfo.initialize(*M);
  SeaDsaHeapAbstractionParams params;
  std::unique_ptr<HeapAbstraction> mem =
    std::make_unique<SeaDsaHeapAbstraction>(*M, cg, tliw, allocWrapInfo, dsaLibFuncInfo, params);

  //////////////////////////////////////  
  // Run Clam inter-procedural analysis
  //////////////////////////////////////
  
  /// Translation from LLVM to CrabIR
  CrabBuilderParams cparams;
  // Translate all memory operations using seadsa
  cparams.setPrecision(clam::CrabBuilderPrecision::MEM);
  // Deal with unsigned comparisons
  cparams.lowerUnsignedICmpIntoSigned();
  // Disable warning messages
  crab::CrabEnableWarningMsg(false);
  CrabBuilderManager man(cparams, tliw, std::move(mem));
  
  /// Set Crab parameters
  AnalysisParams aparams;
  // Use the interval domain
  aparams.dom = CrabDomain::INTERVALS;
  // Enable inter-procedural analysis
  aparams.run_inter = true;
  // Check for assertions
  //aparams.check = clam::CheckerKind::ASSERTION;
  
  /// Create an inter-analysis instance 
  InterGlobalClam ga(*M, man);
  /// Run the Crab analysis
  ClamGlobalAnalysis::abs_dom_map_t assumptions;
  ga.analyze(aparams, assumptions);


  ///////////////////////////////////////////////////////  
  // Run our new size estimator for allocated objects
  //////////////////////////////////////////////////////
  
  AllocSizeVisitor ASV(ga);
  ASV.visit(*M);
  
  return 0;
}




///////////////////////////////////////////////////////////////////

void outputResults(Module &M, const InterGlobalClam &ana) {

  // 1. Ask the Clam analysis for the invariants that hold at the
  // entry of each basic block.
  llvm::outs() << "===Invariants at the entry of each block===\n";
  for (auto &f: M) {
    for (auto &b: f) {
      llvm::Optional<clam_abstract_domain> dom = ana.getPre(&b);
      if (dom.hasValue()) {
	llvm::outs() << f.getName() << "#" << b.getName() << ":\n";
	crab::outs() << dom.getValue() << "\n";
      }
    }
  }

#if 0  
  // 2. Ask the Clam analysis API for the ranges of LLVM values
  llvm::outs() << "===Ranges for each Instruction's definition===\n";
  for (auto &f: M) {
    for (auto &b: f) {
      for (auto &i: b) {
	if (!i.getType()->isVoidTy()) {
	  auto rangeVal = ana.range(i);
	  llvm::outs() << "Range for " << i << " = " << rangeVal << "\n";
	}
      }
    }
  }
#endif
  
  /// 3. Print results about assertion checks
  llvm::outs() << "===Assertion checks ===\n";
  ana.getChecksDB().write(crab::outs());
}
