variable "rg-name" {
    type = string
    description = "ResourceGroup name"
}

variable "vm-name" {
    type = string
    description = "Virtualmachine Name"
}

variable "vm-size" {
    type=string
    description  = "Virtualmachine Size"
}

variable "vm-type" {
    type=map
    default= {
        server="WindowsServer"
        client="MicrosoftWindowsDesktop"
    }
}


variable "skus"{
    type=map
    default={
        2019 = "2019-Datacenter"
        2022 = "2022-datacenter"
    }
}

variable "os-version" {
  type = string
  description = "choose between 2019 and 2022"
}

variable "Timeperiod" {
  type = number
  description = "Number of days"
}

variable "sizes" {
  type = map
  default = {
    Memory_8_GB = "Standard_D2ds_v4",
    Memory_16_GB_4CPUS = "Standard_D4s_v4"
  }
}

variable "locationCode" {
  type = string
  description = "Enter Quest Business region Code: AMER, EMEA, APJ"
}

variable "location" {
  type = map
  default = {
    AMER = "West US2"
    EMEA = "Germany West Central"
    APJ = "Southeast Asia"
  }
}

variable "shutdown_loction_code" {
  type = map
  default = {
    AMER = "Pacific Standard Time"
    EMEA = "Greenwich Standard Time"
    APJ = "India Standard Time"
  }
}

variable "access-ip" {
  type = string
  description = "Requester's IP address"
}