using NeuralynxNCS, Base.Test

ncs = readncs(joinpath(dirname(@__FILE__), "TestFile.Ncs"))
@test ncs.header == "######## Neuralynx\r\nTest File\r\n"
@test ncs.samples == [typemin(Int16):typemax(Int16);]
dt = 1/32000
@test ncs.times == [0:dt:dt*512*128-dt;]
@test length(ncs.times.ranges) == 1
