module MyApp exposing (..)

import IO exposing (IO)
import Cli exposing (CliProgram)


main : CliProgram
main =
    Cli.run program


program : IO ()
program =
    IO.do (askName) <| \name ->
    IO.do (IO.writeLine <| "Hello " ++ name) <| \_ ->
    IO.do (askAge) <| \age ->
    if age > 18 then
        IO.writeLine "You are an adult"
    else
        IO.writeLine "You are minor..."


askName : IO String
askName =
    IO.do (IO.writeLine "What's your name?") <| \_ ->
    IO.readLine


askAge : IO Float
askAge =
    IO.do (IO.writeLine "What's your age?") <| \_ ->
    IO.do (IO.readLine) <| \age ->
    case String.toFloat age of
        Just f ->
            IO.return f

        Nothing ->
            IO.do (IO.writeLine "Not a number, try again") <| \_ ->
            askAge
