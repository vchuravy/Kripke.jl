using ClangCompiler
using ClangCompiler.LLVM

# TODO:
# - Kripke needs to install headers into prefix dir
# - Kripke needs to install libs into prefix
# - Fix LLVM13 and then try StaticLibrary
# - add a cxx"" macro instead of requiring files
# - CXX Types and ABI
# - function name mangling


# source file
KRIPKE_SRC = "/home/vchuravy/src/Kripke/"
PREFIX = "/home/vchuravy/llnl_prefix"
src = joinpath(@__DIR__, "miniKripke.cpp")

# compilation flags
args = get_compiler_args()
push!(args, "-I" * joinpath(PREFIX, "include"))
push!(args, "-I" * joinpath(KRIPKE_SRC, "src"))
push!(args, "-I" * joinpath(KRIPKE_SRC, "build", "include"))

# generate LLVM IR
irgen = IRGenerator(src, args)

# create JIT
jit = LLJIT(;tm=JITTargetMachine())
cc = CXCompiler(irgen, jit)

# LLVM.load_library_permantly(joinpath(KRIPKE_SRC, "build", "lib", "libkripke.so"))

link_process_symbols(cc)
const libkripke = joinpath(KRIPKE_SRC, "build", "lib", "libkripke.so")
LLVM.add!(get_dylib(cc), LLVM.DynamicLibDefinitionGenerator(libkripke))

# compile and link
compile(cc)

# lookup and call the main function 
addr = lookup(jit, "main")
@eval main() = ccall($(pointer(addr)), Cint, ())

main()

# clean up
dispose(cc)
