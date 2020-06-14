module MyApp exposing (..)

import IO exposing (IO)
import Cli exposing (CliProgram)


main : CliProgram
main =
    Cli.run program


program : IO ()
program =
    IO.do (askName) <| \name ->
    IO.do (IO.writeLn <| "Hello " ++ name) <| \_ ->
    IO.do (askAge) <| \age ->
    if age > 18 then
        IO.writeLn "You are an adult"
    else
        IO.writeLn "You are minor..."


askName : IO String
askName =
    IO.do (IO.writeLn "What's your name?") <| \_ ->
    IO.readLine


askAge : IO Float
askAge =
    IO.do (IO.writeLn "What's your age?") <| \_ ->
    IO.do (IO.readLine) <| \age ->
    case String.toFloat age of
        Just f ->
            IO.return f

        Nothing ->
            IO.do (IO.writeLn "Not a number, try again") <| \_ ->
            askAge
