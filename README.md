# Community and OKD Operators

Operators stored here will be pushed to [quay.io](https://quay.io)'s AppRegistry and will be visibile in the Operator Hub on all OKD clusters.

## Adding your OKD operator

*The process for adding operators isn't finalized and is subject to change.*

To add your operator to this repo, you will need to submit a PR with your operator resources in a new directory named after your operator beneath the `community-operators/` directory:

```bash
$ ls community-operators/my-operator/
my-operator.v1.0.0.clusterserviceversion.yaml
my-operator-crd1.crd.yaml
my-operator-crd2.crd.yaml
my-operator.package.yaml
```

The operator resources are your operator's CSV [follow this guide to create an OLM-compatible CSV for your operator](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/Documentation/design/building-your-csv.md), CRDs, and the package.yaml file for your operator.

An operator's CSV must contain the annotations mentioned [here](https://github.com/operator-framework/operator-marketplace/blob/master/docs/marketplace-required-csv-annotations.md) for it to be displayed properly within the Marketplace UI.

## Updating your OKD operator

Similarly, to update your operator you need to submit a PR with any changes to your operator resources.

## Pulling OperatorBundles from quay.io
### Prerequisites
The following prequistis are required run to the quay.io scripts:

* [jq](https://stedolan.github.io/jq/) must be installed
* A quay.io account

To pull your operator bundle from quay.io, simply run the following command:
```bash
$ scripts/pull-from-quay $NAMESPACE $REPOSITORY
```

In the command above, `$NAMESPACE` is the [quay.io](https://quay.io) namespace. Possible values include:

* [redhat-operators](https://quay.io/organization/redhat-operators)
* [certified-operators](https://quay.io/organization/certified-operators)
* [community-operators](https://quay.io/organization/community-operators)
* your personal quay.io namespace.

The `$REGISTRY` is the name of the folder you created under the `$NAMESPACE` directory.

For example, for `community-operators/etcd` the `$NAMESPACE` would be `community-operators` and the `$REGISTRY` would be `etcd`.