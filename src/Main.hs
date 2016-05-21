{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE BangPatterns #-}
module Main where

import           Control.Monad
import           Data.Bifunctor
import           Data.Map.Strict            (Map)
import qualified Data.Map.Strict            as Map
import           Data.Set                   (Set)
import qualified Data.Set                   as Set
import           System.Directory
import           System.Environment
import           System.Exit
import           System.IO
import           System.IO.Temp
import           System.Random

main :: IO ()
main = do
  args <- getArgs
  when (null args) $ do
    putStrLn $ "Usage: gc-test <size>"
    exitWith (ExitFailure 1)
  let nStr:_ = args
      size   = read nStr
  hSetBuffering stderr NoBuffering
  m <- createBigMap size
  hPutStrLn stderr $ "Inverting map"
  let !m' = invertMap m
  withTempFile "." "temp.csv" $ \fp h -> do
    hPutStrLn stderr "Writing temp file"
    hPutStrLn h $ show $ Map.toList m'
    hClose h

createBigMap :: Int -> IO (Map Int (Set Int))
createBigMap size = do
  let insertRandomSet m i = do
--        when (i `mod` 1000 == 0 ) $ do
--          hPutStr stderr $ "\r\ESC[KInserting " ++ show i ++ "th set"
        n <- randomRIO (10,100)
        set <- Set.fromList <$> replicateM n (randomRIO (minBound,maxBound))
        return $ Map.insert i set m
  m <- foldM insertRandomSet Map.empty [0..size-1]
  putStrLn ""
  return m

invertMap :: forall a b. (Ord a, Ord b) => Map a (Set b) -> Map b a
invertMap m = Map.foldlWithKey' foo Map.empty m
  where
    foo :: Map b a -> a -> Set b -> Map b a
    foo bm a bSet = Set.foldl bar bm bSet
      where
        bar :: Map b a -> b -> Map b a
        bar bm' b = Map.insert b a bm'

