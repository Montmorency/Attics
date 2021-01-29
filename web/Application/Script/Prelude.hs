module Application.Script.Prelude
( module IHP.ControllerPrelude
, module Generated.Types
, module IHP.Prelude
, module IHP.ScriptSupport
, mapIOLog_
)
where

import IHP.Prelude
import IHP.ControllerPrelude
import Generated.Types
import IHP.ScriptSupport

mapIOLog_ :: (Int -> Int -> a -> Text) -> (a -> IO b) -> [a] -> IO ()
mapIOLog_ logF f as =
  let total = L.length as
   in mapIOLog' 1 total logF f as
  where
    mapIOLog' _ _ _ _ [] = pure ()
    mapIOLog' i total logF f (a : as) = do
      putStrLn $ logF i total a
      f a
      mapIOLog' (i + 1) total logF f as