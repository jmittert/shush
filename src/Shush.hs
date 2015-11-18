{-|
Module        : Shush
Description   : Network functions for Shush
Copyright     : (c) Jason Mittertreiner, 2015
License       : GPL-3
Maintainer    : jmittert@uwaterloo.ca
Stability     : experimental
Portability   : Unix

This module contains various network functions to handle HTTP request
 -}
module Shush where
import Network.Socket
import qualified Data.Map.Strict as Map
import Utils
import HttpRequest
import Config

-- | Sends a 404 to a socket request
send404_11 :: Socket -> IO Int
send404_11 sock =
    send sock $ status404_11 ++ (genHeader.length) body404 ++ "\r\n" ++ body404

-- | Sends a HTTP 1.0 response to a socket request
sendHTTP1_0 :: HTTPRequest -> Socket -> IO Int
sendHTTP1_0 req sock = do
    config <- parseConfigFile "shush.conf"
    let http_path = getValue config "http_path"
    body <- readFile $ http_path ++ "/" ++ "index.html"
    send sock $ createResponse body

-- | Reads a File into a response
createResponse :: String -> String
createResponse body = status200_10
        ++ genHeader (length body)
        ++ case body of
            [] -> ""
            y:ys -> "\r\n" ++ body

-- | HTTP 200 1.0 response
status200_10 = "HTTP/1.0 200 OK\r\n"
-- | HTTP 404 1.0 response
status404_10 = "HTTP/1.0 404 Not Found\r\n"
-- | HTTP 200 1.1 response
status200_11 = "HTTP/1.1 200 OK\r\n"
-- | HTTP 404 1.1 response
status404_11 = "HTTP/1.1 404 Not Found\r\n"

-- | 404 HTML String
body404 = "<html>\r\n<head>\r\n<title>404 Not Found</title>\n\r</head>\
\\r\n<body><p><strong>404 Not Found</strong></p></body>\r\n</html>\r\n"

-- | Generates appriate headers for a body length
genHeader :: Int -> String
genHeader len = "Server: Shush/0.1\r\n" ++
    "Last-Modified: Thu, 29 Oct 2015 10:35:00 GMT\r\n" ++
    "Content-Type: text/html\r\n" ++
    "Content-Length: " ++ show len ++ "\r\n"

-- | Send a HTTP 1.1 request
sendHTTP1_1 :: HTTPRequest -> Socket -> IO Int
sendHTTP1_1 req sock = undefined
