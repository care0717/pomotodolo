module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (Html, div, h1, img, input, text)
import Html.Attributes exposing (class, src, type_, value)
import Html.Events exposing (onClick)
import Task
import Time



-- MODEL

initTime = 250

type alias Model =
    { zone : Time.Zone
    , timer : Int
    , isStart : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc initTime False
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | DoTimer
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            let
                c =
                    if model.isStart then
                        model.timer - 1

                    else
                        model.timer
            in
            ( { model | timer = c }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        DoTimer ->
            let
                r = not model.isStart
            in
            ( { model | isStart = r }, Cmd.none )

        Reset ->
            ( { model | timer = initTime, isStart = False }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        c =
            String.fromInt model.timer

        bt =
            if model.isStart then
                "Stop!"

            else
                "Start"

        btClass =
            if model.isStart then
                "bt stop-bt"

            else
                "bt"
    in
    div [ class "grid-container" ]
        [ div [ class "start" ]
            [ div
                [ class "area-overlap start-bt" ]
                [ input [ type_ "button", value bt, onClick DoTimer, class btClass ] []
                ]
            ]
        , div
            [ class "counter" ]
            [ h1 [] [ text c ]
            ]
        , div
            [ class "reset" ]
            [ input [ type_ "button", value "Reset", onClick Reset, class "bt reset-bt" ] []
            ]
        ]


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
