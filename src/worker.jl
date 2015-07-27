
import Base.TcpSocket

const END_OF_DATA_SECTION = -1
const JULIA_EXCEPTION_THROWN = -2
const TIMING_DATA = -3
const END_OF_STREAM = -4
const NULL = -5

readint(sock::TcpSocket) = ntoh(read(sock, Int32))

function readobj(sock::TcpSocket)
    len = readint(sock)
    bytes = readbytes(sock, len)
    return bytes
end

writeint(sock::TcpSocket, x::Int) = write(sock, hton(int32(x)))

function writeobj(sock::TcpSocket, obj::Vector{Uint8})
    writeint(sock, length(obj))
    write(sock, obj)
end

writeobj(sock::TcpSocket, obj) = writeobj(sock, convert(Vector{Uint8}, obj))

## function launch_worker()
##     port = int(readline(STDIN))
##     info("JuliaWorker: Connecting to port $(port)!")
##     sock = connect("127.0.0.1", port)
##     info("JuliaWorker: Connected!")
##     part_id = readint(sock)
##     info("JuliaWorker: partition id = $part_id")
##     cmd = readobj(sock)
##     info("JuliaWorker: cmd bytes = $cmd")
##     writeobj(sock, "hello")
##     writeobj(sock, "I'm working...")
##     writeobj(sock, "good bye")
##     info("JuliaWorker: Wrote object")
##     write(sock, -1)
##     info("JuliaWorker: Exiting")
## end

function launch_worker()
    try
        port = int(readline(STDIN))
        info("JuliaWorker: Connecting to port $(port)!")
        sock = connect("127.0.0.1", port)
        info("JuliaWorker: Connected!")
        part_id = readint(sock)
        info("JuliaWorker: partition id = $part_id")
        cmd = readobj(sock)
        info("JuliaWorker: cmd bytes = $cmd")
        writeobj(sock, "hello")
        writeobj(sock, "I'm working...")
        writeobj(sock, "good bye")
        info("JuliaWorker: Wrote object")
        writeint(sock, END_OF_DATA_SECTION)
        writeint(sock, END_OF_STREAM)
        info("JuliaWorker: Exiting")
    catch e
        # TODO: handle the case when JVM closes connection 
        writeint(sock, JULIA_EXCEPTION_THROWN)
        # TODO: write stacktrace to the socket
        exit(-1)
    end
end


