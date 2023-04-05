{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
module Ldbcollector.Source.OSI
    ( OSI (..)
    ) where

import           Ldbcollector.Model
import qualified Data.Vector           as V
import qualified Data.Map              as Map
import qualified Data.Yaml as Y
import qualified Data.Yaml.Internal as Y

import qualified Network.Protocol.OpenSource.License as OSI
import           Control.Monad.Except (runExceptT)

newtype OSILicense
    = OSILicense OSI.OSILicense
    deriving (Eq, Show, Generic)
instance ToJSON OSILicense

instance LicenseFactC OSILicense where
    getType _ = "OSILicense"
    getApplicableLNs (OSILicense l) =
        (NLN . newNLN "osi" .  OSI.olId) l
        `AlternativeLNs`
        ((LN . newLN  .  OSI.olName) l : map (\i -> NLN $ newNLN (OSI.oiScheme i) (OSI.oiIdentifier i)) (OSI.olIdentifiers l))
        `ImpreciseLNs`
        map (LN . newLN . OSI.oonName) (OSI.olOther_names l)
    getImpliedStmts (OSILicense l) = let
            urls = (map (\link -> (LicenseUrl . unpack . OSI.olUrl) link `SubStatements` [LicenseComment (OSI.olNote link)]) . OSI.olLinks) l
        in urls

data OSI = OSI
instance Source OSI where
    getOrigin _ = Origin "OSI"
    getFacts OSI = do
        response <- runExceptT OSI.allLicenses
        case response of
            Left err -> do
                putStrLn $ "Error: " ++ err
                pure mempty
            Right licenses -> (return . V.fromList . map (wrapFact . OSILicense)) licenses
