use crate::model::*;

use serde_derive::{Deserialize, Serialize};
use std::collections::HashMap;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct LicensesJson(HashMap<String, Vec<String>>);

fn read_hanshammel_compatibility_checker_licenses_json() -> Result<LicensesJson, Box<dyn Error>> {
    let file = File::open("../data/HansHammel-license-compatibility-checker/lib/licenses.json")?;
    let reader = BufReader::new(file);
    let cl = serde_json::from_reader(reader)?;
    Ok(cl)
}

pub struct HansHammelSource {}
impl Source for HansHammelSource {
    fn get_origin(&self) -> Origin {
        Origin::new_with_url(
            "HansHammel license compatibility checker",
            "https://github.com/HansHammel/license-compatibility-checker",
        )
    }

    fn get_tasks(&self) -> Vec<LicenseGraphBuilderTask> {
        let LicensesJson(map) = read_hanshammel_compatibility_checker_licenses_json()
            .expect("should be able to parse hanshammel json");
        map.iter()
            .map(|(ty, licenses)| {
                LicenseGraphBuilderTask::new(
                    licenses
                        .iter()
                        .map(|license| LicenseGraphNode::license_name(license))
                        .collect(),
                )
                .edge(
                    LicenseGraphEdge::AppliesTo,
                    vec![LicenseGraphNode::license_type(ty)],
                )
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test_helper;

    #[test]
    fn tests_source() {
        test_helper::test_single_origin(
            "source_hanshammel",
            &HansHammelSource {},
            vec!["BSD-3-Clause"],
        )
    }
}
