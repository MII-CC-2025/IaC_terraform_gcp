# Lab 2. Terraform con GCP

En esta guía vamos a crear infraestructura en GCP, en concreto, crearemos una IP pública y una máquina virtual, 
a la que le asociaremos esa IP y la clave SSH que tenemos en nuestra máquina.

## Credenciales de autentificación y autorización

Aunque se pueden incluir en la configuración del proveedor es más seguro utilizar 
variables de entorno. Existen varias opciones, en este caso usaremos la variable GOOGLE_CREDENTIALS.
Para más información consulta: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication

```
export GOOGLE_CREDENTIALS=<ruta>/cuenta_servicio.json
```

## Definiendo el proveedor

Para especificar el proveedor, en este caso GCP, creamos un fichero .tf, por ejemplo main.tf con el siguiente contenido:


```
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.23.0"
    }
  }
}

provider "google" {
  # Configuration options  

  project     = "cc-2024"
  region      = "us-central1"
  zone = "us-central1-a"
  
  #credentials = <path>/cuenta_servicio.json
  
}
```

## Data Sources y Outputs

Para practicar con el uso de data sources y outputs, creamos un fichero (data.tf) 
para obtener el data source "google_project" y mostrar varios parámetros del proyecto mediante outputs. 

```
# data.tf

data "google_project" "project" {}

output "project_id" {
  value = data.google_project.project.project_id
} 

output "project_name" {
  value = data.google_project.project.name
} 

output "project_number" {
  value = data.google_project.project.number
} 
```

## Variables

Vamos a crear tres variables, en el fichero vars.tf, con el nombre para la IP, para la máquina virtual y el tipo de máquina a crear:

```
variable "ip_name" {
    type = string
    default = "ip-server"
}

variable "vm_name" {
    type = string
    default = "server"
}

variable "vm_machine" {
    type = string
    default = "e2-micro"
}
```
Los valores por defecto para estas variables son los que aparecen indicados, pero se pueden cambiar utilizando el fichero
terraforms.tfvars o mediante variables de entorno TF_VAR_nombre, por ejemplo: 

```
$ export  TF_VAR_vm_name=WebServer
```


## Recursos

Como recursos, vamos a crear una IP estática, por ejemplo, en el fichero ip.tf

```
resource "google_compute_address" "static_ip" {
       name = var.ip_name
}


output "show_ip" {
    value = google_compute_address.static_ip.address
}
```

Y, también, por ejemplo en el fichero vm.tf, una máquina virtual con la última versión de Ubuntu 22.04, utilizando el data source "google_compute_image",
a la máquina virtual le asociaremos la IP anterior y la clave SSH que tenemos en nuestra máquina.

```
data "google_compute_image" "vm_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

output "server_image" {
  value = data.google_compute_image.vm_image.name
}



resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_machine
  boot_disk {
    initialize_params {
      image = data.google_compute_image.vm_image.name #"ubuntu-2204-jammy-v20240319" #"ubuntu-2204-jammy-v20240228"
    }
  }
  network_interface {
    network       = "default"
    access_config {
        nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    ssh-keys =  "usuario:${file("~/.ssh/id_rsa.pub")}" 
  }
}

```

## Iniciando Terraform

```
$ terraform init

...

```

## Formateando el código Terraform

```
$ terraform ftm

...

```

## Validando el código Terraform

```
$ terraform validate

...

```

## Planificando la infraestructura

```
$ terraform plan

...

```

## Aplicando la infraestructura

```
$ terraform apply --auto-approve

...

```

## Eliminando la infraestructura

```
$ terraform destroy --auto-approve

...

```

