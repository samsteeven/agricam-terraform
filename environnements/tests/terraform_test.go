package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAgriCam(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformBinary: "terraform",
		TerraformDir: "../dev",
		Vars: map[string]interface{}{
			"environnement": "test",
			"type_instance": "t3.micro",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Vérifie que le VPC a été créé
	vpcId := terraform.Output(t, terraformOptions, "id_vpc")
	assert.NotEmpty(t, vpcId)
}
