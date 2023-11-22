PHP Application Migration Example
===

This simple repository is designed to help demonstrate migration of an application from VM-based infrastructure on OpenShift Virtualization to modern, containerized applications with the least amount of effort and customization possible. It's a deliberately simple example designed to highlight the platform features that enable this practice, and it's expected that a real containerization/modernization of an application would be more complex. It also includes a demonstration of managing these resources with OpenShift GitOps for declarative, auditable management that supports promotion through staging environments. Robust CI/CD pipelines, strict security, etc. - none of these things are in this demo.

If your application exists today inside a virtual machine, running any OS at all, and you can make that application work inside a Linux container, possibly with some amount of modification, then you can get the benefits of OpenShift Builds, Deployment rollout triggers, Service discovery, Service load balancing, and Route-based load balancing for your containers alongside your VMs.

Prerequisites
---

1. OpenShift installed on bare metal or a hypervisor with nested virtualization enabled
1. A default StorageClass with the capability to provision `volumeMode: Block` PVs
1. An account with cluster-admin logged in to `oc`
1. The integrated registry is enabled and functional

Basic Walkthrough
---

1. Bootstrap OpenShift GitOps (based on ArgoCD) to configure it to point to the repository, deploying an htpasswd identity provider with an appropriate group for ArgoCD configuration as well as three virtual machines to host the application.
    ```sh
    while ! oc apply --server-side=true --force-conflicts -k cluster/bootstrap ; do sleep 2; done
    ```
1. Browse to the OpenShift console, open the Virtualization menu on the left, look at Virtual Machines. Change the Project pulldown to `vm-modernization`. Show that the VMs are running in the same state they are after the Migration Toolkit for Virtualization lab in the OCP-V Roadshow. It's as if you just finished walking through that lab, importing the VMs from vSphere.
1. `curl` the Route exposing the VM-based app to show it's working, maybe curl it a few times to show the load balancing (it puts the VM hostnames in the response)
1. The next step after migrating the VMs is to show the value of the application platform, for both containers and VMs, so set the stage with the application running in IIS on Windows Server - but then highlight that in this case, the app is actually written in PHP - a fully cross-platform programming language.
    1. Show the IIS UI in one of the winweb servers
    1. Show the index.php inside this repo being a simple toy example app with some basic database queries
1. Show what a BuildConfig looks like in OpenShift, maybe just clicking through the GUI to create a new one
1. Change the branch from `main` to `main+1` via `git checkout main+1` or similar, and rerun the bootstrap on the new branch (without such a forceful application)
    ```sh
    oc apply --server-side=true -k cluster/bootstrap
    ```
1. Show the Route and Services and highlight how the Route changed after the second reconciliation
1. Show in the console that the Build is running from the BuildConfig
1. Show the ImageStream, briefly discuss the integrated registry
1. Show the failing pod for the deployment because the image doesn't exist
1. Maybe `curl` the Route a few more times to show it responding from the VMs and not trying to balance to the failing pods
1. Highlight that the database is still in a VM
    - **Talking point**: Migrating databases from existing VMs to containers is a bit trickier, controlling for state is hard and it might be easier to leave it alone
1. Show the Deployment manifest, highlight the annotation for the ImageStream rollout trigger
1. Maybe show the build log to fill for time while the build runs, talk a bit about S2I being a simple way to package an application into a supported container image and runtime (here, PHP and httpd on UBI)
1. Show that there are 2 VM replicas, 2 pod replicas, and 1 database VM running
1. `curl` the Route a few times to show it load balancing across all replicas
1. Show the resource utilization between then VMs and the containerized application
    - **Talking point**: This app is doing the exact same thing in a container that it does in the VM. There is no change in business process that this app is fulfilling, despite the radical change in infrastructure
1. Pull up the Project monitoring tab and highlight the shared metrics aggregation and storage between the VMs and containers
1. Turn off the winweb VMs by changing to the `main+2` branch and rerunning bootstrap
1. `curl` the Route a few times to show it load balancing across the containerized replicas
1. Completely remove the winweb VMs by changing to the `main+3` branch and rerunning bootstrap
1. Closing
    - You can begin to adopt modern, cloud-native management practices with fully legacy applications, gaining the advantages of GitOps before modernizing the application
    - Modernizing your app may require code changes, it may require maintaining two copies of the codebase for a time
    - You might need more robust CI/CD than a BuildConfig, ImageStream, and S2I - that's okay, we have OpenShift Pipelines based on Tekton
    - All of these features shown today are delivered as open source extensions on top of a CNCF-certified Kubernetes core, and other technology that runs on Kubernetes can run here as well
    - There is value in doing this modernization, not only in the resource utilization but in the ease of testing changes (consider a different BuildConfig that triggers off of a different branch, maybe `dev`, and an alternate deployment in the same cluster) and adopting modern processes to add velocity to your code changes
