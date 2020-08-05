module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Playground exposing (..)


main =
    game view update ( 0, 0 )


view computer ( x, y ) =
    [ theBackground 0
        |> moveDown 385
    , myWesley -100
        |> move x y
        |> scale 0.5
        |> moveRight -300
    , theGround 0
        |> moveDown 385
    , theTarget 0
        |> moveDown 385
    ]


update computer ( x, y ) =
    ( x + toX computer.keyboard
    , y + toY computer.keyboard
    )


theBullet computer =
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


theBackground computer =
    group
        [ rectangle lightBlue 10000 500 |> moveUp 500
        ]


theGround computer =
    group
        [ rectangle lightGreen 10000 500
        ]


myWesley computer =
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
        , theBullet 0 |> moveRight 215 |> moveDown 45
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
