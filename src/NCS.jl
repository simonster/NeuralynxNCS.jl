module NCS
using PiecewiseIncreasingRanges, Compat

immutable NCSContinuousChannel
    header::ByteString
    samples::Vector{Int16}
    times::PiecewiseIncreasingRange{Float64,StepRange{Int64,Int64},Int64}
end

immutable NCSRecordHeader
    qwTimeStamp::UInt64
    dwChannelNumber::UInt32
    dwSampleFreq::UInt32
    dwNumValidSamples::UInt32
end

Base.read(io::IO, ::Type{NCSRecordHeader}) =
    NCSRecordHeader(read(io, UInt64), read(io, UInt32), read(io, UInt32), read(io, UInt32))

function compute_times(rec::NCSRecordHeader, sample_multiplier::Int64, step::Int64)
    @compat first_sample = Int64(rec.qwTimeStamp)*sample_multiplier
    first_sample:step:first_sample+step*(rec.dwNumValidSamples-1)
end

function readncs(filename::String)
    io = open(filename, "r")
    try
        header = rstrip(bytestring(read(io, UInt8, 16384)), '\0')
        eof(io) && return NCSContinuousChannel(header, Int16[], PiecewiseIncreasingRange(StepRange{Int,Int}[], 1))

        nrecs = div(filesize(filename)-16384, 1044)
        sample_buffer = Array(Int16, 512)
        samples = Array(Int16, nrecs*512)
        nsamples = 0
        times = Array(StepRange{Int,Int}, nrecs)

        # Read first header so we can save its channel number to make
        # sure we only have one
        rec1 = read(io, NCSRecordHeader)
        read!(io, sample_buffer)
        copy!(samples, nsamples+1, sample_buffer, 1, rec1.dwNumValidSamples)
        nsamples += rec1.dwNumValidSamples

        # Figure out range multipliers
        @compat divisor = lcm(Int64(rec1.dwSampleFreq), 10^6)
        sample_multiplier = div(divisor, 10^6)
        @compat step = div(divisor, Int64(rec1.dwSampleFreq))

        nrecs = 1
        times[1] = compute_times(rec1, sample_multiplier, step)

        while !eof(io)
            rec = read(io, NCSRecordHeader)
            rec.dwChannelNumber == rec1.dwChannelNumber || error("only one channel supported per file")
            rec.dwSampleFreq == rec1.dwSampleFreq || error("sample rate is non-constant")
            read!(io, sample_buffer)
            copy!(samples, nsamples+1, sample_buffer, 1, rec.dwNumValidSamples)
            nsamples += rec.dwNumValidSamples
            nrecs += 1
            times[nrecs] = compute_times(rec, sample_multiplier, step)
        end

        resize!(samples, nsamples)
        resize!(times, nrecs)

        return NCSContinuousChannel(header, samples, PiecewiseIncreasingRange(times, divisor))
    finally
        close(io)
    end
end

export readncs
end

