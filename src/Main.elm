module Main exposing (..)

import Playground exposing (..)
import Time exposing (..)



--Model--


main =
    game view update initModel


initModel : Model
initModel =
    { wesMoves = { x = -300, y = 0 }
    , lastShotFired = NeverFired
    , shotBullets = [ NotFired ]
    }


type LastShotFired
    = NeverFired
    | LastFiredStamp Time


type alias Model =
    { wesMoves : WesMoves
    , lastShotFired : LastShotFired
    , shotBullets : List ShotBullet
    }


type alias WesMoves =
    { x : Number, y : Number }


type alias InFlightPosition =
    Number


type alias FrozenOriginWesOffset =
    WesMoves


type ShotBullet
    = NotFired
    | Fired InFlightPosition FrozenOriginWesOffset



--Update--


update : Computer -> Model -> Model
update computer model =
    let
        updatedWesMoves =
            { x = model.wesMoves.x + toX computer.keyboard
            , y = model.wesMoves.y + toY computer.keyboard
            }

        updatedBulletShoots =
            updateBulletsShot computer model

        updatedLastFired =
            updateLastFired computer model.lastShotFired
    in
    { model
        | wesMoves = updatedWesMoves
        , lastShotFired = updatedLastFired
        , shotBullets = updatedBulletShoots
    }


updateLastFired computer previousFiredValue =
    if computer.keyboard.space then
        LastFiredStamp computer.time

    else
        previousFiredValue


updateBulletsShot computer model =
    let
        incrementedBullets =
            List.foldl (bulletIncrementer computer.screen.width) [] model.shotBullets
    in
    case computer.keyboard.space of
        True ->
            Fired 15 model.wesMoves :: incrementedBullets

        _ ->
            incrementedBullets


moreThanMillisFromPosix checker nowPosix thenPosix =
    let
        delta =
            Time.posixToMillis nowPosix - Time.posixToMillis thenPosix
    in
    if delta > checker then
        True

    else
        False


bulletIncrementer width bullet acc =
    case bullet of
        Fired x wP ->
            if x > (width * 2) then
                acc

            else
                Fired (x + 5) wP :: acc

        NotFired ->
            NotFired :: acc



--View--


view : Computer -> Model -> List Shape
view computer model =
    [ theBackground
        |> moveDown 385
    , theGround 0 |> moveDown 385
    , theTarget 0 |> moveDown 385
    , myWesley
        |> scale 0.5
        |> move model.wesMoves.x
            model.wesMoves.y
    ]
        ++ shotBulletsView model


theBackground =
    group
        [ rectangle lightBlue 10000 500 |> moveUp 500
        ]


theBullet =
    group
        [ circle black 10 ]


theTarget time =
    group
        [ circle red 100 |> moveUp 350 |> moveRight 200
        , circle white 80 |> moveUp 350 |> moveRight 200
        , circle red 60 |> moveUp 350 |> moveRight 200
        , circle white 40 |> moveUp 350 |> moveRight 200
        , circle red 20 |> moveUp 350 |> moveRight 200
        ]


theGround computer =
    group
        [ rectangle lightGreen 10000 500
        ]


shotBulletsView model =
    List.map (shotBulletView model) model.shotBullets


shotBulletView model singleBullet =
    let
        moveFunction : Shape -> Shape
        moveFunction =
            case singleBullet of
                NotFired ->
                    move model.wesMoves.x model.wesMoves.y

                Fired x frozenWP ->
                    move (frozenWP.x + x) frozenWP.y
    in
    group
        [ circle black 5 ]
        |> moveDown 22.5
        |> moveRight 108
        |> moveFunction


myWesley =
    group
        [ square (rgb 212 162 106) 40 |> moveDown 40
        , oval (rgb 212 162 106) 20 40
            |> moveLeft 40
            |> moveUp 10
        , oval (rgb 212 162 106) 20 40
            |> moveRight 40
            |> moveUp 10
        , square (rgb 212 162 106) 80
        , wesEyes |> moveUp 10
        , circle darkYellow 30
            |> moveUp 50
        , circle darkYellow 20
            |> moveUp 50
            |> moveRight 20
        , circle darkYellow 20
            |> moveUp 50
            |> moveLeft 20
        , polygon black [ ( -25, -20 ), ( 0, 2 ), ( 25, -20 ) ]
            |> rotate 180
            |> moveDown 30
        , rectangle white 40 3 |> moveDown 13
        , wesBody |> moveDown 95
        , wesGun |> moveRight 160 |> moveDown 60
        ]


wesEyes =
    group
        [ circle white 15 |> moveLeft 17
        , circle white 15 |> moveRight 17
        , circle blue 10 |> moveLeft 17
        , circle blue 10 |> moveRight 17
        , circle black 4 |> moveLeft 17
        , circle black 4 |> moveRight 17
        ]


wesBody =
    group
        [ rectangle orange 100 120 |> moveDown 10
        , rectangle darkGray 100 100 |> moveDown 120
        , circle (rgb 212 162 106) 12 |> moveLeft 60 |> moveDown 115
        , circle (rgb 212 162 106) 12 |> moveRight 145 |> moveUp 35
        , rectangle orange 30 160 |> moveLeft 60 |> moveDown 30
        , rectangle orange 160 30 |> moveRight 60 |> moveUp 35
        , circle lightBlue 25 |> moveDown 180 |> moveLeft 25
        , circle lightBlue 25 |> moveDown 180 |> moveRight 25
        , rectangle darkGray 100 5 |> moveDown 170
        , rectangle darkOrange 5 85 |> moveLeft 42 |> moveDown 28
        ]


wesGun =
    group
        [ rectangle black 20 50
        , rectangle black 50 20 |> moveRight 30 |> moveUp 15
        ]
