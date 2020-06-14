module IO exposing
    ( IO, return, writeLine, readLine, do, exit
    , Effect(..), Process, start, step
    )

{-|


# Write IO programs

@docs IO, return, writeLine, readLine, do, exit

# Run IO

@docs Effect, Process, start, step

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)

{-| The effect that should be performed
-}
type Effect
    = WriteLn String
    | ReadLine
    | Exit
    | NoOp


{-| The "rest" of your IO monad program.
-}
type Process
    = Process (Decoder ( Process, Effect ))


{-| This is the building blocks of a program.
-}
type IO a
    = IO ((a -> ( Process, Effect )) -> ( Process, Effect ))


{-| Compose two IO "pieces" to one.

This is the same concept as `andThen` but with
the arguments flipped.
-}
do : IO a -> (a -> IO b) -> IO b
do (IO fn) cont =
    IO
        (\next ->
            fn
                (\a ->
                    let
                        (IO io2) =
                            cont a
                    in
                    io2 next
                )
        )

{-| Wrap a value

Same concept as `Decode.succeed`.

-}
return : a -> IO a
return a =
    IO
        (\next ->
            ( Decode.succeed a
                |> Decode.map next
                |> Process
            , NoOp
            )
        )


{-| Read a line from the user.
-}
readLine : IO String
readLine =
    IO
        (\next ->
            ( Decode.string
                |> Decode.map next
                |> Process
            , ReadLine
            )
        )

{-| Print a line to the console. A new line
is added to the output.
-}
writeLine : String -> IO ()
writeLine str =
    IO
        (\next ->
            ( Decode.succeed ()
                |> Decode.map next
                |> Process
            , WriteLn str
            )
        )

{-| Exit the program.
-}
exit : IO ()
exit =
    IO
        (\_ ->
            ( Decode.fail "Exited"
                |> Process
            , Exit
            )
        )


{-| Step to the next instruction of your process.
-}
step : Value -> Process -> ( Process, Effect )
step value (Process decoder) =
    case Decode.decodeValue decoder value of
        Ok ( nextProcess, nextEffect ) ->
            ( nextProcess
            , nextEffect
            )

        Err err ->
            ( Process decoder
            , NoOp
            )


{-| Create a `Process` from an IO program.
-}
start : IO () -> ( Process, Effect )
start (IO io) =
    let
        done _ =
            ( Decode.fail "Exited"
                |> Process
            , Exit
            )
    in
    io done
