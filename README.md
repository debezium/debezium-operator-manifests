# debezium-operator-manifests
This is a repository of operator bundle manifests for released versions of [Debezium operator](https://github.com/debezium/debezium-operator)

## Publishing bundles to OperatorHub catalog
Full documentation is available at [OperatorHub.io](https://operatorhub.io/contribute)

*Prerequisities:*
1. Version of operator bundle is present in `olm/bundles` of this repo
2. Container image for this version of operator bundle was pushed 
3. Read [Contributing Prerequisites](https://k8s-operatorhub.github.io/community-operators/contributing-prerequisites/) and configure your git appropriately 
4. Fork OperatorHub's [community operators repo](https://github.com/k8s-operatorhub/community-operators)
https://github.com/k8s-operatorhub/community-operators/tree/main/operators

*Steps:*
The code snippet bellow demonstrates the process of publishif $BUDNLE_VERSION to OperatorHub's community catalog

```bash
export BUNDLE_VERSION="2.4.0" 
# Assuming you are in the root of this repository
export DBZ_MANIFESTS_REPO_DIR="$PWD"
# Change the following
export COMMUNITY_OPERATORS_REPO_DIR="placeholder" 
export GH_ORG="placeholder"
export GIT_BRANCH="debezium-operator.v$BUNDLE_VERSION"
export GIT_COMMIT_MSG="operator debezium-operator ($BUNDLE_VERSION)"

# Clone your fork of community operators repository
git clone "git@github.com:$GH_ORG/community-operators.git" "$COMMUNITY_OPERATORS_REPO_DIR"

# Copy $BUNDLE_VERSION manifests to $COMMUNITY_OPERATORS_REPO_DIR
# (and possibly any other changes you wish to submit)
cp -r "$DBZ_MANIFESTS_REPO_DIR/olm/bundles/$BUNDLE_VERSION" "$COMMUNITY_OPERATORS_REPO_DIR/operators/debezium-operator"

# Commit and push changes to community operators repository
pushd "$COMMUNITY_OPERATORS_REPO_DIR"
# Crate new branch in $COMMUNITY_OPERATORS_REPO_DIR
git switch -c "$GIT_BRANCH"
git add .
# Use -s to sign the commit (e.g:  Signed-off-by: John Doe <john.doe@example.com>)
git commit -s -m "$GIT_COMMIT_MSG"
git push origin "$GIT_BRANCH"

# Done
popd
```

Now open a PR agaisnt the main branch of OperatorHub's [community operators repo](https://github.com/k8s-operatorhub/community-operators). Once the PR is approved by somebeody listed in `ci.yaml` all is done.

## Creating new bundle manifests
Following these steps to generate OLM bundle manifest for new Debezium Operator release.

```bash
export DEBEZIUM_VERSION="2.4.0"
export MAVEN_REPO_CENTRAL="https://repo1.maven.org/maven2"
export BUNDLE_URL="$MAVEN_REPO_CENTRAL/io/debezium/debezium-operator/$DEBEZIUM_VERSION/debezium-operator-$DEBEZIUM_VERSION-olm-bundle.zip"

# Add bundle to olm/bundles
# (and commit right away)
./scripts/install-olm-bundle.sh -u "$BUNDLE_URL" -v $DEBEZIUM_VERSION --commit

# Alternatively you can also add bundle from  local file
# ./scripts/install-olm-bundle.sh -i "$BUNDLE_ZIP" -v $DEBEZIUM_VERSION --commit


# Optional if you also wish to build the test catalog later
# Build and push bundle image 
# (defaults to quay.io/debezium/operator-bundle)
./scripts/create-olm-bundle-image.sh -v "$DEBEZIUM_VERSION" --push
```

Now open a PR agaisnt the main branch of [manifest repo](https://github.com/debezium/debezium-operator-manifests) and all is done.

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

