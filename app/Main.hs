{-|
Module        : Main
Description  : Shush is a Simple HTTP server
Copyright     : (c) Jason Mittertreiner, 2015
License       : GPL-3
Maintainer    : jmittert@uwaterloo.ca
Stability     : experimental
Portability   : Unix

Shush Main module
 -}
module Main where
import Config
import Shush
import HttpRequest
import HttpResponse
import Network.Socket

{-|
 - Listen on a port to respond to HTTP Requests
-}
main :: IO ()
main = do
    -- create socket
    sock <- socket AF_INET Stream 0

    {--
        - ReuseAddr does two things: it allows you to bind to any address that
        - the socket even when a previously kill process is still in TIME_WAIT
        -
        - https://stackoverflow.com/questions/14388706/socket-options-so-reuseaddr-and-so-reuseport-how-do-they-differ-do-they-mean-t
    --}
    setSocketOption sock ReuseAddr 1

    -- listen on specified port
    bindSocket sock (SockAddrInet 80 iNADDR_ANY)
    -- allow a maximum of 1 outstanding connections
    listen sock 1
    mainLoop sock

-- | Accept one connection and handle it
mainLoop :: Socket -> IO ()
mainLoop sock = do
  conn <- accept sock
  runConn conn
  mainLoop sock

-- | Manages a Socket request
runConn :: (Socket, SockAddr) -> IO ()
runConn (sock, _) = do
    mesg <- recv sock 4069
    putStrLn mesg
    case parseRequest mesg of
        Right req ->
            case version req of
                HTTP_10 -> sendHTTP1_0 req sock
                HTTP_11 -> sendHTTP1_1 req sock
        Left req -> do
            res <- http404_10
            send sock $ show res
    sClose sock
