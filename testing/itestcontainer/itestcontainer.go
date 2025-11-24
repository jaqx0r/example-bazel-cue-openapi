// itestcontainer is a runner shim invoked by `rules_itest`'s `itest_service` as an `exe` to launch a container image, using `testcontainers`.
//
// Pass the name of the container, any environment the container needs, and any volumes to mount.
//
// Exposed ports are inferred from the ASSIGNED_PORTS environment variable. Use
// the `named_ports` parameter to `itest_service` and use the internal port to
// expose as the port name.  `itest` will assign a port on the host.
//
// Volumes exist in the Docker volume space on the host, but are identified
// with the prefix `bazel-itest-`, and if run with the text execution
// environment in Bazel (i.e. with the environment variable `TEST_TARGET` set)
// then a hash that uniquely identifies the test will be appended to the volume
// name.  This allows tests to run concurrently but avoid contention and
// potential locking issues when sharing a volume name.
package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"sync"
	"syscall"

	"github.com/testcontainers/testcontainers-go"
)

var (
	name   = flag.String("name", "", "`name`(`:tag`) name and optional tag of the container to launch")
	volume = flag.String("volume", "", "`name`:`path` pairs of volumes to mount.  If `TEST_TARGET` is set in the environment, that value is hashed and appended to the volume name.  The string `bazel-itest-` is always prepended.")
	env    = flag.String("env", "", "KEY[,KEY] list of environment variable names to pass through to the container")
)

type logConsumer struct {
}

func (logConsumer) Accept(l testcontainers.Log) {
	log.Printf("%s: %s", l.LogType, l.Content)
}

func main() {
	flag.Parse()

	if *name == "" {
		log.Fatal("`name` must be set")
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	wg := sync.WaitGroup{}

	var assignedPorts map[string]string
	portsString := os.Getenv("ASSIGNED_PORTS")
	if portsString != "" {
		err := json.Unmarshal([]byte(portsString), &assignedPorts)
		if err != nil {
			log.Fatalf("json.Unmarshal(%v): %v", portsString, err)
		}
	}
	log.Println("Ports:", assignedPorts)

	// Map the suffix of the named ports to exposed ports.
	exposedPortsMap := make(map[string]string, len(assignedPorts))
	for portName, externalPort := range assignedPorts {
		parts := strings.Split(portName, ":")

		exposedPortName := parts[len(parts)-1]
		if _, err := strconv.Atoi(exposedPortName); err != nil {
			log.Printf("port name %q can't be mapped; please use numeric port names in `named_ports`", exposedPortName)
			continue
		}
		if _, ok := exposedPortsMap[externalPort]; !ok {
			exposedPortsMap[externalPort] = exposedPortName
		}
	}
	exposedPorts := make([]string, 0, len(exposedPortsMap))
	for k, v :=  range exposedPortsMap {
		exposedPorts = append(exposedPorts, fmt.Sprintf("%s:%s", k, v))
	}
	log.Println("Exposed Ports:", exposedPorts)

	environment := make(map[string]string, 0)
	for envVar := range strings.SplitSeq(*env, ",") {
		if envVar == "" {
			continue
		}
		value := os.Getenv(envVar)
		if value == "" {
			log.Fatalf("No environment variable found: %q", envVar)
		}
		environment[envVar] = value
	}
	log.Println("Environment:", environment)

	// Create a mount name suffix for the volume based on TEST_TARGET.
	suffix := ""
	testTarget := os.Getenv("TEST_TARGET")
	if testTarget != "" {
		hasher := sha256.New()
		hasher.Write([]byte(testTarget))
		hB := hasher.Sum(nil)
		suffix = hex.EncodeToString(hB)
	}
	mounts := make([]testcontainers.ContainerMount, 0)
	for volumeMount := range strings.SplitSeq(*volume, ",") {
		parts := strings.SplitN(volumeMount, ":", 2)
		volumeName := ""
		if suffix != "" {
			volumeName = fmt.Sprintf("bazel-itest-%s-%s", parts[0], suffix)
		} else {
			volumeName = fmt.Sprintf("bazel-itest-%s", parts[0])
		}
		mounts = append(mounts,
			testcontainers.ContainerMount{
				Source: testcontainers.GenericVolumeMountSource{Name: volumeName},
				Target: testcontainers.ContainerMountTarget(parts[1]),
			})
	}
	log.Println("Volume Mounts:", mounts)

	logConsumer := logConsumer{}

	c, err := testcontainers.Run(ctx, *name,
		testcontainers.WithExposedPorts(exposedPorts...),
		testcontainers.WithLogConsumers(logConsumer),
		testcontainers.WithEnv(environment),
		testcontainers.WithMounts(mounts...),
	)
	if err != nil {
		log.Fatalf("testcontainers.Run(): %v", err)
	}
	wg.Add(1)
	go func() {
		defer wg.Done()
		name := c.GetContainerID()
		n, err := c.Inspect(ctx)
		if err != nil {
			name = n.Name
		}
		<-ctx.Done()
		log.Println("Stopping ", name)
		testcontainers.TerminateContainer(c)
	}()
	log.Println("Started", *name)
	log.Println("Waiting, press Ctrl-C to shutdown")
	<-ctx.Done()
	stop()
	wg.Wait()
	log.Println("itestcontainer done")
}
