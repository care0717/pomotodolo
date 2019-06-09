port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (Html, div, i, p, section, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Platform.Cmd exposing (Cmd)
import Task
import Time


port notifyUser : () -> Cmd msg


port notified : (Bool -> msg) -> Sub msg



-- MODEL


initTime =
    3


type alias Model =
    { timer : Int
    , isStart : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model initTime False
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | DoTimer
    | Reset
    | Notification
    | Notified Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            let
                c =
                    if model.isStart then
                        model.timer - 1

                    else
                        model.timer

                status =
                    if c < 0 then
                        update Notification model

                    else
                        ( { model | timer = c }
                        , Cmd.none
                        )
            in
            status

        DoTimer ->
            let
                isStart =
                    not model.isStart
            in
            ( { model | isStart = isStart }, Cmd.none )

        Reset ->
            ( { model | timer = initTime, isStart = False }
            , Cmd.none
            )

        Notification ->
            ( model, notifyUser () )

        Notified _ ->
            update Reset model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ notified Notified, Time.every 1000 Tick ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        c =
            String.fromInt model.timer

        bt =
            if model.isStart then
                "fas fa-stop"

            else
                "fas fa-play"
    in
    section [ class "section" ]
        [ div [ class "container" ]
            [ div
                []
                [ p [ class "title" ] [ text c ]
                ]
            , div
                [ class "icon is-large button", type_ "button", onClick DoTimer ]
                [ i [ class bt ] []
                ]
            , div
                [ class "icon is-large button", type_ "button", onClick Reset ]
                [ i [ class "fas fa-undo" ] []
                ]
            ]
        ]


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
