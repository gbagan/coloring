module GraphParams.UI
  where

import Relude

import Pha.Html (Html, Prop)
import Pha.Html as H
import Pha.Html.Events as E

baseButtonClass :: String
baseButtonClass = "px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700"

buttonClass :: String
buttonClass = baseButtonClass <> " rounded"

button :: ∀msg. {name :: String, onClick :: msg, attrs :: Array (Prop msg)} → Html msg
button {name, onClick, attrs} =
  H.button ([ H.class_ $ buttonClass, E.onClick \_ → onClick ] <> attrs) [ H.text name ]

buttonGroup ∷ ∀msg. Array {name :: String, onClick :: msg, attrs :: Array (Prop msg)} → Html msg
buttonGroup buttons =
  H.div [] $
    buttons # mapWithIndex \i {name, onClick, attrs} →
      let
        suffix =
          if i == 0 then " rounded-l"
          else if i == len - 1 then " rounded-r"
          else ""
      in
      H.button ([ H.class_ $ baseButtonClass <> suffix, E.onClick \_ → onClick ] <> attrs) [ H.text name ]
  where
    len = length buttons

cardClass ∷ String
cardClass = "p-6 bg-white border border-gray-200 rounded-lg shadow"

card ∷ ∀ a. String → Array (Html a) → Html a
card title body =
  H.div [ H.class_ cardClass ]
    $ [ H.div [ H.class_ "text-xl mb-2" ] [ H.text title ] ]
    <> body

textareaClass ∷ String
textareaClass = "block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500"

checkboxClass ∷ String
checkboxClass = "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 focus:ring-2"

textInputClass :: String
textInputClass = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"

selectClass ∷ String
selectClass = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"

dialog ∷ ∀msg. String → Array (Html msg) → Array { name :: String, onClick :: msg } → Html msg
dialog title body buttons =
  H.div [ H.class_ "absolute w-full h-full flex items-center justify-center bg-transp-grey inset-0 z-50" ]
    [ H.div [ H.class_ "bg-white text-black rounded block border-2" ]
        [ H.div [ H.class_ "p-4 min-h-8 border-b-2" ]
            [ H.div [ H.class_ "text-4xl font-medium inline-block" ] [ H.text title ]
            ]
        , H.div [ H.class_ "p-6 border-b-2" ] body
        , H.div [ H.class_ "p-4 text-right" ] $ 
            buttons # mapWithIndex \i {name, onClick} ->
              H.button
                [ H.class_ $ buttonClass <> (if i == 0 then "" else " ml-4")
                , E.onClick \_ -> onClick
                ] [ H.text name ]
        ]
    ]