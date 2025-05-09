using Gismo
using Test

@testset verbose = true "jl" begin
    @testset verbose = true "bases" begin
        @testset "constructors" begin
            @test_nowarn(KV = KnotVector([0.,0.,0.,1.,1.,1.]))
            KV = KnotVector([0.,0.,0.,1.,1.,1.])
            @test_nowarn(TBB = TensorBSplineBasis(KV,KV))
            TBB = TensorBSplineBasis(KV,KV)
            @test_nowarn(THB = THBSplineBasis(TBB))
            THB = THBSplineBasis(TBB)
        end

        # @testset "print" begin
        #     KV = KnotVector([0.,0.,0.,1.,1.,1.])
        #     TBB = TensorBSplineBasis(KV,KV)
        #     THB = THBSplineBasis(TBB)

        #     oldstd = stdout
        #     redirect_stdout(devnull)
        #     @test_nowarn(print(KV))
        #     @test_nowarn(print(TBB))
        #     @test_nowarn(print(THB))
        #     redirect_stdout(oldstd) # recover original stdout
        # end

        @testset "refinement" begin
            KV = KnotVector([0.,0.,0.,1.,1.,1.])
            TBB = TensorBSplineBasis(KV,KV)
            THB = THBSplineBasis(TBB)
            @test_nowarn(uniformRefine!(TBB))
            @test_nowarn(uniformRefine!(THB))
            boxes = Matrix{Cdouble}([0.0 0.5; 0.0 0.5])
            @test_nowarn(refine!(THB,boxes))
            boxes = Vector{Cint}([1,0,0,2,2])
            @test_nowarn(refineElements!(THB,boxes))
        end


    end
    @testset verbose = true "splines" begin
        @testset "constructors" begin
            KV = KnotVector([0.,0.,0.,1.,1.,1.])
            TBB = TensorBSplineBasis(KV,KV)
            THB = THBSplineBasis(TBB)

            coefs_TBB = rand(size(TBB),3)
            @test_nowarn(TB = TensorBSpline(TBB,coefs_TBB))
            coefs_THB = rand(size(THB),3)
            @test_nowarn(THB = TensorBSpline(THB,coefs_THB))
        end

        @testset "evaluation" begin
            KV = KnotVector([0.,0.,0.,1.,1.,1.])
            TBB = TensorBSplineBasis(KV,KV)
            THB = THBSplineBasis(TBB)
            coefs_TBB = rand(size(TBB),3)
            TB = TensorBSpline(TBB,coefs_TBB)
            coefs_THB = rand(size(THB),3)
            THB = TensorBSpline(THB,coefs_THB)

            N = 10
            points1D = range(0,stop=1,length=N)
            points2D = zeros(2,N*N)
            points2D[1,:] = repeat(points1D, N)
            points2D[2,:] = repeat(points1D, inner=N)
            @test_nowarn(ev = asMatrix(val(TB,points2D)))
            @test_nowarn(ev = asMatrix(val(THB,points2D)))
        end
    end
end