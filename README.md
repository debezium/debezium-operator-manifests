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
export MANIFESTS_REPO_DIR="$PWD/debezium-operator-manifests" 
export COMMUNITY_OPERATORS_REPO_DIR="$PWD/community-operators" 
export BUNDLE_VERSION="X.Y.1" 
# Change the following
export GH_ORG="placeholder"
# Keep things organized
export GIT_BRANCH="debezium-operator.v$BUNDLE_VERSION"
# Commit message format is mandatory!
export GIT_COMMIT_MSG="operator debezium-operator ($BUNDLE_VERSION)"

# Clone repositories
git clone "git@github.com:debezium/debezium-operator-manifests.git" "$MANIFESTS_REPO_DIR"
git clone "git@github.com:$GH_ORG/community-operators.git" "$COMMUNITY_OPERATORS_REPO_DIR"

pushd "$COMMUNITY_OPERATORS_REPO_DIR"
# Crate new branch in $COMMUNITY_OPERATORS_REPO_DIR
git switch -c "$GIT_BRANCH"

# Copy $BUNDLE_VERSION manifests to $COMMUNITY_OPERATORS_REPO_DIR
# (and possibly any other changes you wish to submit)
cp -r "$MANIFESTS_REPO_DIR/olm/bundles/$BUNDLE_REPLACES_VERSION" "$COMMUNITY_OPERATORS_REPO_DIR/operators/debezium"

# Commit and push 
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

*Prerequisities (if you want to contribute!):*
1. For this repository

The code snippet bellow demonstrates the process of creating operator bundle for new release of Debezium operator. 

_Note: Fork is not neccessary if you just want to try generating the bundle. In such case skip the commit and push part._

```bash
export OPERATOR_REPO_DIR="$PWD/debezium-operator"
export MANIFESTS_REPO_DIR="$PWD/debezium-operator-manifests"
export BUNDLE_VERSION="X.Y.1" 
export BUNDLE_REPLACES_VERSION="X.Y.0"
# Change the following to your fork!
export GH_ORG="debezium"
# Keep things organized (Jira ticket is required if you do this outside of release pipeline!)
export GIT_BRANCH="DBZ-XXX"
# Commit message format is mandatory!
export GIT_COMMIT_MSG="$GIT_BRANCH operator debezium-operator ($BUNDLE_VERSION)"


# Clone repositories
git clone "git@github.com:debezium/debezium-operator.git" $OPERATOR_REPO_DIR
git clone "git@github.com:$GH_ORG/debezium-operator-manifests.git" $MANIFESTS_REPO_DIR

# Build operator 
pushd "$OPERATOR_REPO"
mvn clean install 
popd

# Crate new branch in $COMMUNITY_OPERATORS_REPO_DIR
pushd "$MANIFESTS_REPO_DIR"
git switch -c "$GIT_BRANCH"
popd

# Build the bundle manifest for $BUNDLE_VERSION 
# (replacing $BUNDLE_REPLACES_VERSION in this case)
$OPERATOR_REPO_DIR/scripts/create-olm-bundle.sh \
    -i "$OPERATOR_REPO_DIR/target/bundle/debezium-operator" \
    -o "$MANIFESTS_REPO_DIR/olm/bundles" \
    -v "$BUNDLE_VERSION" \
    -r "$BUNDLE_REPLACES_VERSION"  

# Commit and push
pushd "$MANIFESTS_REPO_DIR"
git add .
# Review the files staged for commit!
git commit -m "$GIT_COMMIT_MSG"
git push origin "$GIT_BRANCH"
popd

# Optional if you also wish to build the test catalog later
# Build and push bundle image 
# (defaults to quay.io/debezium/operator-bundle)
$OPERATOR_REPO_DIR/scripts/create-olm-bundle-image.sh \
    -i "$MANIFESTS_REPO_DIR/olm/bundles" \
    -v "$BUNDLE_VERSION" \
    --push
```

Now open a PR agaisnt the main branch of [manifest repo](https://github.com/debezium/debezium-operator-manifests) and all is done.

## Creating test catalog
You can build a test OLM catalog index from these operator bundles

_Note: while the script uses these manifests files, the bundles included in the catalog have to be published as container images_

```bash
# Build and push catalog image
# (defaults to quay.io/debezium/operator-catalog)
$OPERATOR_REPO_DIR/scripts/create-olm-test-catalog.sh \
    -i "$MANIFESTS_REPO_DIR/olm/bundles" \
    -o "$MANIFESTS_REPO_DIR/olm/catalog" \
    --push
```

