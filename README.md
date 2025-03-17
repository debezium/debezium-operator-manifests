# debezium-operator-manifests
This is a repository of operator bundle manifests for released versions of [Debezium operator](https://github.com/debezium/debezium-operator)


## Creating new bundle manifests
Following these steps to generate OLM bundle manifest for new Debezium Operator release.

```bash
# Change the following
export DEBEZIUM_VERSION="X.Y.Z.Final"

# Change the following (should match maven version for desired release)
# (and commit right away)
./scripts/install-olm-bundle.sh -v $DEBEZIUM_VERSION --commit

# Alternatively you can also add bundle from  local file
# ./scripts/install-olm-bundle.sh -i "$BUNDLE_ZIP" -v $DEBEZIUM_VERSION --commit


# Optional if you also wish to build the test catalog later
# Build and push bundle image 
# (defaults to quay.io/debezium/operator-bundle)
./scripts/create-olm-bundle-image.sh -v "$DEBEZIUM_VERSION" --push
```

_Note: After installing the bundle you should review it for any potential problems and adjust accordingly. In case the changes were also committed, ammend any changes to the latest commit._

Now push the changes and open a PR agaisnt the main branch of [manifest repo](https://github.com/debezium/debezium-operator-manifests) and all is done.


## Creating test catalog
You can build a test OLM catalog index from these operator bundles

_Note: while the script uses these manifests files, the bundles included in the catalog have to be published as container images_

```bash
# Build and push catalog image (assumes bundle images were pushed)
# (defaults to quay.io/debezium/operator-catalog)
./scripts/create-olm-test-catalog.sh \
    -i "$MANIFESTS_REPO_DIR/olm/bundles" \
    -o "$MANIFESTS_REPO_DIR/olm/catalog" \
    --push
```



## Creating new HELM charts

~~Following these steps to create Helm chart for new Debezium Operator release.~~

<del>
# Change the following (should match maven version for desired release)
export DEBEZIUM_VERSION="X.Y.Z.Final"
# Install chart to helm/charts
# (and commit right away)
./scripts/install-helm-chart.sh -v $DEBEZIUM_VERSION --commit
</del>

~~_Note: After installing the chart you should review it for any potential problems and adjust accordingly. In case the changes were also committed, ammend any changes to the latest commit._~~

~~Now push the changes and open a PR agaisnt the main branch of [manifest repo](https://github.com/debezium/debezium-operator-manifests) and all is done. GHA pipeline will create a GH release for new chart and publish it to index available at [charts.debezium.io](https://charts.debezium.io/index.yaml).~~

Debezium Helm charts are now part of the Debezium release process. The charts are published to index available at [charts.debezium.io](https://charts.debezium.io/index.yaml).
For more details, please refer to [debezium-charts](https://github.com/debezium/debezium-charts/blob/main/README.md).
Any changes to the charts must be done in the relative project repo.

## Publishing bundles to OperatorHub catalogs
Full documentation is available at [OperatorHub.io](https://operatorhub.io/contribute)

*Prerequisities:*
1. Version of operator bundle is present in `olm/bundles` of this repo
2. Read [Contributing Prerequisites](https://k8s-operatorhub.github.io/community-operators/contributing-prerequisites/) and configure your git appropriately 
3. Fork OperatorHub's [community operators repo](https://github.com/k8s-operatorhub/community-operators) and clone it
3. Fork OCP OperatorHub's [community operators prod repo](https://github.com/redhat-openshift-ecosystem/community-operators-prod) and clone it

*Steps:*
The code snippet bellow demonstrates the process of publishif $BUDNLE_VERSION to OperatorHub's community catalog

```bash
# Change the following
export BUNDLE_VERSION="X.Y.Z-final" 
export REPO_K8_OPERATORS="placeholder" 
export REPO_OKD_OPERATORS="placeholder" 

# Copy the bundle and push changes
./scripts/release-operatorhub.sh  -o $REPO_OKD_OPERATORS -k $REPO_K8_OPERATORS -v "$BUNDLE_VERSION"  --push
```

Now open a PRs against the main branch of OperatorHub's [community operators repo](https://github.com/k8s-operatorhub/community-operators) and 
OCP OperatorHub's [community operators prod repo](https://github.com/redhat-openshift-ecosystem/community-operators-prod)
