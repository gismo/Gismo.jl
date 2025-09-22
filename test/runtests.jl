using Gismo
using SparseArrays
using Test

@testset verbose = true "Gismo.jl" begin
    @testset verbose = true "Eigen" begin
        @testset "matrixDouble" begin
            empty = EigenMatrix(3, 3)
            @test rows(empty) == 3
            @test cols(empty) == 3

            M0 = Matrix{Cdouble}([1.0 2.0 3.0; 4.0 5.0 6.0; 7.0 8.0 9.0])
            m = EigenMatrix(M0)

            @test rows(m) == 3
            @test cols(m) == 3
            @test M0 == copyMatrix(m)
        end

        @testset "matrixInt" begin
            empty = EigenMatrixInt(3, 3)
            @test rows(empty) == 3
            @test cols(empty) == 3

            M0 = Matrix{Cint}([1 2 3; 4 5 6; 7 8 9])
            m = EigenMatrixInt(M0)

            @test rows(m) == 3
            @test cols(m) == 3
            @test M0 == copyMatrix(m)
        end

        @testset "sparseMatrix" begin
            @test_nowarn (m = EigenSparseMatrix())
            R = C = Vector{Cint}([1; 2; 3])
            V = [1.0; 2.0; 3.0]
            @test_nowarn (m = EigenSparseMatrix(R, C, V))
            M = sparse(R, C, V);
            @test_nowarn (m = EigenSparseMatrix(M))
            EM = EigenSparseMatrix(M)
            @test rows(EM) == 3
            @test cols(EM) == 3
            @test Gismo.nnz(EM) == 3
            @test M == copyMatrix(EM)
            (Rows, Cols, Vals) = findnz(M)
            @test Rows == R
            @test Cols == C
            @test Vals == V
        end
    end

    @testset verbose = true "bases" begin
        @testset "constructors" begin
            @test_nowarn(KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0]))
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            @test_nowarn(TBB = TensorBSplineBasis(KV, KV))
            TBB = TensorBSplineBasis(KV, KV)
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
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            THB = THBSplineBasis(TBB)
            @test size(TBB) == 9
            @test size(THB) == 9

            @test_nowarn(uniformRefine!(TBB))
            @test_nowarn(uniformRefine!(THB))
            @test size(TBB) == 16
            @test size(THB) == 16

            boxes = Matrix{Cdouble}([0.0 0.5; 0.0 0.5])
            @test_nowarn(refine!(THB, boxes))
            @test size(THB) == 19

            boxes = Vector{Cint}([2, 0, 0, 2, 2])
            @test_nowarn(refineElements!(THB, boxes))
            @test size(THB) == 22
            @test getLevelAtPoint(THB, [0.125, 0.125]) == 2
        end

        @testset "elements" begin
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            uniformRefine!(TBB)
            THB = THBSplineBasis(TBB)
            @test numElements(TBB) == 4

            boxes = Matrix{Cdouble}([0.0 0.5; 0.0 0.5])
            refine!(THB, boxes)
            @test numElements(THB) == 7

            (knotBoxes, indexBoxes, levelBoxes) = getElementData(THB)
            @test rows(knotBoxes) == 2 #d
            @test cols(knotBoxes) == 7*2
            @test rows(indexBoxes) == 2*2+1 #2*d+1
            @test cols(indexBoxes) == 7
            @test rows(levelBoxes) == 7
        end

        @testset "boundary" begin
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            uniformRefine!(TBB)
            @test rows(boundary(TBB, 1))==4
            @test rows(boundaryOffset(TBB, 1, 0))==4

            THB = THBSplineBasis(TBB)
            boxes = Matrix{Cdouble}([0.0 0.5; 0.0 0.5])
            refine!(THB, boxes)
            @test rows(boundary(THB, 1))==5
            @test rows(boundaryOffset(THB, 1, 0))==5
        end

        @testset "evaluation" begin
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            uniformRefine!(TBB)
            THB = THBSplineBasis(TBB)

            N = 10
            points1D = range(0, stop = 1, length = N)
            points2D = zeros(2, N*N)
            points2D[1, :] = repeat(points1D, N)
            points2D[2, :] = repeat(points1D, inner = N)

            @test_nowarn(acts = copyMatrix(actives(TBB, points2D)))
            @test_nowarn(acts = copyMatrix(actives(THB, points2D)))
            @test_nowarn(vals = copyMatrix(val(TBB, points2D)))
            @test_nowarn(vals = copyMatrix(val(THB, points2D)))
            @test_nowarn(der = copyMatrix(deriv(TBB, points2D)))
            @test_nowarn(der = copyMatrix(deriv(THB, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(TBB, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(THB, points2D)))

            @test_nowarn ((val) = compute(TBB, points2D, 0))
            @test_nowarn ((val) = compute(THB, points2D, 0))
            @test_nowarn ((val, der) = compute(TBB, points2D, 1))
            @test_nowarn ((val, der) = compute(THB, points2D, 1))
            @test_nowarn ((val, der, der2) = compute(TBB, points2D, 2))
            @test_nowarn ((val, der, der2) = compute(THB, points2D, 2))

            i = 1
            @test_nowarn(vals = copyMatrix(val(TBB, i, points2D)))
            @test_nowarn(vals = copyMatrix(val(THB, i, points2D)))
            @test_nowarn(der = copyMatrix(deriv(TBB, i, points2D)))
            @test_nowarn(der = copyMatrix(deriv(THB, i, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(TBB, i, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(THB, i, points2D)))
        end
    end
    @testset verbose = true "splines" begin
        @testset "constructors" begin
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            THB = THBSplineBasis(TBB)

            coefs_TBB = rand(size(TBB), 3)
            @test_nowarn(TB = TensorBSpline(TBB, coefs_TBB))
            coefs_THB = rand(size(THB), 3)
            @test_nowarn(THB = TensorBSpline(THB, coefs_THB))
        end

        @testset "evaluation" begin
            KV = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0])
            TBB = TensorBSplineBasis(KV, KV)
            THB = THBSplineBasis(TBB)
            coefs_TBB = rand(size(TBB), 3)
            TB = TensorBSpline(TBB, coefs_TBB)
            coefs_THB = rand(size(THB), 3)
            THB = TensorBSpline(THB, coefs_THB)

            N = 10
            points1D = range(0, stop = 1, length = N)
            points2D = zeros(2, N*N)
            points2D[1, :] = repeat(points1D, N)
            points2D[2, :] = repeat(points1D, inner = N)
            @test_nowarn(vals = copyMatrix(val(TB, points2D)))
            @test_nowarn(vals = copyMatrix(val(THB, points2D)))
            @test_nowarn(der = copyMatrix(deriv(TB, points2D)))
            @test_nowarn(der = copyMatrix(deriv(THB, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(TB, points2D)))
            @test_nowarn(der2 = copyMatrix(deriv2(THB, points2D)))

            @test_nowarn ((val) = compute(TB, points2D, 0))
            @test_nowarn ((val) = compute(THB, points2D, 0))
            @test_nowarn ((val, der) = compute(TB, points2D, 1))
            @test_nowarn ((val, der) = compute(THB, points2D, 1))
            @test_nowarn ((val, der, der2) = compute(TB, points2D, 2))
            @test_nowarn ((val, der, der2) = compute(THB, points2D, 2))
        end
    end

    @testset verbose = true "optionlist" begin
        @testset "setDict" begin
            options = Dict([("a", 1), ("b", 1.1), ("c", true), ("d", "one")])
            gsOptionList = OptionList(options)
            @test getInt(gsOptionList, "a") == 1
            @test getReal(gsOptionList, "b") == 1.1
            @test getSwitch(gsOptionList, "c") == true
            # Conversion from Cstring to String is not supported
            # @test getString(gsOptionList,"d") == "one"
        end

        @testset "setSeparate" begin
            gsOptionList = OptionList()
            addInt(gsOptionList, "a", 2)
            addReal(gsOptionList, "b", 2.0)
            addSwitch(gsOptionList, "c", false)
            addString(gsOptionList, "d", "two")
            @test getInt(gsOptionList, "a") == 2
            @test getReal(gsOptionList, "b") == 2.0
            @test getSwitch(gsOptionList, "c") == false
            # Conversion from Cstring to String is not supported
            # @test getString(gsOptionList,"d") == "two"
        end
    end

    @testset verbose = true "quadrule" begin
        @testset "1D" begin
            rule1D = GaussRule(Cint(2))
            nodes, weights = mapTo(rule1D, 0.0, 1.0)
            @test rows(nodes) == 1
            @test cols(nodes) == 2
            @test rows(weights) == 2
            @test cols(weights) == 0
        end

        @testset "2D" begin
            rule2D = LobattoRule(Cint(2), Array{Cint}([3, 3]))
            low = Vector{Float64}([0.0, 0.0])
            upp = Vector{Float64}([1.0, 1.0])
            nodes, weights = mapTo(rule2D, low, upp)
            @test rows(nodes) == 2
            @test cols(nodes) == 9
            @test rows(weights) == 9
            @test cols(weights) == 0
        end
    end
end
