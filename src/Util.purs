module GraphParams.Util where

import Data.Number as Number
import Relude
import Data.Int as Int
import Web.UIEvent.MouseEvent as ME
import Web.Event.Event as E
import Web.DOM.Element as Element
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage as Storage

repeat ∷ ∀ a. Int → (Int → a) → Array a
repeat 0 _ = []
repeat n f = 0 .. (n - 1) <#> f

map2 ∷ ∀a b c. Array a → Array b → (Int → a → b → c) → Array c
map2 t1 t2 fn = zipWith ($) (mapWithIndex fn t1) t2

map3 ∷ ∀a b c d. Array a → Array b → Array c → (Int → a → b → c → d) → Array d
map3 t1 t2 t3 fn = zipWith ($) (zipWith ($) (mapWithIndex fn t1) t2) t3

pseudoRandom ∷ Int → Number
pseudoRandom n = m - Number.floor m
  where
  m = 100.0 * sin (toNumber (n + 1))

pointerDecoder ∷ ME.MouseEvent → Effect (Maybe { x ∷ Number, y ∷ Number })
pointerDecoder ev = do
    case E.currentTarget (ME.toEvent ev) >>= Element.fromEventTarget of
        Just el → do
            {left, top, width, height} ← Element.getBoundingClientRect el
            pure $ Just {
                x: (Int.toNumber(ME.clientX ev) - left) / width,
                y: (Int.toNumber(ME.clientY ev) - top) / height
            }
        _ → pure Nothing

storagePut ∷ ∀ m. MonadAff m => String → String → m Unit
storagePut name value = liftEffect $ window >>= localStorage >>= Storage.setItem name value

storageGet ∷ ∀ m. MonadAff m => String → m (Maybe String)
storageGet name = liftEffect $ window >>= localStorage >>= Storage.getItem name