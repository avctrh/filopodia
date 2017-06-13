module Dampf.Docker where

import Dampf.AppFile
import System.Process
import Control.Monad
import System.Exit
import Data.Maybe

buildDocker :: Dampfs -> IO ()
buildDocker (Dampfs dampfs) = do
  forM_ [(nm,imspec) | Image nm imspec <- dampfs] $ \(nm,imspec) -> do
    let cmd = "docker build -t "++nm++" "++dockerFile imspec
    --putStrLn cmd
    ExitSuccess <- system $ cmd
    return ()

deployDocker :: Dampfs -> IO ()
deployDocker (Dampfs dampfs) = do
  forM_ [(cnm,cspec) | Container cnm cspec <- dampfs] $ \(cnm,cspec) -> do
    let imnm = image cspec
        port = case expose cspec of
                 Nothing -> " "
                 Just ps -> concatMap (\p -> " -p "++show p++":"++show p++" ") ps
        cmd = " "++(fromMaybe "" $ command cspec)
    system $ "docker stop "++cnm
    system $ "docker rm "++cnm
    system $ "docker run -d --restart=always --net=\"host\" --name="++cnm++port++imnm++cmd

