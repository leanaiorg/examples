# Tracking and testing model containers on update
This example illustrates how to set up an argo-based tracker that listens to pushes to a docker registry and creates an argo workflow for running tests on the container whenever a new container is pushed.

This can be useful for several different tasks, but in this example we will illustrate running a ML model server based on OpenFaaS alongside a tester that queries a prediction and measures the time of the prediciton. Specifically, the example scenario is that whenever an image (e.g. `model-server`) is pushed to a repo, a workflow will be created by argo that attempts to run the container alongside a tester, with the name `-tester` appended to the model container name (here, `model-server-tester`), which is predefined to query a prediction from the model server and measure the time taken to complete the query. After this, the function is deployed to the OpenFaaS gateway as an OpenFaaS Function, first deleting any existing server with the same name (container image and tag).

## Prerequisites
This example assumes argo-workflows and argo-events already installed and running in namespace. For instructions, refer to [argo workflows](https://argoproj.github.io/argo) and [argo events](https://argoproj.github.io/projects/argo-events)

Furthermore, a model server container image and a corresponding `-tester` image must exist in the repo that is tracked. The tester image for the example is built as shown in the `model-testing-container/` folder.

## Setup
### "Step 0" - webhook source
For this example, a docker registry is hosted and configured to send event notifications to the webhook url. Setting up notifications when hosting your own registry is quite simple, refer to the docker documentation on [notifications](https://docs.docker.com/registry/notifications/) for more information.

Note that the `argo-gateway.yaml` file contains a spec for a kubernetes service, which is the endpoint that the docker registry should send notifications to.

### Step 1 - set up webhook gateway and sensor
With the argo events gateway and sensor controller already installed, step 1 is to modify and apply the event source, gatway and sensor components in the namespace where the workflows should be run. The main modification is in the sensor, in which the namespace for the configmap with the workflow needs to be specified. It is set to `<namespace of configmap>` by default, and the configmap is created in  the next step so choosing the namespace is up to you. After modifying the components as desired, apply the configuration like so:

```
kubectl apply -f workflow-components/ -n <desired namespace>
```

Check the logs of both the gateway and sensor controllers for errors, and then the logs of the actual gateway and sensor pods that were just deployed as well.

### Step 2 - create configmap of workflow template
The next step is to create a configmap containing the workflow template. This is just one alternative for providing templates in file, refer to [argo triggers](https://argoproj.github.io/argo-events/trigger/) to learn of others, but a configmap is a simple way. Modify the configmap and provide the OpenFaaS serving namespace, then apply it in the namespace you specified in the sensor configuration in step 1:

```
kubectl apply -f model-testing-worfklow.yaml -n <desired namespace>
```

Here, the key is set to `workflow`, which is how the sensor identifies the template when triggering a workflow from the configmap `prediction-testing-workflow`.

This should conclude setup!


## Running it
The registry should now be tracked by the argo events source, and when pushing to the registry argo will attempt to create a workflow based on the container image that was pushed, provided that a corresponding tester container image exists.

## Debugging
If you want to look at the full message body of the webhook requests, the debug sensor is useful and outputs the message. The gateway must be modified to also list the debugging sensor as a listener, and the debugging sensor configuration may vary depending on setup. When it receives a message, it will print the message in a docker "whalesay" fashion, and this can be viewed in the logs of pod that the sensor creates whenever triggering:

```
kubectl logs debug-webhook-XXXXX main
```