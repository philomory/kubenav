package kubenav

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	"github.com/kubenav/kubenav/pkg/kube"

	"k8s.io/apimachinery/pkg/types"
	"k8s.io/client-go/rest"
)

// KubernetesRequest is used to execute a request against a Kubernetes API. The Kubernetes API server and it's ca are
// specified via the "clusterServer" and "clusterCertificateAuthorityData" arguments. To skip the tls verification the
// request can set the "clusterInsecureSkipTLSVerify" argument to true. To handle the authentication against the API
// server the "user*" arguments can be used.
// The "requestMethod", "requestURL" and "requestBody" arguments are then used for the actually request. E.g. to get all
// Pods from the Kubernetes API the method "GET" and the URL "/api/v1/pods" can be used.
func KubernetesRequest(clusterServer, clusterCertificateAuthorityData string, clusterInsecureSkipTLSVerify bool, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword, requestMethod, requestURL, requestBody string) (string, error) {
	_, clientset, err := kube.GetClient(clusterServer, clusterCertificateAuthorityData, clusterInsecureSkipTLSVerify, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword)
	if err != nil {
		return "", err
	}

	var responseResult rest.Result
	var statusCode int
	ctx := context.Background()

	requestURL = strings.TrimRight(clusterServer, "/") + requestURL

	if requestMethod == http.MethodGet {
		responseResult = clientset.RESTClient().Get().RequestURI(requestURL).Do(ctx)
	} else if requestMethod == http.MethodDelete {
		responseResult = clientset.RESTClient().Delete().RequestURI(requestURL).Body([]byte(requestBody)).Do(ctx)
	} else if requestMethod == http.MethodPatch {
		responseResult = clientset.RESTClient().Patch(types.JSONPatchType).RequestURI(requestURL).Body([]byte(requestBody)).Do(ctx)
	} else if requestMethod == http.MethodPost {
		responseResult = clientset.RESTClient().Post().RequestURI(requestURL).Body([]byte(requestBody)).Do(ctx)
	}

	if responseResult.Error() != nil {
		return "", responseResult.Error()
	}

	responseResult = responseResult.StatusCode(&statusCode)
	if statusCode == http.StatusUnauthorized {
		return "", fmt.Errorf(http.StatusText(http.StatusUnauthorized))
	}

	responseBody, err := responseResult.Raw()
	if err != nil {
		return "", err
	}

	if statusCode < 200 || statusCode >= 300 {
		return "", fmt.Errorf(string(responseBody))
	}

	return string(responseBody), nil
}
