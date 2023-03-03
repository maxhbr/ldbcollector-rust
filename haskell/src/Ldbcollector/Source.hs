module Ldbcollector.Source where

import Ldbcollector.Model 
import Ldbcollector.Source.Scancode
import Ldbcollector.Source.SPDX
import Ldbcollector.Source.Cavil
import Ldbcollector.Source.Fedora


applySources :: LicenseGraphM ()
applySources = do
    applySource SPDXLicenseIds
    applySource (ScancodeLicenseDB "../data/nexB-scancode-licensedb/docs/")
    applySource (CavilLicenseChanges "../data/openSUSE-cavil/lib/Cavil/resources/license_changes.txt")
    applySource (FedoraLicenseData "../data/fedora-legal-fedora-license-data.tomls")